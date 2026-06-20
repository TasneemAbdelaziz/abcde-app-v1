// [DATA] screen — owner: Lead. Also demonstrates the RateSheet.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/models/visit_stage.dart';
import '../../core/models/patient_profile.dart';
import '../home/home_vm.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/star_row.dart';
import 'journey_vm.dart';

/// Treatment journey: a timeline of stages the patient can rate.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JourneyVm>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JourneyVm>();
    final home = context.watch<HomeVm>();
    final profile = home.profile;
    final visit = home.visit;
    final journeySummary = visit?.stage.title ?? '';
    final arrivalAt = visit?.arrivedAt;

    return Scaffold(
      appBar: const BrandBar(title: 'Journey'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                _JourneyHeader(
                  profile: profile,
                  journeySummary: journeySummary,
                  arrivalAt: arrivalAt,
                ),
                SizedBox(height: 24.h),
                for (int i = 0; i < vm.stages.length; i++)
                  _StageRow(
                    number: i + 1,
                    stage: vm.stages[i],
                    isLast: i == vm.stages.length - 1,
                    onRate: (rating) {
                      vm.rateStage(vm.stages[i].id, rating);
                    },
                  ),
                SizedBox(height: 8.h),
                Text(
                  'Each completed stage opens a service rating. Your ratings feed the hospital\'s quality reports.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/// The blue gradient header with patient info from the backend.

class _JourneyHeader extends StatelessWidget {
  final PatientProfile? profile;
  final String journeySummary;
  final DateTime? arrivalAt;

  const _JourneyHeader({
    required this.profile,
    required this.journeySummary,
    this.arrivalAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueStrong, AppColors.blueDeep],
        ),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile != null && profile!.serial.isNotEmpty
                ? 'Visit #${profile!.serial} · Cardiac pathway'
                : 'Visit · Care Journey',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            profile?.name ?? 'Patient',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            journeySummary.isNotEmpty ? journeySummary : '—',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.sp,
            ),
          ),
          if (arrivalAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Admitted ${_formatArrival(arrivalAt!)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatArrival(DateTime arrivalAt) {
    final local = arrivalAt.toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[local.weekday - 1];
    final month = months[local.month - 1];
    final day = local.day.toString().padLeft(2, '0');
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    return '$weekday, $day $month · $time';
  }
}

/// A stage row in the journey timeline.
class _StageRow extends StatelessWidget {
  final int number;
  final VisitStage stage;
  final bool isLast;
  final ValueChanged<int> onRate;

  const _StageRow({
    required this.number,
    required this.stage,
    required this.isLast,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = stage.status == 'done';
    final isCurrent = stage.status == 'current';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline number + small circle
            SizedBox(
              width: 44.w,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.teal
                              : isCurrent
                              ? AppColors.blue
                              : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      width: 2.w,
                      height: 52.h,
                      color: AppColors.border,
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Stage content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$number. ${stage.title}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (stage.detail.isNotEmpty || stage.time.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        '${stage.detail.isNotEmpty ? stage.detail : ''}${stage.detail.isNotEmpty && stage.time.isNotEmpty ? ' · ' : ''}${stage.time}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (isCurrent || stage.status == 'upcoming')
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.bluePale
                              : AppColors.bgSoft,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          isCurrent ? 'Happening now' : 'Upcoming',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isCurrent
                                ? AppColors.blue
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (isDone)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: StarRow(
                        rating: stage.rating,
                        size: 16,
                        onTap: onRate,
                      ),
                    ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
