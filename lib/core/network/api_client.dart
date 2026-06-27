import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'secure_client.dart';

/// Thrown when an API call fails (network error, non-2xx status, bad JSON).
///
/// [message] is safe to show to the user; [statusCode] is null for network
/// errors (no response at all).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// A thin wrapper around `package:http` for talking to the backend.
///
/// Responsibilities:
///   - prefix every path with [ApiConfig.baseUrl],
///   - send/receive JSON,
///   - attach the bearer [token] once we have one (after login),
///   - turn failures into a single [ApiException] type.
///
/// One instance is shared app-wide (created in main.dart).
class ApiClient {
  final http.Client _http;

  /// Bearer token saved after a successful login. Null = not logged in.
  String? token;

  /// Called once when the server rejects a request with 401 Unauthorized
  /// (expired/invalid token). main.dart uses it to clear the session and send
  /// the user back to the login screen instead of leaving them stuck.
  void Function()? onUnauthorized;

  /// While true, a 401 does NOT trigger [onUnauthorized] — used during the
  /// silent token-restore check on startup, where the splash handles routing.
  bool suppressAuthRedirect = false;

  /// Current app language (e.g. 'ar'). Appended as `?lang=` to every request so
  /// the backend returns localized text. Set from the LocaleController.
  String? lang;

  ApiClient({http.Client? httpClient})
      : _http = httpClient ?? buildHttpClient();

  Map<String, String> _headers({bool json = false}) {
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      // The backend localizes the response from this header (ar | ru | zh | en).
      if (lang != null && lang!.isNotEmpty) 'X-locale': lang!,
    };
  }

  /// POST [path] with a JSON [body]; returns the decoded JSON map.
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _send(() => _http.post(
          _uri(path),
          headers: _headers(json: true),
          body: jsonEncode(body),
        ));
  }

  /// PUT [path] with a JSON [body]; returns the decoded JSON map.
  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _send(() => _http.put(
          _uri(path),
          headers: _headers(json: true),
          body: jsonEncode(body),
        ));
  }

  /// PATCH [path] with a JSON [body]; returns the decoded JSON map.
  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _send(() => _http.patch(
          _uri(path),
          headers: _headers(json: true),
          body: jsonEncode(body),
        ));
  }

  /// GET [path]; returns the decoded JSON map.
  Future<Map<String, dynamic>> getJson(String path) async {
    return _send(() => _http.get(_uri(path), headers: _headers()));
  }

  /// DELETE [path]; returns the decoded JSON map.
  Future<Map<String, dynamic>> deleteJson(String path) async {
    return _send(() => _http.delete(_uri(path), headers: _headers()));
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  /// Runs [request] with a timeout, retrying ONCE on a transient connection
  /// drop.
  ///
  /// The backend keeps connections alive but sometimes closes an idle pooled
  /// one; reusing it then fails with "Connection closed before full header was
  /// received". That error is safe to retry — the second attempt opens a fresh
  /// connection. We only retry idempotent reads is NOT assumed here: a dropped
  /// connection means the server never received/answered the request, so a
  /// single retry is safe for any verb.
  Future<http.Response> _attempt(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 20));
    } on http.ClientException catch (e) {
      if (!_isConnectionClosed(e)) rethrow;
      return await request().timeout(const Duration(seconds: 20));
    }
  }

  bool _isConnectionClosed(http.ClientException e) =>
      e.message.contains('Connection closed before full header was received');

  /// Runs [request], validates the status, and decodes the JSON body.
  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    http.Response res;
    try {
      res = await _attempt(request);
    } catch (e) {
      // SocketException, TimeoutException, HandshakeException, etc. — no usable
      // response. Surface the real error during debugging so we can tell a DNS
      // failure from a TLS / connectivity problem.
      // ignore: avoid_print
      print('[ApiClient] request failed for ${ApiConfig.baseUrl}: $e');
      throw ApiException(
        'Cannot reach the server ($e). Check your connection and try again.',
      );
    }

    Map<String, dynamic> data = {};
    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {
        throw ApiException('Unexpected response from server.',
            statusCode: res.statusCode);
      }
    }

    if (res.statusCode == 401 && !suppressAuthRedirect) {
      // Session no longer valid — let the app drop it and go to login.
      onUnauthorized?.call();
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      // Prefer the server's message if it sent one.
      final msg = (data['message'] ?? data['error'])?.toString();
      throw ApiException(
        msg ?? 'Request failed (HTTP ${res.statusCode}).',
        statusCode: res.statusCode,
      );
    }

    return data;
  }
}
