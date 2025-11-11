// test/services/settings_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import '../test_setup.dart';

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;

    setUpAll(() async {
      // Setup test environment with mocks
      await setupTestEnvironment();
    });

    setUp(() {
      settingsService = SettingsService();
    });

    tearDownAll(() async {
      await teardownTestEnvironment();
    });

    group('Service Initialization', () {
      test('should have static init method', () {
        expect(SettingsService.init, isA<Function>());
      });

      test('should extend ChangeNotifier', () {
        expect(settingsService, isA<ChangeNotifier>());
      });
    });

    group('Theme Management', () {
      test('should provide isDarkMode property', () {
        expect(settingsService.isDarkMode, isA<bool>());
      });

      test('should support setting isDarkMode', () {
        final initialValue = settingsService.isDarkMode;
        settingsService.isDarkMode = !initialValue;
        expect(settingsService.isDarkMode, equals(!initialValue));
        // Revert
        settingsService.isDarkMode = initialValue;
      });

      test('should provide themeMode based on isDarkMode', () {
        settingsService.isDarkMode = true;
        expect(settingsService.themeMode, equals(ThemeMode.dark));

        settingsService.isDarkMode = false;
        expect(settingsService.themeMode, equals(ThemeMode.light));
      });

      test('should have setTheme method', () {
        settingsService.setTheme(ThemeMode.dark);
        expect(settingsService.isDarkMode, isTrue);

        settingsService.setTheme(ThemeMode.light);
        expect(settingsService.isDarkMode, isFalse);
      });
    });

    group('Language Settings', () {
      test('should default to English language', () {
        expect(settingsService.language, equals('en'));
      });

      test('should support setting language', () {
        settingsService.setAppLanguage('hi');
        expect(settingsService.language, equals('hi'));
        // Reset
        settingsService.setAppLanguage('en');
      });
    });

    group('Font Size Settings', () {
      test('should provide fontSize property', () {
        expect(settingsService.fontSize, isA<String>());
      });

      test('should support setting font size', () {
        settingsService.setFontSize('large');
        expect(settingsService.fontSize, equals('large'));
        // Reset
        settingsService.setFontSize('small');
      });
    });

    group('Music Settings', () {
      test('should provide musicEnabled property', () {
        expect(settingsService.musicEnabled, isA<bool>());
      });

      test('should support toggling music', () {
        final initialValue = settingsService.musicEnabled;
        settingsService.musicEnabled = !initialValue;
        expect(settingsService.musicEnabled, equals(!initialValue));
        // Revert
        settingsService.musicEnabled = initialValue;
      });
    });

    group('Text Shadow Settings', () {
      test('should provide textShadowEnabled property', () {
        expect(settingsService.textShadowEnabled, isA<bool>());
      });

      test('should support toggling text shadow', () {
        final initialValue = settingsService.textShadowEnabled;
        settingsService.textShadowEnabled = !initialValue;
        expect(settingsService.textShadowEnabled, equals(!initialValue));
        // Revert
        settingsService.textShadowEnabled = initialValue;
      });
    });

    group('Background Opacity Settings', () {
      test('should provide backgroundOpacity property', () {
        expect(settingsService.backgroundOpacity, isA<double>());
      });

      test('should validate opacity range (0.0 to 1.0)', () {
        expect(
          settingsService.backgroundOpacity,
          allOf(greaterThanOrEqualTo(0.0), lessThanOrEqualTo(1.0)),
        );
      });

      test('should support setting background opacity', () {
        settingsService.backgroundOpacity = 0.5;
        expect(settingsService.backgroundOpacity, equals(0.5));
        // Reset
        settingsService.backgroundOpacity = 1.0;
      });
    });

    group('Error Handling and Validation', () {
      test('should handle missing settings gracefully', () {
        // Should return sensible defaults for missing keys
        expect(settingsService.isDarkMode, isA<bool>());
        expect(settingsService.language, isA<String>());
        expect(settingsService.fontSize, isA<String>());
      });

      test('should not crash when settings are accessed', () {
        // SettingsService with Hive should handle errors gracefully
        expect(settingsService, isNotNull);
        expect(settingsService.isDarkMode, isA<bool>());
      });
    });

    group('ChangeNotifier Integration', () {
      test('should notify listeners on isDarkMode change', () {
        bool notified = false;
        settingsService.addListener(() {
          notified = true;
        });

        final initial = settingsService.isDarkMode;
        settingsService.isDarkMode = !initial;

        expect(notified, isTrue);
        settingsService.removeListener(() {});
      });

      test('should notify listeners on language change', () {
        bool notified = false;
        settingsService.addListener(() {
          notified = true;
        });

        settingsService.setAppLanguage('hi');

        expect(notified, isTrue);
        settingsService.removeListener(() {});
      });
    });
  });
}
