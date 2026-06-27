// [DATA] screen — owner: Beginner 2. Opened from an active visit.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/models/visit.dart';
import '../../core/models/visit_stage.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/rate_sheet.dart';
import '../../core/widgets/star_row.dart';
import 'visits_vm.dart';

/// The stage-by-stage timeline of an active visit. The patient can rate any
/// stage that's already completed.
class CareJourneyScreen extends StatelessWidget {
  final String visitId;
  const CareJourneyScreen({super.key, required this.visitId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitsVm>();
    final visit = vm.visitById(visitId);
    final journey = visit?.journey;

    final title = context.watch<LocaleController>().t('title_care_journey');
    if (journey == null) {
      return Scaffold(
        appBar: BrandBar(title: title),
        body: Center(
          child: Text(context.watch<LocaleController>().t('visit_not_found')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: BrandBar(title: title),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          _JourneyHeader(journey: journey),
          SizedBox(height: 18.h),
          for (int i = 0; i < journey.stages.length; i++)
            _StageRow(
              number: i + 1,
              stage: journey.stages[i],
              isLast: i == journey.stages.length - 1,
              onRate: () async {
                final rating = await RateSheet.show(
                  context,
                  stageTitle: journey.stages[i].title,
                );
                if (rating != null) {
                  vm.rateStage(visitId, journey.stages[i].id, rating);
                }
              },
            ),
          SizedBox(height: 8.h),
          Text(
            'Each completed stage opens a service rating. Your ratings feed '
            'the hospital\'s quality reports.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// The blue gradient header with visit code, patient name, and condition.
class _JourneyHeader extends StatelessWidget {
  final VisitJourney journey;
  const _JourneyHeader({required this.journey});

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
            'Visit #${journey.visitCode} · ${journey.pathway}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            journey.patientName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${journey.condition} · ${journey.admitted}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// One stage in the timeline: a status dot + connector line on the left, and
/// the stage title / detail / rating control on the right.
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
        : '${stage.time} · ${stage.detail}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline gutter: dot + vertical connector.
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
                    child: Container(
                      width: 2.w,
                      color: AppColors.border2,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Stage content.
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
    // Completed + already rated → show the stars.
    if (_isDone && stage.rating > 0) {
      return StarRow(rating: stage.rating, size: 15);
    }
    // Completed + not rated → offer the rating button.
    if (_isDone) {
      return GestureDetector(
        onTap: onRate,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border2),
            borderRadius: BorderRadius.circular(8.r),
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
    // Current stage → "Happening now".
    if (_isCurrent) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.bluePale,
          borderRadius: BorderRadius.circular(8.r),
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
    // Upcoming.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8.r),
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