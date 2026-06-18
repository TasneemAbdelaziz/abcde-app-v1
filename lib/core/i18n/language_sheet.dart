import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import 'locale_controller.dart';

/// Shared bottom sheet for switching the app language. Used by the BrandBar
/// globe and the onboarding globe so they behave identically.
Future<void> showLanguageSheet(BuildContext context) async {
  final ctrl = context.read<LocaleController>();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.bgCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Row(
              children: [
                Icon(Icons.language, color: AppColors.blue, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  ctrl.t('choose_language'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          for (final lang in LocaleController.supported)
            ListTile(
              title: Text(
                lang.label,
                style: TextStyle(fontSize: 15.sp, color: AppColors.text),
              ),
              trailing: lang.code == ctrl.code
                  ? Icon(Icons.check, color: AppColors.blue, size: 20.sp)
                  : null,
              onTap: () {
                ctrl.setLocale(lang.locale);
                Navigator.pop(sheetCtx);
              },
            ),
          SizedBox(height: 8.h),
        ],
      ),
    ),
  );
}
