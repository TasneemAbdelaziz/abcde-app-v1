import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedTab = 0;
  double _rating = 3.0;
  String _comment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandBar(title: 'Rate care'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            SizedBox(height: 20.h),
            Expanded(
              child: _selectedTab == 0
                  ? _buildOverallRating()
                  : _buildStagesRating(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [_buildTab('Overall', 0), _buildTab('Stages', 1)]),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _selectedTab == index;
    final icon = index == 0 ? Icons.star_rounded : Icons.timeline_rounded;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 1) {
            Navigator.pushNamed(context, Routes.journey);
            return;
          }
          setState(() => _selectedTab = index);
        },
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.blue : AppColors.bgCard,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you rate your overall care?',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 18.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _rating.toStringAsFixed(1),
                style: TextStyle(
                  color: AppColors.blueDeep,
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final filled = index < _rating.round();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline,
                    size: 28.sp,
                    color: filled ? AppColors.amber : AppColors.textMuted,
                  );
                }),
              ),
              SizedBox(height: 24.h),
              Slider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: _rating.toStringAsFixed(0),
                activeColor: AppColors.blue,
                inactiveColor: AppColors.border,
                onChanged: (value) => setState(() => _rating = value),
              ),
              SizedBox(height: 4.h),
              Text(
                'Drag the slider to choose your rating',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
              SizedBox(height: 18.h),
              TextField(
                onChanged: (value) => setState(() => _comment = value),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add a comment (optional)',
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thanks! You rated your care ${_rating.toStringAsFixed(0)} stars.' +
                              (_comment.isEmpty ? '' : ' Comment saved.'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Submit Rating'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStagesRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate individual stages in your care journey',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          'Tap a stage from the Care Journey screen to rate it and leave stage-specific feedback.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.sp,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
