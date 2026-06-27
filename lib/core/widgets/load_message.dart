import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

/// Centered status message with an optional Retry button.
///
/// The standard "this screen has no data to show" state — used for both load
/// errors (with [onRetry]) and empty results. Keeps every data screen looking
/// the same instead of each one inventing its own spinner-forever fallback.
class LoadMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;
  const LoadMessage({
    super.key,
    required this.icon,
    required this.text,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.sp, color: AppColors.textDim),
            SizedBox(height: 12.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
