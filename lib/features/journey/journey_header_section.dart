import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/journey_header.dart';

class JourneyHeaderSection extends StatelessWidget {
  final JourneyHeader header;

  const JourneyHeaderSection({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blueDeep,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit: ${header.visitId} · ${header.pathway}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            header.patientName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            header.diagnosis,
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            header.admissionDate,
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
