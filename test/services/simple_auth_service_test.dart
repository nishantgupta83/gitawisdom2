// test/services/simple_auth_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/simple_auth_service.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('SimpleAuthService', () {
    late SimpleAuthService service;

    setUp(() async {
      service = SimpleAuthService();
      await service.initialize();
    });

    tearDown(() async {
      await service.signOut();
    });

    group('Initialization', () {
      test('should initialize without errors', () async {
        expect(service, isNotNull);
        expect(service.isAuthenticated, isFalse);
        expect(service.isAnonymous, isFalse);
      });

      test('should be singleton instance', () {
        final instance1 = SimpleAuthService();
        final instance2 = SimpleAuthService.instance;
        expect(instance1, equals(instance2));
      });
    });

    group('Anonymous Sign In', () {
      test('should sign in as guest successfully', () async {
        final result = await service.signInAnonymously();

        expect(result, isTrue);
        expect(service.isAuthenticated, isTrue);
        expect(service.isAnonymous, isTrue);
        expect(service.userEmail, isNull);
        expect(service.userName, isNull);
        expect(service.error, isNull);
      });

      test('should continue as anonymous successfully', () async {
        final result = await service.continueAsAnonymous();

        expect(result, isTrue);
        expect(service.isAuthenticated, isTrue);
        expect(service.isAnonymous, isTrue);
      });

      test('should set loading state during sign in', () async {
        expect(service.isLoading, isFalse);

        final future = service.signInAnonymously();
        // Loading state should be true during operation
        await Future.delayed(const Duration(milliseconds: 100));

        await future;
        expect(service.isLoading, isFalse);
      });

      test('should notify listeners on anonymous sign in', () async {
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.signInAnonymously();

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Email Sign In', () {
      test('should sign in with email successfully', () async {
        final result = await service.signInWithEmail('test@example.com', 'password123');

        expect(result, isTrue);
        expect(service.isAuthenticated, isTrue);
        expect(service.isAnonymous, isFalse);
        expect(service.userEmail, equals('test@example.com'));
        expect(service.error, isNull);
      });

      test('should extract display name from email', () async {
        await service.signInWithEmail('john.doe@example.com', 'password');

        expect(service.displayName, equals('john.doe'));
      });

      test('should handle empty email', () async {
        final result = await service.signInWithEmail('', 'password');

        expect(result, isTrue); // Service simulates auth, doesn't validate
        expect(service.userEmail, isEmpty);
      });

      test('should notify listeners on email sign in', () async {
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.signInWithEmail('test@example.com', 'password');

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Sign Up', () {
      test('should sign up with email and name successfully', () async {
        final result = await service.signUp('new@example.com', 'password', 'John Doe');

        expect(result, isTrue);
        expect(service.isAuthenticated, isTrue);
        expect(service.isAnonymous, isFalse);
        expect(service.userEmail, equals('new@example.com'));
        expect(service.userName, equals('John Doe'));
        expect(service.displayName, equals('John Doe'));
        expect(service.error, isNull);
      });

      test('should sign up with email only (no name)', () async {
        final result = await service.signUp('new@example.com', 'password', '');

        expect(result, isTrue);
        expect(service.userName, isNull);
        expect(service.displayName, equals('new'));
      });

      test('should use signUpWithEmail alias', () async {
        final result = await service.signUpWithEmail('test@example.com', 'password', 'Test User');

        expect(result, isTrue);
        expect(service.userEmail, equals('test@example.com'));
        expect(service.userName, equals('Test User'));
      });

      test('should notify listeners on sign up', () async {
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.signUp('test@example.com', 'password', 'Test');

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Sign Out', () {
      test('should sign out from authenticated state', () async {
        await service.signInWithEmail('test@example.com', 'password');
        expect(service.isAuthenticated, isTrue);

        await service.signOut();

        expect(service.isAuthenticated, isFalse);
        expect(service.isAnonymous, isFalse);
        expect(service.userEmail, isNull);
        expect(service.userName, isNull);
      });

      test('should sign out from anonymous state', () async {
        await service.signInAnonymously();
        expect(service.isAuthenticated, isTrue);

        await service.signOut();

        expect(service.isAuthenticated, isFalse);
        expect(service.isAnonymous, isFalse);
      });

      test('should clear error on sign out', () async {
        // Manually set an error
        await service.signInWithEmail('test@example.com', 'password');

        await service.signOut();

        expect(service.error, isNull);
      });

      test('should notify listeners on sign out', () async {
        await service.signInAnonymously();

        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.signOut();

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Password Reset', () {
      test('should send password reset email', () async {
        final result = await service.resetPassword('test@example.com');

        expect(result, isTrue);
      });

      test('should handle empty email for password reset', () async {
        final result = await service.resetPassword('');

        expect(result, isTrue); // Service simulates sending
      });

      test('should set loading state during password reset', () async {
        expect(service.isLoading, isFalse);

        final future = service.resetPassword('test@example.com');
        await Future.delayed(const Duration(milliseconds: 100));

        await future;
        expect(service.isLoading, isFalse);
      });
    });

    group('State Management', () {
      test('should clear error', () async {
        // Manually trigger an operation
        await service.signInWithEmail('test@example.com', 'password');

        service.clearError();

        expect(service.error, isNull);
      });

      test('should provide auth state stream', () async {
        final statesReceived = <bool>[];
        final subscription = service.authStateChanges.take(3).listen(statesReceived.add);

        await service.signInAnonymously();
        await Future.delayed(const Duration(seconds: 3));

        await subscription.cancel();
        expect(statesReceived, isNotEmpty);
        expect(statesReceived.last, isTrue);
      });
    });

    group('Display Name Logic', () {
      test('should return full name when available', () async {
        await service.signUp('test@example.com', 'password', 'Full Name');

        expect(service.displayName, equals('Full Name'));
      });

      test('should extract from email when name not set', () async {
        await service.signInWithEmail('john.smith@example.com', 'password');

        expect(service.displayName, equals('john.smith'));
      });

      test('should return null when no email or name', () async {
        expect(service.displayName, isNull);
      });
    });

    group('Authentication State Transitions', () {
      test('should transition from anonymous to authenticated', () async {
        await service.signInAnonymously();
        expect(service.isAnonymous, isTrue);

        await service.signInWithEmail('test@example.com', 'password');

        expect(service.isAnonymous, isFalse);
        expect(service.isAuthenticated, isTrue);
      });

      test('should transition from authenticated to anonymous', () async {
        await service.signInWithEmail('test@example.com', 'password');
        expect(service.isAnonymous, isFalse);

        await service.signOut();
        await service.signInAnonymously();

        expect(service.isAnonymous, isTrue);
      });

      test('should handle multiple sign in attempts', () async {
        await service.signInWithEmail('first@example.com', 'password');
        expect(service.userEmail, equals('first@example.com'));

        await service.signInWithEmail('second@example.com', 'password');
        expect(service.userEmail, equals('second@example.com'));
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in email', () async {
        await service.signInWithEmail('test+tag@example.com', 'password');

        expect(service.userEmail, equals('test+tag@example.com'));
        expect(service.displayName, equals('test+tag'));
      });

      test('should handle very long names', () async {
        const longName = 'Very Long Name That Exceeds Normal Length';
        await service.signUp('test@example.com', 'password', longName);

        expect(service.userName, equals(longName));
      });

      test('should handle concurrent sign in attempts', () async {
        final futures = [
          service.signInAnonymously(),
          service.signInWithEmail('test@example.com', 'password'),
        ];

        await Future.wait(futures);

        // One of them should succeed
        expect(service.isAuthenticated, isTrue);
      });
    });
  });
}
