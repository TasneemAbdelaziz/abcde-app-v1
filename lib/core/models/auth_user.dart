/// The signed-in user returned by `POST /auth/login` (inside `data.user`).
///
/// We keep only the fields the app needs right now. Add more as screens use
/// them. [fromJson] is defensive: missing fields become empty strings.
class AuthUser {
  final String id;
  final String name;
  final String role;

  const AuthUser({required this.id, required this.name, required this.role});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['user_id'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
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
