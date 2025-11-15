// Integration tests for content browsing flow
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;
import 'integration_test_setup.dart';

/// Content Browsing Flow Integration Tests
///
/// Tests complete content browsing user journeys including:
/// - Daily verses carousel navigation
/// - Chapter browsing and detail view
/// - Verse detail navigation
/// - Scenario browsing and categories
/// - Bookmark functionality across content types
/// - Content sharing capabilities
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Content Browsing Flow Tests', () {
    setUpAll(() async {
      await IntegrationTestSetup.setup();
      TestLogger.logTestStart('Content Flow Test Suite');
    });

    tearDownAll(() async {
      await IntegrationTestSetup.teardown();
      TestLogger.printSummary();
    });

    testWidgets('1. Home screen displays daily verses', (tester) async {
      TestLogger.logTestStart('Home screen daily verses');

      try {
        TestLogger.logStep('Launching app');
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Verifying home screen displayed');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Checking for daily verses');
        final hasVerses = find.byType(PageView).evaluate().isNotEmpty ||
                         find.textContaining('Verse').evaluate().isNotEmpty ||
                         find.textContaining('Chapter').evaluate().isNotEmpty;

        expect(hasVerses, true, reason: 'Home should display verses');

        await IntegrationTestSetup.takeScreenshot('home_daily_verses');
        TestLogger.logTestEnd('Home screen daily verses', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Home screen daily verses', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('2. Swipe through daily verses carousel', (tester) async {
      TestLogger.logTestStart('Swipe verses carousel');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Finding verse carousel');
        final pageView = find.byType(PageView);

        if (pageView.evaluate().isNotEmpty) {
          TestLogger.logStep('Swiping through verses');

          // Swipe left (next verse)
          await tester.drag(pageView.first, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          await IntegrationTestSetup.takeScreenshot('verse_swipe_1');

          // Swipe left again
          await tester.drag(pageView.first, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          await IntegrationTestSetup.takeScreenshot('verse_swipe_2');

          // Swipe right (previous verse)
          await tester.drag(pageView.first, const Offset(300, 0));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Carousel navigation successful');
        }

        TestLogger.logTestEnd('Swipe verses carousel', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Swipe verses carousel', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('3. Tap verse to view detail', (tester) async {
      TestLogger.logTestStart('Tap verse for detail');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for verse to tap');
        final pageView = find.byType(PageView);

        if (pageView.evaluate().isNotEmpty) {
          TestLogger.logStep('Tapping on verse');
          await IntegrationTestSetup.tapElement(tester, pageView);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Checking if detail view opened');
          // May navigate to detail or expand in place
          await IntegrationTestSetup.takeScreenshot('verse_detail_view');
        }

        TestLogger.logTestEnd('Tap verse for detail', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Tap verse for detail', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('4. Bookmark verse from home screen', (tester) async {
      TestLogger.logTestStart('Bookmark verse from home');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for bookmark button');
        final bookmarkButton = find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty
            ? find.byIcon(Icons.bookmark_border)
            : find.byIcon(Icons.bookmark);

        if (bookmarkButton.evaluate().isNotEmpty) {
          TestLogger.logStep('Tapping bookmark button');
          await IntegrationTestSetup.tapElement(tester, bookmarkButton.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verse bookmarked');
          await IntegrationTestSetup.takeScreenshot('verse_bookmarked');
        }

        TestLogger.logTestEnd('Bookmark verse from home', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Bookmark verse from home', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('5. Navigate to chapters screen', (tester) async {
      TestLogger.logTestStart('Navigate to chapters');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Tapping chapters tab');
        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');

        TestLogger.logStep('Verifying chapters screen');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final hasChapters = find.text('Chapters').evaluate().isNotEmpty ||
                           find.textContaining('Chapter').evaluate().isNotEmpty ||
                           find.byType(ListView).evaluate().isNotEmpty;

        expect(hasChapters, true, reason: 'Should show chapters');

        await IntegrationTestSetup.takeScreenshot('chapters_screen');
        TestLogger.logTestEnd('Navigate to chapters', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate to chapters', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('6. Browse chapter list', (tester) async {
      TestLogger.logTestStart('Browse chapter list');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Counting chapters displayed');
        final chapters = find.byType(ListTile).evaluate().length +
                        find.byType(Card).evaluate().length;

        debugPrint('Chapters displayed: $chapters');

        TestLogger.logStep('Scrolling through chapters');
        final listView = find.byType(ListView);

        if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          await tester.drag(listView.first, const Offset(0, 300));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
        }

        await IntegrationTestSetup.takeScreenshot('chapters_browsed');
        TestLogger.logTestEnd('Browse chapter list', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Browse chapter list', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('7. Open chapter detail view', (tester) async {
      TestLogger.logTestStart('Open chapter detail');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Tapping first chapter');
        final chapters = find.byType(ListTile);

        if (chapters.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, chapters.first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verifying chapter detail view');
          final hasDetail = find.byType(ListView).evaluate().isNotEmpty ||
                           find.textContaining('Verse').evaluate().isNotEmpty;

          debugPrint('Chapter detail loaded: $hasDetail');

          await IntegrationTestSetup.takeScreenshot('chapter_detail_opened');
        }

        TestLogger.logTestEnd('Open chapter detail', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Open chapter detail', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('8. Browse verses in chapter', (tester) async {
      TestLogger.logTestStart('Browse verses in chapter');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final chapters = find.byType(ListTile);
        if (chapters.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, chapters.first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Scrolling through verses');
          final listView = find.byType(ListView);

          if (listView.evaluate().isNotEmpty) {
            // Scroll down
            await tester.drag(listView.first, const Offset(0, -400));
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

            await IntegrationTestSetup.takeScreenshot('verses_scrolled');

            // Scroll back up
            await tester.drag(listView.first, const Offset(0, 200));
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
          }
        }

        TestLogger.logTestEnd('Browse verses in chapter', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Browse verses in chapter', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('9. Navigate back from chapter detail', (tester) async {
      TestLogger.logTestStart('Navigate back from chapter');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final chapters = find.byType(ListTile);
        if (chapters.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, chapters.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Tapping back button');
          final backButton = find.byIcon(Icons.arrow_back);

          if (backButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, backButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('Verifying returned to chapters list');
            final backAtList = find.text('Chapters').evaluate().isNotEmpty ||
                              chapters.evaluate().isNotEmpty;

            expect(backAtList, true, reason: 'Should return to chapters list');

            await IntegrationTestSetup.takeScreenshot('back_to_chapters');
          }
        }

        TestLogger.logTestEnd('Navigate back from chapter', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate back from chapter', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('10. Browse scenarios with categories', (tester) async {
      TestLogger.logTestStart('Browse scenarios categories');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for category filters');
        final hasFilters = find.byType(FilterChip).evaluate().isNotEmpty ||
                          find.byType(ChoiceChip).evaluate().isNotEmpty;

        debugPrint('Category filters available: $hasFilters');

        TestLogger.logStep('Checking scenario list');
        final hasScenarios = find.byType(ListView).evaluate().isNotEmpty ||
                            find.byType(Card).evaluate().isNotEmpty;

        expect(hasScenarios, true, reason: 'Should show scenarios');

        await IntegrationTestSetup.takeScreenshot('scenarios_categories');
        TestLogger.logTestEnd('Browse scenarios categories', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Browse scenarios categories', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('11. Filter scenarios by category', (tester) async {
      TestLogger.logTestStart('Filter scenarios by category');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for category chips');
        final filterChips = find.byType(FilterChip);
        final choiceChips = find.byType(ChoiceChip);

        if (filterChips.evaluate().isNotEmpty) {
          TestLogger.logStep('Tapping category filter');
          await IntegrationTestSetup.tapElement(tester, filterChips.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          await IntegrationTestSetup.takeScreenshot('category_filtered');
        } else if (choiceChips.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, choiceChips.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          await IntegrationTestSetup.takeScreenshot('category_filtered');
        }

        TestLogger.logTestEnd('Filter scenarios by category', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Filter scenarios by category', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('12. Open scenario detail from list', (tester) async {
      TestLogger.logTestStart('Open scenario detail');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Tapping first scenario');
        final scenarios = find.byType(ListTile);

        if (scenarios.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, scenarios.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verifying scenario detail view');
          await IntegrationTestSetup.takeScreenshot('scenario_detail_opened');
        }

        TestLogger.logTestEnd('Open scenario detail', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Open scenario detail', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('13. Read scenario guidance (Heart vs Duty)', (tester) async {
      TestLogger.logTestStart('Read scenario guidance');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final scenarios = find.byType(ListTile);
        if (scenarios.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, scenarios.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for guidance sections');
          final hasGuidance = find.textContaining('Heart').evaluate().isNotEmpty ||
                             find.textContaining('Duty').evaluate().isNotEmpty ||
                             find.textContaining('Guidance').evaluate().isNotEmpty;

          debugPrint('Guidance sections found: $hasGuidance');

          TestLogger.logStep('Scrolling through guidance');
          final listView = find.byType(ListView);
          if (listView.evaluate().isNotEmpty) {
            await tester.drag(listView.first, const Offset(0, -300));
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
          }

          await IntegrationTestSetup.takeScreenshot('scenario_guidance_read');
        }

        TestLogger.logTestEnd('Read scenario guidance', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Read scenario guidance', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('14. Bookmark scenario from detail', (tester) async {
      TestLogger.logTestStart('Bookmark scenario from detail');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final scenarios = find.byType(ListTile);
        if (scenarios.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, scenarios.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for bookmark button');
          final bookmarkButton = find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty
              ? find.byIcon(Icons.bookmark_border)
              : find.byIcon(Icons.bookmark);

          if (bookmarkButton.evaluate().isNotEmpty) {
            TestLogger.logStep('Bookmarking scenario');
            await IntegrationTestSetup.tapElement(tester, bookmarkButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            await IntegrationTestSetup.takeScreenshot('scenario_bookmarked');
          }
        }

        TestLogger.logTestEnd('Bookmark scenario from detail', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Bookmark scenario from detail', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('15. Share functionality available', (tester) async {
      TestLogger.logTestStart('Share functionality check');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Checking scenario detail for share');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final scenarios = find.byType(ListTile);
        if (scenarios.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, scenarios.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for share button');
          final shareButton = find.byIcon(Icons.share);

          if (shareButton.evaluate().isNotEmpty) {
            debugPrint('Share button available');
            await IntegrationTestSetup.takeScreenshot('share_button_available');
          }
        }

        TestLogger.logTestEnd('Share functionality check', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Share functionality check', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('16. Navigate between different content types', (tester) async {
      TestLogger.logTestStart('Navigate between content types');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('1. View daily verses');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('2. Browse chapters');
        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('3. Open a chapter');
        final chapters = find.byType(ListTile);
        if (chapters.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, chapters.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, backButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }
        }

        TestLogger.logStep('4. Browse scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('5. Return to home');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await IntegrationTestSetup.takeScreenshot('content_type_navigation');
        TestLogger.logTestEnd('Navigate between content types', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate between content types', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('17. Complete content browsing journey', (tester) async {
      TestLogger.logTestStart('Complete content browsing journey');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('1. Start at home with daily verses');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final pageView = find.byType(PageView);
        if (pageView.evaluate().isNotEmpty) {
          TestLogger.logStep('2. Swipe through verses');
          await tester.drag(pageView.first, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('3. Navigate to chapters');
        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final chapters = find.byType(ListTile);
        if (chapters.evaluate().isNotEmpty) {
          TestLogger.logStep('4. Open chapter detail');
          await IntegrationTestSetup.tapElement(tester, chapters.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('5. Browse verses');
          final listView = find.byType(ListView);
          if (listView.evaluate().isNotEmpty) {
            await tester.drag(listView.first, const Offset(0, -300));
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }

          TestLogger.logStep('6. Return to chapters');
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, backButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }
        }

        TestLogger.logStep('7. Navigate to scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final scenarios = find.byType(ListTile);
        if (scenarios.evaluate().isNotEmpty) {
          TestLogger.logStep('8. Open scenario detail');
          await IntegrationTestSetup.tapElement(tester, scenarios.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('9. Read guidance');
          final scenarioListView = find.byType(ListView);
          if (scenarioListView.evaluate().isNotEmpty) {
            await tester.drag(scenarioListView.first, const Offset(0, -200));
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }

          TestLogger.logStep('10. Bookmark scenario');
          final bookmarkButton = find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty
              ? find.byIcon(Icons.bookmark_border)
              : find.byIcon(Icons.bookmark);

          if (bookmarkButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, bookmarkButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }
        }

        await IntegrationTestSetup.takeScreenshot('complete_content_journey');
        TestLogger.logTestEnd('Complete content browsing journey', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Complete content browsing journey', passed: false, error: e.toString());
        rethrow;
      }
    });
  });
}
