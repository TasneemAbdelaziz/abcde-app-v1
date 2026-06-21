import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../i18n/locale_controller.dart';
import '../theme/app_theme.dart';

/// The shared bottom navigation bar (Home Â· Visits Â· AI Advisor Â· Reports Â· Family).
///
/// It is index-based, not route-based: it lives once inside [MainShell] and
/// only reports which tab was tapped. The shell keeps the bar fixed and swaps
/// the page content (so the bar never rebuilds while navigating between tabs).
///
/// Style copied from the prototype: white bar, blue for the active tab.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // (icon, translation key) for the five tabs, in display order.
  static const List<({IconData icon, String key})> _tabs = [
    (icon: Icons.home_outlined, key: 'nav_home'),
    (icon: Icons.calendar_today_outlined, key: 'nav_visits'),
    (icon: Icons.chat_bubble_outline, key: 'nav_ai'),
    (icon: Icons.description_outlined, key: 'nav_reports'),
    (icon: Icons.people_outline, key: 'nav_family'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (int i = 0; i < _tabs.length; i++)
              Expanded(
                child: _NavTab(
                  icon: _tabs[i].icon,
                  label: loc.t(_tabs[i].key),
                  active: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.blue : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
