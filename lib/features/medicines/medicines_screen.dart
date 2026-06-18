// [DATA] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/models/medicine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import 'medicines_vm.dart';

/// All prescribed medicines, each with a product photo, dose, and schedule.
class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicinesVm>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: const BrandBar(title: 'My Medicines'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              itemCount: vm.medicines.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (_, i) => _MedicineCard(medicine: vm.medicines[i]),
            ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Row(
        children: [
          _MedicinePhoto(asset: medicine.photoAsset),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${medicine.name} ${medicine.dose}',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  medicine.schedule,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Square product photo. Falls back to a pill icon when the asset is missing,
/// so the screen works before the real photos are added to assets/images/meds/.
class _MedicinePhoto extends StatelessWidget {
  final String asset;
  const _MedicinePhoto({required this.asset});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppColors.bgCard2,
      alignment: Alignment.center,
      child: Icon(Icons.medication_outlined,
          color: AppColors.blue, size: 30.sp),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: 64.r,
        height: 64.r,
        child: asset.isEmpty
            ? fallback
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}