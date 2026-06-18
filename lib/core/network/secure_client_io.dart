import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Hosts whose TLS certificate we accept even if the chain doesn't fully
/// verify. This is a DEV workaround for `aiu.edu.eg` serving an incomplete
/// certificate chain (missing intermediate CA) — Dart verifies strictly and
/// rejects it, while browsers/Postman auto-complete the chain.
///
/// The real fix is server-side: install the full chain (leaf + intermediate).
/// Keep this list as small as possible and remove it once the server is fixed.
const Set<String> _allowedHosts = {'aiu.edu.eg'};

/// Mobile/desktop client. Only the hosts in [_allowedHosts] bypass the chain
/// check; every other host is still verified normally.
http.Client createHttpClient() {
  final inner = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) =>
            _allowedHosts.contains(host);
  return IOClient(inner);
}
