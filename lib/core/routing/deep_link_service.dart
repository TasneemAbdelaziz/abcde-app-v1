import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
    rootNavigatorKey.currentState?.pushNamed(route);
  }
}
