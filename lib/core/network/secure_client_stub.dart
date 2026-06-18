import 'package:http/http.dart' as http;

/// Web (and any platform without `dart:io`): the browser/runtime handles TLS,
/// so the default client is fine.
http.Client createHttpClient() => http.Client();
