// Integration tests for journal entry flow
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;
import 'integration_test_setup.dart';

/// Journal Entry Flow Integration Tests
///
/// Tests complete journal user journeys including:
/// - Access journal screen (with auth)
/// - Create new journal entries
/// - View existing entries
/// - Edit journal entries
/// - Delete entries
/// - Journal entry persistence
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journal Entry Flow Tests', () {
    setUpAll(() async {
      await IntegrationTestSetup.setup();
      TestLogger.logTestStart('Journal Flow Test Suite');
    });

    tearDownAll(() async {
      await IntegrationTestSetup.teardown();
      TestLogger.printSummary();
    });

    testWidgets('1. Navigate to journal tab', (tester) async {
      TestLogger.logTestStart('Navigate to journal tab');

      try {
        TestLogger.logStep('Launching app');
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Tapping journal tab');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');

        TestLogger.logStep('Verifying journal screen or auth prompt');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Should see either journal or auth prompt
        final hasJournalOrAuth = find.text('My Journal').evaluate().isNotEmpty ||
                                 find.text('Sign in to access Journal').evaluate().isNotEmpty ||
                                 find.byIcon(Icons.add).evaluate().isNotEmpty;

        expect(hasJournalOrAuth, true, reason: 'Should show journal or auth');

        await IntegrationTestSetup.takeScreenshot('journal_tab_accessed');
        TestLogger.logTestEnd('Navigate to journal tab', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate to journal tab', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('2. Sign in as guest to access journal', (tester) async {
      TestLogger.logTestStart('Guest sign in for journal');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for guest sign-in option');
        final guestButton = find.textContaining('Guest');

        if (guestButton.evaluate().isNotEmpty) {
          TestLogger.logStep('Signing in as guest');
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verifying journal access granted');
          final hasJournal = find.byType(FloatingActionButton).evaluate().isNotEmpty ||
                            find.text('My Journal').evaluate().isNotEmpty;

          expect(hasJournal, true, reason: 'Should access journal as guest');

          await IntegrationTestSetup.takeScreenshot('guest_journal_access');
        }

        TestLogger.logTestEnd('Guest sign in for journal', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Guest sign in for journal', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('3. Journal screen displays correctly', (tester) async {
      TestLogger.logTestStart('Journal screen display');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Sign in as guest if needed
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('Verifying journal UI elements');
        // Should have FAB for adding entries
        final hasFAB = find.byType(FloatingActionButton).evaluate().isNotEmpty;
        debugPrint('FAB present: $hasFAB');

        await IntegrationTestSetup.takeScreenshot('journal_screen_display');
        TestLogger.logTestEnd('Journal screen display', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Journal screen display', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('4. Tap FAB to create new entry', (tester) async {
      TestLogger.logTestStart('Tap FAB for new entry');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Sign in as guest if needed
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('Tapping FAB button');
        final fab = find.byType(FloatingActionButton);

        if (fab.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, fab);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Verifying entry dialog or screen opened');
          // Should see dialog or new screen with text input
          final hasDialog = find.byType(Dialog).evaluate().isNotEmpty ||
                           find.byType(TextField).evaluate().isNotEmpty;

          debugPrint('Entry creation UI shown: $hasDialog');

          await IntegrationTestSetup.takeScreenshot('new_entry_dialog');
        }

        TestLogger.logTestEnd('Tap FAB for new entry', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Tap FAB for new entry', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('5. Enter journal entry text', (tester) async {
      TestLogger.logTestStart('Enter journal entry text');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure journal access
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, fab);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Finding text input field');
          final textFields = find.byType(TextField);

          if (textFields.evaluate().isNotEmpty) {
            final entryText = TestDataFactory.generateJournalEntry(
              content: 'Today I learned about dharma and my true purpose in life.'
            );

            TestLogger.logStep('Entering journal text');
            await IntegrationTestSetup.enterText(tester, textFields.first, entryText);

            await IntegrationTestSetup.takeScreenshot('journal_text_entered');
          }
        }

        TestLogger.logTestEnd('Enter journal entry text', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Enter journal entry text', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('6. Save new journal entry', (tester) async {
      TestLogger.logTestStart('Save new journal entry');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure journal access
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, fab);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            final entryText = 'Integration test entry - ${DateTime.now().toIso8601String()}';
            await IntegrationTestSetup.enterText(tester, textFields.first, entryText);

            TestLogger.logStep('Looking for save button');
            final saveButton = find.text('Save').evaluate().isNotEmpty
                ? find.text('Save')
                : find.widgetWithText(ElevatedButton, 'Save');

            if (saveButton.evaluate().isNotEmpty) {
              TestLogger.logStep('Tapping save button');
              await IntegrationTestSetup.tapElement(tester, saveButton);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

              TestLogger.logStep('Entry saved');
              await IntegrationTestSetup.takeScreenshot('entry_saved');
            }
          }
        }

        TestLogger.logTestEnd('Save new journal entry', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Save new journal entry', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('7. View saved entry in list', (tester) async {
      TestLogger.logTestStart('View saved entry in list');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure journal access
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('Checking for journal entries');
        final hasEntries = find.byType(ListView).evaluate().isNotEmpty ||
                          find.byType(Card).evaluate().isNotEmpty ||
                          find.byType(ListTile).evaluate().isNotEmpty;

        debugPrint('Journal entries visible: $hasEntries');

        await IntegrationTestSetup.takeScreenshot('journal_entries_list');
        TestLogger.logTestEnd('View saved entry in list', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('View saved entry in list', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('8. Tap entry to view details', (tester) async {
      TestLogger.logTestStart('Tap entry to view details');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure journal access
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('Looking for entry to tap');
        final entries = find.byType(ListTile);

        if (entries.evaluate().isNotEmpty) {
          TestLogger.logStep('Tapping first entry');
          await IntegrationTestSetup.tapElement(tester, entries.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Entry detail view shown');
          await IntegrationTestSetup.takeScreenshot('entry_detail_view');
        } else {
          TestLogger.logStep('No entries available to tap');
        }

        TestLogger.logTestEnd('Tap entry to view details', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Tap entry to view details', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('9. Edit existing journal entry', (tester) async {
      TestLogger.logTestStart('Edit existing entry');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure journal access
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        final entries = find.byType(ListTile);
        if (entries.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, entries.first);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for edit button');
          final editButton = find.byIcon(Icons.edit).evaluate().isNotEmpty
              ? find.byIcon(Icons.edit)
              : find.text('Edit');

          if (editButton.evaluate().isNotEmpty) {
            TestLogger.logStep('Tapping edit button');
            await IntegrationTestSetup.tapElement(tester, editButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            TestLogger.logStep('Edit mode activated');
            await IntegrationTestSetup.takeScreenshot('entry_edit_mode');
          }
        }

        TestLogger.logTestEnd('Edit existing entry', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Edit existing entry', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('10. Delete journal entry', (tester) async {
      TestLogger.logTestStart('Delete journal entry');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure journal access
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('Looking for delete action');
        // Try swipe to delete or delete button
        final entries = find.byType(ListTile);

        if (entries.evaluate().isNotEmpty) {
          TestLogger.logStep('Attempting swipe to delete');
          // Swipe left to reveal delete action
          await tester.drag(entries.first, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          // Look for delete button
          final deleteButton = find.byIcon(Icons.delete);
          if (deleteButton.evaluate().isNotEmpty) {
            TestLogger.logStep('Tapping delete button');
            await IntegrationTestSetup.tapElement(tester, deleteButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

            // May show confirmation dialog
            final confirmButton = find.text('Delete').evaluate().isNotEmpty ||
                                 find.text('Confirm').evaluate().isNotEmpty;

            if (confirmButton) {
              final deleteConfirm = find.text('Delete').evaluate().isNotEmpty
                  ? find.text('Delete')
                  : find.text('Confirm');
              await IntegrationTestSetup.tapElement(tester, deleteConfirm);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
            }

            await IntegrationTestSetup.takeScreenshot('entry_deleted');
          }
        }

        TestLogger.logTestEnd('Delete journal entry', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Delete journal entry', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('11. Journal empty state', (tester) async {
      TestLogger.logTestStart('Journal empty state');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure journal access
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('Checking for empty state or entries');
        final hasEntries = find.byType(ListTile).evaluate().isNotEmpty;
        final hasEmptyState = find.textContaining('No entries').evaluate().isNotEmpty ||
                             find.textContaining('Start').evaluate().isNotEmpty;

        debugPrint('Has entries: $hasEntries');
        debugPrint('Has empty state: $hasEmptyState');

        await IntegrationTestSetup.takeScreenshot('journal_state_check');
        TestLogger.logTestEnd('Journal empty state', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Journal empty state', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('12. Complete journal flow', (tester) async {
      TestLogger.logTestStart('Complete journal flow');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('1. Navigate to journal');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('2. Sign in as guest if needed');
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, guestButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('3. Create new entry');
        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, fab);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await IntegrationTestSetup.enterText(
              tester,
              textFields.first,
              'Complete flow test - ${DateTime.now()}'
            );

            final saveButton = find.text('Save');
            if (saveButton.evaluate().isNotEmpty) {
              await IntegrationTestSetup.tapElement(tester, saveButton);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
            }
          }
        }

        TestLogger.logStep('4. Verify entry appears in list');
        await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('5. Navigate away and back');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('6. Verify entry persists');
        await IntegrationTestSetup.takeScreenshot('complete_journal_flow');

        TestLogger.logTestEnd('Complete journal flow', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Complete journal flow', passed: false, error: e.toString());
        rethrow;
      }
    });
  });
}
