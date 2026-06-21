// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';

/// Patient education / development resources.
class DevelopmentScreen extends StatefulWidget {
  const DevelopmentScreen({super.key});

  @override
  State<DevelopmentScreen> createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends State<DevelopmentScreen> {
  final _suggestionController = TextEditingController();
  final _areas = <String>[
    'Patient Services',
    'Facilities & Cleanliness',
    'Staff & Communication',
    'Waiting Time',
    'Mobile App & Technology',
    'Other',
  ];

  String _selectedArea = 'Patient Services';
  String _suggestionText = '';
  bool _submitted = false;

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandBar(title: context.watch<LocaleController>().t('title_development')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: _submitted
              ? _buildSuccessView(context)
              : _buildFormView(context),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: AppColors.blue,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Share your suggestions and opinions to help us improve the hospital.',
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Text(
          context.read<LocaleController>().t('dev_area'),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.bg,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedArea,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textMuted,
              ),
              items: _areas
                  .map(
                    (area) => DropdownMenuItem<String>(
                      value: area,
                      child: Text(
                        area,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (area) {
                if (area == null) return;
                setState(() => _selectedArea = area);
              },
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          context.read<LocaleController>().t('dev_suggestion'),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: TextField(
            controller: _suggestionController,
            maxLines: 8,
            minLines: 5,
            onChanged: (value) => setState(() => _suggestionText = value),
            style: TextStyle(fontSize: 14.sp, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Describe your idea to improve the hospital...',
              hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 52.h,
          child: ElevatedButton(
            onPressed: _suggestionText.trim().isEmpty
                ? null
                : () {
                    setState(() => _submitted = true);
                  },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              context.read<LocaleController>().t('dev_submit'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80.h),
        Text('👏', style: TextStyle(fontSize: 52.sp)),
        SizedBox(height: 24.h),
        Text(
          context.read<LocaleController>().t('dev_thanks'),
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Your suggestion has been sent to the hospital improvement team.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textMuted,
            height: 1.6,
          ),
        ),
        SizedBox(height: 40.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _submitted = false;
                _suggestionController.clear();
                _suggestionText = '';
                _selectedArea = _areas.first;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'Home',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
