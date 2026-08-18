import 'package:flutter/material.dart';
import 'package:puzzle_match/ui/motion.dart';

class AppTheme {
  static const background = Color(0xFF2C2C2C);
  static const surface = Color(0xFF3A3A3A);
  static const card = Color(0xFFF4EFE4);
  static const accent = Color(0xFFFF9F1C);
  static const accentDeep = Color(0xFFE85D04);
  static const hint = Color(0xFFFFD54F);
  static const success = Color(0xFF76FF03);
  static const tileSeparator = Color(0xFFD7C4A3);
  static const textMuted = Color(0xFFBDBDBD);

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: accent,
      secondary: hint,
      surface: surface,
      error: Color(0xFFE53935),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
        },
      ),
    );
  }
}
