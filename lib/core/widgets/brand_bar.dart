import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

/// The fixed brand bar shown at the top of EVERY screen.
///
/// Layout matches the prototype: hospital logo on the left, AIU logo + a
/// language (globe) button on the right. If [title] is given, a second row
/// with a back button and the page title is shown underneath (used by detail
/// screens like Treatment, Diagnosis, ...). Tab screens pass no title.
///
/// Use it as the `appBar` of a Scaffold:
///   appBar: const BrandBar(),              // tabs
///   appBar: const BrandBar(title: 'Reports'), // detail screens
class BrandBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const BrandBar({super.key, this.title});

  // Heights scale with ScreenUtil (.h). Getters, not const, so `.h` works.
  double get _brandRow => 56.h;
  double get _titleRow => 44.h;

  @override
  Size get preferredSize =>
      Size.fromHeight(title == null ? _brandRow : _brandRow + _titleRow);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Brand row (logos) ---
          Container(
            height: _brandRow,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              color: AppColors.bg,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                _logo('assets/images/hospital_logo.png', 'Alamein Model Hospital',
                    height: 35.h),
                const Spacer(),
                _logo('assets/images/aiu_logo.png', 'AIU', height: 40.h),
                IconButton(
                  icon: const Icon(Icons.language, color: AppColors.textMuted),
                  // TODO: open the language picker.
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // --- Title row (only on detail screens) ---
          if (title != null)
            Container(
              height: _titleRow,
              color: AppColors.bg,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  if (canPop)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    SizedBox(width: 12.w),
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Shows the logo image, falling back to styled text if the PNG is missing,
  /// so the app runs before the real logos are dropped into assets/images/.
  Widget _logo(String asset, String fallback, {required double height}) {
    return Image.asset(
      asset,
      height: height,
      errorBuilder: (_, __, ___) => Text(
        fallback,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    );
  }
}
