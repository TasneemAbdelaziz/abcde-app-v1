// [DATA] screen — owner: Lead. Also demonstrates the RateSheet.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/models/visit_stage.dart';
import '../../core/models/patient_profile.dart';
import '../home/home_vm.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/load_message.dart';
import '../../core/widgets/rate_sheet.dart';
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
      appBar: BrandBar(title: context.watch<LocaleController>().t('title_journey')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
          ? LoadMessage(
              icon: Icons.cloud_off,
              text: vm.error!,
              onRetry: () => context.read<JourneyVm>().load(),
            )
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
                    onRate: () async {
                      final rating = await RateSheet.show(
                        context,
                        stageTitle: vm.stages[i].title,
                      );
                      if (rating != null) {
                        vm.rateStage(vm.stages[i].id, rating);
                      }
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
  final VoidCallback onRate;

  const _StageRow({
    required this.number,
    required this.stage,
    required this.isLast,
    required this.onRate,
  });

  bool get _isDone => stage.status == 'done';
  bool get _isCurrent => stage.status == 'current';

  Color get _dotColor {
    if (_isDone) return AppColors.teal;
    if (_isCurrent) return AppColors.blue;
    return AppColors.border2;
  }

  @override
  Widget build(BuildContext context) {
    final detailLine = stage.time.isEmpty
        ? stage.detail
        : stage.detail.isEmpty
        ? stage.time
        : '${stage.time} · ${stage.detail}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22.w,
            child: Column(
              children: [
                SizedBox(height: 4.h),
                Container(
                  width: 13.r,
                  height: 13.r,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2.w, color: AppColors.border2),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$number. ${stage.title}',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (detailLine.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      detailLine,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  _control(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _control() {
    if (_isDone && stage.rating > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StarRow(rating: stage.rating, size: 15, onTap: (_) => onRate()),
          SizedBox(height: 6.h),
          Text(
            'Tap to edit rating',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
        ],
      );
    }

    if (_isDone) {
      return GestureDetector(
        onTap: onRate,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'Rate this stage',
            style: TextStyle(
              color: AppColors.blue,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (_isCurrent) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.bluePale,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              'Happening now',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        'Upcoming',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
