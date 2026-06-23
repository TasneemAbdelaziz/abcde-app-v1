import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/repositories/patient_api_repository.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import '../../core/widgets/star_row.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedTab = 0;
  int _stars = 0; // 0 = not rated yet
  String _comment = '';

  @override
  void initState() {
    super.initState();
    // Load any existing overall rating so we can re-display it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  Future<void> _loadExisting() async {
    try {
      final existing =
          await context.read<PatientApiRepository>().getOverallRating();
      if (existing == null || !mounted) return;
      setState(() {
        _stars = existing.stars;
        _comment = existing.comment;
      });
    } catch (_) {
      // No rating yet / offline — leave the empty state.
    }
  }

  /// Opens the overall-rating bottom sheet (5 stars + optional comment) and
  /// saves the result to `POST /ratings/overall`.
  Future<void> _openOverallSheet() async {
    final result = await OverallRateSheet.show(
      context,
      initialStars: _stars,
      initialComment: _comment,
    );
    if (result == null || !mounted) return;

    // Optimistic UI; roll back the previous values if the save fails.
    final prevStars = _stars;
    final prevComment = _comment;
    setState(() {
      _stars = result.stars;
      _comment = result.comment;
    });

    try {
      await context.read<PatientApiRepository>().submitOverallRating(
            stars: result.stars,
            comment: result.comment,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<LocaleController>().t('rate_thanks'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stars = prevStars;
        _comment = prevComment;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your rating. $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandBar(title: context.watch<LocaleController>().t('rate_care_title')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            SizedBox(height: 20.h),
            Expanded(
              child: _selectedTab == 0
                  ? _buildOverallRating()
                  : _buildStagesRating(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        _buildTab(context.read<LocaleController>().t('rate_tab_overall'), 0),
        _buildTab(context.read<LocaleController>().t('rate_tab_stages'), 1),
      ]),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _selectedTab == index;
    final icon = index == 0 ? Icons.star_rounded : Icons.timeline_rounded;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 1) {
            Navigator.pushNamed(context, Routes.journey);
            return;
          }
          setState(() => _selectedTab = index);
        },
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.blue : AppColors.bgCard,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallRating() {
    final rated = _stars > 0;
    final loc = context.watch<LocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('rate_q_overall'),
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 18.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (rated) ...[
                Text(
                  '$_stars.0',
                  style: TextStyle(
                    color: AppColors.blueDeep,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                StarRow(rating: _stars, size: 28),
                if (_comment.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    '“$_comment”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ] else ...[
                Icon(Icons.star_outline, size: 44.sp, color: AppColors.textDim),
                SizedBox(height: 8.h),
                Text(
                  loc.t('rate_none'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
                ),
              ],
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _openOverallSheet,
                  child: Text(loc.t(rated ? 'rate_edit' : 'rate_cta')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStagesRating() {
    final loc = context.watch<LocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('rate_stages_title'),
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          loc.t('rate_stages_hint'),
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.sp,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// The overall-care rating returned by the bottom sheet.
typedef OverallRating = ({int stars, String comment});

/// Bottom sheet for the overall care rating: a 5-star picker plus an optional
/// comment. Returns the chosen [OverallRating], or null if dismissed.
class OverallRateSheet extends StatefulWidget {
  final int initialStars;
  final String initialComment;

  const OverallRateSheet({
    super.key,
    required this.initialStars,
    required this.initialComment,
  });

  static Future<OverallRating?> show(
    BuildContext context, {
    int initialStars = 0,
    String initialComment = '',
  }) {
    return showModalBottomSheet<OverallRating>(
      context: context,
      isScrollControlled: true, // lifts above the keyboard for the comment
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (_) => OverallRateSheet(
        initialStars: initialStars,
        initialComment: initialComment,
      ),
    );
  }

  @override
  State<OverallRateSheet> createState() => OverallRateSheetState();
}

class OverallRateSheetState extends State<OverallRateSheet> {
  late int _stars = widget.initialStars;
  late final TextEditingController _commentCtrl =
      TextEditingController(text: widget.initialComment);

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return Padding(
      // Sit above the keyboard when the comment field is focused.
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 18.h,
        bottom: 24.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle.
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border2,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            loc.t('rate_sheet_title'),
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            loc.t('rate_q_overall'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
          ),
          SizedBox(height: 18.h),
          // 5 tappable stars.
          StarRow(
            rating: _stars,
            size: 40,
            onTap: (value) => setState(() => _stars = value),
          ),
          SizedBox(height: 18.h),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            minLines: 3,
            style: TextStyle(fontSize: 14.sp, color: AppColors.text),
            decoration: InputDecoration(
              hintText: loc.t('rate_comment_hint'),
              hintStyle: TextStyle(color: AppColors.textDim, fontSize: 14.sp),
              filled: true,
              fillColor: AppColors.bgSoft,
              contentPadding: EdgeInsets.all(14.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              // Disabled until at least one star is chosen.
              onPressed: _stars == 0
                  ? null
                  : () => Navigator.pop(
                        context,
                        (stars: _stars, comment: _commentCtrl.text.trim()),
                      ),
              child: Text(loc.t('rate_submit')),
            ),
          ),
        ],
      ),
    );
  }
}
