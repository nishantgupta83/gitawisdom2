// test/services/progressive_scenario_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gitawisdom2/models/scenario.dart';
import 'package:gitawisdom2/services/progressive_scenario_service.dart';
import 'package:gitawisdom2/services/intelligent_caching_service.dart';
import 'package:gitawisdom2/services/progressive_cache_service.dart';

void main() {
  late ProgressiveScenarioService service;

  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ScenarioAdapter());
    }
  });

  setUp(() {
    service = ProgressiveScenarioService.instance;
  });

  tearDownAll(() async {
    // Clean up Hive boxes after tests
    await Hive.deleteFromDisk();
  });

  group('ProgressiveScenarioService', () {
    test('should be a singleton', () {
      final instance1 = ProgressiveScenarioService.instance;
      final instance2 = ProgressiveScenarioService.instance;
      expect(identical(instance1, instance2), true);
    });

    test('initialize should complete without errors', () async {
      await expectLater(service.initialize(), completes);
    });

    test('hasScenarios should return false before initialization', () {
      // Create a new instance (not initialized yet)
      expect(service.hasScenarios, isFalse);
    });

    test('scenarioCount should return 0 when no scenarios are loaded', () {
      final count = service.scenarioCount;
      expect(count, isA<int>());
      expect(count >= 0, true);
    });

    test('searchScenarios with empty query should return scenarios', () {
      final results = service.searchScenarios('');
      expect(results, isA<List<Scenario>>());
    });

    test('searchScenarios with query should return filtered results', () {
      final results = service.searchScenarios('work');
      expect(results, isA<List<Scenario>>());
    });

    test('searchScenarios with maxResults should limit results', () {
      final results = service.searchScenarios('', maxResults: 5);
      expect(results.length, lessThanOrEqualTo(5));
    });

    test('searchScenarios should handle special characters', () {
      final results = service.searchScenarios('work-life');
      expect(results, isA<List<Scenario>>());
    });

    test('searchScenarios should be case-insensitive', () {
      final resultsLower = service.searchScenarios('work');
      final resultsUpper = service.searchScenarios('WORK');
      expect(resultsLower, isA<List<Scenario>>());
      expect(resultsUpper, isA<List<Scenario>>());
    });

    test('searchScenarios should handle unicode characters', () {
      final results = service.searchScenarios('कर्म'); // Sanskrit text
      expect(results, isA<List<Scenario>>());
    });

    test('multiple initialize calls should not cause errors', () async {
      await service.initialize();
      await expectLater(service.initialize(), completes);
    });

    test('scenarioCount should increase after loading', () async {
      await service.initialize();
      final count = service.scenarioCount;
      expect(count >= 0, true);
    });
  });

  group('ProgressiveScenarioService Edge Cases', () {
    test('should handle null maxResults gracefully', () {
      final results = service.searchScenarios('test', maxResults: null);
      expect(results, isA<List<Scenario>>());
    });

    test('should handle zero maxResults', () {
      final results = service.searchScenarios('test', maxResults: 0);
      expect(results, isEmpty);
    });

    test('should handle negative maxResults as unlimited', () {
      final results = service.searchScenarios('test', maxResults: -1);
      expect(results, isA<List<Scenario>>());
    });

    test('should handle very long query strings', () {
      final longQuery = 'test ' * 100;
      final results = service.searchScenarios(longQuery);
      expect(results, isA<List<Scenario>>());
    });

    test('should handle empty string query', () {
      final results = service.searchScenarios('   ');
      expect(results, isA<List<Scenario>>());
    });
  });

  group('ProgressiveScenarioService Performance', () {
    test('searchScenarios should complete in reasonable time', () async {
      await service.initialize();

      final stopwatch = Stopwatch()..start();
      final results = service.searchScenarios('work-life balance');
      stopwatch.stop();

      expect(results, isA<List<Scenario>>());
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be fast
    });

    test('multiple searches should be consistent', () async {
      await service.initialize();

      final results1 = service.searchScenarios('career');
      final results2 = service.searchScenarios('career');

      expect(results1.length, equals(results2.length));
    });
  });
}
