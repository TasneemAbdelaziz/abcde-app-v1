import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/repositories/patient_api_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/star_row.dart';

/// The overall-care rating returned by the bottom sheet.
typedef OverallRating = ({int stars, String comment});

/// Opens the overall-care rating bottom sheet from anywhere (the Home tile or a
/// watch deep link) and saves the result — no full page needed. The sheet shows
/// immediately; we don't block it on a network read so a watch tap feels
/// instant. Shows a snackbar on success/failure.
Future<void> presentOverallRatingSheet(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final loc = context.read<LocaleController>();
  final repo = context.read<PatientApiRepository>();

  final result = await OverallRateSheet.show(context);
  if (result == null) return;

  try {
    await repo.submitOverallRating(
      stars: result.stars,
      comment: result.comment,
    );
    messenger.showSnackBar(
      SnackBar(content: Text(loc.t('rate_thanks'))),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not save your rating. $e')),
    );
  }
}

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
