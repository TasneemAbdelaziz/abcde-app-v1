import 'package:firebase_messaging/firebase_messaging.dart';

import '../network/api_client.dart';
import '../routing/deep_link_service.dart';

/// Receives the "open this screen" command relayed from the watch via FCM
/// (watch → POST /remote/open → server → FCM → here) and opens the screen.
///
/// The push is a DATA message carrying `{ "route": "/diagnosis" }`. We hand the
/// route to [DeepLinkService.open], so it goes through the same allow-list and
/// rating/alert handling as a direct deep link.
class PushService {
  PushService._();

  static bool _refreshWired = false;

  /// Sets up the message listeners. Call once after `Firebase.initializeApp()`.
  static Future<void> init() async {
    // Ask for notification permission (Android 13+ shows a prompt).
    await FirebaseMessaging.instance.requestPermission();

    // App in foreground.
    FirebaseMessaging.onMessage.listen(_handle);
    // App was in background and the user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_handle);
    // App was terminated and launched by tapping the notification.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handle(initial);
  }

  static void _handle(RemoteMessage message) {
    // ignore: avoid_print
    print('[Push] FCM received data=${message.data}');
    final route = message.data['route'];
    if (route is String && route.isNotEmpty) {
      DeepLinkService.open(route);
    }
  }

  /// Registers this device's FCM token with the backend so the server can push
  /// to it. Call once we're authenticated (e.g. from the Home screen). Safe to
  /// call repeatedly — the server upserts by token. Best-effort: never throws.
  static Future<void> registerToken(ApiClient api) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      // ignore: avoid_print
      print('[Push] fcm token = ${token == null ? "NULL" : "${token.substring(0, 12)}… (len ${token.length})"}');
      if (token != null) await _post(api, token);

      // Re-register whenever Firebase rotates the token.
      if (!_refreshWired) {
        _refreshWired = true;
        FirebaseMessaging.instance.onTokenRefresh
            .listen((t) => _post(api, t));
      }
    } catch (_) {
      // Push is a nice-to-have; ignore failures (no Google Play, offline, ...).
    }
  }

  static Future<void> _post(ApiClient api, String token) async {
    try {
      final res = await api.postJson('/me/devices', {
        'fcm_token': token,
        'platform': 'android',
      });
      // ignore: avoid_print
      print('[Push] /me/devices OK: $res');
    } catch (e) {
      // ignore: avoid_print
      print('[Push] /me/devices FAILED: $e');
    }
  }
}
