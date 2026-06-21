// [DATA] screen — reads HomeVm (patient profile from the API + placeholders).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/vital.dart';
import '../../core/notifications/notification_center.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/rate_sheet.dart';
import 'home_vm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load once the screen is shown (we're authenticated by now). Post-frame so
    // we don't notifyListeners during the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeVm>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeVm>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: const BrandBar(),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeVm>().load(),
        child: _body(context, vm),
      ),
    );
  }

  Widget _body(BuildContext context, HomeVm vm) {
    if (vm.loading && vm.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.profile == null) {
      return _ErrorState(message: vm.error!, onRetry: () => vm.load());
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      children: [
        _GreetingCard(vm: vm),
        SizedBox(height: 22.h),
        _SectionTitle('VITAL READINGS'),
        SizedBox(height: 12.h),
        if (vm.hasVitals)
          _VitalsStrip(vitals: vm.vitals)
        else
          const _EmptyHint('No recent vital readings.'),
        SizedBox(height: 24.h),
        _SectionTitle('MY HEALTH'),
        SizedBox(height: 12.h),
        const _MyHealthGrid(),
      ],
    );
  }
}

// ===========================================================================
// Greeting / patient summary card (the blue gradient card).
// ===========================================================================
class _GreetingCard extends StatelessWidget {
  final HomeVm vm;
  const _GreetingCard({required this.vm});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _orDash(String? v) => (v == null || v.isEmpty) ? '—' : v;

  String _admitted(HomeVm vm) {
    final d = vm.visit?.arrivedAt;
    return d == null ? '—' : DateFormat('MMM d, yyyy').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final p = vm.profile;

    final name = (p?.name.isNotEmpty ?? false) ? p!.name : 'Patient';

    // "56 yrs · Female · Emergency Bay 2"
    final room = vm.visit?.locationName ?? '';
    final bits = <String>[
      if (p?.age != null) '${p!.age} yrs',
      if (p != null && p.genderLabel.isNotEmpty) p.genderLabel,
      if (room.isNotEmpty) room,
    ];
    final condition = (p != null && p.chronicConditions.isNotEmpty)
        ? p.chronicConditions
        : null;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue, AppColors.blueDeep],
        ),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Icon(Icons.person, color: Colors.white, size: 30.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting 👋',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      bits.join('  ·  '),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              _NotificationBell(
                unread: context.watch<NotificationCenter>().unread,
              ),
            ],
          ),
          if (condition != null) ...[
            SizedBox(height: 12.h),
            _ConditionPill(text: condition),
          ],
          SizedBox(height: 16.h),
          _CareJourneyCard(vm: vm),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _InfoChip(label: 'Admitted', value: _admitted(vm)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _InfoChip(
                  label: 'Doctor',
                  value: _orDash(vm.visit?.doctorName),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int unread;
  const _NotificationBell({required this.unread});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.notifications),
      child: SizedBox(
        width: 30.w,
        height: 30.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none, color: Colors.white, size: 26.sp),
            if (unread > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConditionPill extends StatelessWidget {
  final String text;
  const _ConditionPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CareJourneyCard extends StatelessWidget {
  final HomeVm vm;
  const _CareJourneyCard({required this.vm});

  String _journeyText(HomeVm vm) {
    final stage = vm.visit?.stage;
    if (stage == null) return 'Not in an active visit';
    if (stage.index == 0) return stage.title; // unknown stage key
    return 'Stage ${stage.index} of ${stage.total} · ${stage.title}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Care Journey',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _journeyText(vm),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, Routes.journey),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('View', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Section title.
// ===========================================================================
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.blueDeep,
        fontSize: 13.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Small muted note shown when a section has no data (e.g. no vitals yet).
class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
      ),
    );
  }
}

// ===========================================================================
// Vital readings horizontal strip.
// ===========================================================================
class _VitalsStrip extends StatelessWidget {
  final List<Vital> vitals;
  const _VitalsStrip({required this.vitals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vitals.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) => _VitalCard(vital: vitals[i]),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final Vital vital;
  const _VitalCard({required this.vital});

  (IconData, Color) get _style {
    switch (vital.label) {
      case 'Heart Rate':
        return (Icons.favorite, AppColors.red);
      case 'SpO₂':
        return (Icons.water_drop, AppColors.blue);
      case 'Blood Pressure':
        return (Icons.monitor_heart, AppColors.green);
      case 'Temperature':
        return (Icons.thermostat, AppColors.green);
      default:
        return (Icons.air, AppColors.teal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style;
    return Container(
      width: 120.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 18.sp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                vital.value,
                style: TextStyle(
                  color: color,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (vital.unit.isNotEmpty) ...[
                SizedBox(width: 3.w),
                Text(
                  vital.unit,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
          Text(
            vital.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// "My Health" feature grid.
// ===========================================================================
class _MyHealthGrid extends StatelessWidget {
  const _MyHealthGrid();

  @override
  Widget build(BuildContext context) {
    final tiles = <_FeatureTile>[
      _FeatureTile(
        icon: Icons.medical_services_outlined,
        color: AppColors.teal,
        label: 'Diagnosis',
        onTap: () => Navigator.pushNamed(context, Routes.diagnosis),
      ),
      _FeatureTile(
        icon: Icons.healing_outlined,
        color: AppColors.green,
        label: 'Treatment Plan',
        onTap: () => Navigator.pushNamed(context, Routes.treatment),
      ),
      _FeatureTile(
        icon: Icons.star_outline,
        color: AppColors.amber,
        label: 'Rating',
        onTap: () => Navigator.pushNamed(context, Routes.rating),
      ),
      _FeatureTile(
        icon: Icons.lightbulb_outline,
        color: AppColors.blue,
        label: 'Development',
        onTap: () => Navigator.pushNamed(context, Routes.development),
      ),
      _FeatureTile(
        icon: Icons.play_circle_outline,
        color: AppColors.blueDeep,
        label: 'Entertainment',
        onTap: () => Navigator.pushNamed(context, Routes.entertainment),
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 0.95,
      children: tiles,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
            boxShadow: AppTheme.shadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Error state.
// ===========================================================================
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Icon(Icons.cloud_off, size: 48.sp, color: AppColors.textDim),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}
