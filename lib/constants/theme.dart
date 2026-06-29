import 'package:flutter/material.dart';

class AppColors {
  static const tanGold = Color(0xFFB8A082);
  static const success = Color(0xFF4CAF50);
  static const explainer = Color(0xFFFFC107);
  static const danger = Color(0xFFE53935);
  static const neutral = Color(0xFF9E9E9E);
  static const background = Color(0xFFFAFAFA);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.tanGold,
    brightness: Brightness.light,
    surface: AppColors.background,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0.5,
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Colors.white,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
    ),
  ),
);
