// [DATA] screen — owner: Product.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/models/family_member.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import 'family_vm.dart';

/// Family / visitor information and contacts.
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FamilyVm>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: BrandBar(title: context.watch<LocaleController>().t('title_family')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              children: [
                _buildHeader(context),
                SizedBox(height: 20.h),
                for (final member in vm.members) ...[
                  _FamilyMemberCard(member: member),
                  SizedBox(height: 14.h),
                ],
                SizedBox(height: 8.h),
                _buildActionButtons(context, vm),
                SizedBox(height: 32.h),
                _buildPrivacyControls(context, vm),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.watch<LocaleController>().t('family_manage'),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, FamilyVm vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => vm.scanQRCode(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              side: const BorderSide(color: AppColors.blue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, color: AppColors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  context.watch<LocaleController>().t('fam_scan_qr'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => vm.addManually(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              side: const BorderSide(color: AppColors.blue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, color: AppColors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  context.watch<LocaleController>().t('add_manually'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyControls(BuildContext context, FamilyVm vm) {
    final loc = context.watch<LocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('privacy_controls'),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
            boxShadow: AppTheme.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('what_family_sees'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 16.h),
              _buildToggleRow(
                loc.t('fam_see_vitals'),
                vm.showVitals,
                (v) => vm.toggleVitals(v),
              ),
              SizedBox(height: 14.h),
              _buildToggleRow(
                loc.t('fam_see_medications'),
                vm.showMedications,
                (v) => vm.toggleMedications(v),
              ),
              SizedBox(height: 14.h),
              _buildToggleRow(
                loc.t('fam_see_labs'),
                vm.showLabResults,
                (v) => vm.toggleLabResults(v),
              ),
              SizedBox(height: 14.h),
              _buildToggleRow(
                loc.t('fam_see_journey'),
                vm.showCareJourney,
                (v) => vm.toggleCareJourney(v),
              ),
              SizedBox(height: 16.h),
              Text(
                loc.t('fam_privacy_note'),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.text),
        ),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.blue),
      ],
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;

  const _FamilyMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  member.initials,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '● ${context.watch<LocaleController>().t('active')}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${member.role} — ${member.relationship}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () =>
                _showPermissionsSheet(context, context.read<FamilyVm>(), member),
            child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: member.accessLevel == 'View Only'
                  ? AppColors.textDim.withValues(alpha: 0.08)
                  : AppColors.bluePale,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  member.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: member.accessLevel == 'View Only'
                        ? AppColors.textMuted
                        : AppColors.blueDeep,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.accessLevel,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: member.accessLevel == 'View Only'
                            ? AppColors.textMuted
                            : AppColors.blue,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.tune,
                      size: 16.sp,
                      color: member.accessLevel == 'View Only'
                          ? AppColors.textMuted
                          : AppColors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet that edits a family member's six permission flags and saves
/// them via `PATCH /family/{id}/permissions`.
Future<void> _showPermissionsSheet(
  BuildContext context,
  FamilyVm vm,
  FamilyMember member,
) async {
  final perms = <String, bool>{
    'can_see_status': member.canSeeStatus,
    'receives_alerts': member.receivesAlerts,
    'can_book': member.canBook,
    'can_rate': member.canRate,
    'can_raise_emergency': member.canRaiseEmergency,
    'is_decision_maker': member.isDecisionMaker,
  };
  const labels = <String, String>{
    'can_see_status': 'Can see care status',
    'receives_alerts': 'Receives alerts',
    'can_book': 'Can book appointments',
    'can_rate': 'Can submit ratings',
    'can_raise_emergency': 'Can raise emergency',
    'is_decision_maker': 'Decision maker',
  };

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 18.h,
          bottom: 20.h + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Permissions',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 8.h),
            for (final entry in labels.entries)
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.blue,
                title: Text(
                  entry.value,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.text),
                ),
                value: perms[entry.key] ?? false,
                onChanged: (v) => setSheet(() => perms[entry.key] = v),
              ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  vm.updatePermissions(member.id, Map.of(perms));
                  Navigator.pop(sheetContext);
                },
                child: const Text('Save permissions'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
