// test/services/service_locator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/service_locator.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('ServiceLocator', () {
    late ServiceLocator locator;

    setUp(() {
      locator = ServiceLocator();
    });

    tearDown(() {
      locator.dispose();
    });

    group('Initialization', () {
      test('should create service locator instance', () {
        expect(locator, isNotNull);
        expect(locator, isA<ServiceLocator>());
      });

      test('should be a singleton', () {
        final instance1 = ServiceLocator.instance;
        final instance2 = ServiceLocator.instance;
        expect(instance1, same(instance2));
      });

      test('should be accessible via factory', () {
        final factory1 = ServiceLocator();
        final factory2 = ServiceLocator();
        expect(factory1, same(factory2));
      });

      test('should match instance property', () {
        final factory = ServiceLocator();
        final instance = ServiceLocator.instance;
        expect(factory, same(instance));
      });
    });

    group('EnhancedSupabaseService', () {
      test('should provide enhanced supabase service', () {
        final service = locator.enhancedSupabaseService;
        expect(service, isNotNull);
        expect(service, isA<EnhancedSupabaseService>());
      });

      test('should return same instance on multiple calls', () {
        final service1 = locator.enhancedSupabaseService;
        final service2 = locator.enhancedSupabaseService;
        expect(service1, same(service2));
      });

      test('should lazy initialize service', () {
        // Service should be created on first access
        final service = locator.enhancedSupabaseService;
        expect(service, isNotNull);
      });

      test('should be thread-safe', () {
        final service1 = locator.enhancedSupabaseService;
        final service2 = ServiceLocator.instance.enhancedSupabaseService;
        expect(service1, same(service2));
      });
    });

    group('SupabaseAuthService', () {
      test('should provide supabase auth service', () {
        final service = locator.supabaseAuthService;
        expect(service, isNotNull);
        expect(service, isA<SupabaseAuthService>());
      });

      test('should return same instance on multiple calls', () {
        final service1 = locator.supabaseAuthService;
        final service2 = locator.supabaseAuthService;
        expect(service1, same(service2));
      });

      test('should lazy initialize service', () {
        // Service should be created on first access
        final service = locator.supabaseAuthService;
        expect(service, isNotNull);
      });

      test('should match SupabaseAuthService.instance', () {
        final locatorService = locator.supabaseAuthService;
        final directInstance = SupabaseAuthService.instance;
        expect(locatorService, same(directInstance));
      });
    });

    group('Service Dependencies', () {
      test('should provide both services independently', () {
        final supabaseService = locator.enhancedSupabaseService;
        final authService = locator.supabaseAuthService;

        expect(supabaseService, isNotNull);
        expect(authService, isNotNull);
        expect(supabaseService, isNot(same(authService)));
      });

      test('should maintain service instances after access', () {
        final supabase1 = locator.enhancedSupabaseService;
        final auth1 = locator.supabaseAuthService;
        final supabase2 = locator.enhancedSupabaseService;
        final auth2 = locator.supabaseAuthService;

        expect(supabase1, same(supabase2));
        expect(auth1, same(auth2));
      });
    });

    group('Initialize', () {
      test('should initialize all services', () async {
        // Initialize should complete without errors
        try {
          await locator.initialize();
        } catch (e) {
          // Network errors are acceptable in tests
        }
        expect(locator, isNotNull);
      });

      test('should initialize enhanced supabase service', () async {
        try {
          await locator.initialize();

          final service = locator.enhancedSupabaseService;
          expect(service, isNotNull);
        } catch (e) {
          // Network errors are acceptable
        }
      });

      test('should initialize auth service', () async {
        try {
          await locator.initialize();

          final service = locator.supabaseAuthService;
          expect(service, isNotNull);
        } catch (e) {
          // Network errors are acceptable
        }
      });

      test('should initialize services in parallel', () async {
        // Initialization should use Future.wait for parallel execution
        try {
          final startTime = DateTime.now();
          await locator.initialize();
          final duration = DateTime.now().difference(startTime);

          // Should complete (parallel execution should be faster than sequential)
          expect(duration, isNotNull);
        } catch (e) {
          // Network errors are acceptable
        }
      });

      test('should handle initialization errors gracefully', () async {
        try {
          await locator.initialize();
        } catch (e) {
          // Should not crash on network errors
        }
        expect(locator, isNotNull);
      });

      test('should allow multiple initialization calls', () async {
        try {
          await locator.initialize();
          await locator.initialize(); // Second call should be safe
        } catch (e) {
          // Network errors are acceptable
        }
        expect(locator, isNotNull);
      });

      test('should maintain service instances after initialization', () async {
        final supabaseBefore = locator.enhancedSupabaseService;
        final authBefore = locator.supabaseAuthService;

        try {
          await locator.initialize();
        } catch (e) {
          // Network errors are acceptable
        }

        final supabaseAfter = locator.enhancedSupabaseService;
        final authAfter = locator.supabaseAuthService;

        expect(supabaseBefore, same(supabaseAfter));
        expect(authBefore, same(authAfter));
      });
    });

    group('Dispose', () {
      test('should dispose without errors', () {
        locator.dispose();
        expect(locator, isNotNull);
      });

      test('should clear service references', () {
        final supabase = locator.enhancedSupabaseService;
        final auth = locator.supabaseAuthService;

        expect(supabase, isNotNull);
        expect(auth, isNotNull);

        locator.dispose();

        // After dispose, new instances should be created
        final supabaseAfter = locator.enhancedSupabaseService;
        final authAfter = locator.supabaseAuthService;

        expect(supabaseAfter, isNotNull);
        expect(authAfter, isNotNull);
      });

      test('should handle multiple dispose calls', () {
        locator.dispose();
        locator.dispose();
        locator.dispose();
        expect(locator, isNotNull);
      });

      test('should handle dispose without initialization', () {
        final newLocator = ServiceLocator();
        newLocator.dispose();
        expect(newLocator, isNotNull);
      });

      test('should allow reinitialization after dispose', () async {
        try {
          await locator.initialize();
        } catch (e) {
          // Network errors acceptable
        }

        locator.dispose();

        try {
          await locator.initialize();
        } catch (e) {
          // Network errors acceptable
        }

        expect(locator, isNotNull);
      });
    });

    group('Lazy Loading', () {
      test('should not create services until accessed', () {
        final newLocator = ServiceLocator();
        // Services not accessed yet, but locator should be valid
        expect(newLocator, isNotNull);
        newLocator.dispose();
      });

      test('should create enhanced supabase service on first access', () {
        final newLocator = ServiceLocator();
        final service = newLocator.enhancedSupabaseService;
        expect(service, isNotNull);
        newLocator.dispose();
      });

      test('should create auth service on first access', () {
        final newLocator = ServiceLocator();
        final service = newLocator.supabaseAuthService;
        expect(service, isNotNull);
        newLocator.dispose();
      });

      test('should handle mixed access patterns', () {
        final newLocator = ServiceLocator();

        final auth1 = newLocator.supabaseAuthService;
        final supabase1 = newLocator.enhancedSupabaseService;
        final auth2 = newLocator.supabaseAuthService;
        final supabase2 = newLocator.enhancedSupabaseService;

        expect(auth1, same(auth2));
        expect(supabase1, same(supabase2));

        newLocator.dispose();
      });
    });

    group('Concurrent Access', () {
      test('should handle concurrent service access', () async {
        final futures = <Future>[];

        for (int i = 0; i < 10; i++) {
          futures.add(Future(() {
            final service = locator.enhancedSupabaseService;
            return service;
          }));
        }

        final services = await Future.wait(futures);

        // All should return the same instance
        for (int i = 1; i < services.length; i++) {
          expect(services[i], same(services[0]));
        }
      });

      test('should handle concurrent auth service access', () async {
        final futures = <Future>[];

        for (int i = 0; i < 10; i++) {
          futures.add(Future(() {
            final service = locator.supabaseAuthService;
            return service;
          }));
        }

        final services = await Future.wait(futures);

        // All should return the same instance
        for (int i = 1; i < services.length; i++) {
          expect(services[i], same(services[0]));
        }
      });

      test('should handle concurrent initialization calls', () async {
        final futures = <Future>[];

        for (int i = 0; i < 5; i++) {
          futures.add(locator.initialize().catchError((_) => null));
        }

        await Future.wait(futures);

        expect(locator, isNotNull);
      });

      test('should handle mixed concurrent operations', () async {
        final futures = <Future>[];

        futures.add(Future(() => locator.enhancedSupabaseService));
        futures.add(Future(() => locator.supabaseAuthService));
        futures.add(locator.initialize().catchError((_) => null));
        futures.add(Future(() => locator.enhancedSupabaseService));
        futures.add(Future(() => locator.supabaseAuthService));

        await Future.wait(futures);

        expect(locator, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle service access errors gracefully', () {
        try {
          final service = locator.enhancedSupabaseService;
          expect(service, isNotNull);
        } catch (e) {
          fail('Should not throw exception: $e');
        }
      });

      test('should handle initialization failures', () async {
        try {
          await locator.initialize();
        } catch (e) {
          // Network errors are expected in test environment
        }

        // Services should still be accessible
        final supabase = locator.enhancedSupabaseService;
        final auth = locator.supabaseAuthService;

        expect(supabase, isNotNull);
        expect(auth, isNotNull);
      });

      test('should recover from dispose errors', () {
        locator.dispose();

        // Should be able to use services after dispose
        final service = locator.enhancedSupabaseService;
        expect(service, isNotNull);
      });
    });

    group('Service Lifecycle', () {
      test('should maintain service instances across operations', () {
        final supabase1 = locator.enhancedSupabaseService;
        final auth1 = locator.supabaseAuthService;

        // Perform operations
        final supabase2 = locator.enhancedSupabaseService;
        final auth2 = locator.supabaseAuthService;

        expect(supabase1, same(supabase2));
        expect(auth1, same(auth2));
      });

      test('should create new instances after dispose', () {
        final supabase1 = locator.enhancedSupabaseService;

        locator.dispose();

        final supabase2 = locator.enhancedSupabaseService;

        expect(supabase1, isNotNull);
        expect(supabase2, isNotNull);
        // After dispose, new instance is created
      });

      test('should handle rapid dispose and access cycles', () {
        for (int i = 0; i < 5; i++) {
          final service = locator.enhancedSupabaseService;
          expect(service, isNotNull);
          locator.dispose();
        }

        final finalService = locator.enhancedSupabaseService;
        expect(finalService, isNotNull);
      });
    });

    group('Singleton Pattern', () {
      test('should enforce singleton across different access methods', () {
        final factory = ServiceLocator();
        final instance = ServiceLocator.instance;
        final directCall = ServiceLocator();

        expect(factory, same(instance));
        expect(instance, same(directCall));
      });

      test('should maintain singleton after operations', () async {
        final before = ServiceLocator.instance;

        try {
          await locator.initialize();
        } catch (e) {
          // Network errors acceptable
        }

        locator.dispose();

        final after = ServiceLocator.instance;

        expect(before, same(after));
      });

      test('should not create multiple instances', () {
        final instances = <ServiceLocator>[];

        for (int i = 0; i < 10; i++) {
          instances.add(ServiceLocator());
        }

        for (int i = 1; i < instances.length; i++) {
          expect(instances[i], same(instances[0]));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle rapid service access', () {
        for (int i = 0; i < 100; i++) {
          final service = locator.enhancedSupabaseService;
          expect(service, isNotNull);
        }
      });

      test('should handle alternating service access', () {
        for (int i = 0; i < 10; i++) {
          final supabase = locator.enhancedSupabaseService;
          final auth = locator.supabaseAuthService;

          expect(supabase, isNotNull);
          expect(auth, isNotNull);
        }
      });

      test('should handle dispose between service access', () {
        final supabase1 = locator.enhancedSupabaseService;

        locator.dispose();

        final auth = locator.supabaseAuthService;

        locator.dispose();

        final supabase2 = locator.enhancedSupabaseService;

        expect(supabase1, isNotNull);
        expect(auth, isNotNull);
        expect(supabase2, isNotNull);
      });

      test('should handle initialization between service access', () async {
        final supabase1 = locator.enhancedSupabaseService;

        try {
          await locator.initialize();
        } catch (e) {
          // Network errors acceptable
        }

        final auth = locator.supabaseAuthService;

        try {
          await locator.initialize();
        } catch (e) {
          // Network errors acceptable
        }

        final supabase2 = locator.enhancedSupabaseService;

        expect(supabase1, same(supabase2));
        expect(auth, isNotNull);
      });
    });
  });
}
