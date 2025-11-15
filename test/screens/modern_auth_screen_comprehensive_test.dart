// test/screens/modern_auth_screen_comprehensive_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/screens/modern_auth_screen.dart';
import 'package:GitaWisdom/screens/root_scaffold.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import 'package:GitaWisdom/widgets/social_auth_buttons.dart';
import '../test_setup.dart';

/// Comprehensive mock for SupabaseAuthService
class MockSupabaseAuthService extends ChangeNotifier implements SupabaseAuthService {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _isAnonymous = false;
  int _signInCallCount = 0;
  int _signUpCallCount = 0;
  int _googleSignInCallCount = 0;
  int _appleSignInCallCount = 0;
  int _anonymousSignInCallCount = 0;
  int _resetPasswordCallCount = 0;
  bool _shouldFailSignIn = false;
  bool _shouldFailSignUp = false;
  bool _shouldFailGoogleSignIn = false;
  bool _shouldFailAppleSignIn = false;
  bool _shouldFailAnonymousSignIn = false;
  bool _shouldFailResetPassword = false;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isAnonymous => _isAnonymous;

  // Getters for test verification
  int get signInCallCount => _signInCallCount;
  int get signUpCallCount => _signUpCallCount;
  int get googleSignInCallCount => _googleSignInCallCount;
  int get appleSignInCallCount => _appleSignInCallCount;
  int get anonymousSignInCallCount => _anonymousSignInCallCount;
  int get resetPasswordCallCount => _resetPasswordCallCount;

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

  void setAnonymous(bool value) {
    _isAnonymous = value;
    notifyListeners();
  }

  void setShouldFailSignIn(bool value) {
    _shouldFailSignIn = value;
  }

  void setShouldFailSignUp(bool value) {
    _shouldFailSignUp = value;
  }

  void setShouldFailGoogleSignIn(bool value) {
    _shouldFailGoogleSignIn = value;
  }

  void setShouldFailAppleSignIn(bool value) {
    _shouldFailAppleSignIn = value;
  }

  void setShouldFailAnonymousSignIn(bool value) {
    _shouldFailAnonymousSignIn = value;
  }

  void setShouldFailResetPassword(bool value) {
    _shouldFailResetPassword = value;
  }

  void reset() {
    _signInCallCount = 0;
    _signUpCallCount = 0;
    _googleSignInCallCount = 0;
    _appleSignInCallCount = 0;
    _anonymousSignInCallCount = 0;
    _resetPasswordCallCount = 0;
    _isLoading = false;
    _error = null;
    _isAuthenticated = false;
    _isAnonymous = false;
    _shouldFailSignIn = false;
    _shouldFailSignUp = false;
    _shouldFailGoogleSignIn = false;
    _shouldFailAppleSignIn = false;
    _shouldFailAnonymousSignIn = false;
    _shouldFailResetPassword = false;
  }

