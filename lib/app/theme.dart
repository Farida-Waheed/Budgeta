// lib/app/theme.dart
import 'package:flutter/material.dart';

class BudgetaColors {
  static const Color background = Color(0xFFFCF5EE); // FCF5EE
  static const Color accentLight = Color(0xFFFFC4C4); // FFC4C4
  static const Color primary = Color(0xFFEE6983); // EE6983
  static const Color deep = Color(0xFF850E35); // 850E35

  static const Color textPrimary = deep;
  static const Color textSecondary = Colors.black54;
}

class BudgetaTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: BudgetaColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BudgetaColors.primary,
        primary: BudgetaColors.primary,
        secondary: BudgetaColors.accentLight,
        // 'background' is deprecated; using surface + scaffoldBackgroundColor instead
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BudgetaColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: BudgetaColors.primary,
        unselectedItemColor: BudgetaColors.deep,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BudgetaColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: BudgetaColors.deep,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: BudgetaColors.textPrimary,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          color: BudgetaColors.deep,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: BudgetaColors.primary,
        disabledColor: BudgetaColors.accentLight,
        // 'withOpacity' deprecated → use withValues to control alpha
        backgroundColor:
            BudgetaColors.accentLight.withValues(alpha: 0.4),
        labelStyle: const TextStyle(color: BudgetaColors.deep),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BudgetaColors.accentLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: BudgetaColors.accentLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: BudgetaColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
