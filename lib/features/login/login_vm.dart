import 'package:flutter/foundation.dart';

import '../../core/models/auth_user.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/auth_repository.dart';

/// Which login method the user is on.
enum LoginTab { idPassword, qr }

/// ViewModel for the Login screen.
///
/// Holds the form state (tab, loading, error) and talks to [AuthRepository].
/// The screen reads these fields and calls [submit] / [submitQr]; it never
/// touches the repository directly.
class LoginVm extends ChangeNotifier {
  final AuthRepository _auth;

  LoginVm(this._auth);

  LoginTab tab = LoginTab.idPassword;
  bool loading = false;

  /// User-facing error from the last attempt, or null.
  String? error;

  void switchTab(LoginTab next) {
    if (tab == next) return;
    tab = next;
    error = null;
    notifyListeners();
  }

  /// Logs in with national ID + password. Returns the session on success,
  /// or null on failure (with [error] set for the UI).
  Future<AuthSession?> submit(String identifier, String password) async {
    if (identifier.trim().isEmpty || password.isEmpty) {
      error = 'Please enter your National ID and password.';
      notifyListeners();
      return null;
    }
    return _run(() => _auth.login(identifier, password));
  }

  /// Logs in with a scanned QR token.
  Future<AuthSession?> submitQr(String qrToken) async {
    if (qrToken.trim().isEmpty) {
      error = 'No QR code detected. Try again.';
      notifyListeners();
      return null;
    }
    return _run(() => _auth.loginWithQr(qrToken));
  }

  /// Shared runner: toggles [loading], maps errors to [error].
  Future<AuthSession?> _run(Future<AuthSession> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final session = await action();
      return session;
    } on ApiException catch (e) {
      // 401/422 usually means wrong credentials.
      error = (e.statusCode == 401 || e.statusCode == 422)
          ? 'Wrong National ID or password.'
          : e.message;
      return null;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
