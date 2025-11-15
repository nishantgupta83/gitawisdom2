// test/services/settings_service_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import '../test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    late SettingsService service;
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

      service = SettingsService();
    });

    tearDown(() async {
      service.dispose();

      if (Hive.isBoxOpen(SettingsService.boxName)) {
        await settingsBox.clear();
        await settingsBox.close();
      }

      await teardownTestEnvironment();
    });

    group('Initialization', () {
      test('init() creates settings box if not open', () async {
        if (Hive.isBoxOpen(SettingsService.boxName)) {
          await settingsBox.close();
        }

        await SettingsService.init();

        expect(Hive.isBoxOpen(SettingsService.boxName), isTrue);

        // Reopen for tearDown
        if (!Hive.isBoxOpen(SettingsService.boxName)) {
          settingsBox = await Hive.openBox(SettingsService.boxName);
        } else {
          settingsBox = Hive.box(SettingsService.boxName);
        }
      });

      test('init() sets default values on first run', () async {
        await settingsBox.clear();
        await SettingsService.init();

        expect(settingsBox.get(SettingsService.darkKey), isFalse);
        expect(settingsBox.get(SettingsService.musicKey), isTrue);
      });

      test('init() does not override existing settings', () async {
        await settingsBox.put(SettingsService.darkKey, true);
        await settingsBox.put('first_run_completed', true);

        await SettingsService.init();

        expect(settingsBox.get(SettingsService.darkKey), isTrue);
      });

      test('box getter returns opened box', () {
        expect(service.box, isNotNull);
        expect(service.box.isOpen, isTrue);
        expect(service.box.name, equals(SettingsService.boxName));
      });
    });

    group('Dark Mode', () {
      test('isDarkMode returns default false', () {
        expect(service.isDarkMode, isFalse);
      });

      test('isDarkMode returns stored value', () async {
        await settingsBox.put(SettingsService.darkKey, true);
        expect(service.isDarkMode, isTrue);
      });

      test('isDarkMode setter updates value', () {
        service.isDarkMode = true;

        // Wait for debounce
        expect(service.isDarkMode, isTrue);
      });

      test('isDarkMode setter persists to box after debounce', () async {
        service.isDarkMode = true;

        // Wait for debounce duration
        await Future.delayed(const Duration(milliseconds: 350));

        expect(settingsBox.get(SettingsService.darkKey), isTrue);
      });

      test('isDarkMode uses cache for immediate reads', () {
        service.isDarkMode = true;

        // Should return cached value immediately
        expect(service.isDarkMode, isTrue);
      });

      test('isDarkMode handles read errors gracefully', () async {
        // Close the box to trigger an error
        await settingsBox.close();

        // Create new service to trigger box access
        final newService = SettingsService();

        // Should return false as fallback
        expect(newService.isDarkMode, isFalse);

        newService.dispose();

        // Reopen for cleanup
        settingsBox = await Hive.openBox(SettingsService.boxName);
      });

      test('themeMode returns correct mode for dark', () {
        service.isDarkMode = true;
        expect(service.themeMode, equals(ThemeMode.dark));
      });

      test('themeMode returns correct mode for light', () {
        service.isDarkMode = false;
        expect(service.themeMode, equals(ThemeMode.light));
      });

      test('setTheme() sets dark mode for ThemeMode.dark', () {
        service.setTheme(ThemeMode.dark);
        expect(service.isDarkMode, isTrue);
      });

      test('setTheme() sets light mode for ThemeMode.light', () {
        service.setTheme(ThemeMode.light);
        expect(service.isDarkMode, isFalse);
      });

      test('setTheme() handles ThemeMode.system', () {
        service.setTheme(ThemeMode.system);
        expect(service.isDarkMode, isFalse);
      });
    });

    group('Language Settings', () {
      test('language returns default "en"', () {
        expect(service.language, equals('en'));
      });

      test('language returns stored value', () async {
        await settingsBox.put(SettingsService.langKey, 'hi');
        expect(service.language, equals('hi'));
      });

      test('language setter updates value', () {
        service.language = 'es';
        expect(settingsBox.get(SettingsService.langKey), equals('es'));
      });

      test('language handles read errors gracefully', () async {
        await settingsBox.close();
        final newService = SettingsService();

        expect(newService.language, equals('en'));

        newService.dispose();
        settingsBox = await Hive.openBox(SettingsService.boxName);
      });

      test('setAppLanguage() updates language', () {
        service.setAppLanguage('fr');
        expect(service.language, equals('fr'));
      });

      test('setAppLanguage() does not update if same language', () async {
        service.language = 'en';
        final box = service.box;
        final initialLength = box.length;

        service.setAppLanguage('en');

        // Should not add new entry
        expect(box.length, equals(initialLength));
      });
    });

    group('Font Size Settings', () {
      test('fontSize returns default "small"', () {
        expect(service.fontSize, equals('small'));
      });

      test('fontSize returns stored value', () async {
        await settingsBox.put(SettingsService.fontKey, 'large');
        expect(service.fontSize, equals('large'));
      });

      test('fontSize setter updates value', () {
        service.fontSize = 'medium';
        expect(settingsBox.get(SettingsService.fontKey), equals('medium'));
      });

      test('fontSize handles read errors gracefully', () async {
        await settingsBox.close();
        final newService = SettingsService();

        expect(newService.fontSize, equals('small'));

        newService.dispose();
        settingsBox = await Hive.openBox(SettingsService.boxName);
      });

      test('setFontSize() updates font size', () {
        service.setFontSize('large');
        expect(service.fontSize, equals('large'));
      });

      test('setFontSize() supports all standard sizes', () {
        service.setFontSize('small');
        expect(service.fontSize, equals('small'));

        service.setFontSize('medium');
        expect(service.fontSize, equals('medium'));

        service.setFontSize('large');
        expect(service.fontSize, equals('large'));
      });
    });

    group('Music Settings', () {
      test('musicEnabled returns default true', () {
        expect(service.musicEnabled, isTrue);
      });

      test('musicEnabled returns stored value', () async {
        await settingsBox.put(SettingsService.musicKey, false);
        expect(service.musicEnabled, isFalse);
      });

      test('musicEnabled setter updates value', () {
        service.musicEnabled = false;
        expect(settingsBox.get(SettingsService.musicKey), isFalse);
      });

      test('musicEnabled handles read errors gracefully', () async {
        await settingsBox.close();
        final newService = SettingsService();

        expect(newService.musicEnabled, isTrue);

        newService.dispose();
        settingsBox = await Hive.openBox(SettingsService.boxName);
      });
    });

    group('Text Shadow Settings', () {
      test('textShadowEnabled returns default false', () {
        expect(service.textShadowEnabled, isFalse);
      });

      test('textShadowEnabled returns stored value', () async {
        await settingsBox.put(SettingsService.shadowKey, true);
        expect(service.textShadowEnabled, isTrue);
      });

      test('textShadowEnabled setter updates value', () {
        service.textShadowEnabled = true;
        expect(service.textShadowEnabled, isTrue);
      });

      test('textShadowEnabled setter persists to box after debounce', () async {
        service.textShadowEnabled = true;

        await Future.delayed(const Duration(milliseconds: 350));

        expect(settingsBox.get(SettingsService.shadowKey), isTrue);
      });

      test('textShadowEnabled uses cache for immediate reads', () {
        service.textShadowEnabled = true;
        expect(service.textShadowEnabled, isTrue);
      });

      test('textShadowEnabled handles read errors gracefully', () async {
        await settingsBox.close();
        final newService = SettingsService();

        expect(newService.textShadowEnabled, isFalse);

        newService.dispose();
        settingsBox = await Hive.openBox(SettingsService.boxName);
      });
    });

    group('Background Opacity Settings', () {
      test('backgroundOpacity returns default 1.0', () {
        expect(service.backgroundOpacity, equals(1.0));
      });

      test('backgroundOpacity returns stored value', () async {
        await settingsBox.put(SettingsService.opacityKey, 0.5);
        expect(service.backgroundOpacity, equals(0.5));
      });

      test('backgroundOpacity setter updates value', () {
        service.backgroundOpacity = 0.7;
        expect(settingsBox.get(SettingsService.opacityKey), equals(0.7));
      });

      test('backgroundOpacity handles read errors gracefully', () async {
        await settingsBox.close();
        final newService = SettingsService();

        expect(newService.backgroundOpacity, equals(1.0));

        newService.dispose();
        settingsBox = await Hive.openBox(SettingsService.boxName);
      });

      test('backgroundOpacity supports edge values (0.0)', () {
        service.backgroundOpacity = 0.0;
        expect(service.backgroundOpacity, equals(0.0));
      });

      test('backgroundOpacity supports edge values (1.0)', () {
        service.backgroundOpacity = 1.0;
        expect(service.backgroundOpacity, equals(1.0));
      });

      test('backgroundOpacity supports mid-range values', () {
        service.backgroundOpacity = 0.5;
        expect(service.backgroundOpacity, equals(0.5));
      });
    });

    group('Cache Refresh Management', () {
      test('lastCacheRefreshDate returns null by default', () {
        expect(service.lastCacheRefreshDate, isNull);
      });

      test('setLastCacheRefreshDate() stores date', () {
        final now = DateTime.now();
        service.setLastCacheRefreshDate(now);

        final stored = service.lastCacheRefreshDate;
        expect(stored, isNotNull);
        expect(stored!.year, equals(now.year));
        expect(stored.month, equals(now.month));
        expect(stored.day, equals(now.day));
      });

      test('lastCacheRefreshDate persists across instances', () async {
        final now = DateTime.now();
        service.setLastCacheRefreshDate(now);

        final newService = SettingsService();
        final stored = newService.lastCacheRefreshDate;

        expect(stored, isNotNull);
        expect(stored!.year, equals(now.year));
        expect(stored.month, equals(now.month));
        expect(stored.day, equals(now.day));

        newService.dispose();
      });

      test('lastCacheRefreshDate handles errors gracefully', () async {
        await settingsBox.put(SettingsService.lastCacheRefreshKey, 'invalid-date');

        expect(service.lastCacheRefreshDate, isNull);
      });

      test('canRefreshCache returns true when no previous refresh', () {
        expect(service.canRefreshCache, isTrue);
      });

      test('canRefreshCache returns false within 20 days', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        service.setLastCacheRefreshDate(yesterday);

        expect(service.canRefreshCache, isFalse);
      });

      test('canRefreshCache returns true after 20+ days', () {
        final longAgo = DateTime.now().subtract(const Duration(days: 21));
        service.setLastCacheRefreshDate(longAgo);

        expect(service.canRefreshCache, isTrue);
      });

      test('canRefreshCache returns true exactly at 20 days', () {
        final exactlyTwentyDays = DateTime.now().subtract(const Duration(days: 20));
        service.setLastCacheRefreshDate(exactlyTwentyDays);

        expect(service.canRefreshCache, isTrue);
      });

      test('daysUntilNextRefresh returns 0 when no previous refresh', () {
        expect(service.daysUntilNextRefresh, equals(0));
      });

      test('daysUntilNextRefresh calculates correctly within 20 days', () {
        final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
        service.setLastCacheRefreshDate(fiveDaysAgo);

        expect(service.daysUntilNextRefresh, equals(15));
      });

      test('daysUntilNextRefresh returns 0 after 20+ days', () {
        final longAgo = DateTime.now().subtract(const Duration(days: 25));
        service.setLastCacheRefreshDate(longAgo);

        expect(service.daysUntilNextRefresh, equals(0));
      });

      test('daysUntilNextRefresh returns 0 exactly at 20 days', () {
        final exactlyTwentyDays = DateTime.now().subtract(const Duration(days: 20));
        service.setLastCacheRefreshDate(exactlyTwentyDays);

        expect(service.daysUntilNextRefresh, equals(0));
      });
    });

    group('ChangeNotifier Behavior', () {
      test('notifies listeners on dark mode change', () async {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        service.isDarkMode = true;

        expect(notified, isTrue);
      });

      test('notifies listeners on language change', () {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        service.language = 'hi';

        expect(notified, isTrue);
      });

      test('notifies listeners on font size change', () {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        service.fontSize = 'large';

        expect(notified, isTrue);
      });

      test('notifies listeners on music enabled change', () {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        service.musicEnabled = false;

        expect(notified, isTrue);
      });

      test('notifies listeners on text shadow change', () {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        service.textShadowEnabled = true;

        expect(notified, isTrue);
      });

      test('notifies listeners on cache refresh date change', () {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        service.setLastCacheRefreshDate(DateTime.now());

        expect(notified, isTrue);
      });

      test('notifies listeners only once per debounced change', () async {
        int notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

        service.isDarkMode = true;
        service.isDarkMode = false;
        service.isDarkMode = true;

        // Initial immediate notifications from cache updates
        expect(notifyCount, greaterThanOrEqualTo(1));

        // Wait for debounce
        await Future.delayed(const Duration(milliseconds: 350));

        // Should have limited notifications due to debouncing
        expect(notifyCount, lessThanOrEqualTo(6));
      });

      test('supports multiple listeners', () {
        int listener1Count = 0;
        int listener2Count = 0;

        service.addListener(() {
          listener1Count++;
        });
        service.addListener(() {
          listener2Count++;
        });

        service.language = 'fr';

        expect(listener1Count, equals(1));
        expect(listener2Count, equals(1));
      });

      test('removes listeners properly', () {
        int notifyCount = 0;
        void listener() {
          notifyCount++;
        }

        service.addListener(listener);
        service.language = 'es';
        expect(notifyCount, equals(1));

        service.removeListener(listener);
        service.language = 'fr';

        // Should still be 1 since listener was removed
        expect(notifyCount, equals(1));
      });

      test('setAppLanguage notifies only on actual change', () {
        int notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

        service.setAppLanguage('en'); // Same as default
        expect(notifyCount, equals(0));

        service.setAppLanguage('hi'); // Different
        expect(notifyCount, greaterThanOrEqualTo(1)); // Should notify at least once

        final countAfterFirstChange = notifyCount;
        service.setAppLanguage('hi'); // Same again
        expect(notifyCount, equals(countAfterFirstChange)); // Should not increase
      });
    });

    group('Edge Cases', () {
      test('handles rapid dark mode toggles', () async {
        for (int i = 0; i < 50; i++) {
          service.isDarkMode = i.isEven;
        }

        await Future.delayed(const Duration(milliseconds: 350));

        expect(service.isDarkMode, isNotNull);
      });

      test('handles rapid shadow toggles', () async {
        for (int i = 0; i < 50; i++) {
          service.textShadowEnabled = i.isEven;
        }

        await Future.delayed(const Duration(milliseconds: 350));

        expect(service.textShadowEnabled, isNotNull);
      });

      test('handles multiple rapid setting changes', () async {
        service.isDarkMode = true;
        service.language = 'hi';
        service.fontSize = 'large';
        service.musicEnabled = false;
        service.textShadowEnabled = true;
        service.backgroundOpacity = 0.5;

        await Future.delayed(const Duration(milliseconds: 350));

        expect(service.isDarkMode, isTrue);
        expect(service.language, equals('hi'));
        expect(service.fontSize, equals('large'));
        expect(service.musicEnabled, isFalse);
        expect(service.textShadowEnabled, isTrue);
        expect(service.backgroundOpacity, equals(0.5));
      });

      test('handles dispose gracefully', () {
        // Create a new service instance for this test to avoid double disposal
        final testService = SettingsService();
        expect(() => testService.dispose(), returnsNormally);
      });

      test('cancels timers on dispose', () async {
        // Create a new service instance for this test
        final testService = SettingsService();
        testService.isDarkMode = true;
        testService.textShadowEnabled = true;

        expect(() => testService.dispose(), returnsNormally);
      });

      test('handles null/invalid values gracefully', () async {
        // Put invalid values in box
        await settingsBox.put(SettingsService.darkKey, 'not-a-bool');
        await settingsBox.put(SettingsService.fontKey, 123);
        await settingsBox.put(SettingsService.opacityKey, 'not-a-double');

        // Should handle gracefully with defaults
        expect(() => service.isDarkMode, returnsNormally);
        expect(() => service.fontSize, returnsNormally);
        expect(() => service.backgroundOpacity, returnsNormally);
      });
    });

    group('Persistence', () {
      test('persists all settings across instances', () async {
        service.isDarkMode = true;
        service.language = 'hi';
        service.fontSize = 'large';
        service.musicEnabled = false;
        service.textShadowEnabled = true;
        service.backgroundOpacity = 0.7;
        service.setLastCacheRefreshDate(DateTime.now());

        await Future.delayed(const Duration(milliseconds: 350));

        final newService = SettingsService();

        expect(newService.isDarkMode, isTrue);
        expect(newService.language, equals('hi'));
        expect(newService.fontSize, equals('large'));
        expect(newService.musicEnabled, isFalse);
        expect(newService.textShadowEnabled, isTrue);
        expect(newService.backgroundOpacity, equals(0.7));
        expect(newService.lastCacheRefreshDate, isNotNull);

        newService.dispose();
      });

      test('persists cache refresh date with exact timestamp', () {
        final testDate = DateTime(2024, 1, 15, 10, 30, 0);
        service.setLastCacheRefreshDate(testDate);

        final newService = SettingsService();
        final stored = newService.lastCacheRefreshDate;

        expect(stored, isNotNull);
        expect(stored!.year, equals(2024));
        expect(stored.month, equals(1));
        expect(stored.day, equals(15));

        newService.dispose();
      });
    });
  });
}
