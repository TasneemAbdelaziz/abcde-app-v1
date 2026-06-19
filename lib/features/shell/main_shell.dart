import 'package:flutter/material.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/global_alert_overlay.dart';
import '../ai_advisor/ai_advisor_screen.dart';
import '../family/family_screen.dart';
import '../home/home_screen.dart';
import '../reports/reports_screen.dart';
import '../visits/visits_screen.dart';

/// The app's main shell: a fixed bottom navigation bar + a body that swaps
/// between the five tab pages.
///
/// Why a shell? So the bottom bar stays FIXED while navigating between tabs â
/// only the page content changes. An IndexedStack also keeps each tab's state
/// (scroll position, etc.) when you switch away and back.
///
/// Each tab page is its own Scaffold with the BrandBar at top, so the top
/// logo bar is fixed on every page too.
class MainShell extends StatefulWidget {
  /// Which tab to open first (0 = Home, 1 = Visits, ... 4 = Family).
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    GlobalAlert.updateTab(_index);
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex;
      GlobalAlert.updateTab(_index);
    }
  }

  // The five tab pages, in the same order as the bottom-nav tabs.
  static const List<Widget> _pages = [
    HomeScreen(),
    VisitsScreen(),
    AiAdvisorScreen(),
    ReportsScreen(),
    FamilyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          GlobalAlert.updateTab(i);
        },
      ),
    );
  }
}
