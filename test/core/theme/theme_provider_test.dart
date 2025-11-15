// test/core/theme/theme_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:GitaWisdom/core/theme/theme_provider.dart';
import 'package:GitaWisdom/core/app_config.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import '../../test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    late ThemeProvider provider;
    late Box settingsBox;

    setUp(() async {
      await setupTestEnvironment();

      // Ensure settings box is open
      if (!Hive.isBoxOpen(SettingsService.boxName)) {
        settingsBox = await Hive.openBox(SettingsService.boxName);
      } else {
        settingsBox = Hive.box(SettingsService.boxName);
      }

      // Clear any existing settings
      await settingsBox.clear();

      provider = ThemeProvider();
    });

    tearDown(() async {
      // Wait for any pending timers to complete
      await Future.delayed(const Duration(milliseconds: 200));

      provider.dispose();

      // Wait a bit after dispose to ensure cleanup
      await Future.delayed(const Duration(milliseconds: 50));

      if (Hive.isBoxOpen(SettingsService.boxName)) {
        await settingsBox.clear();
        await settingsBox.close();
      }

      await teardownTestEnvironment();
    });

    group('Initialization', () {
      test('initializes with default values before initialize() is called', () async {
        expect(provider.isDark, equals(AppConfig.defaultDarkMode));
        expect(provider.fontPref, equals(AppConfig.defaultFontSize));
        expect(provider.shadowEnabled, equals(AppConfig.defaultShadowEnabled));
        expect(provider.backgroundOpacity, equals(AppConfig.defaultBackgroundOpacity));

        // Initialize to prevent dispose error
        await provider.initialize();
      });

      test('initialize() loads settings from Hive box', () async {
        // Set some values in settings box before initializing
        await settingsBox.put(SettingsService.darkKey, true);
        await settingsBox.put(SettingsService.fontKey, 'large');
        await settingsBox.put(SettingsService.shadowKey, true);
        await settingsBox.put(SettingsService.opacityKey, 0.7);

        await provider.initialize();

        expect(provider.isDark, isTrue);
        expect(provider.fontPref, equals('large'));
        expect(provider.shadowEnabled, isTrue);
        expect(provider.backgroundOpacity, equals(0.7));
      });

      test('initialize() uses defaults if box is empty', () async {
        await provider.initialize();

        expect(provider.isDark, equals(AppConfig.defaultDarkMode));
        expect(provider.fontPref, equals(AppConfig.defaultFontSize));
        expect(provider.shadowEnabled, equals(AppConfig.defaultShadowEnabled));
        expect(provider.backgroundOpacity, equals(AppConfig.defaultBackgroundOpacity));
      });

      test('initialize() handles missing keys gracefully', () async {
        await settingsBox.put(SettingsService.darkKey, true);
        // Other keys are missing

        await provider.initialize();

        expect(provider.isDark, isTrue);
        expect(provider.fontPref, equals(AppConfig.defaultFontSize));
        expect(provider.shadowEnabled, equals(AppConfig.defaultShadowEnabled));
        expect(provider.backgroundOpacity, equals(AppConfig.defaultBackgroundOpacity));
      });

      test('initialize() sets up listener on settings box', () async {
        await provider.initialize();

        // Change a value in the box
        await settingsBox.put(SettingsService.darkKey, true);

        // Wait for debounce timer
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.isDark, isTrue);
      });
    });

    group('Getters', () {
      test('isDark returns current dark mode state', () async {
        await provider.initialize();
        expect(provider.isDark, equals(AppConfig.defaultDarkMode));

        await provider.updateTheme(isDark: true);
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.isDark, isTrue);
      });

      test('fontPref returns current font preference', () async {
        await provider.initialize();
        expect(provider.fontPref, equals(AppConfig.defaultFontSize));

        await provider.setFontSize('large');
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.fontPref, equals('large'));
      });

      test('shadowEnabled returns current shadow state', () async {
        await provider.initialize();
        expect(provider.shadowEnabled, equals(AppConfig.defaultShadowEnabled));

        await provider.toggleShadow();
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.shadowEnabled, equals(!AppConfig.defaultShadowEnabled));
      });

      test('backgroundOpacity returns current opacity value', () async {
        await provider.initialize();
        expect(provider.backgroundOpacity, equals(AppConfig.defaultBackgroundOpacity));

        await provider.setBackgroundOpacity(0.5);
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.backgroundOpacity, equals(0.5));
      });

      test('textScale returns correct scale for font preference', () async {
        await provider.initialize();

        await provider.setFontSize('small');
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.textScale, equals(AppConfig.getTextScale('small')));

        await provider.setFontSize('medium');
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.textScale, equals(AppConfig.getTextScale('medium')));

        await provider.setFontSize('large');
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.textScale, equals(AppConfig.getTextScale('large')));
      });

      test('themeMode returns correct ThemeMode', () async {
        await provider.initialize();

        await provider.updateTheme(isDark: false);
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.themeMode.toString(), contains('light'));

        await provider.updateTheme(isDark: true);
        await Future.delayed(const Duration(milliseconds: 150));
        expect(provider.themeMode.toString(), contains('dark'));
      });

      test('lightTheme returns non-null ThemeData', () async {
        await provider.initialize();
        expect(provider.lightTheme, isNotNull);
      });

      test('darkTheme returns non-null ThemeData', () async {
        await provider.initialize();
        expect(provider.darkTheme, isNotNull);
      });

      test('currentTheme returns light theme when not dark mode', () async {
        await provider.initialize();
        await provider.updateTheme(isDark: false);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.currentTheme.brightness.toString(), contains('light'));
      });

      test('currentTheme returns dark theme when dark mode enabled', () async {
        await provider.initialize();
        await provider.updateTheme(isDark: true);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.currentTheme.brightness.toString(), contains('dark'));
      });
    });

    group('Theme Updates', () {
      test('updateTheme() updates dark mode', () async {
        await provider.initialize();

        await provider.updateTheme(isDark: true);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.isDark, isTrue);
        expect(settingsBox.get(SettingsService.darkKey), isTrue);
      });

      test('updateTheme() updates font preference', () async {
        await provider.initialize();

        await provider.updateTheme(fontPref: 'large');
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.fontPref, equals('large'));
        expect(settingsBox.get(SettingsService.fontKey), equals('large'));
      });

      test('updateTheme() updates shadow enabled', () async {
        await provider.initialize();

        await provider.updateTheme(shadowEnabled: true);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.shadowEnabled, isTrue);
        expect(settingsBox.get(SettingsService.shadowKey), isTrue);
      });

      test('updateTheme() updates background opacity', () async {
        await provider.initialize();

        await provider.updateTheme(backgroundOpacity: 0.8);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.backgroundOpacity, equals(0.8));
        expect(settingsBox.get(SettingsService.opacityKey), equals(0.8));
      });

      test('updateTheme() updates multiple settings at once', () async {
        await provider.initialize();

        await provider.updateTheme(
          isDark: true,
          fontPref: 'large',
          shadowEnabled: true,
          backgroundOpacity: 0.6,
        );
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.isDark, isTrue);
        expect(provider.fontPref, equals('large'));
        expect(provider.shadowEnabled, isTrue);
        expect(provider.backgroundOpacity, equals(0.6));
      });

      test('updateTheme() does not update if value is same', () async {
        await provider.initialize();
        await provider.updateTheme(isDark: true);
        await Future.delayed(const Duration(milliseconds: 150));

        final callCount = settingsBox.length;

        await provider.updateTheme(isDark: true); // Same value
        await Future.delayed(const Duration(milliseconds: 150));

        // Box should not have new entries
        expect(settingsBox.length, equals(callCount));
      });

      test('toggleDarkMode() toggles dark mode state', () async {
        await provider.initialize();
        final initialState = provider.isDark;

        await provider.toggleDarkMode();
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.isDark, equals(!initialState));
      });

      test('setFontSize() updates font preference', () async {
        await provider.initialize();

        await provider.setFontSize('medium');
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.fontPref, equals('medium'));
      });

      test('toggleShadow() toggles shadow state', () async {
        await provider.initialize();
        final initialState = provider.shadowEnabled;

        await provider.toggleShadow();
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.shadowEnabled, equals(!initialState));
      });

      test('setBackgroundOpacity() updates opacity value', () async {
        await provider.initialize();

        await provider.setBackgroundOpacity(0.3);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.backgroundOpacity, equals(0.3));
      });
    });

    group('ChangeNotifier Behavior', () {
      test('notifies listeners on dark mode change', () async {
        await provider.initialize();
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });

        await settingsBox.put(SettingsService.darkKey, true);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(notified, isTrue);
      });

      test('notifies listeners on font change', () async {
        await provider.initialize();
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });

        await settingsBox.put(SettingsService.fontKey, 'large');
        await Future.delayed(const Duration(milliseconds: 150));

        expect(notified, isTrue);
      });

      test('notifies listeners on shadow change', () async {
        await provider.initialize();
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });

        await settingsBox.put(SettingsService.shadowKey, true);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(notified, isTrue);
      });

      test('notifies listeners on opacity change', () async {
        await provider.initialize();
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });

        await settingsBox.put(SettingsService.opacityKey, 0.7);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(notified, isTrue);
      });

      test('notifies listeners only once per change due to debouncing', () async {
        await provider.initialize();
        int notifyCount = 0;
        provider.addListener(() {
          notifyCount++;
        });

        await settingsBox.put(SettingsService.darkKey, true);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(notifyCount, equals(1));
      });

      test('debounces rapid theme changes', () async {
        await provider.initialize();
        int notifyCount = 0;
        provider.addListener(() {
          notifyCount++;
        });

        // Make multiple rapid changes
        await settingsBox.put(SettingsService.darkKey, true);
        await settingsBox.put(SettingsService.darkKey, false);
        await settingsBox.put(SettingsService.darkKey, true);

        // Wait for debounce
        await Future.delayed(const Duration(milliseconds: 150));

        // Should only notify once due to debouncing
        expect(notifyCount, equals(1));
      });

      test('supports multiple listeners', () async {
        await provider.initialize();
        int listener1Count = 0;
        int listener2Count = 0;

        provider.addListener(() {
          listener1Count++;
        });
        provider.addListener(() {
          listener2Count++;
        });

        await settingsBox.put(SettingsService.darkKey, true);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(listener1Count, equals(1));
        expect(listener2Count, equals(1));
      });

      test('removes listeners properly', () async {
        await provider.initialize();
        int notifyCount = 0;
        void listener() {
          notifyCount++;
        }

        provider.addListener(listener);
        await settingsBox.put(SettingsService.darkKey, true);
        await Future.delayed(const Duration(milliseconds: 150));
        expect(notifyCount, equals(1));

        provider.removeListener(listener);
        await settingsBox.put(SettingsService.darkKey, false);
        await Future.delayed(const Duration(milliseconds: 150));

        // Should still be 1 since listener was removed
        expect(notifyCount, equals(1));
      });
    });

    group('Edge Cases', () {
      test('handles rapid toggle calls', () async {
        await provider.initialize();

        for (int i = 0; i < 20; i++) {
          await provider.toggleDarkMode();
        }

        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.isDark, isNotNull);
      });

      test('handles multiple font size changes', () async {
        await provider.initialize();

        await provider.setFontSize('small');
        await provider.setFontSize('medium');
        await provider.setFontSize('large');
        await provider.setFontSize('small');

        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.fontPref, equals('small'));
      });

      test('handles opacity edge values (0.0)', () async {
        await provider.initialize();

        await provider.setBackgroundOpacity(0.0);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.backgroundOpacity, equals(0.0));
      });

      test('handles opacity edge values (1.0)', () async {
        await provider.initialize();

        await provider.setBackgroundOpacity(1.0);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.backgroundOpacity, equals(1.0));
      });

      test('handles opacity mid-range values', () async {
        await provider.initialize();

        await provider.setBackgroundOpacity(0.5);
        await Future.delayed(const Duration(milliseconds: 150));

        expect(provider.backgroundOpacity, equals(0.5));
      });

      test('handles dispose gracefully', () {
        expect(() => provider.dispose(), returnsNormally);
      });

      test('handles dispose without initialization', () {
        final newProvider = ThemeProvider();
        expect(() => newProvider.dispose(), returnsNormally);
      });

      test('cancels timer on dispose', () async {
        await provider.initialize();

        // Trigger a change to start the timer
        await settingsBox.put(SettingsService.darkKey, true);

        // Dispose immediately
        provider.dispose();

        // Should not throw
        expect(true, isTrue);
      });

      test('handles settings box not available', () async {
        // Close the settings box
        await settingsBox.close();

        // Try to update theme
        await provider.updateTheme(isDark: true);

        // Should not throw, just handle gracefully
        expect(true, isTrue);

        // Reopen for cleanup
        settingsBox = await Hive.openBox(SettingsService.boxName);
      });
    });

    group('Persistence', () {
      test('persists dark mode preference', () async {
        await provider.initialize();
        await provider.updateTheme(isDark: true);
        await Future.delayed(const Duration(milliseconds: 150));

        // Create new provider and initialize
        final newProvider = ThemeProvider();
        await newProvider.initialize();

        expect(newProvider.isDark, isTrue);

        newProvider.dispose();
      });

      test('persists font preference', () async {
        await provider.initialize();
        await provider.setFontSize('large');
        await Future.delayed(const Duration(milliseconds: 150));

        final newProvider = ThemeProvider();
        await newProvider.initialize();

        expect(newProvider.fontPref, equals('large'));

        newProvider.dispose();
      });

      test('persists shadow preference', () async {
        await provider.initialize();
        await provider.updateTheme(shadowEnabled: true);
        await Future.delayed(const Duration(milliseconds: 150));

        final newProvider = ThemeProvider();
        await newProvider.initialize();

        expect(newProvider.shadowEnabled, isTrue);

        newProvider.dispose();
      });

      test('persists opacity preference', () async {
        await provider.initialize();
        await provider.setBackgroundOpacity(0.7);
        await Future.delayed(const Duration(milliseconds: 150));

        final newProvider = ThemeProvider();
        await newProvider.initialize();

        expect(newProvider.backgroundOpacity, equals(0.7));

        newProvider.dispose();
      });

      test('persists multiple preferences simultaneously', () async {
        await provider.initialize();
        await provider.updateTheme(
          isDark: true,
          fontPref: 'large',
          shadowEnabled: true,
          backgroundOpacity: 0.6,
        );
        await Future.delayed(const Duration(milliseconds: 150));

        final newProvider = ThemeProvider();
        await newProvider.initialize();

        expect(newProvider.isDark, isTrue);
        expect(newProvider.fontPref, equals('large'));
        expect(newProvider.shadowEnabled, isTrue);
        expect(newProvider.backgroundOpacity, equals(0.6));

        newProvider.dispose();
      });
    });
  });
}
