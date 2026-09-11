import 'package:flutter/material.dart';

import 'wammetka_colors.dart';

abstract final class WammetkaTheme {
  static const double radiusCard = 16;
  static const double radiusButton = 24;
  static const double space = 8;

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: WammetkaColors.primary,
      onPrimary: Colors.white,
      secondary: WammetkaColors.accent,
      onSecondary: Colors.white,
      error: WammetkaColors.error,
      onError: Colors.white,
      surface: WammetkaColors.surface,
      onSurface: WammetkaColors.text,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: WammetkaColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: WammetkaColors.background,
        foregroundColor: WammetkaColors.text,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: WammetkaColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WammetkaColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
