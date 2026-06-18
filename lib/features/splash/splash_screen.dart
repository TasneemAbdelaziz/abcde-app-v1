import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/notifications/notification_center.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/routing/routes.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_theme.dart';

/// Animated branded splash with the hospital logo, shown at launch.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Drives the one-shot entrance (logo + text fade/scale).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  // Drives the gentle, looping glow behind the logo.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
  );
  late final Animation<double> _footerFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// Decides where to go after the splash:
  ///   - a saved & still-valid token  → Home (skip login)
  ///   - onboarding already seen       → Login
  ///   - first launch                  → Onboarding
  Future<void> _boot() async {
    final auth = context.read<AuthRepository>();
    final notifications = context.read<NotificationCenter>();
    final navigator = Navigator.of(context);

    final restore = auth.tryRestore();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    final loggedIn = await restore;

    if (!mounted) return;

    if (loggedIn) {
      notifications.start();
      navigator.pushReplacementNamed(Routes.home);
    } else if (AppPrefs.onboardingSeen) {
      navigator.pushReplacementNamed(Routes.login);
    } else {
      navigator.pushReplacementNamed(Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();

    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blueLight, AppColors.blue, AppColors.blueDeep],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
            // Decorative translucent circles for depth.
            Positioned(
              top: -60.h,
              right: -50.w,
              child: _circle(220.w, 0.10),
            ),
            Positioned(
              bottom: -70.h,
              left: -60.w,
              child: _circle(260.w, 0.08),
            ),

            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo card with a soft pulsing glow behind it.
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.75, end: 1.0).animate(_logoScale),
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) {
                          final t = _pulse.value; // 0..1
                          return Container(
                            padding: EdgeInsets.all(22.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white
                                      .withValues(alpha: 0.20 + 0.20 * t),
                                  blurRadius: 30 + 24 * t,
                                  spreadRadius: 2 + 6 * t,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/images/hospital_logo.png',
                          height: 86.h,
                          errorBuilder: (_, __, ___) => Text(
                            'Alamein\nModel Hospital',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 26.h),

                  // Title slides up + fades in.
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(_textFade),
                      child: Column(
                        children: [
                          Text(
                            'Alamein Model Hospital',
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            width: 46.w,
                            height: 3.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Loading indicator.
                  FadeTransition(
                    opacity: _footerFade,
                    child: SizedBox(
                      width: 26.w,
                      height: 26.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),

                  SizedBox(height: 26.h),

                  FadeTransition(
                    opacity: _footerFade,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Text(
                        loc.t('onb_empowered'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          letterSpacing: 1.4,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
