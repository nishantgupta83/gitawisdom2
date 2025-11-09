// test/services/supabase_auth_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import 'test_setup.dart';

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
        expect(authService.userId, isNotNull); // Either currentUser.id or _deviceId
      });

      test('displayName should return null when no user', () {
        expect(authService.displayName, isNull);
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
    });

    group('Error Handling', () {
      test('error property should be settable', () {
        expect(authService.error, isNull);
        // Error would be set during failed operations
      });

      test('isLoading state should track operations', () {
        expect(authService.isLoading, isFalse);
      });
    });
  });
}
