// [DATA] screen — reads NotificationsVm (GET /notifications).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/models/app_notification.dart';
import '../../core/notifications/notification_center.dart';
import '../../core/notifications/notification_text.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import 'notifications_vm.dart';

/// Notifications / alerts list.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationsVm>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsVm>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: BrandBar(title: context.watch<LocaleController>().t('title_notifications')),
      body: RefreshIndicator(
        onRefresh: () => context.read<NotificationsVm>().load(),
        child: _body(context, vm),
      ),
    );
  }

  Widget _body(BuildContext context, NotificationsVm vm) {
    final loc = context.watch<LocaleController>();

    if (vm.loading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.items.isEmpty) {
      return _Centered(
        icon: Icons.cloud_off,
        title: vm.error!,
        action: (loc.t('retry'), () => vm.load()),
      );
    }
    if (vm.items.isEmpty) {
      return _Centered(
        icon: Icons.notifications_none,
        title: loc.t('notif_empty_title'),
        subtitle: loc.t('notif_empty_sub'),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      children: [
        if (vm.unread > 0)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                await vm.markAllRead();
                if (context.mounted) {
                  context.read<NotificationCenter>().refresh();
                }
              },
              child:
                  Text(loc.t('notif_mark_all'), style: TextStyle(fontSize: 13.sp)),
            ),
          ),
        for (final n in vm.items)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _NotificationCard(
              n: n,
              title: notificationTitle(n, loc),
              onTap: () async {
                await vm.markRead(n);
                if (context.mounted) {
                  context.read<NotificationCenter>().refresh();
                }
              },
            ),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification n;
  final String title;
  final VoidCallback onTap;
  const _NotificationCard({
    required this.n,
    required this.title,
    required this.onTap,
  });

  // Icon + accent colour picked from the notification type (best-effort).
  (IconData, Color) get _style {
    final t = n.type.toLowerCase();
    if (t.contains('emergency') || t.contains('alert')) {
      return (Icons.warning_amber_rounded, AppColors.red);
    }
    if (t.contains('appoint')) return (Icons.event, AppColors.blue);
    if (t.contains('med') || t.contains('prescription')) {
      return (Icons.medication_outlined, AppColors.teal);
    }
    if (t.contains('result') || t.contains('lab')) {
      return (Icons.description_outlined, AppColors.green);
    }
    return (Icons.notifications_none, AppColors.blue);
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style;
    final unread = !n.read;

    return Material(
      color: unread ? AppColors.bgCard2 : AppColors.bgCard,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    if (n.body.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        n.body,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (n.createdAt != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        _relativeTime(n.createdAt!),
                        style:
                            TextStyle(fontSize: 11.sp, color: AppColors.textDim),
                      ),
                    ],
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: EdgeInsets.only(left: 8.w, top: 4.h),
                  width: 9.w,
                  height: 9.w,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(t);
  }
}

/// Centered empty / error state with an optional action button.
class _Centered extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final (String, VoidCallback)? action;

  const _Centered({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    // ListView so pull-to-refresh still works on empty/error states.
    return ListView(
      children: [
        SizedBox(height: 140.h),
        Icon(icon, size: 52.sp, color: AppColors.textDim),
        SizedBox(height: 14.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 6.h),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
        ],
        if (action != null) ...[
          SizedBox(height: 16.h),
          Center(
            child: OutlinedButton(
              onPressed: action!.$2,
              child: Text(action!.$1),
            ),
          ),
        ],
      ],
    );
  }
}
