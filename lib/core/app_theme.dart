import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF172A3A);
  static const sea = Color(0xFF007F80);
  static const seaLight = Color(0xFFE8F6F3);
  static const background = Color(0xFFF5F8F7);
  static const outline = Color(0xFFDAE6E3);
  static const amber = Color(0xFFB86A0D);
  static const amberLight = Color(0xFFFFF3DF);
  static const red = Color(0xFFAA3F42);
  static const redLight = Color(0xFFFFEDEE);
}

ThemeData appTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.sea,
    brightness: Brightness.light,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      centerTitle: false,
      surfaceTintColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: AppColors.ink, fontSize: 26,
          fontWeight: FontWeight.w800, letterSpacing: -0.5),
      titleLarge: TextStyle(color: AppColors.ink, fontSize: 19, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: AppColors.ink, height: 1.4),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.outline),
        borderRadius: BorderRadius.circular(18),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sea,
        foregroundColor: Colors.white,
        minimumSize: const Size(44, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.sea,
        minimumSize: const Size(44, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
  );
}
