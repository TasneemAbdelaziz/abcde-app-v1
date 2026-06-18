// [DATA] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/models/visit.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/star_row.dart';
import 'care_journey_screen.dart';
import 'visits_vm.dart';

/// The patient's hospital visits. Only the active visit can be opened (it
/// shows the Care Journey timeline); completed visits show their rating.
class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitsVm>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: const BrandBar(title: 'My Visits'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              itemCount: vm.visits.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (_, i) => _VisitCard(visit: vm.visits[i]),
            ),
    );
  }
}

/// One visit card. Active cards are tappable and open the Care Journey.
class _VisitCard extends StatelessWidget {
  final Visit visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent strip — blue for active, transparent otherwise.
            Container(
              width: 4.w,
              color: visit.isActive ? AppColors.blue : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge + date.
                    Row(
                      children: [
                        _StatusBadge(active: visit.isActive),
                        const Spacer(),
                        Text(
                          visit.dateLabel,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Title.
                    Text(
                      visit.title,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Doctor row.
                    Row(
                      children: [
                        _Avatar(initials: visit.doctorInitials),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit.doctorName,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              visit.department,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Footer: progress link (active) or rating (completed).
                    SizedBox(height: 12.h),
                    if (visit.isActive)
                      Row(
                        children: [
                          Text(
                            'Stage ${visit.currentStage} of ${visit.totalStages} · ${visit.progressLabel}',
                            style: TextStyle(
                              color: AppColors.teal,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward,
                              color: AppColors.teal, size: 15.sp),
                        ],
                      )
                    else
                      Row(
                        children: [
                          StarRow(rating: visit.rating.floor(), size: 16),
                          SizedBox(width: 8.w),
                          Text(
                            '${visit.rating.toStringAsFixed(1)} / 5',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Only active visits open the Care Journey.
    if (!visit.isActive) return card;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CareJourneyScreen(visitId: visit.id),
        ),
      ),
      child: card,
    );
  }
}

/// Small "Active" / "Completed" pill.
class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: active ? AppColors.bluePale : AppColors.border,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        active ? 'Active' : 'Completed',
        style: TextStyle(
          color: active ? AppColors.blue : AppColors.textMuted,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Round doctor avatar showing initials. Colour is derived from the initials
/// so the same doctor always gets the same colour.
class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  static const List<Color> _palette = [
    AppColors.blue,
    AppColors.navy,
    AppColors.teal,
    AppColors.blueStrong,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[initials.hashCode.abs() % _palette.length];
    return Container(
      width: 44.r,
      height: 44.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}