// lib/widgets/app_background.dart

import 'package:flutter/material.dart';
import '../core/app_config.dart';

/// App background widget - handles both theme-based and image-based backgrounds
/// Extracted from the complex background logic in main.dart
class AppBackground extends StatelessWidget {
  final bool isDark;
  final double opacity;
  final bool useImageBackground;

  const AppBackground({
    Key? key,
    required this.isDark,
    required this.opacity,
    this.useImageBackground = false, // Default to theme-based background
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: useImageBackground 
          ? _buildImageBackground()
          : _buildThemeBasedBackground(),
    );
  }

  /// Build theme-based background with gradient colors
  /// Active background system - provides elegant gradient backgrounds
  Widget _buildThemeBasedBackground() {
    if (isDark) {
      return _buildDarkThemeBackground();
    } else {
      return _buildLightThemeBackground();
    }
  }

  /// Dark theme background with enhanced colors matching light theme quality
  Widget _buildDarkThemeBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConfig.darkThemeBaseColor.withOpacity(opacity), // Warmer dark base
            AppConfig.darkThemeMidColor.withOpacity(opacity),  // Mid-tone for depth
            AppConfig.darkThemeAccentColor.withOpacity(opacity), // Subtle purple accent
            AppConfig.darkThemeEdgeColor.withOpacity(opacity), // Lighter edge for dimension
          ],
          stops: AppConfig.darkThemeGradientStops,
        ),
      ),
    );
  }

  /// Light theme background with soft warm gradient
  Widget _buildLightThemeBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConfig.lightThemeBaseColor.withOpacity(opacity), // Soft white base
            AppConfig.lightThemeGradientColor.withOpacity(opacity), // Light gray gradient
            AppConfig.lightThemeAccentColor.withOpacity(opacity), // Warm accent
          ],
          stops: AppConfig.lightThemeGradientStops,
        ),
      ),
    );
  }

  /// Image-based background (preserved for future use)
  /// Can be activated by setting useImageBackground to true
  Widget _buildImageBackground() {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        AppConfig.appBackgroundImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to theme-based background if image fails to load
          debugPrint('❌ Background image failed to load: $error');
          return _buildThemeBasedBackground();
        },
      ),
    );
  }
}