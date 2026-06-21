// [DATA] screen — owner: Product.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
      appBar: const BrandBar(title: 'Family Members'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              children: [
                _buildHeader(),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage who follows your care',
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
                  'Scan QR Code',
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
                  'Add Manually',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIVACY CONTROLS',
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
                'What family can see',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 16.h),
              _buildToggleRow(
                'Vital signs',
                vm.showVitals,
                (v) => vm.toggleVitals(v),
              ),
              SizedBox(height: 14.h),
              _buildToggleRow(
                'Medication schedule',
                vm.showMedications,
                (v) => vm.toggleMedications(v),
              ),
              SizedBox(height: 14.h),
              _buildToggleRow(
                'Lab & test results',
                vm.showLabResults,
                (v) => vm.toggleLabResults(v),
              ),
              SizedBox(height: 14.h),
              _buildToggleRow(
                'Care journey & stages',
                vm.showCareJourney,
                (v) => vm.toggleCareJourney(v),
              ),
              SizedBox(height: 16.h),
              Text(
                'Privacy controls put you in charge of your own information.',
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
                            '● Active',
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
          Container(
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
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    member.accessLevel,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: member.accessLevel == 'View Only'
                          ? AppColors.textMuted
                          : AppColors.blue,
                    ),
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
