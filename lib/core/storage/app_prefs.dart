import 'package:shared_preferences/shared_preferences.dart';

/// Tiny typed wrapper around [SharedPreferences] for small persistent flags.
///
/// Call [init] once in main() before runApp so the values are ready
/// synchronously everywhere else.
class AppPrefs {
  AppPrefs._();

  static late final SharedPreferences _prefs;

  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kAuthToken = 'auth_token';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Whether the user has finished the onboarding carousel at least once.
  static bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;

  static Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_kOnboardingSeen, value);

  /// The saved bearer token, or null if signed out.
  static String? get authToken => _prefs.getString(_kAuthToken);

  static Future<void> setAuthToken(String token) =>
      _prefs.setString(_kAuthToken, token);

  static Future<void> clearAuthToken() => _prefs.remove(_kAuthToken);
}
