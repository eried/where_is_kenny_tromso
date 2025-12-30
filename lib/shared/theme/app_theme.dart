import 'package:flutter/material.dart';

class AppTheme {
  // South Park inspired colors
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color backgroundDark = Color(0xFF1a1a2e);
  static const Color backgroundDarker = Color(0xFF0f0f1a);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryOrange,
        secondary: Colors.orangeAccent,
        surface: backgroundDark,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDarker,
        foregroundColor: textLight,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundDarker,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: backgroundDarker,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: textLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textLight,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textLight,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: textLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textLight),
        bodyMedium: TextStyle(color: textMuted),
      ),
      iconTheme: const IconThemeData(
        color: textLight,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundDarker,
        contentTextStyle: const TextStyle(color: textLight),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  AppTheme._();
}