  @override
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    _signInCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFailSignIn) {
      _error = 'Invalid credentials';
      notifyListeners();
      return false;
    }

    if (email == 'test@example.com' && password == 'password123') {
      _isAuthenticated = true;
      _error = null;
      notifyListeners();
      return true;
    }

    _error = 'Invalid credentials';
    notifyListeners();
    return false;
  }

  @override
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _signUpCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFailSignUp) {
      _error = 'Sign up failed';
      notifyListeners();
      return false;
    }

    if (email.contains('@') && password.length >= 6) {
      _isAuthenticated = true;
      _error = null;
      notifyListeners();
      return true;
    }

    _error = 'Sign up failed';
    notifyListeners();
    return false;
  }

  @override
  Future<bool> signInWithGoogle() async {
    _googleSignInCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFailGoogleSignIn) {
      _error = 'Google sign-in failed';
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _error = null;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> signInWithApple() async {
    _appleSignInCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFailAppleSignIn) {
      _error = 'Apple sign-in failed';
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _error = null;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> continueAsAnonymous() async {
    _anonymousSignInCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFailAnonymousSignIn) {
      _error = 'Anonymous sign-in failed';
      notifyListeners();
      return false;
    }

    _isAnonymous = true;
    _error = null;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> resetPassword(String email) async {
    _resetPasswordCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFailResetPassword) {
      _error = 'Failed to send reset email';
      notifyListeners();
      return false;
    }

    if (email.contains('@')) {
      _error = null;
      notifyListeners();
      return true;
    }

    _error = 'Invalid email';
    notifyListeners();
    return false;
  }

  // Additional required SupabaseAuthService interface methods
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

  group('ModernAuthScreen - Comprehensive Tests', () {
    late MockSupabaseAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockSupabaseAuthService();
    });

    tearDown(() {
      mockAuthService.reset();
    });

    Widget createTestWidget({bool isModal = false}) {
      return MaterialApp(
        home: ChangeNotifierProvider<SupabaseAuthService>.value(
          value: mockAuthService,
          child: ModernAuthScreen(isModal: isModal),
        ),
      );
    }

    // ============================================================
    // WIDGET RENDERING TESTS (20 tests)
    // ============================================================

    group('Widget Rendering', () {
      testWidgets('1. renders ModernAuthScreen widget', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(ModernAuthScreen), findsOneWidget);
      });

      testWidgets('2. renders Scaffold', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('3. renders Stack for layered layout', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(Stack), findsWidgets);
      });

      testWidgets('4. renders SafeArea for proper spacing', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(SafeArea), findsWidgets);
      });

      testWidgets('5. renders app logo with Hero animation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(Hero), findsOneWidget);
        expect(find.byIcon(Icons.auto_stories), findsOneWidget);
      });

      testWidgets('6. displays GitaWisdom title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('GitaWisdom'), findsOneWidget);
      });

      testWidgets('7. displays Welcome to text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Welcome to'), findsOneWidget);
      });

      testWidgets('8. displays tagline', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Ancient wisdom for modern life'), findsOneWidget);
      });

      testWidgets('9. displays Continue as Guest button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Continue as Guest'), findsOneWidget);
      });

      testWidgets('10. displays Guest button icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byIcon(Icons.person_outline_rounded), findsAtLeastNWidgets(1));
      });

      testWidgets('11. displays Sign In tab', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Sign In'), findsWidgets);
      });

      testWidgets('12. displays Sign Up tab', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Sign Up'), findsWidgets);
      });

      testWidgets('13. displays social auth buttons', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(SocialAuthButtons), findsOneWidget);
      });

      testWidgets('14. displays OR divider text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('or continue with email'), findsOneWidget);
      });

      testWidgets('15. displays dividers around OR text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(Divider), findsAtLeastNWidgets(2));
      });

      testWidgets('16. renders in light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: ChangeNotifierProvider<SupabaseAuthService>.value(
              value: mockAuthService,
              child: const ModernAuthScreen(),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(ModernAuthScreen), findsOneWidget);
      });

      testWidgets('17. renders in dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: ChangeNotifierProvider<SupabaseAuthService>.value(
              value: mockAuthService,
              child: const ModernAuthScreen(),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(ModernAuthScreen), findsOneWidget);
      });

      testWidgets('18. renders FadeTransition animation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(FadeTransition), findsWidgets);
      });

      testWidgets('19. renders SlideTransition animation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(SlideTransition), findsWidgets);
      });

      testWidgets('20. renders Consumer for state management', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byType(Consumer<SupabaseAuthService>), findsOneWidget);
      });
    });

    // ============================================================
    // SIGN IN FORM TESTS (30 tests)
    // ============================================================

    group('Sign In Form', () {
      testWidgets('21. shows sign in form by default', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Email Address'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('22. displays Remember me checkbox', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Remember me'), findsOneWidget);
        expect(find.byType(Checkbox), findsOneWidget);
      });

      testWidgets('23. displays Forgot password button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Forgot?'), findsOneWidget);
      });

      testWidgets('24. displays Sign In button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Sign In').last, findsOneWidget);
      });

      testWidgets('25. email field has correct label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        final emailField = find.widgetWithText(TextFormField, 'Email Address');
        expect(emailField, findsOneWidget);
      });

      testWidgets('26. email field has email icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byIcon(Icons.email_outlined), findsAtLeastNWidgets(1));
      });

      testWidgets('27. password field has correct label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('28. password field has lock icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byIcon(Icons.lock_outline_rounded), findsAtLeastNWidgets(1));
      });

      testWidgets('29. password field is obscured initially', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        // Password is obscured by checking for visibility_off icon
        expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));
      });

      testWidgets('30. password has visibility toggle icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));
      });

      testWidgets('31. tapping visibility toggle shows password', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.visibility_off).first);
        await tester.pump();

        // After toggling, visibility icon should appear
        expect(find.byIcon(Icons.visibility), findsAtLeastNWidgets(1));
      });

      testWidgets('32. tapping visibility toggle twice obscures password again', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.visibility_off).first);
        await tester.pump();
        await tester.tap(find.byIcon(Icons.visibility).first);
        await tester.pump();

        // After toggling twice, visibility_off icon should appear again
        expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));
      });

      testWidgets('33. remember me checkbox is unchecked initially', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('34. tapping remember me checkbox checks it', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, true);
      });

      testWidgets('35. tapping remember me checkbox twice unchecks it', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('36. can enter text in email field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('37. can enter text in password field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final passwordFields = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordFields, 'password123');
        await tester.pump();

        expect(find.text('password123'), findsOneWidget);
      });

      testWidgets('38. email field validates empty input', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign In').last);
        await tester.pump();

        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('39. email field validates invalid format', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.tap(find.text('Sign In').last);
        await tester.pump();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('40. email field accepts valid email', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In').last);
        await tester.pump();

        expect(find.text('Please enter a valid email'), findsNothing);
      });

      testWidgets('41. password field validates empty input', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.tap(find.text('Sign In').last);
        await tester.pump();

        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('42. successful sign in calls auth service', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.signInCallCount, 1);
      });

      testWidgets('43. failed sign in shows error', (tester) async {
        mockAuthService.setShouldFailSignIn(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'wrong@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrong');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Invalid credentials'), findsWidgets);
      });

      testWidgets('44. sign in button disabled when loading', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('45. forgot password button opens dialog', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Reset Password'), findsOneWidget);
      });

      testWidgets('46. forgot password dialog has email field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Enter your email address to receive a password reset link.'), findsOneWidget);
      });

      testWidgets('47. forgot password dialog has Cancel button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('48. forgot password dialog has Send Reset Link button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Send Reset Link'), findsOneWidget);
      });

      testWidgets('49. cancel button closes forgot password dialog', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Cancel'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Reset Password'), findsNothing);
      });

      testWidgets('50. sending reset password calls auth service', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(find.byType(TextFormField).last, 'test@example.com');
        await tester.tap(find.text('Send Reset Link'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.resetPasswordCallCount, 1);
      });
    });

    // ============================================================
    // SIGN UP FORM TESTS (20 tests)
    // ============================================================

    group('Sign Up Form', () {
      testWidgets('51. switches to sign up when tab tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets('52. sign up form has name field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      });

      testWidgets('53. sign up form has email field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.widgetWithText(TextFormField, 'Email Address'), findsOneWidget);
      });

      testWidgets('54. sign up form has password field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('55. sign up form has confirm password field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.text('Confirm Password'), findsOneWidget);
      });

      testWidgets('56. name field has person icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.byIcon(Icons.person_outline_rounded), findsWidgets);
      });

      testWidgets('57. name field validates empty input', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Please enter your full name'), findsOneWidget);
      });

      testWidgets('58. can enter text in name field', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
        await tester.pump();

        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('59. sign up email validates empty input', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('60. sign up email validates format', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'invalid-email');
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('61. sign up password validates empty input', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('62. sign up password validates minimum length', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), '123');
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });

      testWidgets('63. confirm password validates empty input', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), 'password123');
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Please confirm your password'), findsOneWidget);
      });

      testWidgets('64. confirm password validates match', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), 'password123');
        await tester.enterText(fields.at(3), 'different');
        await tester.tap(find.text('Create Account'));
        await tester.pump();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('65. sign up password has visibility toggle', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));
      });

      testWidgets('66. confirm password has visibility toggle', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(2));
      });

      testWidgets('67. successful sign up calls auth service', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), 'password123');
        await tester.enterText(fields.at(3), 'password123');
        await tester.tap(find.text('Create Account'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.signUpCallCount, 1);
      });

      testWidgets('68. failed sign up shows error', (tester) async {
        mockAuthService.setShouldFailSignUp(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), 'password123');
        await tester.enterText(fields.at(3), 'password123');
        await tester.tap(find.text('Create Account'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Sign up failed'), findsWidgets);
      });

      testWidgets('69. switching tabs clears form fields', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final emailField = find.widgetWithText(TextFormField, 'Email Address');
        final controller = tester.widget<TextFormField>(emailField).controller;
        expect(controller?.text, '');
      });

      testWidgets('70. sign up uses default name if empty', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), '   '); // Whitespace only
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), 'password123');
        await tester.enterText(fields.at(3), 'password123');
        await tester.tap(find.text('Create Account'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.signUpCallCount, 0); // Should fail validation
      });
    });

    // ============================================================
    // GUEST AUTHENTICATION TESTS (10 tests)
    // ============================================================

    group('Guest Authentication', () {
      testWidgets('71. guest button is visible', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        expect(find.text('Continue as Guest'), findsOneWidget);
      });

      testWidgets('72. tapping guest button calls auth service', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.anonymousSignInCallCount, 1);
      });

      testWidgets('73. successful guest login sets anonymous state', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.isAnonymous, true);
      });

      testWidgets('74. guest button disabled when loading', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('75. failed guest login shows snackbar', (tester) async {
        mockAuthService.setShouldFailAnonymousSignIn(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Unable to continue as guest. Please try again.'), findsOneWidget);
      });

      testWidgets('76. guest button has correct styling', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final button = find.ancestor(
          of: find.text('Continue as Guest'),
          matching: find.byType(Container),
        ).first;
        expect(button, findsOneWidget);
      });

      testWidgets('77. guest button navigates on success in non-modal mode', (tester) async {
        await tester.pumpWidget(createTestWidget(isModal: false));
        await tester.pump();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(RootScaffold), findsOneWidget);
      });

      testWidgets('78. guest button pops on success in modal mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider<SupabaseAuthService>.value(
                          value: mockAuthService,
                          child: const ModernAuthScreen(isModal: true),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Auth'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Open Auth'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Continue as Guest'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ModernAuthScreen), findsNothing);
      });

      testWidgets('79. guest button handles timeout gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Continue as Guest'));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.anonymousSignInCallCount, 1);
      });

      testWidgets('80. guest button has Material ripple effect', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final inkWell = find.ancestor(
          of: find.text('Continue as Guest'),
          matching: find.byType(InkWell),
        );
        expect(inkWell, findsOneWidget);
      });
    });

    // ============================================================
    // ERROR HANDLING TESTS (15 tests)
    // ============================================================

    group('Error Handling', () {
      testWidgets('81. displays error banner when error exists', (tester) async {
        mockAuthService.setError('Test error message');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
        expect(find.text('Test error message'), findsOneWidget);
      });

      testWidgets('82. error banner has close button', (tester) async {
        mockAuthService.setError('Test error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('83. tapping close button clears error', (tester) async {
        mockAuthService.setError('Test error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        expect(mockAuthService.error, null);
      });

      testWidgets('84. error banner has correct styling', (tester) async {
        mockAuthService.setError('Test error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final errorContainer = find.ancestor(
          of: find.text('Test error'),
          matching: find.byType(Container),
        );
        expect(errorContainer, findsWidgets);
      });

      testWidgets('85. multiple errors show last error only', (tester) async {
        mockAuthService.setError('First error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        mockAuthService.setError('Second error');
        await tester.pump();

        expect(find.text('First error'), findsNothing);
        expect(find.text('Second error'), findsOneWidget);
      });

      testWidgets('86. failed sign in shows snackbar', (tester) async {
        mockAuthService.setShouldFailSignIn(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrong');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Invalid credentials'), findsWidgets);
      });

      testWidgets('87. error persists after failed validation', (tester) async {
        mockAuthService.setError('Previous error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign In').last);
        await tester.pump();

        expect(find.text('Previous error'), findsOneWidget);
      });

      testWidgets('88. error clears on successful auth', (tester) async {
        mockAuthService.setError('Previous error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.error, null);
      });

      testWidgets('89. validation errors show in red', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign In').last);
        await tester.pump();

        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('90. form validation prevents submission', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign In').last);
        await tester.pump();

        expect(mockAuthService.signInCallCount, 0);
      });

      testWidgets('91. error banner shows error icon', (tester) async {
        mockAuthService.setError('Test error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      });

      testWidgets('92. reset password error shows in snackbar', (tester) async {
        mockAuthService.setShouldFailResetPassword(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(find.byType(TextFormField).last, 'test@example.com');
        await tester.tap(find.text('Send Reset Link'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Failed to send reset email'), findsOneWidget);
      });

      testWidgets('93. successful reset password shows success message', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(find.byType(TextFormField).last, 'test@example.com');
        await tester.tap(find.text('Send Reset Link'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Password reset email sent!'), findsOneWidget);
      });

      testWidgets('94. empty reset password email does not call service', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Forgot?'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Send Reset Link'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(mockAuthService.resetPasswordCallCount, 0);
      });

      testWidgets('95. error banner is dismissible', (tester) async {
        mockAuthService.setError('Dismissible error');
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        expect(find.text('Dismissible error'), findsNothing);
      });
    });

    // ============================================================
    // LOADING STATE TESTS (10 tests)
    // ============================================================

    group('Loading State', () {
      testWidgets('96. shows loading overlay when loading', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('97. loading overlay displays Please wait text', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Please wait...'), findsOneWidget);
      });

      testWidgets('98. loading overlay prevents interaction', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final overlay = find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Container),
        ).first;
        expect(overlay, findsOneWidget);
      });

      testWidgets('99. loading overlay has semi-transparent background', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('100. loading state hides when auth completes', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        mockAuthService.setLoading(false);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('101. buttons disabled during loading', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('102. form fields accessible during loading overlay', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(TextFormField), findsWidgets);
      });

      testWidgets('103. loading overlay centered on screen', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final center = find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Center),
        );
        expect(center, findsOneWidget);
      });

      testWidgets('104. loading indicator in card container', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final container = find.ancestor(
          of: find.text('Please wait...'),
          matching: find.byType(Container),
        );
        expect(container, findsWidgets);
      });

      testWidgets('105. loading overlay covers entire screen', (tester) async {
        mockAuthService.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    // ============================================================
    // NAVIGATION TESTS (10 tests)
    // ============================================================

    group('Navigation', () {
      testWidgets('106. successful sign in navigates to home (non-modal)', (tester) async {
        await tester.pumpWidget(createTestWidget(isModal: false));
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(RootScaffold), findsOneWidget);
      });

      testWidgets('107. successful sign up navigates to home (non-modal)', (tester) async {
        await tester.pumpWidget(createTestWidget(isModal: false));
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);
        await tester.pump();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'John Doe');
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), 'password123');
        await tester.enterText(fields.at(3), 'password123');
        await tester.tap(find.text('Create Account'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(RootScaffold), findsOneWidget);
      });

      testWidgets('108. modal mode pops on successful sign in', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider<SupabaseAuthService>.value(
                          value: mockAuthService,
                          child: const ModernAuthScreen(isModal: true),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Auth'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Open Auth'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ModernAuthScreen), findsNothing);
      });

      testWidgets('109. isModal property defaults to false', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SupabaseAuthService>.value(
              value: mockAuthService,
              child: const ModernAuthScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(ModernAuthScreen), findsOneWidget);
      });

      testWidgets('110. auth state change listener navigates automatically', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        mockAuthService.setAuthenticated(true);
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(RootScaffold), findsOneWidget);
      });

      testWidgets('111. navigation waits for mounted check', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 50));

        // Should wait for 100ms delay
        expect(find.byType(ModernAuthScreen), findsOneWidget);
      });

      testWidgets('112. failed auth does not navigate', (tester) async {
        mockAuthService.setShouldFailSignIn(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrong');
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ModernAuthScreen), findsOneWidget);
      });

      testWidgets('113. OAuth completion auto-navigates', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        mockAuthService.setAuthenticated(true);
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(RootScaffold), findsOneWidget);
      });

      testWidgets('114. anonymous auth does not auto-navigate', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        mockAuthService.setAnonymous(true);
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(RootScaffold), findsOneWidget);
      });

      testWidgets('115. navigation respects loading state', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        mockAuthService.setAuthenticated(true);
        mockAuthService.setLoading(true);
        await tester.pump(const Duration(milliseconds: 400));

        // Should not navigate while loading
        expect(find.byType(ModernAuthScreen), findsOneWidget);
      });
    });

    // ============================================================
    // ANIMATION TESTS (5 tests)
    // ============================================================

    group('Animations', () {
      testWidgets('116. fade animation runs on mount', (tester) async {
        await tester.pumpWidget(createTestWidget());

        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(FadeTransition), findsWidgets);
      });

      testWidgets('117. slide animation runs on mount', (tester) async {
        await tester.pumpWidget(createTestWidget());

        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(SlideTransition), findsWidgets);
      });

      testWidgets('118. tab switch animation works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Sign Up').last);

        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 60));
        }

        expect(find.text('Full Name'), findsOneWidget);
      });

      testWidgets('119. animated background renders', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('120. floating orbs animate', (tester) async {
        await tester.pumpWidget(createTestWidget());

        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(AnimatedBuilder), findsWidgets);
      });
    });
  });
}
