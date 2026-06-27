// [DATA] screen — owner: Lead.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/models/diagnosis.dart';
import '../../core/models/treatment.dart';
import '../../core/routing/routes.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/load_message.dart';
import '../diagnosis/diagnosis_video_screen.dart';
import '../home/home_vm.dart';
import 'treatment_vm.dart';

/// The patient's treatment plan: recovery progress, explainer videos, today's
/// medicine timeline, daily goals, and upcoming appointments.
class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreatmentVm>();
    final loc = context.watch<LocaleController>();
    final p = vm.plan;

    // The attending doctor comes from the real backend visit (same as the rest
    // of the app), falling back to the plan's value if the visit isn't loaded.
    final visit = context.watch<HomeVm>().visit;
    final doctorName = (visit?.doctorName ?? '').isNotEmpty
        ? visit!.doctorName
        : (p?.doctorName ?? '');
    final doctorMeta = (visit?.departmentName ?? '').isNotEmpty
        ? visit!.departmentName
        : (p?.doctorMeta ?? '');

    // Only show the quick-stats row when the backend actually has a value.
    final hasStats = p != null &&
        (p.nextDose.isNotEmpty ||
            p.toDischarge.isNotEmpty ||
            p.adherencePercent > 0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: BrandBar(title: loc.t('title_treatment')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : (vm.error != null || p == null)
              ? LoadMessage(
                  icon: Icons.cloud_off,
                  text: vm.error ?? 'Could not load the treatment plan.',
                  onRetry: () => context.read<TreatmentVm>().load(),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
                  children: [
                    _DoctorHeader(name: doctorName, meta: doctorMeta),
                    SizedBox(height: 16.h),

                    _RecoveryCard(plan: p),
                    SizedBox(height: 14.h),

                    if (hasStats) ...[
                      _StatsRow(plan: p),
                      SizedBox(height: 18.h),
                    ],

                    _Label(loc.t('tx_surgery')),
                    SizedBox(height: 10.h),
                    _VideoCard(video: p.surgeryVideo),
                    SizedBox(height: 18.h),

                    _Label(loc.t('tx_after')),
                    SizedBox(height: 10.h),
                    _VideoCard(video: p.afterSurgeryVideo),
                    SizedBox(height: 16.h),

                    const _MyMedicinesButton(),
                    SizedBox(height: 18.h),

                    if (p.timeline.isNotEmpty) ...[
                      _Label(loc.t('tx_timeline')),
                      SizedBox(height: 12.h),
                      for (int i = 0; i < p.timeline.length; i++)
                        _DoseRow(
                          dose: p.timeline[i],
                          isLast: i == p.timeline.length - 1,
                        ),
                      SizedBox(height: 18.h),
                    ],

                    if (p.goals.isNotEmpty) ...[
                      _Label(loc.t('tx_goals')),
                      SizedBox(height: 10.h),
                      for (final g in p.goals) ...[
                        _GoalCard(goal: g),
                        SizedBox(height: 10.h),
                      ],
                      SizedBox(height: 8.h),
                    ],

                    if (p.upcoming.isNotEmpty) ...[
                      _Label(loc.t('tx_upcoming')),
                      SizedBox(height: 10.h),
                      for (final u in p.upcoming) ...[
                        _UpcomingCard(item: u),
                        SizedBox(height: 10.h),
                      ],
                    ],
                  ],
                ),
    );
  }
}

// --- Header -----------------------------------------------------------------

class _DoctorHeader extends StatelessWidget {
  final String name;
  final String meta;
  const _DoctorHeader({required this.name, required this.meta});

