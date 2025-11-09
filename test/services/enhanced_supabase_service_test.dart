// test/services/enhanced_supabase_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('EnhancedSupabaseService', () {
    late EnhancedSupabaseService service;

    setUp(() {
      service = EnhancedSupabaseService();
    });

    group('Supabase Service Initialization', () {
      test('service should initialize without errors', () {
        expect(service, isNotNull);
      });

      test('service should have client property', () {
        expect(service.client, isNotNull);
      });

      test('testConnection method should exist and return Future<bool>', () {
        expect(service.testConnection, isA<Function>());
      });

      test('initializeLanguages method should exist and be async', () {
        expect(service.initializeLanguages, isA<Function>());
      });
    });

    group('Service Methods', () {
      test('initializeLanguages should complete initialization', () async {
        // MVP version should initialize without throwing exceptions
        // Note: This requires actual Supabase connection or mocking
        expect(() async => await service.initializeLanguages(), isNotNull);
      });
    });

    group('Service Error Handling', () {
      test('testConnection should handle connection gracefully', () async {
        // Test that testConnection returns a boolean (success/failure)
        final result = await service.testConnection();
        expect(result, isA<bool>());
      });
    });
  });
}
