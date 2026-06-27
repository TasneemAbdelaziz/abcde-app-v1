import '../models/auth_user.dart';
import '../network/api_client.dart';
import '../storage/app_prefs.dart';

/// Handles authentication against the backend:
///   - `POST /auth/login`      (national ID / email + password)
///   - `POST /auth/login/qr`   (patient QR wristband)
///   - `POST /auth/logout`
///   - `GET  /auth/me`
///
/// On success it stores the bearer token on the shared [ApiClient] (so every
/// later request is authenticated) AND in [AppPrefs] (so the user stays logged
/// in after restarting the app — see [tryRestore]).
class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  /// The logged-in session, or null if signed out.
  AuthSession? currentSession;

  bool get isLoggedIn => currentSession != null;

  /// On app start: if a token was saved, re-authenticate with it and verify it
  /// still works via `GET /auth/me`. Returns true if the session was restored.
  Future<bool> tryRestore() async {
    final token = AppPrefs.authToken;
    if (token == null || token.isEmpty) return false;

    _api.token = token;
    _api.suppressAuthRedirect = true; // splash handles routing on failure
    try {
      final res = await _api.getJson('/auth/me');
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        currentSession =
            AuthSession(token: token, user: AuthUser.fromJson(data));
      }
      // Request succeeded → the token is valid; stay logged in.
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // The server actually rejected the token (expired / invalid) — only
        // THEN do we drop it and require a fresh login.
        _api.token = null;
        currentSession = null;
        await AppPrefs.clearAuthToken();
        return false;
      }
      // Any other failure (network down, timeout, TLS, 5xx) is transient. Keep
      // the saved token and stay logged in — the app loads once the network
      // recovers, and a genuine 401 later still bounces to login.
      return true;
    } catch (_) {
      // Non-API error (socket/timeout) — also transient; keep the token.
      return true;
    } finally {
      _api.suppressAuthRedirect = false;
    }
  }

  /// Logs in with an identifier (national ID or email) and password.
  Future<AuthSession> login(String identifier, String password) {
    return _doLogin('/auth/login', {
      'identifier': identifier.trim(),
      'password': password,
    });
  }

  /// Logs in by scanning the patient QR wristband token.
  Future<AuthSession> loginWithQr(String qrToken) {
    return _doLogin('/auth/login/qr', {'qr_token': qrToken.trim()});
  }

  /// Clears the session locally (and tells the server, best-effort).
  Future<void> logout() async {
    try {
      await _api.postJson('/auth/logout', const {});
    } catch (_) {
      // Even if the server call fails, drop the local session.
    }
    currentSession = null;
    _api.token = null;
    await AppPrefs.clearAuthToken();
  }

  Future<AuthSession> _doLogin(String path, Map<String, dynamic> body) async {
    final res = await _api.postJson(path, body);

    // The API wraps the payload in `data`: { data: { token, user } }.
    final data = res['data'];
    if (data is! Map<String, dynamic> || data['token'] == null) {
      throw ApiException('Login failed: unexpected response.');
    }

    final session = AuthSession.fromData(data);
    currentSession = session;
    _api.token = session.token; // authenticate all later requests
    await AppPrefs.setAuthToken(session.token); // stay logged in after restart
    return session;
  }
}
