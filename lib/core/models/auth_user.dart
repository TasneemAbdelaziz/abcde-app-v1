/// The signed-in user returned by `POST /auth/login` (inside `data.user`).
///
/// We keep only the fields the app needs right now. Add more as screens use
/// them. [fromJson] is defensive: missing fields become empty strings.
class AuthUser {
  final String id;
  final String name;
  final String role;
  final String locale; // the patient's preferred language, e.g. 'ar'
  final String serial; // patient_serial, e.g. 'ALM-20413'

  const AuthUser({
    required this.id,
    required this.name,
    required this.role,
    this.locale = '',
    this.serial = '',
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // /auth/me nests the patient profile under `patient`.
    final patient =
        json['patient'] is Map<String, dynamic> ? json['patient'] : const {};
    return AuthUser(
      id: (json['id'] ?? json['user_id'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      locale:
          (json['locale'] ?? patient['preferred_language'] ?? '').toString(),
      serial: (json['patient_serial'] ?? patient['patient_serial'] ?? '')
          .toString(),
    );
  }
}

/// Result of a successful login: a bearer token + the user it belongs to.
class AuthSession {
  final String token;
  final AuthUser user;

  const AuthSession({required this.token, required this.user});

  /// Parses the `data` object of an auth response: `{ token, user: {...} }`.
  factory AuthSession.fromData(Map<String, dynamic> data) {
    final userJson = data['user'];
    return AuthSession(
      token: (data['token'] ?? '').toString(),
      user: AuthUser.fromJson(
        userJson is Map<String, dynamic> ? userJson : const {},
      ),
    );
  }
}
