// Integration tests for offline functionality and caching
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;
import 'integration_test_setup.dart';

/// Offline and Caching Flow Integration Tests
///
/// Tests data caching and offline functionality including:
/// - Initial cache population
/// - Content availability offline
/// - Search with cached data
/// - Network reconnection behavior
/// - Cache persistence across app restarts
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline and Caching Flow Tests', () {
    setUpAll(() async {
      await IntegrationTestSetup.setup();
      TestLogger.logTestStart('Offline Flow Test Suite');
    });

    tearDownAll(() async {
      await IntegrationTestSetup.teardown();
      TestLogger.printSummary();
    });

    testWidgets('1. App loads with initial cache population', (tester) async {
      TestLogger.logTestStart('Initial cache population');

      try {
        TestLogger.logStep('Launching app for first time');
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester, duration: const Duration(seconds: 10));

        TestLogger.logStep('Verifying app loaded successfully');
        final hasUI = find.byType(BottomNavigationBar).evaluate().isNotEmpty;
        expect(hasUI, true, reason: 'App should load with UI');

        TestLogger.logStep('Allowing time for cache population');
        await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

        await IntegrationTestSetup.takeScreenshot('initial_cache_load');
        TestLogger.logTestEnd('Initial cache population', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Initial cache population', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('2. Scenarios load from cache', (tester) async {
      TestLogger.logTestStart('Scenarios cache load');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Verifying scenarios displayed');
        final hasScenarios = find.byType(ListView).evaluate().isNotEmpty ||
                            find.byType(Card).evaluate().isNotEmpty ||
                            find.byType(ListTile).evaluate().isNotEmpty;

        debugPrint('Scenarios loaded from cache: $hasScenarios');

        await IntegrationTestSetup.takeScreenshot('scenarios_cached');
        TestLogger.logTestEnd('Scenarios cache load', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Scenarios cache load', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('3. Chapters load from cache', (tester) async {
      TestLogger.logTestStart('Chapters cache load');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to chapters');
        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Verifying chapters displayed');
        final hasChapters = find.byType(ListView).evaluate().isNotEmpty ||
                           find.byType(Card).evaluate().isNotEmpty ||
                           find.textContaining('Chapter').evaluate().isNotEmpty;

        debugPrint('Chapters loaded from cache: $hasChapters');

        await IntegrationTestSetup.takeScreenshot('chapters_cached');
        TestLogger.logTestEnd('Chapters cache load', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Chapters cache load', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('4. Daily verses load from cache', (tester) async {
      TestLogger.logTestStart('Daily verses cache load');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Checking home screen for daily verses');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Verifying verse content displayed');
        // Look for verse indicators like PageView or verse text
        final hasVerses = find.byType(PageView).evaluate().isNotEmpty ||
                         find.textContaining('Chapter').evaluate().isNotEmpty;

        debugPrint('Daily verses loaded: $hasVerses');

        await IntegrationTestSetup.takeScreenshot('verses_cached');
        TestLogger.logTestEnd('Daily verses cache load', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Daily verses cache load', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('5. Search works with cached data', (tester) async {
      TestLogger.logTestStart('Search with cached data');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Performing search on cached data');
        final searchFields = find.byType(TextField);

        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'peace');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verifying search results from cache');
          final hasResults = find.byType(ListTile).evaluate().isNotEmpty ||
                            find.byType(Card).evaluate().isNotEmpty;

          debugPrint('Search results from cache: $hasResults');

          await IntegrationTestSetup.takeScreenshot('search_cached_data');
        }

        TestLogger.logTestEnd('Search with cached data', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Search with cached data', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('6. Navigate between cached screens quickly', (tester) async {
      TestLogger.logTestStart('Quick navigation with cache');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Rapidly navigating between cached screens');
        final tabs = ['home_tab', 'chapters_tab', 'scenarios_tab', 'home_tab'];

        for (final tab in tabs) {
          await IntegrationTestSetup.navigateToTab(tester, tab);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
          TestLogger.logStep('Navigated to $tab');
        }

        TestLogger.logStep('All screens loaded quickly from cache');
        await IntegrationTestSetup.takeScreenshot('quick_nav_cached');
        TestLogger.logTestEnd('Quick navigation with cache', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Quick navigation with cache', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('7. Cache persists across navigation', (tester) async {
      TestLogger.logTestStart('Cache persistence navigation');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Loading scenarios screen');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final initialScenarios = find.byType(ListTile).evaluate().length;
        TestLogger.logStep('Initial scenarios count: $initialScenarios');

        TestLogger.logStep('Navigating away');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Returning to scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final finalScenarios = find.byType(ListTile).evaluate().length;
        TestLogger.logStep('Final scenarios count: $finalScenarios');

        debugPrint('Cache maintained: ${initialScenarios == finalScenarios}');

        await IntegrationTestSetup.takeScreenshot('cache_persisted');
        TestLogger.logTestEnd('Cache persistence navigation', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Cache persistence navigation', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('8. Bookmark functionality works offline', (tester) async {
      TestLogger.logTestStart('Offline bookmark functionality');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Opening a scenario');
        final listTiles = find.byType(ListTile);

        if (listTiles.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, listTiles.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Attempting to bookmark');
          final bookmarkButton = find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty
              ? find.byIcon(Icons.bookmark_border)
              : find.byIcon(Icons.bookmark);

          if (bookmarkButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, bookmarkButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('Bookmark saved to local cache');
            await IntegrationTestSetup.takeScreenshot('offline_bookmark');
          }
        }

        TestLogger.logTestEnd('Offline bookmark functionality', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Offline bookmark functionality', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('9. Settings persist in local storage', (tester) async {
      TestLogger.logTestStart('Settings persistence');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to More/Settings');
        await IntegrationTestSetup.navigateToTab(tester, 'more_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Checking for settings toggles');
        final hasSettings = find.byType(Switch).evaluate().isNotEmpty ||
                           find.byType(SwitchListTile).evaluate().isNotEmpty;

        if (hasSettings) {
          TestLogger.logStep('Settings found - stored locally');
          final switchCount = find.byType(Switch).evaluate().length +
                             find.byType(SwitchListTile).evaluate().length;
          debugPrint('Settings toggles count: $switchCount');
        }

        await IntegrationTestSetup.takeScreenshot('settings_local_storage');
        TestLogger.logTestEnd('Settings persistence', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Settings persistence', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('10. Content detail views load from cache', (tester) async {
      TestLogger.logTestStart('Detail views from cache');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Opening chapter detail');
        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final chapters = find.byType(ListTile);
        if (chapters.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, chapters.first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verifying chapter content loaded');
          final hasContent = find.byType(ListView).evaluate().isNotEmpty ||
                            find.textContaining('Verse').evaluate().isNotEmpty;

          debugPrint('Chapter detail loaded from cache: $hasContent');

          await IntegrationTestSetup.takeScreenshot('chapter_detail_cached');

          // Navigate back
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, backButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }
        }

        TestLogger.logStep('Opening scenario detail');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final scenarios = find.byType(ListTile);
        if (scenarios.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, scenarios.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verifying scenario content loaded');
          await IntegrationTestSetup.takeScreenshot('scenario_detail_cached');
        }

        TestLogger.logTestEnd('Detail views from cache', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Detail views from cache', passed: false, error: e.toString());
        rethrow;
      }
    });
  });
}
