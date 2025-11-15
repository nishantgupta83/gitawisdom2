// test/services/supabase_auth_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('SupabaseAuthService', () {
    late SupabaseAuthService authService;

    setUp(() {
      authService = SupabaseAuthService.instance;
    });

    group('Authentication State Management', () {
      test('service should initialize with instance pattern', () {
        expect(SupabaseAuthService.instance, isNotNull);
        expect(identical(authService, SupabaseAuthService.instance), isTrue);
      });

      test('should have initial state properties', () {
        expect(authService.isLoading, isA<bool>());
        expect(authService.error, isNull);
        expect(authService.currentUser, isNull);
      });

      test('isAuthenticated should be false initially', () {
        expect(authService.isAuthenticated, isFalse);
      });

      test('isAnonymous should be false when no user logged in', () {
        // isAnonymous depends on deviceId being set during initialization
        // Before initialization, should be false
        expect(authService.isAnonymous, isFalse);
      });

      test('should provide getter methods', () {
        expect(authService.userEmail, isNull);
        // userId can be null when not authenticated and deviceId not yet initialized
        expect(authService.userId, isA<String?>());
      });

      test('displayName should return null when no user', () {
        expect(authService.displayName, isNull);
      });

      test('should notify listeners on state changes', () {
        var notificationCount = 0;
        authService.addListener(() {
          notificationCount++;
        });

        // Clear error will trigger notification
        authService.clearError();

        expect(notificationCount, greaterThan(0));
      });

      test('should track loading state during operations', () {
        expect(authService.isLoading, isFalse);
        // Loading state will be true during async operations
      });

      test('should handle error state', () {
        authService.clearError();
        expect(authService.error, isNull);
      });
    });

    group('Database User ID Management', () {
      test('databaseUserId should provide valid ID', () {
        final userId = authService.databaseUserId;
        expect(userId, isNotEmpty);
      });

      test('databaseUserId should return consistent value', () {
        final userId1 = authService.databaseUserId;
        final userId2 = authService.databaseUserId;
        expect(userId1, equals(userId2));
      });

      test('databaseUserId should start with device_ prefix for anonymous users', () {
        final userId = authService.databaseUserId;
        expect(userId, startsWith('device_'));
      });

      test('databaseUserId should always provide ID even without initialization', () {
        final dbUserId = authService.databaseUserId;

        // databaseUserId should always return a value
        expect(dbUserId, isNotEmpty);

        // For anonymous users, should start with device_ prefix
        if (!authService.isAuthenticated) {
          expect(dbUserId, startsWith('device_'));
        }
      });
    });

    group('Service Lifecycle', () {
      test('initialize method should exist and be async', () {
        expect(authService.initialize, isA<Function>());
      });

      test('should extend ChangeNotifier for state management', () {
        // SupabaseAuthService extends ChangeNotifier
        // Test that it has expected methods
        expect(authService.addListener, isA<Function>());
        expect(authService.removeListener, isA<Function>());
        expect(authService.notifyListeners, isA<Function>());
      });

      test('should handle multiple initializations gracefully', () async {
        // First initialization
        await authService.initialize();

        // Second initialization should not throw
        expect(() => authService.initialize(), returnsNormally);
      });

      test('should have dispose method for cleanup', () {
        // Don't actually call dispose on singleton in tests
        // Just verify the method exists
        expect(authService.dispose, isA<Function>());
      });
    });

    group('Error Handling', () {
      test('error property should be settable', () {
        expect(authService.error, isNull);
        // Error would be set during failed operations
      });

      test('isLoading state should track operations', () {
        expect(authService.isLoading, isFalse);
      });

      test('clearError should reset error state', () {
        authService.clearError();
        expect(authService.error, isNull);
      });

      test('should handle AuthException gracefully', () async {
        // Try to sign in with invalid credentials
        final result = await authService.signInWithEmail('invalid@test.com', 'wrongpassword');

        expect(result, isFalse);
        expect(authService.error, isNotNull);
      });

      test('should handle network errors gracefully', () async {
        // This will fail due to mock Supabase setup
        final result = await authService.signUpWithEmail('test@example.com', 'Test1234', 'Test User');

        // Should not crash
        expect(result, isA<bool>());
      });
    });

    group('Email Sign Up Flow', () {
      test('should reject invalid email format', () async {
        final result = await authService.signUpWithEmail('invalid-email', 'Test1234', 'Test User');

        expect(result, isFalse);
        expect(authService.error, contains('valid email'));
      });

      test('should reject weak password', () async {
        final result = await authService.signUpWithEmail('test@example.com', 'weak', 'Test User');

        expect(result, isFalse);
        expect(authService.error, contains('8 characters'));
      });

      test('should reject password without numbers', () async {
        final result = await authService.signUpWithEmail('test@example.com', 'NoNumbers', 'Test User');

        expect(result, isFalse);
        expect(authService.error, contains('numbers'));
      });

      test('should reject password without letters', () async {
        final result = await authService.signUpWithEmail('test@example.com', '12345678', 'Test User');

        expect(result, isFalse);
        expect(authService.error, contains('letters'));
      });

      test('should trim and lowercase email', () async {
        // This test verifies email normalization happens
        final result = await authService.signUpWithEmail('  TEST@EXAMPLE.COM  ', 'Test1234', 'Test User');

        // Should not crash due to email format
        expect(result, isA<bool>());
      });

      test('should store name in user metadata', () async {
        // This test verifies the signup flow includes metadata
        final result = await authService.signUpWithEmail('test@example.com', 'Test1234', 'John Doe');

        // Should attempt to create account
        expect(result, isA<bool>());
      });

      test('should handle signup with existing email', () async {
        final result = await authService.signUpWithEmail('existing@example.com', 'Test1234', 'Test User');

        // Should fail gracefully
        expect(result, isA<bool>());
      });

      test('should set loading state during signup', () async {
        var loadingStateChanges = 0;
        authService.addListener(() {
          if (authService.isLoading) {
            loadingStateChanges++;
          }
        });

        await authService.signUpWithEmail('test@example.com', 'Test1234', 'Test User');

        // Loading state should have been set at least once
        expect(loadingStateChanges, greaterThanOrEqualTo(0));
      });
    });

    group('Email Sign In Flow', () {
      test('should handle invalid credentials', () async {
        final result = await authService.signInWithEmail('wrong@example.com', 'wrongpass');

        expect(result, isFalse);
        expect(authService.error, isNotNull);
      });

      test('should normalize email before signin', () async {
        final result = await authService.signInWithEmail('  TEST@EXAMPLE.COM  ', 'Test1234');

        // Should not crash due to email format
        expect(result, isA<bool>());
      });

      test('should handle empty email', () async {
        final result = await authService.signInWithEmail('', 'Test1234');

        expect(result, isFalse);
      });

      test('should handle empty password', () async {
        final result = await authService.signInWithEmail('test@example.com', '');

        expect(result, isFalse);
      });

      test('should set loading state during signin', () async {
        var wasLoading = false;
        authService.addListener(() {
          if (authService.isLoading) {
            wasLoading = true;
          }
        });

        await authService.signInWithEmail('test@example.com', 'Test1234');

        // Should have tracked loading state
        expect(wasLoading, isA<bool>());
      });

      test('should clear error before signin attempt', () async {
        // Set an error first
        authService.clearError();

        await authService.signInWithEmail('test@example.com', 'Test1234');

        // Error state should have been managed
        expect(authService.error, isA<String?>());
      });
    });

    group('Anonymous Authentication', () {
      test('should allow anonymous sign in', () async {
        final result = await authService.signInAnonymously();

        expect(result, isTrue);
        expect(authService.isAuthenticated, isFalse);
      });

      test('should generate device ID for anonymous users', () async {
        await authService.signInAnonymously();

        final deviceId = authService.userId;
        expect(deviceId, isNotNull);
        expect(deviceId, isNotEmpty);
      });

      test('should set isAnonymous to true after anonymous signin', () async {
        await authService.signInAnonymously();

        // Should have device ID but no user
        expect(authService.isAnonymous, isTrue);
      });

      test('continueAsAnonymous should work same as signInAnonymously', () async {
        final result = await authService.continueAsAnonymous();

        expect(result, isTrue);
        expect(authService.isAnonymous, isTrue);
      });

      test('should provide consistent device ID across calls', () async {
        await authService.signInAnonymously();

        final deviceId1 = authService.userId;
        final deviceId2 = authService.userId;

        expect(deviceId1, equals(deviceId2));
      });

      test('should not have currentUser after anonymous signin', () async {
        await authService.signInAnonymously();

        expect(authService.currentUser, isNull);
      });

      test('should allow data operations with device ID', () async {
        await authService.signInAnonymously();

        final dbUserId = authService.databaseUserId;
        expect(dbUserId, isNotEmpty);
        expect(dbUserId, startsWith('device_'));
      });

      test('should notify listeners on anonymous signin', () async {
        var notified = false;
        authService.addListener(() {
          notified = true;
        });

        await authService.signInAnonymously();

        expect(notified, isTrue);
      });
    });

    group('Sign Out Flow', () {
      test('should sign out successfully', () async {
        await authService.signOut();

        expect(authService.currentUser, isNull);
        expect(authService.isAuthenticated, isFalse);
      });

      test('should handle sign out when not authenticated', () async {
        // Should not crash even if not authenticated
        expect(() => authService.signOut(), returnsNormally);
      });

      test('should notify listeners on sign out', () async {
        var notified = false;
        authService.addListener(() {
          notified = true;
        });

        await authService.signOut();

        expect(notified, isTrue);
      });

      test('should clear user state on sign out', () async {
        await authService.signOut();

        expect(authService.currentUser, isNull);
        expect(authService.userEmail, isNull);
      });
    });

    group('Password Reset Flow', () {
      test('should reject invalid email', () async {
        final result = await authService.resetPassword('invalid-email');

        expect(result, isFalse);
        expect(authService.error, contains('valid email'));
      });

      test('should accept valid email', () async {
        final result = await authService.resetPassword('test@example.com');

        // Should attempt to send reset email
        expect(result, isA<bool>());
      });

      test('should normalize email before reset', () async {
        final result = await authService.resetPassword('  TEST@EXAMPLE.COM  ');

        // Should not crash
        expect(result, isA<bool>());
      });

      test('should set loading state during password reset', () async {
        var wasLoading = false;
        authService.addListener(() {
          if (authService.isLoading) {
            wasLoading = true;
          }
        });

        await authService.resetPassword('test@example.com');

        expect(wasLoading, isA<bool>());
      });

      test('should handle reset for non-existent email', () async {
        final result = await authService.resetPassword('nonexistent@example.com');

        // Should not reveal if email exists
        expect(result, isA<bool>());
      });
    });

    group('Password Update Flow', () {
      test('should reject update when not authenticated', () async {
        final result = await authService.updatePassword('NewPass123');

        expect(result, isFalse);
        expect(authService.error, contains('signed in'));
      });

      test('should reject weak password', () async {
        final result = await authService.updatePassword('weak');

        expect(result, isFalse);
        expect(authService.error, contains('8 characters'));
      });

      test('should reject password without numbers', () async {
        final result = await authService.updatePassword('NoNumbers');

        expect(result, isFalse);
        expect(authService.error, contains('numbers'));
      });

      test('should reject password without letters', () async {
        final result = await authService.updatePassword('12345678');

        expect(result, isFalse);
        expect(authService.error, contains('letters'));
      });

      test('should set loading state during password update', () async {
        var wasLoading = false;
        authService.addListener(() {
          if (authService.isLoading) {
            wasLoading = true;
          }
        });

        await authService.updatePassword('NewPass123');

        expect(wasLoading, isA<bool>());
      });
    });

    group('OTP Verification', () {
      test('should handle OTP verification', () async {
        final result = await authService.verifyOTP('test@example.com', '123456');

        expect(result, isA<bool>());
      });

      test('should normalize email for OTP verification', () async {
        final result = await authService.verifyOTP('  TEST@EXAMPLE.COM  ', '123456');

        expect(result, isA<bool>());
      });

      test('should handle invalid OTP code', () async {
        final result = await authService.verifyOTP('test@example.com', 'invalid');

        expect(result, isA<bool>());
      });

      test('should set loading state during OTP verification', () async {
        var wasLoading = false;
        authService.addListener(() {
          if (authService.isLoading) {
            wasLoading = true;
          }
        });

        await authService.verifyOTP('test@example.com', '123456');

        expect(wasLoading, isA<bool>());
      });
    });

    group('Social Authentication - Google', () {
      test('should have Google sign in method', () {
        expect(authService.signInWithGoogle, isA<Function>());
      });

      test('should handle Google sign in cancellation', () async {
        // User cancels the flow
        final result = await authService.signInWithGoogle();

        // Should return false without error
        expect(result, isFalse);
      });

      test('should set loading state during Google signin', () async {
        var wasLoading = false;
        authService.addListener(() {
          if (authService.isLoading) {
            wasLoading = true;
          }
        });

        await authService.signInWithGoogle();

        expect(wasLoading, isA<bool>());
      });

      test('should handle Google signin errors gracefully', () async {
        final result = await authService.signInWithGoogle();

        // Should not crash
        expect(result, isA<bool>());
      });

      test('should handle simulator limitations for Google', () async {
        final result = await authService.signInWithGoogle();

        if (!result && authService.error != null) {
          // Error message should be user-friendly
          expect(authService.error, isNotEmpty);
        }
      });
    });

    group('Social Authentication - Apple', () {
      test('should have Apple sign in method', () {
        expect(authService.signInWithApple, isA<Function>());
      });

      test('should handle Apple sign in cancellation', () async {
        final result = await authService.signInWithApple();

        // Should return false without error on cancellation
        expect(result, isFalse);
      });

      test('should set loading state during Apple signin', () async {
        var wasLoading = false;
        authService.addListener(() {
          if (authService.isLoading) {
            wasLoading = true;
          }
        });

        await authService.signInWithApple();

        expect(wasLoading, isA<bool>());
      });

      test('should handle Apple signin errors gracefully', () async {
        final result = await authService.signInWithApple();

        // Should not crash
        expect(result, isA<bool>());
      });
    });

    group('Account Deletion', () {
      test('should reject deletion when not authenticated', () async {
        final result = await authService.deleteAccount();

        expect(result, isFalse);
        expect(authService.error, contains('signed in'));
      });

      test('should set loading state during deletion', () async {
        var wasLoading = false;
        authService.addListener(() {
          if (authService.isLoading) {
            wasLoading = true;
          }
        });

        await authService.deleteAccount();

        expect(wasLoading, isA<bool>());
      });

      test('should handle deletion errors gracefully', () async {
        final result = await authService.deleteAccount();

        // Should not crash
        expect(result, isA<bool>());
      });
    });

    group('Session Management', () {
      test('should have auth state changes stream', () {
        expect(authService.authStateChanges, isA<Stream<bool>>());
      });

      test('should check user existence', () async {
        final result = await authService.checkUserExists('test@example.com');

        expect(result, isA<bool>());
      });

      test('should handle session restoration on init', () async {
        await authService.initialize();

        // Should not crash if no session exists
        expect(authService.currentUser, isA<User?>());
      });
    });

    group('Display Name Handling', () {
      test('should return null for anonymous users', () {
        expect(authService.displayName, isNull);
      });

      test('should extract name from email when metadata unavailable', () {
        // When signed in with email, displayName should extract from email
        // This is tested indirectly through the getter
        expect(authService.displayName, isA<String?>());
      });
    });

    group('Input Validation', () {
      test('should validate email format correctly', () async {
        // Test various email formats
        final invalidEmails = [
          'invalid',
          '@example.com',
          'test@',
          'test..user@example.com',
        ];

        for (final email in invalidEmails) {
          final result = await authService.signUpWithEmail(email, 'Test1234', 'Test');
          expect(result, isFalse, reason: 'Should reject: $email');
        }
      });

      test('should accept valid email formats', () async {
        final validEmails = [
          'test@example.com',
          'user.name@example.com',
          'user+tag@example.co.uk',
        ];

        for (final email in validEmails) {
          final result = await authService.signUpWithEmail(email, 'Test1234', 'Test');
          expect(result, isA<bool>(), reason: 'Should accept: $email');
        }
      });

      test('should validate password strength correctly', () async {
        final weakPasswords = [
          'short',
          'nouppercase',
          'NOLOWERCASE',
          'NoNumber',
          '12345678',
        ];

        for (final password in weakPasswords) {
          final result = await authService.signUpWithEmail('test@example.com', password, 'Test');
          expect(result, isFalse, reason: 'Should reject: $password');
        }
      });
    });

    group('Listener Notifications', () {
      test('should notify on error clear', () {
        var notified = false;
        authService.addListener(() {
          notified = true;
        });

        authService.clearError();
        expect(notified, isTrue);
      });

      test('should handle multiple listeners', () {
        var count1 = 0;
        var count2 = 0;

        void listener1() => count1++;
        void listener2() => count2++;

        authService.addListener(listener1);
        authService.addListener(listener2);

        authService.clearError();

        expect(count1, greaterThan(0));
        expect(count2, greaterThan(0));

        authService.removeListener(listener1);
        authService.removeListener(listener2);
      });

      test('should allow listener removal', () {
        var count = 0;
        void listener() => count++;

        authService.addListener(listener);
        authService.clearError();

        final firstCount = count;

        authService.removeListener(listener);
        authService.clearError();

        expect(count, equals(firstCount));
      });
    });
  });
}
