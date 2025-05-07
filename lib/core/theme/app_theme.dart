// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Centralized app theme configurations using Material 3 tokens.
class AppTheme {
  // Seed color for generating the ColorScheme
  static const Color _seedColor = Color(0xFF1976D2);

  // Light color scheme from seed
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
    secondary: Color(0xFFF9A825),
  );

  // Dark color scheme from seed
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
    secondary: Color(0xFFF9A825),
  );

  /// Light theme data
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.onSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightColorScheme.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.primary),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
  );

  /// Dark theme data
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.onSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      foregroundColor: darkColorScheme.onSurface,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkColorScheme.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkColorScheme.primary),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface),
    ),
  );
}
