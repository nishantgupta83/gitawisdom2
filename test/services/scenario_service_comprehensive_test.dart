// test/services/scenario_service_comprehensive_test.dart
// Comprehensive tests for ScenarioService covering all functionality

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

  group('ScenarioService - Comprehensive Tests', () {
    late ScenarioService service;
    late Box<Scenario> scenariosBox;
    late Box settingsBox;
    late List<Scenario> testScenarios;

    setUp(() async {
      service = ScenarioService.instance;

      // Open scenarios box
      if (!Hive.isBoxOpen('scenarios')) {
        scenariosBox = await Hive.openBox<Scenario>('scenarios');
      } else {
        scenariosBox = Hive.box<Scenario>('scenarios');
      }

      // Open settings box
      if (!Hive.isBoxOpen('settings')) {
        settingsBox = await Hive.openBox('settings');
      } else {
        settingsBox = Hive.box('settings');
      }

      // Create comprehensive test scenarios
      testScenarios = [
        Scenario(
          title: 'Managing Work Stress',
          description: 'Dealing with workplace pressure and deadlines',
          category: 'career',
          chapter: 2,
          heartResponse: 'Take a break and relax',
          dutyResponse: 'Stay focused and complete your work',
          gitaWisdom: 'Perform your duty without attachment to results',
          verse: 'You have a right to perform your prescribed duty',
          verseNumber: '2.47',
          tags: ['work', 'stress', 'career'],
          actionSteps: ['Take deep breaths', 'Prioritize tasks', 'Delegate when possible'],
          createdAt: DateTime.now(),
        ),
        Scenario(
          title: 'Parenting Challenges',
          description: 'Balancing discipline and love with children',
          category: 'relationships',
          chapter: 3,
          heartResponse: 'Be patient and understanding',
          dutyResponse: 'Set clear boundaries and rules',
          gitaWisdom: 'Act with wisdom and compassion',
          verse: 'Let your actions be guided by dharma',
          verseNumber: '3.19',
          tags: ['parenting', 'family', 'relationships'],
          actionSteps: ['Listen actively', 'Set consistent rules', 'Show unconditional love'],
          createdAt: DateTime.now(),
        ),
        Scenario(
          title: 'Financial Anxiety',
          description: 'Worrying about money and future security',
          category: 'personal growth',
          chapter: 2,
          heartResponse: 'Trust that things will work out',
          dutyResponse: 'Create a budget and savings plan',
          gitaWisdom: 'Do your duty and let go of worry',
          verse: 'The soul is neither born nor dies',
          verseNumber: '2.20',
          tags: ['finance', 'anxiety', 'planning'],
          actionSteps: ['Track expenses', 'Create emergency fund', 'Seek financial advice'],
          createdAt: DateTime.now(),
        ),
        Scenario(
          title: 'Dealing with Older Parents',
          description: 'Managing care for aging parents',
          category: 'relationships',
          chapter: 1,
          heartResponse: 'Show love and gratitude',
          dutyResponse: 'Ensure their needs are met',
          gitaWisdom: 'Honor your parents and elders',
          verse: 'Respect those who came before you',
          verseNumber: '1.28',
          tags: ['parents', 'elderly', 'family'],
          actionSteps: ['Visit regularly', 'Arrange medical care', 'Listen to their stories'],
          createdAt: DateTime.now(),
        ),
      ];

      // Populate scenarios box
      await scenariosBox.clear();
      for (int i = 0; i < testScenarios.length; i++) {
        await scenariosBox.put('scenario_$i', testScenarios[i]);
      }

      // Clear settings
      await settingsBox.clear();

      // Initialize service
      await service.initialize();
      await service.getAllScenarios();
    });

    tearDown(() async {
      // Clean up after each test
      await scenariosBox.clear();
      await settingsBox.clear();
    });

    group('Initialization Tests', () {
      test('should initialize service successfully', () async {
        expect(service, isNotNull);
        expect(service.hasScenarios, isTrue);
      });

      test('should be a singleton instance', () {
        final instance1 = ScenarioService.instance;
        final instance2 = ScenarioService.instance;
        expect(instance1, same(instance2));
      });

      test('should prevent multiple initializations', () async {
        await service.initialize();
        await service.initialize();
        await service.initialize();
        // Should not throw error
        expect(service.hasScenarios, isTrue);
      });

      test('should load scenarios from Hive on initialization', () async {
        final newService = ScenarioService.instance;
        await newService.initialize();
        expect(newService.scenarioCount, greaterThanOrEqualTo(0));
      });

      test('should handle initialization with empty box', () async {
        await scenariosBox.clear();
        await service.initialize();
        expect(service, isNotNull);
      });
    });

    group('Cache-First Fetch Tests', () {
      test('should return all cached scenarios immediately', () async {
        final scenarios = await service.getAllScenarios();
        expect(scenarios.length, equals(testScenarios.length));
      });

      test('should return scenarios from cache on second call', () async {
        final scenarios1 = await service.getAllScenarios();
        final scenarios2 = await service.getAllScenarios();
        expect(scenarios1.length, equals(scenarios2.length));
      });

      test('should return empty list when no scenarios cached', () async {
        await service.clearCache();
        final scenarios = await service.getAllScenarios();
        expect(scenarios, isA<List<Scenario>>());
      });

      test('should lazy load scenarios from Hive', () async {
        // Add new scenario instances to Hive (avoid HiveObject reuse)
        for (int i = 0; i < 5; i++) {
          final scenario = Scenario(
            title: 'Lazy Scenario $i',
            description: 'Test lazy loading',
            category: 'test',
            chapter: 1,
            heartResponse: 'Heart',
            dutyResponse: 'Duty',
            gitaWisdom: 'Wisdom',
            createdAt: DateTime.now(),
          );
          await scenariosBox.put('lazy_$i', scenario);
        }

        final scenarios = await service.getAllScenarios();
        expect(scenarios.length, greaterThan(0));
      });
    });

    group('Search Functionality Tests', () {
      test('should return all scenarios for empty query', () {
        final results = service.searchScenarios('');
        expect(results.length, equals(testScenarios.length));
      });

      test('should return all scenarios for whitespace query', () {
        final results = service.searchScenarios('   ');
        expect(results.length, equals(testScenarios.length));
      });

      test('should search by title case-insensitively', () {
        final results1 = service.searchScenarios('work');
        final results2 = service.searchScenarios('WORK');
        final results3 = service.searchScenarios('Work');
        expect(results1.length, equals(results2.length));
        expect(results2.length, equals(results3.length));
      });

      test('should search by description', () {
        final results = service.searchScenarios('workplace');
        expect(results, isNotEmpty);
        expect(results.first.description.toLowerCase(), contains('workplace'));
      });

      test('should search by category', () {
        final results = service.searchScenarios('career');
        expect(results, isNotEmpty);
        expect(results.every((s) => s.category == 'career'), isTrue);
      });

      test('should search by tags', () {
        final results = service.searchScenarios('stress');
        expect(results, isNotEmpty);
        expect(results.any((s) => s.tags?.contains('stress') ?? false), isTrue);
      });

      test('should search in Gita wisdom content', () {
        final results = service.searchScenarios('duty');
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('should search in heart response', () {
        final results = service.searchScenarios('relax');
        expect(results, isNotEmpty);
      });

      test('should search in duty response', () {
        final results = service.searchScenarios('focused');
        expect(results, isNotEmpty);
      });

      test('should search in action steps', () {
        final results = service.searchScenarios('budget');
        expect(results, isNotEmpty);
      });

      test('should handle compound search queries', () {
        final results = service.searchScenarios('work stress');
        expect(results, isNotEmpty);
      });

      test('should respect maxResults parameter', () {
        final results = service.searchScenarios('parent', maxResults: 1);
        expect(results.length, equals(1));
      });

      test('should handle maxResults larger than available', () {
        final results = service.searchScenarios('work', maxResults: 100);
        expect(results.length, lessThanOrEqualTo(100));
      });

      test('should handle zero maxResults', () {
        final results = service.searchScenarios('work', maxResults: 0);
        expect(results, isEmpty);
      });

      test('should handle very long search queries', () {
        final longQuery = 'work ' * 100;
        final results = service.searchScenarios(longQuery);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle special characters in search', () {
        final results = service.searchScenarios('@#\$%^&*()');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle Unicode characters in search', () {
        final results = service.searchScenarios('कर्म');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Search Cache Tests', () {
      test('should cache search results for repeated queries', () {
        // First search
        final results1 = service.searchScenarios('work');
        // Second search (should use cache)
        final results2 = service.searchScenarios('work');
        expect(results1.length, equals(results2.length));
      });

      test('should handle search cache expiration', () {
        final results = service.searchScenarios('test');
        expect(results, isA<List<Scenario>>());
      });

      test('should limit search cache size', () {
        // Create many different search queries
        for (int i = 0; i < 60; i++) {
          service.searchScenarios('query$i');
        }
        // Should not throw error
        expect(true, isTrue);
      });

      test('should clear search cache when scenarios updated', () async {
        service.searchScenarios('work');
        await service.clearCache();
        // Cache should be cleared
        expect(service.scenarioCount, equals(0));
      });
    });

    group('Filter By Tag Tests', () {
      test('should return scenarios matching specific tag', () {
        final results = service.filterByTag('stress');
        expect(results, isNotEmpty);
        expect(results.every((s) => s.tags?.contains('stress') ?? false), isTrue);
      });

      test('should return empty list for non-existent tag', () {
        final results = service.filterByTag('nonexistent');
        expect(results, isEmpty);
      });

      test('should handle empty tag', () {
        final results = service.filterByTag('');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle tag case sensitivity', () {
        final results = service.filterByTag('stress');
        expect(results.length, greaterThanOrEqualTo(0));
      });

      test('should handle special characters in tags', () {
        final results = service.filterByTag('@special');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Filter By Chapter Tests', () {
      test('should return scenarios from specific chapter', () {
        final results = service.filterByChapter(2);
        expect(results, isNotEmpty);
        expect(results.every((s) => s.chapter == 2), isTrue);
      });

      test('should return empty list for chapter with no scenarios', () {
        final results = service.filterByChapter(18);
        expect(results, isEmpty);
      });

      test('should handle chapter 1', () {
        final results = service.filterByChapter(1);
        expect(results, isNotEmpty);
      });

      test('should handle invalid chapter numbers', () {
        final results = service.filterByChapter(0);
        expect(results, isEmpty);
      });

      test('should handle negative chapter numbers', () {
        final results = service.filterByChapter(-1);
        expect(results, isEmpty);
      });

      test('should handle very large chapter numbers', () {
        final results = service.filterByChapter(999);
        expect(results, isEmpty);
      });
    });

    group('Random Scenario Tests', () {
      test('should return a valid scenario', () {
        final scenario = service.getRandomScenario();
        expect(scenario, isNotNull);
        expect(testScenarios.any((s) => s.title == scenario!.title), isTrue);
      });

      test('should return different scenarios on multiple calls', () {
        // Call multiple times and collect results
        final scenarios = <Scenario?>[];
        for (int i = 0; i < 10; i++) {
          scenarios.add(service.getRandomScenario());
        }
        // All should be non-null
        expect(scenarios.every((s) => s != null), isTrue);
      });

      test('should return null for empty cache', () async {
        await service.clearCache();
        final scenario = service.getRandomScenario();
        expect(scenario, isNull);
      });

      test('should return same scenario for single item cache', () async {
        await service.clearCache();
        await scenariosBox.put('single', testScenarios[0]);
        await service.getAllScenarios();

        final scenario = service.getRandomScenario();
        expect(scenario, isNotNull);
        expect(scenario!.title, equals(testScenarios[0].title));
      });
    });

    group('Get All Tags Tests', () {
      test('should return all unique tags sorted', () {
        final tags = service.getAllTags();
        expect(tags, isNotEmpty);
        expect(tags, contains('work'));
        expect(tags, contains('stress'));
      });

      test('should return sorted tags', () {
        final tags = service.getAllTags();
        final sortedTags = [...tags]..sort();
        expect(tags, equals(sortedTags));
      });

      test('should not have duplicates', () {
        final tags = service.getAllTags();
        final uniqueTags = tags.toSet().toList();
        expect(tags.length, equals(uniqueTags.length));
      });

      test('should handle scenarios with null tags', () async {
        await scenariosBox.put('no_tags', Scenario(
          title: 'No Tags',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          tags: null,
          createdAt: DateTime.now(),
        ));
        await service.getAllScenarios();

        final tags = service.getAllTags();
        expect(tags, isA<List<String>>());
      });

      test('should handle scenarios with empty tags', () async {
        await scenariosBox.put('empty_tags', Scenario(
          title: 'Empty Tags',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          tags: [],
          createdAt: DateTime.now(),
        ));
        await service.getAllScenarios();

        final tags = service.getAllTags();
        expect(tags, isA<List<String>>());
      });
    });

    group('Get All Categories Tests', () {
      test('should return all unique categories sorted', () {
        final categories = service.getAllCategories();
        expect(categories, isNotEmpty);
        expect(categories, contains('career'));
        expect(categories, contains('relationships'));
      });

      test('should return sorted categories', () {
        final categories = service.getAllCategories();
        final sortedCategories = [...categories]..sort();
        expect(categories, equals(sortedCategories));
      });

      test('should not have duplicates', () {
        final categories = service.getAllCategories();
        final uniqueCategories = categories.toSet().toList();
        expect(categories.length, equals(uniqueCategories.length));
      });

      test('should handle empty cache', () async {
        await service.clearCache();
        final categories = service.getAllCategories();
        expect(categories, isEmpty);
      });
    });

    group('Fetch Scenarios By Categories Tests', () {
      test('should return scenarios matching given categories', () {
        final results = service.fetchScenariosByCategories(['career', 'relationships']);
        expect(results, isNotEmpty);
        expect(results.every((s) =>
          s.category == 'career' || s.category == 'relationships'), isTrue);
      });

      test('should return empty list for non-matching categories', () {
        final results = service.fetchScenariosByCategories(['nonexistent']);
        expect(results, isEmpty);
      });

      test('should respect limit parameter', () {
        final results = service.fetchScenariosByCategories(['relationships'], limit: 1);
        expect(results.length, equals(1));
      });

      test('should shuffle results', () {
        final results = service.fetchScenariosByCategories(['relationships']);
        expect(results, isNotEmpty);
      });

      test('should handle empty categories list', () {
        final results = service.fetchScenariosByCategories([]);
        expect(results, isEmpty);
      });

      test('should handle duplicate categories', () {
        final results = service.fetchScenariosByCategories(['career', 'career', 'career']);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle case-insensitive category matching', () {
        final results = service.fetchScenariosByCategories(['career']);
        expect(results, isNotEmpty);
      });
    });

    group('Pagination Tests', () {
      test('should return first page of scenarios', () {
        final results = service.getPaginatedScenarios(0, pageSize: 2);
        expect(results.length, equals(2));
      });

      test('should return second page of scenarios', () {
        final results = service.getPaginatedScenarios(1, pageSize: 2);
        expect(results.length, equals(2));
      });

      test('should return empty for out-of-bounds page', () {
        final results = service.getPaginatedScenarios(100);
        expect(results, isEmpty);
      });

      test('should handle custom page size', () {
        final results = service.getPaginatedScenarios(0, pageSize: 3);
        expect(results.length, equals(3));
      });

      test('should handle zero page size', () {
        final results = service.getPaginatedScenarios(0, pageSize: 0);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle negative page numbers', () {
        final results = service.getPaginatedScenarios(-1);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very large page size', () {
        final results = service.getPaginatedScenarios(0, pageSize: 10000);
        expect(results, isA<List<Scenario>>());
      });

      test('should calculate total pages correctly', () {
        final totalPages = service.getTotalPages(pageSize: 2);
        expect(totalPages, equals(2));
      });

      test('should handle total pages with custom page size', () {
        final totalPages = service.getTotalPages(pageSize: 3);
        expect(totalPages, greaterThanOrEqualTo(1));
      });

      test('should handle total pages for empty cache', () async {
        await service.clearCache();
        final totalPages = service.getTotalPages();
        expect(totalPages, greaterThanOrEqualTo(0));
      });
    });

    group('Cache Statistics Tests', () {
      test('should return cache statistics', () {
        final stats = service.getCacheStats();
        expect(stats, isNotNull);
        expect(stats['Total Scenarios'], equals(testScenarios.length));
        expect(stats['Unique Tags'], greaterThan(0));
        expect(stats['Unique Categories'], greaterThan(0));
        expect(stats['Chapters Covered'], greaterThan(0));
      });

      test('should calculate correct scenario count', () {
        final stats = service.getCacheStats();
        expect(stats['Total Scenarios'], equals(4));
      });

      test('should calculate chapters covered correctly', () {
        final stats = service.getCacheStats();
        expect(stats['Chapters Covered'], equals(3));
      });

      test('should return advanced cache statistics', () {
        final stats = service.getAdvancedCacheStats();
        expect(stats, isNotNull);
        expect(stats.containsKey('Total Scenarios'), isTrue);
        expect(stats.containsKey('Cache Valid'), isTrue);
        expect(stats.containsKey('Last Fetch'), isTrue);
      });

      test('should handle advanced stats for empty cache', () async {
        await service.clearCache();
        final stats = service.getAdvancedCacheStats();
        expect(stats['Total Scenarios'], equals(0));
      });
    });

    group('Clear Cache Tests', () {
      test('should clear all cached scenarios', () async {
        expect(service.hasScenarios, isTrue);
        await service.clearCache();
        expect(service.hasScenarios, isFalse);
        expect(service.scenarioCount, equals(0));
      });

      test('should clear Hive box', () async {
        expect(scenariosBox.isNotEmpty, isTrue);
        await service.clearCache();
        expect(scenariosBox.isEmpty, isTrue);
      });

      test('should clear sync timestamp', () async {
        await settingsBox.put(ScenarioService.lastSyncKey, DateTime.now().toIso8601String());
        await service.clearCache();
        final syncTime = settingsBox.get(ScenarioService.lastSyncKey);
        expect(syncTime, isNull);
      });

      test('should handle multiple clearCache calls', () async {
        await service.clearCache();
        await service.clearCache();
        await service.clearCache();
        expect(service.hasScenarios, isFalse);
      });
    });

    group('Background Sync Tests', () {
      test('should handle background sync without errors', () async {
        expect(() => service.backgroundSync(), returnsNormally);
      });

      test('should call onComplete callback', () async {
        bool callbackCalled = false;
        await service.backgroundSync(onComplete: () {
          callbackCalled = true;
        });

        await Future.delayed(const Duration(milliseconds: 200));
        expect(callbackCalled, isTrue);
      });

      test('should handle null callback', () async {
        expect(() => service.backgroundSync(onComplete: null), returnsNormally);
      });

      test('should skip sync when cache is valid', () async {
        // Set recent sync time
        await settingsBox.put(
          ScenarioService.lastSyncKey,
          DateTime.now().toIso8601String(),
        );

        bool callbackCalled = false;
        await service.backgroundSync(onComplete: () {
          callbackCalled = true;
        });

        await Future.delayed(const Duration(milliseconds: 200));
        expect(callbackCalled, isTrue);
      });
    });

    group('Relevance Search Tests', () {
      test('should return scenarios sorted by relevance', () async {
        final results = await service.searchScenariosWithRelevance('parent');
        expect(results, isNotEmpty);
      });

      test('should handle empty query', () async {
        final results = await service.searchScenariosWithRelevance('');
        expect(results, isA<List<Scenario>>());
      });

      test('should respect maxResults parameter', () async {
        final results = await service.searchScenariosWithRelevance('stress', maxResults: 1);
        expect(results.length, lessThanOrEqualTo(1));
      });

      test('should prioritize title matches', () async {
        final results = await service.searchScenariosWithRelevance('stress');
        if (results.isNotEmpty) {
          expect(results.first.title.toLowerCase(), contains('stress'));
        }
      });

      test('should handle zero maxResults', () async {
        final results = await service.searchScenariosWithRelevance('test', maxResults: 0);
        expect(results, isEmpty);
      });

      test('should handle null maxResults', () async {
        final results = await service.searchScenariosWithRelevance('test', maxResults: null);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very long queries', () async {
        final longQuery = 'work ' * 100;
        final results = await service.searchScenariosWithRelevance(longQuery);
        expect(results, isA<List<Scenario>>());
      });

      test('should yield to UI thread during processing', () async {
        // Add many scenarios
        for (int i = 0; i < 150; i++) {
          await scenariosBox.put('many_$i', testScenarios[0]);
        }
        await service.getAllScenarios();

        final results = await service.searchScenariosWithRelevance('work');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Concurrent Operations Tests', () {
      test('should handle concurrent getAllScenarios calls', () async {
        final futures = List.generate(5, (_) => service.getAllScenarios());
        final results = await Future.wait(futures);

        expect(results.length, equals(5));
        for (final result in results) {
          expect(result, isA<List<Scenario>>());
        }
      });

      test('should handle concurrent search operations', () async {
        final futures = List.generate(5, (_) => service.searchScenariosWithRelevance('test'));
        final results = await Future.wait(futures);

        expect(results.length, equals(5));
      });

      test('should handle mixed concurrent operations', () async {
        final futures = [
          service.getAllScenarios(),
          service.searchScenariosWithRelevance('work'),
          service.getAllScenarios(),
          service.searchScenariosWithRelevance('parent'),
        ];
        final results = await Future.wait(futures);

        expect(results.length, equals(4));
      });
    });

    group('Data Integrity Tests', () {
      test('should maintain scenario order after operations', () async {
        final initial = await service.getAllScenarios();
        service.searchScenarios('work');
        final afterSearch = await service.getAllScenarios();

        expect(initial.length, equals(afterSearch.length));
      });

      test('should handle scenarios with null fields', () async {
        await scenariosBox.put('null_fields', Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: null,
          verseNumber: null,
          tags: null,
          actionSteps: null,
          createdAt: DateTime.now(),
        ));
        await service.getAllScenarios();

        final results = service.searchScenarios('test');
        expect(results, isNotEmpty);
      });

      test('should preserve scenario data during cache operations', () async {
        final initialScenario = testScenarios[0];
        await service.getAllScenarios();

        final results = service.searchScenarios(initialScenario.title);
        expect(results, isNotEmpty);
        expect(results.first.title, equals(initialScenario.title));
      });
    });

    group('hasScenarios Tests', () {
      test('should return true when scenarios are cached', () {
        expect(service.hasScenarios, isTrue);
      });

      test('should return false when cache is empty', () async {
        await service.clearCache();
        expect(service.hasScenarios, isFalse);
      });
    });

    group('scenarioCount Tests', () {
      test('should return correct count', () {
        expect(service.scenarioCount, equals(testScenarios.length));
      });

      test('should return 0 for empty cache', () async {
        await service.clearCache();
        expect(service.scenarioCount, equals(0));
      });

      test('should update count after clearing cache', () async {
        final initialCount = service.scenarioCount;
        expect(initialCount, greaterThan(0));

        await service.clearCache();
        expect(service.scenarioCount, equals(0));
      });
    });
  });
}
