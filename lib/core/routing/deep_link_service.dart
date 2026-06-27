import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../features/rating/rating_screen.dart' show presentOverallRatingSheet;
import '../../main.dart' show rootNavigatorKey;
import 'routes.dart';

/// Receives deep links relayed from the paired watch (`abcde://open/<route>`)
/// and opens the matching screen, reusing this app's logged-in session.
class DeepLinkService {
  static const _channel = MethodChannel('com.example.abcde_app_v1_2/deeplink');

  /// Routes the watch is allowed to open. Must be registered in main.dart.
  static const _allowed = <String>{
    Routes.diagnosis,
    Routes.treatment,
    Routes.rating,
    Routes.development,
    Routes.entertainment,
    Routes.medicines,
    Routes.journey,
    Routes.notifications,
  };

  // Guards against the SAME deep link being handled twice for one watch tap.
  // On a cold start the route arrives via `getInitialRoute`; with the activity's
  // `singleTop` launch mode Android can ALSO redeliver the same VIEW intent
  // through `onNewIntent` → `navigate`, which would push the screen a second
  // time. We ignore an identical route that arrives within this window.
  static String? _lastRoute;
  static DateTime? _lastAt;
  static const _dedupeWindow = Duration(milliseconds: 1200);

  static void init() {
    // App already running: navigate immediately.
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'navigate') {
        _go(call.arguments as String?);
      }
    });

    // Cold start: ask the native side for the launch route once the first
    // frame (and the Navigator) is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final route = await _channel.invokeMethod<String>('getInitialRoute');
      _go(route);
    });
  }

  static void _go(String? route) {
    if (route == null || route.isEmpty) return;
    if (!_allowed.contains(route)) return;

    // Drop a duplicate delivery of the same route within the dedupe window so
    // the screen opens only once per watch tap.
    final now = DateTime.now();
    if (_lastRoute == route &&
        _lastAt != null &&
        now.difference(_lastAt!) < _dedupeWindow) {
      return;
    }
    _lastRoute = route;
    _lastAt = now;

    // Rating opens the overall-rating bottom sheet directly (matching the Home
    // tile) instead of pushing the full Rate-care page.
    if (route == Routes.rating) {
      final ctx = rootNavigatorKey.currentState?.overlay?.context;
      if (ctx != null) presentOverallRatingSheet(ctx);
      return;
    }

    rootNavigatorKey.currentState?.pushNamed(route);
  }
}
