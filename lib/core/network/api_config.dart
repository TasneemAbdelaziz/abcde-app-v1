/// Where the backend lives.
///
/// The app talks to the hosted Alamein backend (same `{{baseUrl}}` the Postman
/// collection uses). It's a public HTTPS host, so every platform — web,
/// Windows, Android emulator, a real phone — reaches it the same way. No
/// per-platform localhost juggling is needed.
class ApiConfig {
  ApiConfig._();

  /// Full base URL including the `/api/v1` prefix.
  static const String baseUrl = 'https://aiu.edu.eg/abcde/api/v1';
}
