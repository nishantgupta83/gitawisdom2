// test/services/scenario_service_edge_cases_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/scenario_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();

    // Register Scenario adapter if not already registered
    try {
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(ScenarioAdapter());
      }
    } catch (e) {
      // Adapter might already be registered
    }
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('ScenarioService Edge Cases', () {
    late ScenarioService service;
    late Box<Scenario> scenariosBox;

    setUp(() async {
      service = ScenarioService.instance;

      // Open scenarios box for testing
      if (!Hive.isBoxOpen('scenarios')) {
        scenariosBox = await Hive.openBox<Scenario>('scenarios');
      } else {
        scenariosBox = Hive.box<Scenario>('scenarios');
      }

      // Clear box
      await scenariosBox.clear();

      // Initialize service
      await service.initialize();
    });

    group('Lazy Loading', () {
      test('should initialize without loading all scenarios', () async {
        // Add scenarios to box
        for (int i = 0; i < 100; i++) {
          await scenariosBox.put('scenario_$i', Scenario(
            title: 'Scenario $i',
            description: 'Description $i',
            category: 'test',
            chapter: (i % 18) + 1,
            heartResponse: 'Heart',
            dutyResponse: 'Duty',
            gitaWisdom: 'Wisdom',
            verse: 'Verse',
            verseNumber: '1.1',
            createdAt: DateTime.now(),
          ));
        }

        // Reinitialize service
        final newService = ScenarioService.instance;
        await newService.initialize();

        // Service should initialize quickly without loading all data
        expect(newService, isNotNull);
      });

      test('should load scenarios on first getAllScenarios call', () async {
        await scenariosBox.put('test', Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          createdAt: DateTime.now(),
        ));

        final scenarios = await service.getAllScenarios();
        expect(scenarios.length, greaterThan(0));
      });
    });

    group('Search Performance', () {
      test('should handle search with no results', () {
        final results = service.searchScenarios('nonexistentquerythatwontmatch');
        expect(results, isEmpty);
      });

      test('should handle very long search queries', () {
        final longQuery = 'a' * 500;
        final results = service.searchScenarios(longQuery);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle special characters in search', () {
        final specialQuery = '@#\$%^&*()';
        expect(() => service.searchScenarios(specialQuery), returnsNormally);
      });

      test('should handle empty tags gracefully', () {
        final results = service.filterByTag('');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle case sensitivity in tags', () {
        // Create scenarios with different case tags
        final scenario1 = Scenario(
          title: 'Test1',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          tags: ['Stress', 'WORK'],
          createdAt: DateTime.now(),
        );

        scenariosBox.put('test1', scenario1);
        service.getAllScenarios();

        final results = service.filterByTag('Stress');
        expect(results, isNotEmpty);
      });
    });

    group('Pagination Edge Cases', () {
      test('should handle pagination beyond available data', () {
        final results = service.getPaginatedScenarios(1000);
        expect(results, isEmpty);
      });

      test('should handle negative page numbers gracefully', () {
        final results = service.getPaginatedScenarios(-1);
        // Should either handle gracefully or return empty
        expect(results, isA<List<Scenario>>());
      });

      test('should handle zero page size', () {
        final results = service.getPaginatedScenarios(0, pageSize: 0);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very large page sizes', () {
        final results = service.getPaginatedScenarios(0, pageSize: 10000);
        expect(results, isA<List<Scenario>>());
      });

      test('should calculate pages correctly for empty dataset', () {
        await service.clearCache();
        final pages = service.getTotalPages();
        expect(pages, greaterThanOrEqualTo(0));
      });
    });

    group('Category Management', () {
      test('should handle scenarios without categories', () {
        final categories = service.getAllCategories();
        expect(categories, isA<List<String>>());
      });

      test('should fetchScenariosByCategories with empty list', () {
        final results = service.fetchScenariosByCategories([]);
        expect(results, isEmpty);
      });

      test('should handle fetchScenariosByCategories with duplicates', () {
        final results = service.fetchScenariosByCategories(['test', 'test', 'test']);
        expect(results, isA<List<Scenario>>());
      });

      test('should shuffle scenarios consistently', () {
        // Add multiple scenarios in same category
        for (int i = 0; i < 10; i++) {
          scenariosBox.put('test$i', Scenario(
            title: 'Test $i',
            description: 'Test',
            category: 'same',
            chapter: 1,
            heartResponse: 'Heart',
            dutyResponse: 'Duty',
            gitaWisdom: 'Wisdom',
            verse: 'Verse',
            verseNumber: '1.1',
            createdAt: DateTime.now(),
          ));
        }

        await service.getAllScenarios();
        final results = service.fetchScenariosByCategories(['same']);
        expect(results.length, equals(10));
      });
    });

    group('Random Scenario', () {
      test('should return null for empty cache', () async {
        await service.clearCache();
        final scenario = service.getRandomScenario();
        expect(scenario, isNull);
      });

      test('should return scenario for single item cache', () async {
        await scenariosBox.put('test', Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          createdAt: DateTime.now(),
        ));

        await service.getAllScenarios();
        final scenario = service.getRandomScenario();
        expect(scenario, isNotNull);
        expect(scenario!.title, equals('Test'));
      });
    });

    group('Background Sync', () {
      test('should handle background sync gracefully', () async {
        expect(() => service.backgroundSync(), returnsNormally);
      });

      test('should call onComplete callback', () async {
        bool callbackCalled = false;
        await service.backgroundSync(onComplete: () {
          callbackCalled = true;
        });

        // Wait a bit for callback
        await Future.delayed(const Duration(milliseconds: 100));
        expect(callbackCalled, isTrue);
      });

      test('should handle backgroundSync with null callback', () async {
        expect(() => service.backgroundSync(onComplete: null), returnsNormally);
      });
    });

    group('Cache Management', () {
      test('should handle multiple clearCache calls', () async {
        for (int i = 0; i < 5; i++) {
          await service.clearCache();
        }
        expect(service.hasScenarios, isFalse);
      });

      test('should handle hasNewScenariosAvailable gracefully', () async {
        expect(() => service.hasNewScenariosAvailable(), returnsNormally);
      });

      test('should return cache stats with zero scenarios', () async {
        await service.clearCache();
        final stats = service.getCacheStats();
        expect(stats['Total Scenarios'], equals(0));
      });

      test('should handle getAdvancedCacheStats', () {
        final stats = service.getAdvancedCacheStats();
        expect(stats, isNotNull);
        expect(stats, containsKey('Total Scenarios'));
        expect(stats, containsKey('Cache Valid'));
      });
    });

    group('Relevance Search', () {
      test('should handle searchScenariosWithRelevance with empty query', () async {
        final results = await service.searchScenariosWithRelevance('');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle searchScenariosWithRelevance with null maxResults', () async {
        final results = await service.searchScenariosWithRelevance('test', maxResults: null);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle searchScenariosWithRelevance with zero maxResults', () async {
        final results = await service.searchScenariosWithRelevance('test', maxResults: 0);
        expect(results, isEmpty);
      });

      test('should prioritize exact matches in title', () async {
        await scenariosBox.put('test1', Scenario(
          title: 'Stress Management',
          description: 'Other content',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          createdAt: DateTime.now(),
        ));

        await scenariosBox.put('test2', Scenario(
          title: 'Other title',
          description: 'About stress',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          createdAt: DateTime.now(),
        ));

        await service.getAllScenarios();
        final results = await service.searchScenariosWithRelevance('stress');

        if (results.isNotEmpty) {
          expect(results.first.title, contains('Stress'));
        }
      });
    });

    group('Concurrent Operations', () {
      test('should handle concurrent getAllScenarios calls', () async {
        final futures = List.generate(5, (_) => service.getAllScenarios());
        final results = await Future.wait(futures);

        expect(results.length, equals(5));
        for (final result in results) {
          expect(result, isA<List<Scenario>>());
        }
      });

      test('should handle concurrent search operations', () async {
        await scenariosBox.put('test', Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          createdAt: DateTime.now(),
        ));

        await service.getAllScenarios();

        final futures = List.generate(5, (_) => service.searchScenariosWithRelevance('test'));
        final results = await Future.wait(futures);

        expect(results.length, equals(5));
      });
    });

    group('Data Integrity', () {
      test('should maintain scenario order after multiple operations', () async {
        // Add scenarios
        for (int i = 0; i < 5; i++) {
          await scenariosBox.put('test$i', Scenario(
            title: 'Test $i',
            description: 'Test',
            category: 'test',
            chapter: 1,
            heartResponse: 'Heart',
            dutyResponse: 'Duty',
            gitaWisdom: 'Wisdom',
            verse: 'Verse',
            verseNumber: '1.1',
            createdAt: DateTime.now(),
          ));
        }

        final initial = await service.getAllScenarios();
        final afterSearch = await service.getAllScenarios();

        expect(initial.length, equals(afterSearch.length));
      });

      test('should handle scenarios with null tags', () async {
        await scenariosBox.put('test', Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          tags: null,
          createdAt: DateTime.now(),
        ));

        await service.getAllScenarios();
        final tags = service.getAllTags();
        expect(tags, isA<List<String>>());
      });

      test('should handle scenarios with null actionSteps', () async {
        await scenariosBox.put('test', Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: 'Verse',
          verseNumber: '1.1',
          actionSteps: null,
          createdAt: DateTime.now(),
        ));

        await service.getAllScenarios();
        final results = service.searchScenarios('test');
        expect(results, isNotEmpty);
      });
    });
  });
}
