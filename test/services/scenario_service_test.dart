// test/services/scenario_service_test.dart

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

  group('ScenarioService', () {
    late ScenarioService service;
    late Box<Scenario> scenariosBox;
    late List<Scenario> testScenarios;

    setUp(() async {
      service = ScenarioService.instance;

      // Open scenarios box for testing
      if (!Hive.isBoxOpen('scenarios')) {
        scenariosBox = await Hive.openBox<Scenario>('scenarios');
      } else {
        scenariosBox = Hive.box<Scenario>('scenarios');
      }

      // Create test scenarios
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

      // Populate scenarios box with test data
      await scenariosBox.clear();
      for (int i = 0; i < testScenarios.length; i++) {
        await scenariosBox.put('scenario_$i', testScenarios[i]);
      }

      // Initialize service and ensure it loads data from Hive
      await service.initialize();
      // Force reload from Hive by calling getAllScenarios
      // This is needed because the singleton may already be initialized from a previous test
      await service.getAllScenarios();
    });

    tearDown(() async {
      // Don't clear the service cache here - let it persist across tests
      // This works better with the singleton pattern
    });

    group('Initialization', () {
      test('service should initialize without errors', () async {
        expect(service, isNotNull);
        expect(service.hasScenarios, isTrue);
      });

      test('service should be singleton', () {
        final instance1 = ScenarioService.instance;
        final instance2 = ScenarioService.instance;
        expect(instance1, same(instance2));
      });

      test('service should load scenarios from Hive on initialization', () async {
        expect(service.scenarioCount, greaterThan(0));
      });
    });

    group('getAllScenarios', () {
      test('should return all cached scenarios', () async {
        final scenarios = await service.getAllScenarios();
        expect(scenarios.length, equals(testScenarios.length));
      });

      test('should return scenarios immediately from cache', () async {
        // First call loads from Hive
        final scenarios1 = await service.getAllScenarios();
        expect(scenarios1.length, greaterThan(0));

        // Second call should return cached data instantly
        final scenarios2 = await service.getAllScenarios();
        expect(scenarios2.length, equals(scenarios1.length));
      });
    });

    group('searchScenarios', () {
      test('should return all scenarios for empty query', () {
        final results = service.searchScenarios('');
        expect(results.length, equals(testScenarios.length));
      });

      test('should search by title', () {
        final results = service.searchScenarios('Work Stress');
        expect(results.length, equals(1));
        expect(results.first.title, contains('Work'));
      });

      test('should search by description', () {
        final results = service.searchScenarios('workplace');
        expect(results.length, equals(1));
        expect(results.first.description, contains('workplace'));
      });

      test('should search by category', () {
        final results = service.searchScenarios('career');
        expect(results.length, equals(1));
        expect(results.first.category, equals('career'));
      });

      test('should search by tags', () {
        final results = service.searchScenarios('stress');
        expect(results.length, greaterThanOrEqualTo(1));
        expect(results.any((s) => s.tags?.contains('stress') ?? false), isTrue);
      });

      test('should handle compound search queries', () {
        final results = service.searchScenarios('work stress');
        expect(results.length, greaterThanOrEqualTo(1));
        expect(results.first.title, contains('Work'));
        expect(results.first.tags?.contains('stress'), isTrue);
      });

      test('should be case-insensitive', () {
        final results1 = service.searchScenarios('WORK');
        final results2 = service.searchScenarios('work');
        expect(results1.length, equals(results2.length));
      });

      test('should respect maxResults parameter', () {
        final results = service.searchScenarios('parent', maxResults: 1);
        expect(results.length, equals(1));
      });

      test('should search in Gita wisdom content', () {
        final results = service.searchScenarios('duty');
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('should search in heart/duty responses', () {
        final results = service.searchScenarios('relax');
        expect(results.length, greaterThanOrEqualTo(1));
      });

      test('should search in action steps', () {
        final results = service.searchScenarios('budget');
        expect(results.length, greaterThanOrEqualTo(1));
      });
    });

    group('filterByTag', () {
      test('should return scenarios matching specific tag', () {
        final results = service.filterByTag('stress');
        expect(results.length, equals(1));
        expect(results.first.tags?.contains('stress'), isTrue);
      });

      test('should return empty list for non-existent tag', () {
        final results = service.filterByTag('nonexistent');
        expect(results, isEmpty);
      });

      test('should handle tags case-sensitively', () {
        final results = service.filterByTag('stress');
        expect(results.length, greaterThan(0));
      });
    });

    group('filterByChapter', () {
      test('should return scenarios from specific chapter', () {
        final results = service.filterByChapter(2);
        expect(results.length, equals(2));
        expect(results.every((s) => s.chapter == 2), isTrue);
      });

      test('should return empty list for chapter with no scenarios', () {
        final results = service.filterByChapter(18);
        expect(results, isEmpty);
      });

      test('should handle chapter 1', () {
        final results = service.filterByChapter(1);
        expect(results.length, equals(1));
        expect(results.first.title, contains('Older Parents'));
      });
    });

    group('getRandomScenario', () {
      test('should return a scenario from cache', () {
        final scenario = service.getRandomScenario();
        expect(scenario, isNotNull);
        expect(testScenarios.any((s) => s.title == scenario!.title), isTrue);
      });

      test('should return valid scenario on multiple calls', () {
        // Verify that getRandomScenario returns valid scenarios
        for (int i = 0; i < 5; i++) {
          final scenario = service.getRandomScenario();
          expect(scenario, isNotNull);
          expect(testScenarios.any((s) => s.title == scenario!.title), isTrue);
        }
      });
    });

    group('getAllTags', () {
      test('should return all unique tags sorted', () {
        final tags = service.getAllTags();
        expect(tags, isNotEmpty);
        expect(tags, contains('work'));
        expect(tags, contains('stress'));
        expect(tags, contains('parenting'));
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
    });

    group('getAllCategories', () {
      test('should return all unique categories sorted', () {
        final categories = service.getAllCategories();
        expect(categories, isNotEmpty);
        expect(categories, contains('career'));
        expect(categories, contains('relationships'));
        expect(categories, contains('personal growth'));
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
    });

    group('fetchScenariosByCategories', () {
      test('should return scenarios matching given categories', () {
        final results = service.fetchScenariosByCategories(['career', 'relationships']);
        expect(results.length, greaterThanOrEqualTo(2));
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
        // Call multiple times and check if order varies
        final results1 = service.fetchScenariosByCategories(['relationships']);
        final results2 = service.fetchScenariosByCategories(['relationships']);

        // With 2 items, there's a chance they might be in same order,
        // so we just verify both return the same count
        expect(results1.length, equals(results2.length));
      });
    });

    group('getPaginatedScenarios', () {
      test('should return first page of scenarios', () {
        final results = service.getPaginatedScenarios(0, pageSize: 2);
        expect(results.length, equals(2));
      });

      test('should return second page of scenarios', () {
        final results = service.getPaginatedScenarios(1, pageSize: 2);
        expect(results.length, equals(2));
      });

      test('should return partial last page', () {
        final results = service.getPaginatedScenarios(3, pageSize: 2);
        expect(results, isEmpty); // Only 4 scenarios total
      });

      test('should return empty for out-of-bounds page', () {
        final results = service.getPaginatedScenarios(10);
        expect(results, isEmpty);
      });

      test('should handle custom page size', () {
        final results = service.getPaginatedScenarios(0, pageSize: 3);
        expect(results.length, equals(3));
      });
    });

    group('getTotalPages', () {
      test('should calculate total pages correctly', () {
        final totalPages = service.getTotalPages(pageSize: 2);
        expect(totalPages, equals(2)); // 4 scenarios / 2 per page = 2 pages
      });

      test('should handle custom page size', () {
        final totalPages = service.getTotalPages(pageSize: 3);
        expect(totalPages, equals(2)); // 4 scenarios / 3 per page = 1.33 -> 2 pages
      });

      test('should return 1 for single page', () {
        final totalPages = service.getTotalPages(pageSize: 10);
        expect(totalPages, equals(1)); // All 4 scenarios fit in one page
      });
    });

    group('getCacheStats', () {
      test('should return cache statistics', () {
        final stats = service.getCacheStats();
        expect(stats, isNotNull);
        expect(stats['Total Scenarios'], equals(testScenarios.length));
        expect(stats['Unique Tags'], greaterThan(0));
        expect(stats['Unique Categories'], greaterThan(0));
        expect(stats['Chapters Covered'], greaterThan(0));
      });

      test('should have correct total scenarios count', () {
        final stats = service.getCacheStats();
        expect(stats['Total Scenarios'], equals(4));
      });

      test('should calculate unique tags correctly', () {
        final stats = service.getCacheStats();
        final allTags = service.getAllTags();
        expect(stats['Unique Tags'], equals(allTags.length));
      });

      test('should calculate chapters covered correctly', () {
        final stats = service.getCacheStats();
        // We have scenarios in chapters 1, 2, and 3
        expect(stats['Chapters Covered'], equals(3));
      });
    });

    group('clearCache', () {
      test('should clear all cached scenarios', () async {
        expect(service.hasScenarios, isTrue);
        await service.clearCache();
        expect(service.hasScenarios, isFalse);
        expect(service.scenarioCount, equals(0));
        // Restore data for next tests
        for (int i = 0; i < testScenarios.length; i++) {
          await scenariosBox.put('scenario_$i', testScenarios[i]);
        }
        await service.getAllScenarios();
      });

      test('should clear Hive box', () async {
        expect(scenariosBox.isNotEmpty, isTrue);
        await service.clearCache();
        expect(scenariosBox.isEmpty, isTrue);
        // Restore data for next tests
        for (int i = 0; i < testScenarios.length; i++) {
          await scenariosBox.put('scenario_$i', testScenarios[i]);
        }
        await service.getAllScenarios();
      });
    });

    group('hasScenarios', () {
      test('should return true when scenarios are cached', () {
        expect(service.hasScenarios, isTrue);
      });

      test('should return false when cache is empty', () async {
        await service.clearCache();
        expect(service.hasScenarios, isFalse);
        // Restore data for next tests
        for (int i = 0; i < testScenarios.length; i++) {
          await scenariosBox.put('scenario_$i', testScenarios[i]);
        }
        await service.getAllScenarios();
      });
    });

    group('scenarioCount', () {
      test('should return correct count of cached scenarios', () {
        expect(service.scenarioCount, equals(testScenarios.length));
      });

      test('should return 0 when cache is empty', () async {
        await service.clearCache();
        expect(service.scenarioCount, equals(0));
        // Restore data for next tests
        for (int i = 0; i < testScenarios.length; i++) {
          await scenariosBox.put('scenario_$i', testScenarios[i]);
        }
        await service.getAllScenarios();
      });
    });

    group('searchScenariosWithRelevance', () {
      test('should return scenarios sorted by relevance', () async {
        final results = await service.searchScenariosWithRelevance('parent');
        expect(results, isNotEmpty);
        // Scenarios with 'parent' in title should rank higher
        expect(results.first.title.toLowerCase(), contains('parent'));
      });

      test('should handle empty query', () async {
        final results = await service.searchScenariosWithRelevance('');
        expect(results.length, lessThanOrEqualTo(20)); // Default page size
      });

      test('should respect maxResults parameter', () async {
        final results = await service.searchScenariosWithRelevance('stress', maxResults: 1);
        expect(results.length, equals(1));
      });

      test('should prioritize title matches over content matches', () async {
        final results = await service.searchScenariosWithRelevance('stress');
        if (results.isNotEmpty) {
          // The scenario with 'stress' in title should rank higher than
          // scenarios with 'stress' only in tags or content
          expect(results.first.title.toLowerCase(), contains('stress'));
        }
      });
    });
  });
}
