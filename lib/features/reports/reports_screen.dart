// [DATA] screen — owner: Lead.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/report.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import 'reports_vm.dart';

/// Medical reports and lab results.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsVm>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: const BrandBar(title: 'Reports'),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              children: [
                _buildHeader(),
                SizedBox(height: 20.h),
                _buildSegmentedTabs(),
                SizedBox(height: 24.h),
                if (_selectedTab == 0)
                  for (int i = 0; i < vm.reports.length; i++) ...[
                    _ReportCard(report: vm.reports[i]),
                    if (i < vm.reports.length - 1) SizedBox(height: 14.h),
                  ]
                else
                  _buildFinancialSummary(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECORDS',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Dr. Amira Fouad · Cardiology',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Recent reports, lab results, and medical documents.',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabs() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.bluePale2,
        borderRadius: BorderRadius.circular(22.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          _buildSegmentButton(label: 'Health', index: 0),
          _buildSegmentButton(label: 'Financial', index: 1),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({required String label, required int index}) {
    final active = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppColors.bg : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.text : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Current Visit — Bill Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16.h),
          _buildBillingRow('Admission & room (CCU)', 'EGP 4,200'),
          _buildDivider(),
          _buildBillingRow('Catheterization procedure', 'EGP 18,500'),
          _buildDivider(),
          _buildBillingRow('Laboratory & imaging', 'EGP 2,150'),
          _buildDivider(),
          _buildBillingRow('Medication', 'EGP 980'),
          _buildDivider(),
          _buildBillingRow(
            'Insurance coverage',
            '- EGP 19,800',
            valueColor: AppColors.green,
          ),
          SizedBox(height: 16.h),
          _buildDivider(),
          SizedBox(height: 16.h),
          _buildBillingRow(
            'Amount due',
            'EGP 6,030',
            valueColor: AppColors.blueDeep,
            labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            valueStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  labelStyle ??
                  TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
            ),
          ),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(fontSize: 14.sp, color: valueColor ?? AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.border, thickness: 1, height: 0);
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final typeLabel = _reportTypeLabel(report.type);
    final iconData = _reportTypeIcon(report.type);
    final iconColor = _reportTypeColor(report.type);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(iconData, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '$typeLabel • ${_formatDate(report.date)}',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Icon(Icons.download_outlined, color: AppColors.blueDeep, size: 24.sp),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  String _reportTypeLabel(String type) {
    switch (type) {
      case 'lab':
        return 'Laboratory';
      case 'imaging':
        return 'Imaging';
      case 'summary':
        return 'Summary';
      default:
        return type;
    }
  }

  IconData _reportTypeIcon(String type) {
    switch (type) {
      case 'lab':
        return Icons.bloodtype;
      case 'imaging':
        return Icons.monitor_heart_outlined;
      case 'summary':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _reportTypeColor(String type) {
    switch (type) {
      case 'lab':
        return AppColors.red;
      case 'imaging':
        return AppColors.blue;
      case 'summary':
        return AppColors.amber;
      default:
        return AppColors.navy;
    }
  }
}
