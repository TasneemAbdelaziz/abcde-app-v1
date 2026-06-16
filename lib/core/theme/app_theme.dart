import 'package:flutter/material.dart';

/// App colors + ThemeData for the Alamein Patient Portal.
///
/// Every color here is taken straight from the HTML prototype (the `:root`
/// CSS variables). Use these constants everywhere — do NOT hardcode colors
/// inside screens.
class AppColors {
  AppColors._(); // no instances

  // Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCard2 = Color(0xFFEFF6FF);
  static const Color bgSoft = Color(0xFFF4F9FF);

  // Blues
  static const Color blue = Color(0xFF2E86DE); // primary
  static const Color blueStrong = Color(0xFF1769C0);
  static const Color blueDeep = Color(0xFF0F4C8C);
  static const Color blueLight = Color(0xFF5AA2E6);
  static const Color bluePale = Color(0xFFE9F3FD);
  static const Color bluePale2 = Color(0xFFD8E9FB);

  // Brand
  static const Color navy = Color(0xFF143B66);
  static const Color teal = Color(0xFF129D90);

  // Text
  static const Color text = Color(0xFF16324F);
  static const Color textMuted = Color(0xFF5E7186);
  static const Color textDim = Color(0xFF97A6B8);

  // Borders
  static const Color border = Color(0xFFE4EDF6);
  static const Color border2 = Color(0xFFCFE0F0);

  // Status
  static const Color green = Color(0xFF2BA84A);
  static const Color red = Color(0xFFE5484D);
  static const Color amber = Color(0xFFE8920C);
}

/// Single source of truth for the app theme.
class AppTheme {
  AppTheme._();

  // The prototype uses Noto Sans. To ship the exact font, add the .ttf files
  // to pubspec.yaml under `fonts:`. Until then Flutter falls back gracefully.
  static const String fontFamily = 'Noto Sans';

  // Shadows from the prototype (--shadow / --shadow-lg).
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x141E5AA0), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x291E5AA0), blurRadius: 38, offset: Offset(0, 14)),
  ];

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      secondary: AppColors.teal,
      surface: AppColors.bgCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgSoft,
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgCard,
        elevation: 1,
      ),
    );
  }
}
