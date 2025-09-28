// lib/core/theme/text_theme_builder.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../app_config.dart';

/// Builds text themes with platform-specific shadows
/// Handles the complex shadow configuration logic extracted from main.dart
class TextThemeBuilder {
  /// Build text theme with optional shadow support
  /// Creates platform-specific shadow configurations for better readability
  static TextTheme buildTextThemeWithShadows(TextTheme baseTheme, bool shadowEnabled) {
    if (!shadowEnabled) return baseTheme;
    
    return baseTheme.copyWith(
      // Headers - strongest shadow for prominence
      displayLarge: baseTheme.displayLarge?.copyWith(shadows: _getHeaderShadows()),
      displayMedium: baseTheme.displayMedium?.copyWith(shadows: _getHeaderShadows()),
      displaySmall: baseTheme.displaySmall?.copyWith(shadows: _getHeaderShadows()),
      headlineLarge: baseTheme.headlineLarge?.copyWith(shadows: _getHeaderShadows()),
      headlineMedium: baseTheme.headlineMedium?.copyWith(shadows: _getHeaderShadows()),
      headlineSmall: baseTheme.headlineSmall?.copyWith(shadows: _getHeaderShadows()),
      
      // Titles - medium shadow for balance
      titleLarge: baseTheme.titleLarge?.copyWith(shadows: _getBodyShadows()),
      titleMedium: baseTheme.titleMedium?.copyWith(shadows: _getBodyShadows()),
      titleSmall: baseTheme.titleSmall?.copyWith(shadows: _getBodyShadows()),
      
      // Body text - medium shadow for readability
      bodyLarge: baseTheme.bodyLarge?.copyWith(shadows: _getBodyShadows()),
      bodyMedium: baseTheme.bodyMedium?.copyWith(shadows: _getBodyShadows()),
      bodySmall: baseTheme.bodySmall?.copyWith(shadows: _getBodyShadows()),
      
      // Labels - subtle shadow for elegance
      labelLarge: baseTheme.labelLarge?.copyWith(shadows: _getLabelShadows()),
      labelMedium: baseTheme.labelMedium?.copyWith(shadows: _getLabelShadows()),
      labelSmall: baseTheme.labelSmall?.copyWith(shadows: _getLabelShadows()),
    );
  }

  /// Create platform-specific header shadows
  /// iOS gets stronger shadows for better visual hierarchy
  static List<Shadow> _getHeaderShadows() {
    return [
      Shadow(
        color: Platform.isIOS 
            ? Colors.black.withOpacity(0.6) 
            : Colors.black45, // Stronger for headers on iOS
        offset: Platform.isIOS 
            ? const Offset(1.5, 1.5) 
            : const Offset(1.0, 1.0),
        blurRadius: Platform.isIOS 
            ? AppConfig.iOSHeaderShadowBlur 
            : AppConfig.androidHeaderShadowBlur,
      ),
    ];
  }

  /// Create platform-specific body text shadows
  /// Balanced shadow intensity for optimal readability
  static List<Shadow> _getBodyShadows() {
    return [
      Shadow(
        color: Platform.isIOS 
            ? Colors.black.withOpacity(0.5) 
            : Colors.black38, // Lighter for body text on iOS
        offset: Platform.isIOS 
            ? const Offset(1.0, 1.0) 
            : const Offset(0.8, 0.8),
        blurRadius: Platform.isIOS 
            ? AppConfig.iOSBodyShadowBlur 
            : AppConfig.androidBodyShadowBlur,
      ),
    ];
  }

  /// Create platform-specific label shadows
  /// Subtle shadows for labels and small text elements
  static List<Shadow> _getLabelShadows() {
    return [
      Shadow(
        color: Platform.isIOS 
            ? Colors.black45 
            : Colors.black.withOpacity(0.3), // Subtle for labels on iOS
        offset: Platform.isIOS 
            ? const Offset(0.8, 0.8) 
            : const Offset(0.5, 0.5),
        blurRadius: Platform.isIOS 
            ? AppConfig.iOSLabelShadowBlur 
            : AppConfig.androidLabelShadowBlur,
      ),
    ];
  }

  /// Create custom shadow for specific use cases
  /// Allows for one-off shadow configurations when needed
  static List<Shadow> createCustomShadow({
    required Color color,
    required Offset offset,
    required double blurRadius,
  }) {
    return [
      Shadow(
        color: color,
        offset: offset,
        blurRadius: blurRadius,
      ),
    ];
  }
}