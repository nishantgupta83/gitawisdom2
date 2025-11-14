import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/core/app_config.dart';

void main() {
  group('AppConfig', () {
    test('should have correct app information', () {
      expect(AppConfig.appName, equals('GitaWisdom'));
      expect(AppConfig.appTitle, equals('Wisdom Guide'));
      expect(AppConfig.version, isNotEmpty);
      expect(AppConfig.buildNumber, greaterThan(0));
    });

    test('should have timing configurations', () {
      expect(AppConfig.splashDuration, equals(const Duration(seconds: 3)));
      expect(AppConfig.animationDuration, equals(const Duration(milliseconds: 300)));
      expect(AppConfig.debounceDelay, equals(const Duration(milliseconds: 150)));
    });

    test('should have UI configurations', () {
      expect(AppConfig.defaultElevation, equals(8.0));
      expect(AppConfig.cardBorderRadius, equals(14.0));
      expect(AppConfig.cardMargin, isA<EdgeInsets>());
      expect(AppConfig.navBarMargin, isA<EdgeInsets>());
    });

    test('should have text scale configurations', () {
      expect(AppConfig.smallTextScale, equals(0.90));
      expect(AppConfig.mediumTextScale, equals(1.0));
      expect(AppConfig.largeTextScale, equals(1.05));
    });

    test('getTextScale should return correct values', () {
      expect(AppConfig.getTextScale('small'), equals(0.90));
      expect(AppConfig.getTextScale('medium'), equals(1.0));
      expect(AppConfig.getTextScale('large'), equals(1.05));
      expect(AppConfig.getTextScale('invalid'), equals(1.0)); // Default
    });

    test('should have shadow configurations', () {
      expect(AppConfig.iOSHeaderShadowBlur, equals(3.0));
      expect(AppConfig.androidHeaderShadowBlur, equals(2.0));
      expect(AppConfig.iOSBodyShadowBlur, equals(2.0));
      expect(AppConfig.androidBodyShadowBlur, equals(1.5));
      expect(AppConfig.iOSLabelShadowBlur, equals(1.5));
      expect(AppConfig.androidLabelShadowBlur, equals(1.0));
    });

    test('should have color configurations', () {
      expect(AppConfig.transparentColor, equals(Colors.transparent));
      expect(AppConfig.selectedNavColor, equals(Colors.brown));
      expect(AppConfig.splashIconColor, equals(Colors.white));
    });

    test('should have theme color configurations', () {
      expect(AppConfig.lightThemeBaseColor, isA<Color>());
      expect(AppConfig.lightThemeGradientColor, isA<Color>());
      expect(AppConfig.lightThemeAccentColor, isA<Color>());
      expect(AppConfig.darkThemeBaseColor, isA<Color>());
      expect(AppConfig.darkThemeMidColor, isA<Color>());
      expect(AppConfig.darkThemeAccentColor, isA<Color>());
      expect(AppConfig.darkThemeEdgeColor, isA<Color>());
    });

    test('should have gradient stop configurations', () {
      expect(AppConfig.lightThemeGradientStops.length, equals(3));
      expect(AppConfig.darkThemeGradientStops.length, equals(4));
      expect(AppConfig.lightThemeGradientStops, containsAll([0.0, 0.7, 1.0]));
      expect(AppConfig.darkThemeGradientStops, containsAll([0.0, 0.4, 0.7, 1.0]));
    });

    test('should have feature flags', () {
      expect(AppConfig.debugMode, isA<bool>());
      expect(AppConfig.enablePerformanceTracking, isA<bool>());
      expect(AppConfig.enableCrashReporting, isA<bool>());
      expect(AppConfig.enableAnalytics, isA<bool>());
    });

    test('should have default values', () {
      expect(AppConfig.defaultDarkMode, equals(false));
      expect(AppConfig.defaultFontSize, equals('medium'));
      expect(AppConfig.defaultMusicEnabled, equals(true));
      expect(AppConfig.defaultShadowEnabled, equals(false));
      expect(AppConfig.defaultBackgroundOpacity, equals(1.0));
      expect(AppConfig.defaultLanguage, equals('en'));
    });

    test('should have supported locales', () {
      expect(AppConfig.supportedLocales, isNotEmpty);
      expect(AppConfig.supportedLocales.first, equals(const Locale('en', '')));
    });

    test('should have performance configurations', () {
      expect(AppConfig.maxScenarioPreload, equals(100));
      expect(AppConfig.connectionTimeout, equals(const Duration(seconds: 30)));
      expect(AppConfig.serviceInitTimeout, equals(const Duration(seconds: 10)));
    });

    test('isDebugMode getter should work', () {
      expect(AppConfig.isDebugMode, isA<bool>());
    });

    test('displayName getter should return appName', () {
      expect(AppConfig.displayName, equals(AppConfig.appName));
    });

    test('fullVersion should combine version and buildNumber', () {
      final expected = '${AppConfig.version}+${AppConfig.buildNumber}';
      expect(AppConfig.fullVersion, equals(expected));
    });

    test('asset paths should be defined', () {
      expect(AppConfig.splashBackgroundImage, isNotEmpty);
      expect(AppConfig.splashBackgroundImage, contains('assets/'));
    });
  });
}