  /// Initials from the doctor's name (e.g. 'Dr. Karim Adel' → 'KA').
  String get _initials {
    final words = name
        .replaceAll('Dr.', '')
        .replaceAll('د.', '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '—';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return (words[0].characters.first + words[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 14.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
            child: Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                meta,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Recovery ---------------------------------------------------------------

class _RecoveryCard extends StatelessWidget {
  final TreatmentPlan plan;
  const _RecoveryCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.t('tx_recovery'),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${plan.recoveryPercent}% ',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: loc.t('tx_completed'),
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${plan.tasksCompleted} ${loc.t('of')} ${plan.tasksTotal} ${loc.t('tx_tasks_completed')}',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              _RecoveryRing(percent: plan.recoveryPercent),
            ],
          ),
          SizedBox(height: 14.h),
          _ProgressBar(percent: plan.recoveryPercent),
          SizedBox(height: 10.h),
          Row(
            children: [
              _legendDot(AppColors.blue),
              SizedBox(width: 6.w),
              Text(loc.t('tx_completed'),
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
              SizedBox(width: 16.w),
              _legendDot(AppColors.bluePale2),
              SizedBox(width: 6.w),
              Text(loc.t('tx_remaining'),
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c) => Container(
        width: 8.r,
        height: 8.r,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _RecoveryRing extends StatelessWidget {
  final int percent;
  const _RecoveryRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.r,
      height: 64.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64.r,
            height: 64.r,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 7,
              backgroundColor: AppColors.bluePale,
              valueColor: const AlwaysStoppedAnimation(AppColors.blue),
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int percent;
  const _ProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: AppColors.bluePale)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent / 100,
              heightFactor: 1,
              child: Container(color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Stat chips -------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final TreatmentPlan plan;
  const _StatsRow({required this.plan});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.schedule,
            iconColor: AppColors.green,
            value: plan.nextDose,
            label: loc.t('tx_next_dose'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatChip(
            icon: Icons.home_outlined,
            iconColor: AppColors.blue,
            value: plan.toDischarge,
            label: loc.t('tx_to_discharge'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatChip(
            icon: Icons.trending_up,
            iconColor: AppColors.amber,
            value: '${plan.adherencePercent}%',
            label: loc.t('tx_adherence'),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}

// --- Section label ----------------------------------------------------------

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.blue,
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

// --- Video card (reuses the diagnosis video model + player) -----------------

class _VideoCard extends StatelessWidget {
  final DiagnosisVideo video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return GestureDetector(
      onTap: () {
        if (video.available) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DiagnosisVideoScreen(video: video),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.t('video_unavailable'))),
          );
        }
      },
      child: Opacity(
        opacity: video.available ? 1.0 : 0.6,
        child: Container(
          height: 150.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blueStrong, AppColors.blueDeep],
            ),
            boxShadow: AppTheme.shadow,
          ),
          child: Stack(
            children: [
              Center(
                child: video.available
                    ? _playCircle()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 28.sp),
                          SizedBox(height: 6.h),
                          Text(loc.t('coming_soon'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 38.h,
                child: Column(
                  children: [
                    Text(
                      '${loc.t('watch')}: ${video.title}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      video.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  color: Colors.black.withValues(alpha: 0.18),
                  child: Row(
                    children: [
                      Icon(Icons.smart_display_outlined,
                          size: 14.sp, color: Colors.white),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          video.badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        video.duration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playCircle() => Container(
        width: 50.r,
        height: 50.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.18),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
        ),
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28.sp),
      );
}

// --- My Medicines button ----------------------------------------------------

class _MyMedicinesButton extends StatelessWidget {
  const _MyMedicinesButton();

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(Routes.medicines),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.blue, AppColors.blueStrong],
          ),
          boxShadow: AppTheme.shadow,
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.medical_services,
                  color: Colors.white, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.t('my_medicines'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      )),
                  SizedBox(height: 2.h),
                  Text(loc.t('tx_view_all_meds'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.sp,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

// --- Medicine timeline ------------------------------------------------------

class _DoseRow extends StatelessWidget {
  final MedicineDose dose;
  final bool isLast;
  const _DoseRow({required this.dose, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final accent = _accent(dose.status);
    final loc = context.watch<LocaleController>();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline gutter: status icon + connector.
          SizedBox(
            width: 30.w,
            child: Column(
              children: [
                Container(
                  width: 26.r,
                  height: 26.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: _statusGlyph(dose.status, accent),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2.w, color: AppColors.border2),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Content card.
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: dose.status == DoseStatus.dueNow
                      ? AppColors.bluePale
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: dose.status == DoseStatus.dueNow
                        ? AppColors.blue
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dose.time} · ${dose.period}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dose.name,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      dose.note,
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12.sp),
                    ),
                    SizedBox(height: 8.h),
                    _statusPill(loc, dose.status, accent),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(LocaleController loc, DoseStatus status, Color accent) {
    final label = switch (status) {
      DoseStatus.taken => loc.t('dose_taken'),
      DoseStatus.dueNow => loc.t('dose_due'),
      DoseStatus.upcoming => loc.t('dose_upcoming'),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _accent(DoseStatus s) => switch (s) {
        DoseStatus.taken => AppColors.green,
        DoseStatus.dueNow => AppColors.blue,
        DoseStatus.upcoming => AppColors.amber,
      };

  IconData _icon(DoseStatus s) => switch (s) {
        DoseStatus.taken => Icons.check,
        DoseStatus.dueNow => Icons.medication,
        DoseStatus.upcoming => Icons.nightlight_round,
      };

  /// The dot glyph: a drawn pill capsule for "Due now", a Material icon
  /// otherwise (Material has no built-in capsule shape).
  Widget _statusGlyph(DoseStatus s, Color color) {
    if (s == DoseStatus.dueNow) return _PillIcon(color: color, size: 16);
    return Icon(_icon(s), color: color, size: 15.sp);
  }
}

/// A small pill/capsule drawn as a tilted two-tone rounded bar.
class _PillIcon extends StatelessWidget {
  final Color color;
  final double size; // design px
  const _PillIcon({required this.color, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final w = size.sp;
    final h = w * 0.5;
    return Transform.rotate(
      angle: -0.7853981633974483, // -45°
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h),
          border: Border.all(color: color, width: 1.6),
        ),
        child: Row(
          children: [
            // Filled half + hollow half, so it reads as a capsule.
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(h),
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

// --- Goals ------------------------------------------------------------------

class _GoalCard extends StatelessWidget {
  final TreatmentGoal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final done = goal.status == GoalStatus.done;
    final accent = done ? AppColors.green : AppColors.amber;
    final loc = context.watch<LocaleController>();

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? Icons.check : Icons.directions_walk,
              color: accent,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    )),
                Text(goal.subtitle,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12.sp)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              loc.t(done ? 'goal_done' : 'goal_pending'),
              style: TextStyle(
                color: accent,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Upcoming ---------------------------------------------------------------

class _UpcomingCard extends StatelessWidget {
  final UpcomingItem item;
  const _UpcomingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_outlined,
                color: AppColors.blue, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    )),
                Text(item.subtitle,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}