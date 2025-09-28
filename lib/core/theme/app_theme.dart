// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_config.dart';
import 'text_theme_builder.dart';

/// App theme configuration
/// Centralized theme management with light and dark mode support
class AppTheme {
  /// Build light theme with optional shadow support
  static ThemeData buildLightTheme({bool shadowEnabled = false}) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);
    final textTheme = TextThemeBuilder.buildTextThemeWithShadows(baseTextTheme, shadowEnabled);
    
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: AppConfig.transparentColor,
      textTheme: textTheme,
      cardTheme: _buildCardTheme(ThemeData.light().colorScheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(false),
      appBarTheme: _buildAppBarTheme(false),
      elevatedButtonTheme: _buildElevatedButtonTheme(false),
    );
  }

  /// Build dark theme with optional shadow support
  static ThemeData buildDarkTheme({bool shadowEnabled = false}) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    final textTheme = TextThemeBuilder.buildTextThemeWithShadows(baseTextTheme, shadowEnabled);
    
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppConfig.transparentColor,
      textTheme: textTheme,
      cardTheme: _buildCardTheme(ThemeData.dark().colorScheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(true),
      appBarTheme: _buildAppBarTheme(true),
      elevatedButtonTheme: _buildElevatedButtonTheme(true),
    );
  }

  /// Build card theme with consistent styling
  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surface,
      elevation: AppConfig.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
      ),
      margin: AppConfig.cardMargin,
    );
  }

  /// Build bottom navigation bar theme
  static BottomNavigationBarThemeData _buildBottomNavTheme(bool isDark) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppConfig.selectedNavColor,
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      elevation: AppConfig.defaultElevation,
    );
  }

  /// Build app bar theme
  static AppBarTheme _buildAppBarTheme(bool isDark) {
    return AppBarTheme(
      backgroundColor: AppConfig.transparentColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  /// Build elevated button theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.selectedNavColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        elevation: AppConfig.defaultElevation,
      ),
    );
  }

  /// Get theme mode from boolean value
  static ThemeMode getThemeMode(bool isDark) {
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Build theme data based on settings
  static ThemeData buildTheme({
    required bool isDark,
    required bool shadowEnabled,
  }) {
    return isDark 
        ? buildDarkTheme(shadowEnabled: shadowEnabled)
        : buildLightTheme(shadowEnabled: shadowEnabled);
  }
}