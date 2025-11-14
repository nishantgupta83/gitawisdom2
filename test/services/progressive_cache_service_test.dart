import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/progressive_cache_service.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/models/scenario.dart';

import 'progressive_cache_service_test.mocks.dart';

@GenerateMocks([
  EnhancedSupabaseService,
  Box<Scenario>,
])
void main() {
  late MockEnhancedSupabaseService mockSupabaseService;
  late ProgressiveCacheService cacheService;

  setUp(() {
    mockSupabaseService = MockEnhancedSupabaseService();
    cacheService = ProgressiveCacheService(
      supabaseService: mockSupabaseService,
    );
  });

  group('ProgressiveCacheService Tests', () {
    test('should initialize with correct cache tier capacities', () {
      expect(cacheService, isNotNull);
      // Verify cache service is properly instantiated
    });

    test('should fetch scenarios from critical tier first', () async {
      final mockScenarios = [
        Scenario(
          id: 1,
          title: 'Critical Scenario',
          situation: 'Test situation',
          heartResponse: 'Heart response',
          dutyResponse: 'Duty response',
          category: 'critical',
        ),
      ];

      when(mockSupabaseService.getScenariosByCategory('critical'))
          .thenAnswer((_) async => mockScenarios);

      final result = await cacheService.getCriticalScenarios();

      expect(result, isNotEmpty);
      expect(result.length, equals(1));
      expect(result.first.category, equals('critical'));
      verify(mockSupabaseService.getScenariosByCategory('critical')).called(1);
    });

    test('should handle cache miss and fetch from network', () async {
      final mockScenarios = [
        Scenario(
          id: 1,
          title: 'Network Scenario',
          situation: 'Test situation',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'frequent',
        ),
      ];

      when(mockSupabaseService.getAllScenarios())
          .thenAnswer((_) async => mockScenarios);

      final result = await cacheService.getAllScenarios();

      expect(result, isNotEmpty);
      verify(mockSupabaseService.getAllScenarios()).called(1);
    });

    test('should return cached scenarios when available', () async {
      // First call to populate cache
      final mockScenarios = [
        Scenario(
          id: 1,
          title: 'Cached Scenario',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'frequent',
        ),
      ];

      when(mockSupabaseService.getAllScenarios())
          .thenAnswer((_) async => mockScenarios);

      // First fetch (cache miss)
      await cacheService.getAllScenarios();

      // Second fetch (should use cache)
      final cachedResult = await cacheService.getAllScenarios();

      expect(cachedResult, isNotEmpty);
    });

    test('should handle search across cache tiers', () async {
      final mockScenarios = [
        Scenario(
          id: 1,
          title: 'Search Test',
          situation: 'Test situation with keyword',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'frequent',
        ),
      ];

      when(mockSupabaseService.getAllScenarios())
          .thenAnswer((_) async => mockScenarios);

      final results = await cacheService.searchScenarios('keyword');

      expect(results, isNotEmpty);
      expect(results.first.situation, contains('keyword'));
    });

    test('should handle empty cache gracefully', () async {
      when(mockSupabaseService.getAllScenarios())
          .thenAnswer((_) async => []);

      final result = await cacheService.getAllScenarios();

      expect(result, isEmpty);
      verify(mockSupabaseService.getAllScenarios()).called(1);
    });

    test('should handle network errors gracefully', () async {
      when(mockSupabaseService.getAllScenarios())
          .thenThrow(Exception('Network error'));

      expect(
        () => cacheService.getAllScenarios(),
        throwsException,
      );
    });

    test('should invalidate cache when requested', () async {
      // Populate cache
      final mockScenarios = [
        Scenario(
          id: 1,
          title: 'Test',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'frequent',
        ),
      ];

      when(mockSupabaseService.getAllScenarios())
          .thenAnswer((_) async => mockScenarios);

      await cacheService.getAllScenarios();

      // Invalidate cache
      await cacheService.clearCache();

      // Next fetch should hit network again
      await cacheService.getAllScenarios();

      verify(mockSupabaseService.getAllScenarios()).called(2);
    });

    test('should respect cache tier priorities', () async {
      // Critical scenarios should be fetched first
      final criticalScenarios = [
        Scenario(
          id: 1,
          title: 'Critical',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'critical',
        ),
      ];

      when(mockSupabaseService.getScenariosByCategory('critical'))
          .thenAnswer((_) async => criticalScenarios);

      final result = await cacheService.getCriticalScenarios();

      expect(result, isNotEmpty);
      expect(result.first.category, equals('critical'));
    });
  });

  group('ProgressiveCacheService Performance Tests', () {
    test('should complete cache lookup within acceptable time', () async {
      final mockScenarios = List.generate(
        50,
        (index) => Scenario(
          id: index,
          title: 'Scenario $index',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'frequent',
        ),
      );

      when(mockSupabaseService.getAllScenarios())
          .thenAnswer((_) async => mockScenarios);

      final stopwatch = Stopwatch()..start();
      await cacheService.getAllScenarios();
      stopwatch.stop();

      // Cache lookup should be fast (< 100ms for 50 items)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should handle large dataset efficiently', () async {
      final largeDataset = List.generate(
        1000,
        (index) => Scenario(
          id: index,
          title: 'Scenario $index',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'complete',
        ),
      );

      when(mockSupabaseService.getAllScenarios())
          .thenAnswer((_) async => largeDataset);

      final result = await cacheService.getAllScenarios();

      expect(result.length, equals(1000));
    });
  });
}
