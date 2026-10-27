import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTypography.bodyFamily,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.secondary,
      surface: AppColors.canvas,
      onSurface: AppColors.foreground,
      error: AppColors.error,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.foreground,
      contentTextStyle: TextStyle(fontFamily: AppTypography.bodyFamily, color: AppColors.onAccent),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
