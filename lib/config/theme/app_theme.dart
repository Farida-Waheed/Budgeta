import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        titleLarge: AppTypography.header,
        bodyMedium: AppTypography.body,
      ),
      useMaterial3: true,
    );
  }
}
