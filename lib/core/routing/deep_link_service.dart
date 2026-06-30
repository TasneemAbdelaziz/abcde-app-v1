import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../features/rating/rating_screen.dart' show presentOverallRatingSheet;
import '../../main.dart' show rootNavigatorKey;
import '../widgets/global_alert_overlay.dart';
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
    Routes.alert,
    Routes.development,
    Routes.entertainment,
    Routes.medicines,
    Routes.journey,
    Routes.notifications,
  };

  // The route currently on top of the navigator. One watch tap can reach us
  // twice (a cold-start `getInitialRoute` plus a redelivered `onNewIntent`, or
  // a doubled relay), which used to push the same screen twice. We ignore a
  // deep link for a screen that's already on top. Kept correct by [observer]
  // (updated whenever the user navigates, e.g. presses back) and optimistically
  // here on push.
  static String? _currentRoute;

  /// Add this to `MaterialApp.navigatorObservers` so we always know which screen
  /// is on top — that's how we tell a duplicate deep link from a real re-open.
  static final NavigatorObserver observer = _RouteObserver();

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

  /// Opens [route] from outside the deep-link channel (e.g. an FCM push).
  /// Reuses the same allow-list, dedupe, and rating/alert handling.
  static void open(String? route) => _go(route);

  static void _go(String? route) {
    if (route == null || route.isEmpty) return;
    if (!_allowed.contains(route)) return;

    // Rating opens the overall-rating bottom sheet directly (matching the Home
    // tile) instead of pushing a page.
    if (route == Routes.rating) {
      final ctx = rootNavigatorKey.currentState?.overlay?.context;
      if (ctx != null) presentOverallRatingSheet(ctx);
      return;
    }

    // Alert opens the emergency confirmation overlay ("Alert Sent! A nurse will
    // arrive shortly") — same as the floating "Call your doctor" button.
    if (route == Routes.alert) {
      GlobalAlert.openEmergency();
      return;
    }

    // Already showing this screen — ignore a duplicate delivery.
    if (route == _currentRoute) return;

    // Optimistic so a second delivery arriving before the push settles is also
    // ignored; the observer corrects this on pop / other navigation.
    _currentRoute = route;
    rootNavigatorKey.currentState?.pushNamed(route);
  }
}

/// Tracks the top *screen* route name for [DeepLinkService]. Only real pages
/// ([PageRoute]) count — dialogs and bottom sheets (e.g. the rating sheet) are
/// ignored so they don't reset which screen we think is on top.
class _RouteObserver extends NavigatorObserver {
  void _set(Route? route) {
    if (route is PageRoute) DeepLinkService._currentRoute = route.settings.name;
  }

  @override
  void didPush(Route route, Route? previousRoute) => _set(route);

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _set(newRoute);

  @override
  void didPop(Route route, Route? previousRoute) => _set(previousRoute);
}
