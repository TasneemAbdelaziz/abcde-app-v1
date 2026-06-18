// [DATA] screen — owner: Beginner 2.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/models/diagnosis.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import 'diagnosis_video_screen.dart';
import 'diagnosis_vm.dart';

/// Current diagnosis: a doctor-recorded explainer video, a plain-language
/// summary, and prevention videos.
class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiagnosisVm>();
    final dx = vm.diagnosis;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const BrandBar(title: 'Diagnosis'),
      body: (vm.loading || dx == null)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
              children: [
                _DiagnosisHero(diagnosis: dx),
                SizedBox(height: 18.h),

                const _SectionLabel('YOUR CASE EXPLAINED'),
                SizedBox(height: 10.h),
                _VideoCard(video: dx.caseVideo),
                SizedBox(height: 18.h),

                const _SectionLabel('WHAT THIS MEANS'),
                SizedBox(height: 10.h),
                _WhatThisMeansCard(text: dx.explanation),
                SizedBox(height: 18.h),

                const _SectionLabel('HOW TO PREVENT IT FROM WORSENING'),
                SizedBox(height: 10.h),
                for (final v in dx.preventionVideos) ...[
                  _VideoCard(video: v),
                  SizedBox(height: 12.h),
                ],
              ],
            ),
    );
  }
}

/// The blue gradient header card with the current condition.
class _DiagnosisHero extends StatelessWidget {
  final Diagnosis diagnosis;
  const _DiagnosisHero({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue, AppColors.blueStrong],
        ),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current diagnosis',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            diagnosis.condition,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${diagnosis.department} · ${diagnosis.doctor} · '
            'Admitted ${diagnosis.admitted}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// The small grey uppercase label above each section.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// The white bordered "What this means" explanation card.
class _WhatThisMeansCard extends StatelessWidget {
  final String text;
  const _WhatThisMeansCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.text,
          fontSize: 13.sp,
          height: 1.55,
        ),
      ),
    );
  }
}

/// A gradient video card: centered play button, title + subtitle, and a bottom
/// strip with the kind badge (left) and duration (right).
class _VideoCard extends StatelessWidget {
  final DiagnosisVideo video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (video.available) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DiagnosisVideoScreen(video: video),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This video will be available soon.')),
          );
        }
      },
      child: Opacity(
        opacity: video.available ? 1.0 : 0.6,
        child: Container(
          height: 158.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blueStrong, AppColors.blueDeep],
            ),
            boxShadow: AppTheme.shadow,
          ),
          child: Stack(
          children: [
            // Centered play button (or a "Coming soon" state if the video
            // file hasn't been added yet).
            Center(
              child: video.available
                  ? const _PlayButton()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 30.sp,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Coming soon',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),

            // Title + subtitle, sitting just above the bottom strip.
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 40.h,
              child: Column(
                children: [
                  Text(
                    'Watch: ${video.title}',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    video.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom strip: badge on the left, duration on the right.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                color: Colors.black.withValues(alpha: 0.18),
                child: Row(
                  children: [
                    Icon(
                      _badgeIcon(video.kind),
                      size: 14.sp,
                      color: video.kind == DiagnosisVideoKind.alert
                          ? AppColors.amber
                          : Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        video.badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      video.duration,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  IconData _badgeIcon(DiagnosisVideoKind kind) {
    switch (kind) {
      case DiagnosisVideoKind.explainer:
        return Icons.smart_display_outlined;
      case DiagnosisVideoKind.prevention:
        return Icons.verified_user_outlined;
      case DiagnosisVideoKind.alert:
        return Icons.warning_amber_rounded;
    }
  }
}

/// The translucent circular play button shown in the middle of a video card.
class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30.sp),
    );
  }
}