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

  // The currently selected shell tab (0 = Home … 4 = Family). The shell calls
  // [updateTab] when it changes; kept here so the FAB can react to it later.
  static final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  /// Called by the shell whenever the active bottom-nav tab changes.
  static void updateTab(int index) => currentTab.value = index;

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
        // Draggable so the user can move it off content it covers.
        ValueListenableBuilder<String?>(
          valueListenable: _route,
          builder: (context, route, _) {
            if (route != null && _hiddenOn.contains(route)) {
              return const SizedBox.shrink();
            }
            return _DraggableFab(
              onTap: () => _emergencyOpen.value = true,
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

/// The "Call your doctor" FAB, draggable anywhere on screen so it can be moved
/// off content it covers. A short tap still opens the emergency overlay; a drag
/// repositions it. The chosen position is remembered for the session.
class _DraggableFab extends StatefulWidget {
  final VoidCallback onTap;
  const _DraggableFab({required this.onTap});

  /// Top-left position, kept static so it survives the widget being rebuilt
  /// (e.g. when the top route changes).
  static Offset? savedPosition;

  @override
  State<_DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<_DraggableFab> {
  Offset? _pos = _DraggableFab.savedPosition;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        // Approximate footprint of the FAB + its label.
        final fabW = 72.w;
        final fabH = 96.h;

        final minX = 4.w;
        final maxX = (size.width - fabW - 4.w).clamp(minX, double.infinity);
        final minY = MediaQuery.of(context).padding.top + 8.h;
        final maxY =
            (size.height - fabH - 8.h).clamp(minY, double.infinity);

        // Default: bottom-right, lifted above the bottom nav (like the proto).
        final defaultPos = Offset(maxX, (maxY - 70.h).clamp(minY, maxY));
        final pos = _clamp(_pos ?? defaultPos, minX, maxX, minY, maxY);

        return Stack(
          children: [
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _pos = _clamp(
                      (_pos ?? pos) + d.delta,
                      minX,
                      maxX,
                      minY,
                      maxY,
                    );
                    _DraggableFab.savedPosition = _pos;
                  });
                },
                child: AlertFab(onTap: widget.onTap),
              ),
            ),
          ],
        );
      },
    );
  }

  Offset _clamp(Offset p, double minX, double maxX, double minY, double maxY) {
    return Offset(
      p.dx.clamp(minX, maxX).toDouble(),
      p.dy.clamp(minY, maxY).toDouble(),
    );
  }
}
