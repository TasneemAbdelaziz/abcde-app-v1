import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../routing/routes.dart';
import 'alert_fab.dart';

/// Wires the global [AlertFab] into the whole app.
///
/// HOW IT WORKS
///   - [observer] is added to `MaterialApp.navigatorObservers` so we always
///     know which route is on top.
///   - [wrap] is plugged into `MaterialApp.builder`; it Stacks the app content,
///     the floating "Call your doctor" button, and (when tapped) the
///     [EmergencyOverlay] on top of everything.
///
/// The FAB is hidden on the onboarding and login routes â exactly like
/// `updateFab()` in the HTML prototype.
class GlobalAlert {
  GlobalAlert._();

  // The route currently on top of the Navigator (starts at the initial route).
  static final ValueNotifier<String?> _route =
      ValueNotifier<String?>(Routes.home);

  // Whether the emergency confirmation overlay is showing.
  static final ValueNotifier<bool> _emergencyOpen = ValueNotifier<bool>(false);

  /// Routes where the FAB must NOT appear.
  static const Set<String> _hiddenOn = {
    Routes.splash,
    Routes.onboarding,
    Routes.login,
  };

  /// Add this to `MaterialApp.navigatorObservers`.
  static final NavigatorObserver observer = _RouteTracker(_route);

  /// Add this as `MaterialApp.builder`.
  static Widget wrap(BuildContext context, Widget? child) {
    return Stack(
      children: [
        // The actual app (navigator + all screens).
        if (child != null) child,

        // The floating button â shown unless we're on login / onboarding.
        ValueListenableBuilder<String?>(
          valueListenable: _route,
          builder: (context, route, _) {
            if (route != null && _hiddenOn.contains(route)) {
              return const SizedBox.shrink();
            }
            return Positioned(
              right: 16.w,
              bottom: 84.h, // sits above the bottom nav, like the prototype
              child: SafeArea(
                child: AlertFab(onTap: () => _emergencyOpen.value = true),
              ),
            );
          },
        ),

        // The emergency confirmation, layered above the FAB when open.
        ValueListenableBuilder<bool>(
          valueListenable: _emergencyOpen,
          builder: (context, open, _) {
            if (!open) return const SizedBox.shrink();
            return EmergencyOverlay(
              onDismiss: () => _emergencyOpen.value = false,
            );
          },
        ),
      ],
    );
  }
}

/// Keeps [_route] in sync with whatever *screen* is currently on top.
///
/// Only real screens ([PageRoute]) count. Popups like dialogs and bottom sheets
/// (the language picker, logout confirm) push nameless [PopupRoute]s — if we
/// tracked those we'd wrongly think we left login and pop the FAB back up.
class _RouteTracker extends NavigatorObserver {
  final ValueNotifier<String?> _route;

  _RouteTracker(this._route);

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) _route.value = route.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute is PageRoute) _route.value = newRoute.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // Only react when a real screen is popped; ignore closing a popup/sheet.
    if (route is PageRoute) _route.value = previousRoute?.settings.name;
  }
}
