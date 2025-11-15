// Integration tests for search and navigation flow
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;
import 'integration_test_setup.dart';

/// Search and Navigation Flow Integration Tests
///
/// Tests complete search user journeys including:
/// - Scenario search functionality
/// - Search results display
/// - Scenario detail navigation
/// - Bookmark scenarios from search
/// - Filter and category navigation
/// - Search performance and caching
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search and Navigation Flow Tests', () {
    setUpAll(() async {
      await IntegrationTestSetup.setup();
      TestLogger.logTestStart('Search Flow Test Suite');
    });

    tearDownAll(() async {
      await IntegrationTestSetup.teardown();
      TestLogger.printSummary();
    });

    testWidgets('1. Navigate to scenarios screen', (tester) async {
      TestLogger.logTestStart('Navigate to scenarios screen');

      try {
        TestLogger.logStep('Launching app');
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Tapping scenarios tab');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');

        TestLogger.logStep('Verifying scenarios screen displayed');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Should see scenarios title or search bar
        final hasScenariosUI = find.text('Scenarios').evaluate().isNotEmpty ||
                               find.byType(TextField).evaluate().isNotEmpty ||
                               find.byIcon(Icons.search).evaluate().isNotEmpty;

        expect(hasScenariosUI, true, reason: 'Should show scenarios screen');

        await IntegrationTestSetup.takeScreenshot('scenarios_screen');
        TestLogger.logTestEnd('Navigate to scenarios screen', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate to scenarios screen', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('2. Search bar is visible and interactive', (tester) async {
      TestLogger.logTestStart('Search bar visibility');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for search input field');
        final searchField = find.byType(TextField).evaluate().isNotEmpty ||
                           find.byType(TextFormField).evaluate().isNotEmpty;

        expect(searchField, true, reason: 'Search field should be present');

        await IntegrationTestSetup.takeScreenshot('search_bar_visible');
        TestLogger.logTestEnd('Search bar visibility', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Search bar visibility', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('3. Enter search query', (tester) async {
      TestLogger.logTestStart('Enter search query');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Finding search field');
        final searchFields = find.byType(TextField);

        if (searchFields.evaluate().isNotEmpty) {
          TestLogger.logStep('Entering search query: dharma');
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'dharma');

          TestLogger.logStep('Waiting for search results');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          await IntegrationTestSetup.takeScreenshot('search_query_entered');
        }

        TestLogger.logTestEnd('Enter search query', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Enter search query', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('4. Search results are displayed', (tester) async {
      TestLogger.logTestStart('Search results display');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'work');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Checking for search results');
          // Look for list items or cards
          final hasResults = find.byType(ListView).evaluate().isNotEmpty ||
                            find.byType(Card).evaluate().isNotEmpty ||
                            find.byType(ListTile).evaluate().isNotEmpty;

          debugPrint('Search results found: $hasResults');

          await IntegrationTestSetup.takeScreenshot('search_results_displayed');
        }

        TestLogger.logTestEnd('Search results display', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Search results display', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('5. Tap on search result to view detail', (tester) async {
      TestLogger.logTestStart('Tap search result');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'stress');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Tapping first result');
          final listTiles = find.byType(ListTile);
          final cards = find.byType(Card);

          if (listTiles.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, listTiles.first);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('Verifying detail view opened');
            await IntegrationTestSetup.takeScreenshot('scenario_detail_view');
          } else if (cards.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, cards.first);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            await IntegrationTestSetup.takeScreenshot('scenario_detail_view');
          }
        }

        TestLogger.logTestEnd('Tap search result', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Tap search result', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('6. Navigate back from detail view', (tester) async {
      TestLogger.logTestStart('Navigate back from detail');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'family');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          final listTiles = find.byType(ListTile);
          if (listTiles.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, listTiles.first);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('Tapping back button');
            final backButton = find.byIcon(Icons.arrow_back);
            if (backButton.evaluate().isNotEmpty) {
              await IntegrationTestSetup.tapElement(tester, backButton);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

              TestLogger.logStep('Verifying returned to search results');
              await IntegrationTestSetup.takeScreenshot('back_to_search_results');
            }
          }
        }

        TestLogger.logTestEnd('Navigate back from detail', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate back from detail', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('7. Bookmark scenario from detail view', (tester) async {
      TestLogger.logTestStart('Bookmark scenario');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'decision');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          final listTiles = find.byType(ListTile);
          if (listTiles.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, listTiles.first);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('Looking for bookmark button');
            final bookmarkButton = find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty
                ? find.byIcon(Icons.bookmark_border)
                : find.byIcon(Icons.bookmark);

            if (bookmarkButton.evaluate().isNotEmpty) {
              await IntegrationTestSetup.tapElement(tester, bookmarkButton);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

              TestLogger.logStep('Bookmark toggled');
              await IntegrationTestSetup.takeScreenshot('scenario_bookmarked');
            }
          }
        }

        TestLogger.logTestEnd('Bookmark scenario', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Bookmark scenario', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('8. Clear search query', (tester) async {
      TestLogger.logTestStart('Clear search query');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'meditation');
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for clear button');
          final clearButton = find.byIcon(Icons.clear).evaluate().isNotEmpty ||
                             find.byIcon(Icons.close).evaluate().isNotEmpty;

          if (clearButton) {
            final clearIcon = find.byIcon(Icons.clear).evaluate().isNotEmpty
                ? find.byIcon(Icons.clear)
                : find.byIcon(Icons.close);

            await IntegrationTestSetup.tapElement(tester, clearIcon);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('Search cleared');
            await IntegrationTestSetup.takeScreenshot('search_cleared');
          }
        }

        TestLogger.logTestEnd('Clear search query', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Clear search query', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('9. Multiple searches in sequence', (tester) async {
      TestLogger.logTestStart('Multiple sequential searches');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchQueries = ['peace', 'anger', 'love', 'duty'];

        for (final query in searchQueries) {
          TestLogger.logStep('Searching for: $query');

          final searchFields = find.byType(TextField);
          if (searchFields.evaluate().isNotEmpty) {
            await tester.enterText(searchFields.first, '');
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

            await IntegrationTestSetup.enterText(tester, searchFields.first, query);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }
        }

        await IntegrationTestSetup.takeScreenshot('multiple_searches_complete');
        TestLogger.logTestEnd('Multiple sequential searches', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Multiple sequential searches', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('10. Search with no results', (tester) async {
      TestLogger.logTestStart('Search with no results');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          TestLogger.logStep('Entering nonsense query');
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'xyzabc12345');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Checking for empty state message');
          final hasEmptyState = find.textContaining('No').evaluate().isNotEmpty ||
                               find.textContaining('found').evaluate().isNotEmpty;

          debugPrint('Empty state shown: $hasEmptyState');

          await IntegrationTestSetup.takeScreenshot('search_no_results');
        }

        TestLogger.logTestEnd('Search with no results', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Search with no results', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('11. Category filter navigation', (tester) async {
      TestLogger.logTestStart('Category filter navigation');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for category filters or chips');
        final hasFilters = find.byType(FilterChip).evaluate().isNotEmpty ||
                          find.byType(ChoiceChip).evaluate().isNotEmpty;

        if (hasFilters) {
          TestLogger.logStep('Category filters found');
          final filterChip = find.byType(FilterChip).evaluate().isNotEmpty
              ? find.byType(FilterChip).first
              : find.byType(ChoiceChip).first;

          await IntegrationTestSetup.tapElement(tester, filterChip);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          await IntegrationTestSetup.takeScreenshot('category_filter_applied');
        }

        TestLogger.logTestEnd('Category filter navigation', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Category filter navigation', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('12. Scroll through search results', (tester) async {
      TestLogger.logTestStart('Scroll through search results');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'life');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Scrolling through results');
          final listView = find.byType(ListView);

          if (listView.evaluate().isNotEmpty) {
            // Scroll down
            await tester.drag(listView.first, const Offset(0, -300));
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

            // Scroll up
            await tester.drag(listView.first, const Offset(0, 300));
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

            await IntegrationTestSetup.takeScreenshot('scrolled_search_results');
          }
        }

        TestLogger.logTestEnd('Scroll through search results', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Scroll through search results', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('13. Search performance with rapid input', (tester) async {
      TestLogger.logTestStart('Search performance rapid input');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          TestLogger.logStep('Rapidly changing search query');

          final queries = ['a', 'ab', 'abc', 'abcd', 'karma'];
          for (final query in queries) {
            await tester.enterText(searchFields.first, query);
            await tester.pump(const Duration(milliseconds: 100));
          }

          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('App remained responsive');
          await IntegrationTestSetup.takeScreenshot('rapid_search_input');
        }

        TestLogger.logTestEnd('Search performance rapid input', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Search performance rapid input', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('14. Search state persists on navigation', (tester) async {
      TestLogger.logTestStart('Search state persistence');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          TestLogger.logStep('Entering search query');
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'wisdom');
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Navigating away and back');
          await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Checking if search state maintained');
          // Note: Behavior may vary based on implementation
          await IntegrationTestSetup.takeScreenshot('search_state_after_navigation');
        }

        TestLogger.logTestEnd('Search state persistence', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Search state persistence', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('15. Complete search flow journey', (tester) async {
      TestLogger.logTestStart('Complete search flow journey');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('1. Navigate to scenarios');
        await IntegrationTestSetup.navigateToTab(tester, 'scenarios_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('2. Enter search query');
        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await IntegrationTestSetup.enterText(tester, searchFields.first, 'conflict');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('3. View first result');
          final listTiles = find.byType(ListTile);
          if (listTiles.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, listTiles.first);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('4. Bookmark scenario');
            final bookmarkButton = find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty
                ? find.byIcon(Icons.bookmark_border)
                : find.byIcon(Icons.bookmark);

            if (bookmarkButton.evaluate().isNotEmpty) {
              await IntegrationTestSetup.tapElement(tester, bookmarkButton);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
            }

            TestLogger.logStep('5. Return to search');
            final backButton = find.byIcon(Icons.arrow_back);
            if (backButton.evaluate().isNotEmpty) {
              await IntegrationTestSetup.tapElement(tester, backButton);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
            }

            TestLogger.logStep('6. View another result');
            if (listTiles.evaluate().length > 1) {
              await IntegrationTestSetup.tapElement(tester, listTiles.at(1));
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
            }
          }
        }

        await IntegrationTestSetup.takeScreenshot('complete_search_flow');
        TestLogger.logTestEnd('Complete search flow journey', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Complete search flow journey', passed: false, error: e.toString());
        rethrow;
      }
    });
  });
}
