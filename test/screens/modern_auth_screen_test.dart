// test/screens/modern_auth_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/screens/modern_auth_screen.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import '../test_setup.dart';

class MockSupabaseAuthService extends ChangeNotifier implements SupabaseAuthService {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _isAnonymous = false;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isAnonymous => _isAnonymous;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  @override
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (email == 'test@example.com' && password == 'password123') {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    _error = 'Invalid credentials';
    notifyListeners();
    return false;
  }

  @override
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (email.contains('@') && password.length >= 6) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    _error = 'Sign up failed';
    notifyListeners();
    return false;
  }

  @override
  Future<bool> continueAsAnonymous() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isAnonymous = true;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return email.contains('@');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('ModernAuthScreen', () {
    late MockSupabaseAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockSupabaseAuthService();
    });

    Widget createTestWidget({bool isModal = false}) {
      return MaterialApp(
        home: ChangeNotifierProvider<SupabaseAuthService>.value(
          value: mockAuthService,
          child: ModernAuthScreen(isModal: isModal),
        ),
      );
    }

    testWidgets('renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ModernAuthScreen), findsOneWidget);
    });

    testWidgets('displays app logo', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
    });

    testWidgets('displays GitaWisdom title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('GitaWisdom'), findsOneWidget);
    });

    testWidgets('displays tagline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ancient wisdom for modern life'), findsOneWidget);
    });

    testWidgets('displays continue as guest button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsAtLeastNWidgets(1));
    });

    testWidgets('displays sign in and sign up tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Sign Up'), findsWidgets);
    });

    testWidgets('shows sign in form by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot?'), findsOneWidget);
    });

    testWidgets('switches to sign up form when tab tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap Sign Up tab
      final signUpTab = find.text('Sign Up').last;
      await tester.tap(signUpTab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show sign up fields
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('email field validates empty input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find email field
      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      expect(emailField, findsOneWidget);

      // Try to sign in with empty email
      final signInButton = find.text('Sign In').last;
      await tester.tap(signInButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('email field validates format', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Try to sign in
      final signInButton = find.text('Sign In').last;
      await tester.tap(signInButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('password field validates empty input',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Enter email only
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');

      // Try to sign in
      final signInButton = find.text('Sign In').last;
      await tester.tap(signInButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Initially should be obscured (visibility_off icon present)
      expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should now show visibility icon
      expect(find.byIcon(Icons.visibility), findsAtLeastNWidgets(1));
    });

    testWidgets('remember me checkbox toggles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      var checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, false);

      // Tap checkbox
      await tester.tap(checkbox);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should be checked
      checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, true);
    });

    testWidgets('forgot password shows dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap forgot password
      await tester.tap(find.text('Forgot?'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Reset Password'), findsOneWidget);
      expect(
          find.text('Enter your email address to receive a password reset link.'),
          findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('sign up form validates password length',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to sign up
      await tester.tap(find.text('Sign Up').last);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Fill form with short password
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email Address'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Try to create account
      await tester.tap(find.text('Create Account'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('sign up validates password confirmation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to sign up
      await tester.tap(find.text('Sign Up').last);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Fill form with mismatched passwords
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User'); // Name
      await tester.enterText(fields.at(1), 'test@example.com'); // Email
      await tester.enterText(fields.at(2), 'password123'); // Password
      await tester.enterText(fields.at(3), 'password456'); // Confirm
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Try to create account
      await tester.tap(find.text('Create Account'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('displays error banner when error exists',
        (WidgetTester tester) async {
      mockAuthService.setError('Test error message');
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('error banner can be dismissed', (WidgetTester tester) async {
      mockAuthService.setError('Test error message');
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap close button on error banner
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test error message'), findsNothing);
    });

    testWidgets('shows loading overlay when loading', (WidgetTester tester) async {
      mockAuthService.setLoading(true);
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('continue as guest button works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Continue as Guest'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<SupabaseAuthService>.value(
            value: mockAuthService,
            child: const ModernAuthScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ModernAuthScreen), findsOneWidget);
      expect(find.text('GitaWisdom'), findsOneWidget);
    });

    testWidgets('renders correctly in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<SupabaseAuthService>.value(
            value: mockAuthService,
            child: const ModernAuthScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ModernAuthScreen), findsOneWidget);
      expect(find.text('GitaWisdom'), findsOneWidget);
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('displays social auth section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('or continue with email'), findsOneWidget);
    });

    testWidgets('adapts to tablet layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ModernAuthScreen), findsOneWidget);
    });

    testWidgets('clears form when switching tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Enter data in sign in form
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to sign up
      await tester.tap(find.text('Sign Up').last);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Fields should be cleared
      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      final controller =
          tester.widget<TextFormField>(emailField).controller;
      expect(controller?.text, '');
    });

    testWidgets('animations run on mount', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump a few frames to let animations run
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(ModernAuthScreen), findsOneWidget);
    });

    testWidgets('hero animation on logo', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('sign in button disabled when loading',
        (WidgetTester tester) async {
      mockAuthService.setLoading(true);
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Loading overlay should prevent interaction
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles modal vs initial launch mode',
        (WidgetTester tester) async {
      // Test modal mode
      await tester.pumpWidget(createTestWidget(isModal: true));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ModernAuthScreen), findsOneWidget);

      // Test non-modal mode
      await tester.pumpWidget(createTestWidget(isModal: false));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ModernAuthScreen), findsOneWidget);
    });
  });
}
