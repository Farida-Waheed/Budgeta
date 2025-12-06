// lib/app/theme.dart
import 'package:flutter/material.dart';

class BudgetaColors {
  // Brand colors
  static const Color primary = Color(0xFFEE6983); // EE6983
  static const Color deep = Color(0xFF850E35); // 850E35
  static const Color accentLight = Color(0xFFFFC4C4); // FFC4C4

  // Backgrounds
  static const Color backgroundLight = Color(0xFFFCF5EE); // FCF5EE
  static const Color backgroundDark = Color(0xFF1B1020);

  // Neutrals / text
  static const Color textDark = Color(0xFF3C1A2B);
  static const Color textMuted = Color(0xFF866F80);

  // Cards / borders
  static const Color cardBorder = Color(0xFFFFC4C4);

  // For backwards compatibility with other files
  static const Color background = backgroundLight;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
}

class BudgetaGradients {
  // Hero background like the welcome screen
  static const LinearGradient heroBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF8F3),
      Color(0xFFFEE4EC),
    ],
  );

  // Main CTA button gradient
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF7193),
      Color(0xFF9A0E3A),
    ],
  );
}

class BudgetaTheme {
  /// -----------------
  ///   LIGHT THEME
  /// -----------------
  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: BudgetaColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BudgetaColors.primary,
        brightness: Brightness.light,
        primary: BudgetaColors.primary,
        secondary: BudgetaColors.accentLight,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BudgetaColors.backgroundLight,
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
        backgroundColor:
            BudgetaColors.accentLight.withValues(alpha: 0.4), // soft pink
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
          borderSide: const BorderSide(color: BudgetaColors.accentLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: BudgetaColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// -----------------
  ///   DARK THEME
  /// -----------------
  static ThemeData get darkTheme {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: BudgetaColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BudgetaColors.primary,
        brightness: Brightness.dark,
        primary: BudgetaColors.primary,
        secondary: BudgetaColors.accentLight,
        surface: const Color(0xFF26142C),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF26142C),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BudgetaColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF26142C),
        selectedItemColor: BudgetaColors.primary,
        unselectedItemColor: Colors.white70,
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
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          color: Colors.white,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: BudgetaColors.primary,
        disabledColor: Colors.white10,
        backgroundColor: Colors.white10,
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF26142C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: BudgetaColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
