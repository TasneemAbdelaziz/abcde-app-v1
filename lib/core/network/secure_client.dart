import 'package:http/http.dart' as http;

// Picks the right implementation per platform:
//   - dart:io available (Android / iOS / Windows / macOS / Linux) -> _io
//   - otherwise (web)                                             -> _stub
import 'secure_client_stub.dart'
    if (dart.library.io) 'secure_client_io.dart';

/// Builds the shared [http.Client] the app uses for every request.
///
/// On mobile/desktop this returns a client that trusts our backend host even
/// when its TLS chain is missing the intermediate CA (a server misconfig — see
/// [createHttpClient] in secure_client_io.dart). On web the browser does TLS
/// itself, so we just return the default client.
http.Client buildHttpClient() => createHttpClient();
