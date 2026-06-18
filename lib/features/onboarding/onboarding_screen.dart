import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/language_sheet.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/routing/routes.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_theme.dart';

/// One onboarding slide. [image] falls back to a gradient if the photo isn't
/// present in assets yet. Title/body are translation keys resolved per slide.
class _Slide {
  final String image;
  final String titleKey;
  final String bodyKey;
  const _Slide({
    required this.image,
    required this.titleKey,
    required this.bodyKey,
  });
}

const List<_Slide> _slides = [
  _Slide(
    image: 'assets/images/onboarding_1.jpg',
    titleKey: 'onb_s1_title',
    bodyKey: 'onb_s1_body',
  ),
  _Slide(
    image: 'assets/images/onboarding_2.jpg',
    titleKey: 'onb_s2_title',
    bodyKey: 'onb_s2_body',
  ),
  _Slide(
    image: 'assets/images/onboarding_3.jpg',
    titleKey: 'onb_s3_title',
    bodyKey: 'onb_s3_body',
  ),
  _Slide(
    image: 'assets/images/onboarding_4.jpg',
    titleKey: 'onb_s4_title',
    bodyKey: 'onb_s4_body',
  ),
];

/// Onboarding / welcome carousel shown after the splash.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _slides.length - 1;

  void _next() {
    if (_isLast) {
      _openApp();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _openApp() {
    // Remember we've shown onboarding so it's skipped next launch.
    AppPrefs.setOnboardingSeen(true);
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();

    return Scaffold(
      backgroundColor: AppColors.blueDeep,
      body: Stack(
        children: [
          // Swipeable slides (image + dark overlay + text).
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _SlideView(slide: _slides[i], loc: loc),
          ),

          // Top bar: logo + name + language globe.
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  _LogoChip(),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Alamein Model Hospital',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.language,
                    onTap: () => showLanguageSheet(context),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls: dots + buttons + footer.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dots(count: _slides.length, active: _page),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryButton(
                            label: loc.t('onb_next'),
                            filled: false,
                            onTap: _isLast ? null : _next,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _PrimaryButton(
                            label: '${loc.t('onb_open_app')} →',
                            filled: true,
                            onTap: _openApp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      loc.t('onb_empowered'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10.sp,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  final LocaleController loc;
  const _SlideView({required this.slide, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo, or a branded gradient if the asset isn't there yet.
        Image.asset(
          slide.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.blue, AppColors.blueDeep],
              ),
            ),
          ),
        ),
        // Dark gradient so the text stays readable over any photo.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.78),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Slide text, sitting in the lower third like the prototype.
        Padding(
          padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 200.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                loc.t('onb_about'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                loc.t(slide.titleKey),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                loc.t(slide.bodyKey),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13.5.sp,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34.w,
      height: 34.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Image.asset(
        'assets/images/hospital_logo.png',
        errorBuilder: (_, __, ___) =>
            Icon(Icons.local_hospital, color: AppColors.blue, size: 20.sp),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: i == active ? 22.w : 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: i == active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  const _PrimaryButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        height: 50.h,
        child: filled
            ? ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w700)),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w700)),
              ),
      ),
    );
  }
}
