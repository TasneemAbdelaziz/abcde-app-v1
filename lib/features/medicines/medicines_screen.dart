// [DATA] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/models/medicine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import 'medicines_vm.dart';

/// All prescribed medicines, each with a product photo, dose, and schedule.
class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  @override
  void initState() {
    super.initState();
    // (Re)load from the backend every time the screen opens (authenticated).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MedicinesVm>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicinesVm>();
    final loc = context.watch<LocaleController>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: BrandBar(title: loc.t('title_medicines')),
      body: _body(context, vm, loc),
    );
  }

  Widget _body(BuildContext context, MedicinesVm vm, LocaleController loc) {
    if (vm.loading && vm.medicines.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.medicines.isEmpty) {
      return _MedicinesMessage(
        icon: Icons.cloud_off,
        text: loc.t('meds_error'),
        onRetry: () => context.read<MedicinesVm>().load(),
      );
    }
    if (vm.medicines.isEmpty) {
      return _MedicinesMessage(
        icon: Icons.medication_outlined,
        text: loc.t('meds_none'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<MedicinesVm>().load(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        itemCount: vm.medicines.length,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (_, i) => _MedicineCard(medicine: vm.medicines[i]),
      ),
    );
  }
}

/// Centered empty / error message with an optional Retry button.
class _MedicinesMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;
  const _MedicinesMessage({required this.icon, required this.text, this.onRetry});

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