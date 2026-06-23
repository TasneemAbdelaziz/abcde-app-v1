// [STATIC] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/repositories/patient_api_repository.dart';
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

  // Display label → backend enum value (must match the API's `area` enum).
  static const _areas = <(String, String)>[
    ('Patient Services', 'patient_services'),
    ('Facilities & Cleanliness', 'facilities'),
    ('Staff & Communication', 'staff'),
    ('Waiting Time', 'waiting_time'),
    ('Mobile App & Technology', 'app_tech'),
    ('Other', 'other'),
  ];

  String _selectedArea = 'Patient Services';
  String _suggestionText = '';
  bool _submitted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  /// Sends the suggestion to `POST /suggestions`, then shows the success view.
  Future<void> _submit() async {
    final text = _suggestionText.trim();
    if (text.isEmpty || _submitting) return;

    final area = _areas
        .firstWhere((a) => a.$1 == _selectedArea, orElse: () => _areas.last)
        .$2;

    setState(() => _submitting = true);
    try {
      await context.read<PatientApiRepository>().submitSuggestion(
            area: area,
            suggestionText: text,
          );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send your suggestion. $e')),
      );
    }
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
    final loc = context.watch<LocaleController>();
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
                loc.t('dev_intro'),
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
          loc.t('dev_area'),
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
                      value: area.$1,
                      child: Text(
                        loc.t('area_${area.$2}'),
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
          loc.t('dev_suggestion'),
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
              hintText: loc.t('dev_hint'),
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
            onPressed:
                (_suggestionText.trim().isEmpty || _submitting) ? null : _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: _submitting
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    loc.t('dev_submit'),
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80.h),
        Text('👏', style: TextStyle(fontSize: 52.sp)),
        SizedBox(height: 24.h),
        Text(
          loc.t('dev_thanks'),
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          loc.t('dev_thanks_body'),
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
                _selectedArea = _areas.first.$1;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              loc.t('nav_home'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
