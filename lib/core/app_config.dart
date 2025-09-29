// lib/core/app_config.dart

import 'package:flutter/material.dart';

/// Centralized app configuration and constants
/// Maintains app-wide settings and feature flags
class AppConfig {
  // App Information
  static const String appName = 'GitaWisdom';
  static const String appTitle = 'Wisdom Guide';
  
  // Version and Build Information
  static const String version = '2.2.8';
  static const int buildNumber = 21;
  
  // Timing Configuration
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 150);
  
  // UI Configuration
  static const double defaultElevation = 8.0;
  static const double cardBorderRadius = 14.0;
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets navBarMargin = EdgeInsets.only(bottom: 10);
  
  // Text Scale Configuration
  static const double smallTextScale = 0.90;
  static const double mediumTextScale = 1.0;
  static const double largeTextScale = 1.05;
  
  // Shadow Configuration
  static const double iOSHeaderShadowBlur = 3.0;
  static const double androidHeaderShadowBlur = 2.0;
  static const double iOSBodyShadowBlur = 2.0;
  static const double androidBodyShadowBlur = 1.5;
  static const double iOSLabelShadowBlur = 1.5;
  static const double androidLabelShadowBlur = 1.0;
  
  // Color Configuration
  static const Color transparentColor = Colors.transparent;
  static const Color selectedNavColor = Colors.brown;
  static const Color splashIconColor = Colors.white;
  
  // Asset Paths
  static const String appBackgroundImage = 'assets/images/app_bg.png';
  static const String splashBackgroundImage = 'assets/images/app_bg.png';
  
  // Feature Flags
  static const bool debugMode = true; // Set to false for production
  static const bool enablePerformanceTracking = false;
  static const bool enableCrashReporting = false;
  static const bool enableAnalytics = false;
  
  // Theme Colors
  static const Color lightThemeBaseColor = Color(0xFFFAFAFA);
  static const Color lightThemeGradientColor = Color(0xFFF5F5F5);
  static const Color lightThemeAccentColor = Color(0xFFF0F0F8);
  
  static const Color darkThemeBaseColor = Color(0xFF2C2C2C);
  static const Color darkThemeMidColor = Color(0xFF3A3A3A);
  static const Color darkThemeAccentColor = Color(0xFF2E2E3E);
  static const Color darkThemeEdgeColor = Color(0xFF404040);
  
  // Gradient Stops
  static const List<double> lightThemeGradientStops = [0.0, 0.7, 1.0];
  static const List<double> darkThemeGradientStops = [0.0, 0.4, 0.7, 1.0];
  
  // Default Values
  static const bool defaultDarkMode = false;
  static const String defaultFontSize = 'medium';
  static const bool defaultMusicEnabled = true;
  static const bool defaultShadowEnabled = false;
  static const double defaultBackgroundOpacity = 1.0;
  static const String defaultLanguage = 'en';
  
  // Localization
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English only for MVP
  ];
  
  // Performance Configuration
  static const int maxScenarioPreload = 100;
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration serviceInitTimeout = Duration(seconds: 10);
  
  /// Get text scale factor from font preference
  static double getTextScale(String fontPref) {
    switch (fontPref) {
      case 'small':
        return smallTextScale;
      case 'large':
        return largeTextScale;
      case 'medium':
      default:
        return mediumTextScale;
    }
  }
  
  /// Check if app is running in debug mode
  static bool get isDebugMode => debugMode;
  
  /// Get app display name
  static String get displayName => appName;
  
  /// Get full app version string
  static String get fullVersion => '$version+$buildNumber';
}