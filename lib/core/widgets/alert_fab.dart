import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../i18n/locale_controller.dart';
import '../theme/app_theme.dart';

/// The global "Call your doctor" alert button (the red rounded-square FAB
/// from the HTML prototype's `.alert-fab`).
///
/// It mirrors the prototype exactly:
///   - red gradient rounded square (58Ã58, 16px corners) with a white border,
///   - a white stethoscope icon + "Call your doctor" label,
///   - a continuous pulsing red halo (the CSS `@keyframes sosPulse`).
///
/// Tapping it opens [EmergencyOverlay] ("Alert Sent! A nurse will arrive
/// shortly"), just like `showEmergency()` in the prototype.
///
/// It is placed once, globally, in `main.dart` (see `MaterialApp.builder`),
/// so it floats over every screen â and is hidden on onboarding / login.
class AlertFab extends StatefulWidget {
  /// Called when the button is tapped. Use it to show the emergency overlay.
  final VoidCallback onTap;

  const AlertFab({super.key, required this.onTap});

  // Brand red gradient from the prototype: #FF4D4D -> #D32020.
  static const Color _redLight = Color(0xFFff0000);
  static const Color _redDeep = Color(0xFFD32020);

  @override
  State<AlertFab> createState() => _AlertFabState();
}

class _AlertFabState extends State<AlertFab>
    with SingleTickerProviderStateMixin {
  // Drives the pulsing halo. One full cycle every 2s, repeating forever â
  // matching `animation: sosPulse 2s infinite` in the prototype.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    // Constant drop shadow (present at every keyframe).
    const baseShadow = BoxShadow(
      color: Color(0x80D32020), // rgba(211,32,32,.5)
      blurRadius: 26,
      offset: Offset(0, 10),
    );

    return Material(
      // Provides a proper default text style (avoids Flutter's yellow-underline
      // fallback style on the label below).
      type: MaterialType.transparency,
      child: Semantics(
      button: true,
      label: loc.t('alert_call_doctor'),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            // sosPulse peaks at 50%: a halo grows to spread 8px / 16% opacity,
            // then fades. sin() gives a smooth 0 -> 1 -> 0 over the cycle.
            final t = math.sin(_pulse.value * math.pi); // 0..1..0
            final halo = BoxShadow(
              color: AlertFab._redDeep.withValues(alpha: 0.16 * t),
              blurRadius: 0,
              spreadRadius: 8.r * t,
            );

            return Container(
              width: 58.w,
              height: 58.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AlertFab._redLight, AlertFab._redDeep],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white, width: 3.w),
                boxShadow: [baseShadow, halo],
              ),
              child: child,
            );
          },
          // Static contents (don't rebuild every animation tick).
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Full-colour siren image (no tint).
                Image.asset(
                  'assets/icons/call.png',
                  width: 26.w,
                  height: 26.h,
                  // If the asset is ever missing, fall back to the drawn icon
                  // so the button never shows a broken-image box.
                  errorBuilder: (context, error, stack) => SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CustomPaint(painter: _StethoscopePainter()),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  loc.t('alert_call_doctor'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Draws the prototype's stethoscope SVG (24Ã24 view-box) in white.
///
/// Paths copied from the `.alert-fab` icon in the HTML:
///   binaural "U" (M5 3v4 a4 4 0 0 0 8 0 V3), the two earpieces,
///   the lower tube (M9 15v1 a4 4 0 0 0 8 0 v-1.5) and the chest-piece circle.
class _StethoscopePainter extends CustomPainter {
  const _StethoscopePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // The SVG is authored on a 24Ã24 grid; scale to the actual draw size.
    final s = size.width / 24.0;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Offset p(double x, double y) => Offset(x * s, y * s);

    // Binaural tubes: M5 3 v4 a4 4 0 0 0 8 0 V3  (a downward "U").
    final binaural = Path()
      ..moveTo(5 * s, 3 * s)
      ..lineTo(5 * s, 7 * s)
      ..arcToPoint(p(13, 7), radius: Radius.circular(4 * s), clockwise: true)
      ..lineTo(13 * s, 3 * s);
    canvas.drawPath(binaural, stroke);

    // Earpieces: M4 3 h2  and  M12 3 h2.
    canvas.drawLine(p(4, 3), p(6, 3), stroke);
    canvas.drawLine(p(12, 3), p(14, 3), stroke);

    // Lower tube down to the chest-piece: M9 15 v1 a4 4 0 0 0 8 0 v-1.5.
    final lower = Path()
      ..moveTo(9 * s, 15 * s)
      ..lineTo(9 * s, 16 * s)
      ..arcToPoint(p(17, 16), radius: Radius.circular(4 * s), clockwise: true)
      ..lineTo(17 * s, 14.5 * s);
    canvas.drawPath(lower, stroke);

    // Chest-piece: circle cx=18 cy=13 r=2.2.
    canvas.drawCircle(p(18, 13), 2.2 * s, stroke);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) => false;
}

/// Full-screen confirmation overlay shown after the alert is sent.
///
/// Mirrors the prototype's `#emergencyModal`: a dim scrim, a pulsing red ring
/// with a ð¨ glyph, the "Alert Sent!" message, and a Dismiss button.
class EmergencyOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const EmergencyOverlay({super.key, required this.onDismiss});

  @override
  State<EmergencyOverlay> createState() => _EmergencyOverlayState();
}

class _EmergencyOverlayState extends State<EmergencyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return Positioned.fill(
      // Material gives the text widgets a proper default style. Without it,
      // Flutter paints text with its yellow-underlined "fallback" warning style.
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
        onTap: widget.onDismiss, // tap the scrim to close
        child: Container(
          color: const Color(0x8C142846), // rgba(20,40,70,.55)
          alignment: Alignment.center,
          padding: EdgeInsets.all(30.r),
          child: GestureDetector(
            onTap: () {}, // swallow taps on the card
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.border),
                boxShadow: AppTheme.shadowLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing red ring (the `.pulse-ring` element).
                  AnimatedBuilder(
                    animation: _ring,
                    builder: (context, child) {
                      final t = math.sin(_ring.value * math.pi); // 0..1..0
                      return Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: const Color(0x24E5484D),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.red, width: 3.w),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.red
                                  .withValues(alpha: 0.4 * (1 - t)),
                              blurRadius: 0,
                              spreadRadius: 20.r * t,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: Center(
                      child: Image.asset(
                        'assets/icons/call.png',
                        width: 44.w,
                        height: 44.h,
                        errorBuilder: (context, error, stack) => Icon(
                            Icons.notifications_active,
                            color: AppColors.red,
                            size: 36.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    loc.t('alert_sent'),
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    loc.t('alert_nurse'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(loc.t('alert_dismiss')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
