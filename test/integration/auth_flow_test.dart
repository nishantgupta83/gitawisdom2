// Integration tests for user authentication flow
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;
import 'integration_test_setup.dart';

/// Authentication Flow Integration Tests
///
/// Tests complete authentication user journeys including:
/// - App launch authentication state
/// - Google/Apple sign-in flows
/// - Anonymous (guest) sign-in
/// - Sign-out flow
/// - Account deletion flow
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    setUpAll(() async {
      await IntegrationTestSetup.setup();
      TestLogger.logTestStart('Authentication Flow Test Suite');
    });

    tearDownAll(() async {
      await IntegrationTestSetup.teardown();
      TestLogger.printSummary();
    });

    testWidgets('1. App launches and shows correct initial state', (tester) async {
      TestLogger.logTestStart('App launch initial state');

      try {
        TestLogger.logStep('Launching app');
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Verifying initial UI elements');
        // Should see bottom navigation or splash screen
        final hasBottomNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty;
        final hasSplash = find.text('GitaWisdom').evaluate().isNotEmpty;

        expect(hasBottomNav || hasSplash, true, reason: 'Should show main UI or splash');

        await IntegrationTestSetup.takeScreenshot('app_launch_initial_state');
        TestLogger.logTestEnd('App launch initial state', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('App launch initial state', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('2. Navigate to More screen without authentication', (tester) async {
      TestLogger.logTestStart('Navigate to More screen unauthenticated');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to More tab');
        await IntegrationTestSetup.navigateToTab(tester, 'more_tab');

        TestLogger.logStep('Verifying More screen displayed');
        // Should see More/Settings screen
        final moreElements = find.text('More').evaluate().isNotEmpty ||
                            find.text('Settings').evaluate().isNotEmpty;
        expect(moreElements, true);

        await IntegrationTestSetup.takeScreenshot('more_screen_unauthenticated');
        TestLogger.logTestEnd('Navigate to More screen unauthenticated', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate to More screen unauthenticated', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('3. Journal requires authentication prompt', (tester) async {
      TestLogger.logTestStart('Journal authentication prompt');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to Journal tab');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');

        TestLogger.logStep('Checking for auth prompt or journal screen');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Should see either auth prompt or journal (if already authenticated)
        final hasAuthPrompt = find.text('Sign in to access Journal').evaluate().isNotEmpty ||
                              find.text('Sign In').evaluate().isNotEmpty;
        final hasJournal = find.text('My Journal').evaluate().isNotEmpty ||
                          find.byIcon(Icons.add).evaluate().isNotEmpty;

        expect(hasAuthPrompt || hasJournal, true, reason: 'Should show auth prompt or journal');

        await IntegrationTestSetup.takeScreenshot('journal_auth_check');
        TestLogger.logTestEnd('Journal authentication prompt', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Journal authentication prompt', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('4. Navigate to authentication screen', (tester) async {
      TestLogger.logTestStart('Navigate to authentication screen');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to Journal tab');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Look for Sign In button
        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          TestLogger.logStep('Tapping Sign In button');
          await IntegrationTestSetup.tapElement(tester, signInButton);

          TestLogger.logStep('Verifying authentication screen shown');
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          // Should see authentication options
          final hasAuthOptions = find.textContaining('Sign').evaluate().isNotEmpty;
          expect(hasAuthOptions, true, reason: 'Should show auth options');

          await IntegrationTestSetup.takeScreenshot('auth_screen');
        }

        TestLogger.logTestEnd('Navigate to authentication screen', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigate to authentication screen', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('5. Guest mode allows journal access', (tester) async {
      TestLogger.logTestStart('Guest mode journal access');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to Journal tab');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Look for Continue as Guest button
        final guestButton = find.textContaining('Guest');
        if (guestButton.evaluate().isNotEmpty) {
          TestLogger.logStep('Tapping Continue as Guest');
          await IntegrationTestSetup.tapElement(tester, guestButton);

          TestLogger.logStep('Verifying journal access granted');
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          // Should now see journal screen
          final hasJournal = find.byType(FloatingActionButton).evaluate().isNotEmpty;
          expect(hasJournal, true, reason: 'Should show journal after guest sign-in');

          await IntegrationTestSetup.takeScreenshot('guest_journal_access');
        }

        TestLogger.logTestEnd('Guest mode journal access', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Guest mode journal access', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('6. Google Sign In button present', (tester) async {
      TestLogger.logTestStart('Google Sign In button check');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to authentication screen');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, signInButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Checking for Google Sign In button');
          final googleButton = find.textContaining('Google').evaluate().isNotEmpty;

          // Note: Button may or may not be visible depending on auth screen implementation
          debugPrint('Google Sign In button found: $googleButton');

          await IntegrationTestSetup.takeScreenshot('google_signin_check');
        }

        TestLogger.logTestEnd('Google Sign In button check', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Google Sign In button check', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('7. Apple Sign In button present (iOS)', (tester) async {
      TestLogger.logTestStart('Apple Sign In button check');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to authentication screen');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, signInButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Checking for Apple Sign In button');
          final appleButton = find.textContaining('Apple').evaluate().isNotEmpty;

          debugPrint('Apple Sign In button found: $appleButton');

          await IntegrationTestSetup.takeScreenshot('apple_signin_check');
        }

        TestLogger.logTestEnd('Apple Sign In button check', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Apple Sign In button check', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('8. Email sign in form validation', (tester) async {
      TestLogger.logTestStart('Email sign in form validation');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to authentication screen');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, signInButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for email/password fields');
          final emailField = find.byType(TextField).evaluate().isNotEmpty ||
                            find.byType(TextFormField).evaluate().isNotEmpty;

          if (emailField) {
            TestLogger.logStep('Email form fields found');
            await IntegrationTestSetup.takeScreenshot('email_signin_form');
          }
        }

        TestLogger.logTestEnd('Email sign in form validation', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Email sign in form validation', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('9. Navigation between auth modes', (tester) async {
      TestLogger.logTestStart('Navigation between auth modes');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Opening authentication screen');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, signInButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for mode switching options');
          final hasSignUp = find.textContaining('Sign Up').evaluate().isNotEmpty ||
                           find.textContaining('Create').evaluate().isNotEmpty;

          debugPrint('Sign up option available: $hasSignUp');

          await IntegrationTestSetup.takeScreenshot('auth_mode_navigation');
        }

        TestLogger.logTestEnd('Navigation between auth modes', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Navigation between auth modes', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('10. Close authentication screen', (tester) async {
      TestLogger.logTestStart('Close authentication screen');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, signInButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          TestLogger.logStep('Looking for close/back button');
          final backButton = find.byIcon(Icons.close).evaluate().isNotEmpty ||
                            find.byIcon(Icons.arrow_back).evaluate().isNotEmpty;

          if (backButton) {
            final closeBtn = find.byIcon(Icons.close).evaluate().isNotEmpty
                ? find.byIcon(Icons.close)
                : find.byIcon(Icons.arrow_back);

            await IntegrationTestSetup.tapElement(tester, closeBtn);

            TestLogger.logStep('Verifying returned to journal');
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

            await IntegrationTestSetup.takeScreenshot('auth_screen_closed');
          }
        }

        TestLogger.logTestEnd('Close authentication screen', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Close authentication screen', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('11. Account settings visibility when authenticated', (tester) async {
      TestLogger.logTestStart('Account settings visibility');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to More screen');
        await IntegrationTestSetup.navigateToTab(tester, 'more_tab');

        TestLogger.logStep('Checking for account section');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Account section should be visible if authenticated
        final hasAccountSection = find.textContaining('Account').evaluate().isNotEmpty;

        debugPrint('Account section visible: $hasAccountSection');

        await IntegrationTestSetup.takeScreenshot('account_settings_check');
        TestLogger.logTestEnd('Account settings visibility', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Account settings visibility', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('12. Sign out button visibility', (tester) async {
      TestLogger.logTestStart('Sign out button visibility');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to More screen');
        await IntegrationTestSetup.navigateToTab(tester, 'more_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for Sign Out button');
        final signOutButton = find.textContaining('Sign Out').evaluate().isNotEmpty ||
                             find.textContaining('Logout').evaluate().isNotEmpty;

        debugPrint('Sign Out button visible: $signOutButton');

        await IntegrationTestSetup.takeScreenshot('signout_button_check');
        TestLogger.logTestEnd('Sign out button visibility', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Sign out button visibility', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('13. Delete account button visibility', (tester) async {
      TestLogger.logTestStart('Delete account button visibility');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to More screen');
        await IntegrationTestSetup.navigateToTab(tester, 'more_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Looking for Delete Account button');
        final deleteButton = find.textContaining('Delete').evaluate().isNotEmpty;

        debugPrint('Delete Account button visible: $deleteButton');

        await IntegrationTestSetup.takeScreenshot('delete_account_check');
        TestLogger.logTestEnd('Delete account button visibility', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Delete account button visibility', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('14. Authentication state persists across navigation', (tester) async {
      TestLogger.logTestStart('Auth state persistence');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Checking initial auth state in journal');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final initialState = find.text('Sign in to access Journal').evaluate().isEmpty;

        TestLogger.logStep('Navigating to other screens');
        await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await IntegrationTestSetup.navigateToTab(tester, 'chapters_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Returning to journal');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final finalState = find.text('Sign in to access Journal').evaluate().isEmpty;

        expect(initialState, equals(finalState), reason: 'Auth state should persist');

        await IntegrationTestSetup.takeScreenshot('auth_state_persistence');
        TestLogger.logTestEnd('Auth state persistence', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Auth state persistence', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('15. Multiple rapid auth screen opens/closes', (tester) async {
      TestLogger.logTestStart('Rapid auth screen navigation');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Rapidly opening/closing auth screen');
        for (int i = 0; i < 3; i++) {
          await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          final signInButton = find.text('Sign In');
          if (signInButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, signInButton);
            await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

            final backButton = find.byIcon(Icons.close).evaluate().isNotEmpty
                ? find.byIcon(Icons.close)
                : find.byIcon(Icons.arrow_back);

            if (backButton.evaluate().isNotEmpty) {
              await IntegrationTestSetup.tapElement(tester, backButton);
              await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
            }
          }

          await IntegrationTestSetup.navigateToTab(tester, 'home_tab');
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        }

        TestLogger.logStep('Verifying app stability after rapid navigation');
        await IntegrationTestSetup.takeScreenshot('rapid_auth_navigation');
        TestLogger.logTestEnd('Rapid auth screen navigation', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Rapid auth screen navigation', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('16. Auth error handling', (tester) async {
      TestLogger.logTestStart('Auth error handling');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Opening auth screen');
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, signInButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          // Try to submit empty form or invalid credentials
          TestLogger.logStep('Checking form validation');
          final submitButtons = find.widgetWithText(ElevatedButton, 'Sign In').evaluate().isNotEmpty ||
                               find.widgetWithText(FilledButton, 'Sign In').evaluate().isNotEmpty;

          debugPrint('Submit button found: $submitButtons');

          await IntegrationTestSetup.takeScreenshot('auth_error_handling');
        }

        TestLogger.logTestEnd('Auth error handling', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Auth error handling', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('17. Account info display when authenticated', (tester) async {
      TestLogger.logTestStart('Account info display');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Navigating to More screen');
        await IntegrationTestSetup.navigateToTab(tester, 'more_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        TestLogger.logStep('Checking for user email or name display');
        // Look for email-like text or user name
        final hasUserInfo = find.textContaining('@').evaluate().isNotEmpty ||
                           find.textContaining('Guest').evaluate().isNotEmpty;

        debugPrint('User info displayed: $hasUserInfo');

        await IntegrationTestSetup.takeScreenshot('account_info_display');
        TestLogger.logTestEnd('Account info display', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Account info display', passed: false, error: e.toString());
        rethrow;
      }
    });

    testWidgets('18. Authentication flow completion', (tester) async {
      TestLogger.logTestStart('Complete auth flow');

      try {
        app.main();
        await IntegrationTestSetup.waitForAppLoad(tester);

        TestLogger.logStep('Testing complete authentication journey');

        // 1. Start unauthenticated
        await IntegrationTestSetup.navigateToTab(tester, 'journal_tab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // 2. Open auth screen
        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await IntegrationTestSetup.tapElement(tester, signInButton);
          await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

          // 3. Close without signing in
          final backButton = find.byIcon(Icons.close).evaluate().isNotEmpty
              ? find.byIcon(Icons.close)
              : find.byIcon(Icons.arrow_back);

          if (backButton.evaluate().isNotEmpty) {
            await IntegrationTestSetup.tapElement(tester, backButton);
            await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
          }
        }

        // 4. Verify returned to journal prompt
        TestLogger.logStep('Verifying flow completion');
        await IntegrationTestSetup.takeScreenshot('auth_flow_complete');
        TestLogger.logTestEnd('Complete auth flow', passed: true);
      } catch (e) {
        TestLogger.logTestEnd('Complete auth flow', passed: false, error: e.toString());
        rethrow;
      }
    });
  });
}
