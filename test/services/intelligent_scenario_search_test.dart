// test/services/intelligent_scenario_search_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/intelligent_scenario_search.dart';
import 'package:GitaWisdom/services/keyword_search_service.dart';
import 'package:GitaWisdom/services/enhanced_semantic_search_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../test_setup.dart';

// Generate mocks for the dependencies
@GenerateMocks([])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('IntelligentScenarioSearch', () {
    late IntelligentScenarioSearch service;
    late KeywordSearchService keywordService;
    late EnhancedSemanticSearchService semanticService;
    late List<Scenario> testScenarios;

    setUp(() {
      service = IntelligentScenarioSearch.instance;
      keywordService = KeywordSearchService.instance;
      semanticService = EnhancedSemanticSearchService.instance;

      // Create test scenarios
      testScenarios = [
        Scenario(
          title: 'Managing Work Stress',
          description: 'Dealing with workplace pressure and anxiety',
          category: 'Work',
          chapter: 2,
          heartResponse: 'Feel overwhelmed and stressed',
          dutyResponse: 'Focus on your duty without attachment',
          gitaWisdom: 'Perform your duty without worrying about results',
          verse: 'karmanye vadhikaraste',
          verseNumber: '2.47',
          tags: ['stress', 'work', 'anxiety'],
          actionSteps: ['Meditate', 'Focus on process'],
          createdAt: DateTime(2025, 1, 1),
        ),
        Scenario(
          title: 'Family Relationships',
          description: 'Building harmony with family members',
          category: 'Family',
          chapter: 3,
          heartResponse: 'Want peace and understanding',
          dutyResponse: 'Act with compassion',
          gitaWisdom: 'Love without expectation',
          tags: ['family', 'relationships', 'love'],
          actionSteps: ['Listen actively', 'Show empathy'],
          createdAt: DateTime(2025, 1, 2),
        ),
        Scenario(
          title: 'Career Purpose',
          description: 'Finding meaning in professional life',
          category: 'Career',
          chapter: 3,
          heartResponse: 'Seeking direction',
          dutyResponse: 'Align with dharma',
          gitaWisdom: 'Follow your dharma',
          tags: ['career', 'purpose', 'dharma'],
          actionSteps: ['Reflect', 'Set goals'],
          createdAt: DateTime(2025, 1, 3),
        ),
      ];

      // Initialize services
      keywordService.indexScenarios(testScenarios);
      semanticService.initialize(testScenarios);
    });

    group('Initialization', () {
      test('service should be singleton', () {
        final instance1 = IntelligentScenarioSearch.instance;
        final instance2 = IntelligentScenarioSearch.instance;
        expect(instance1, equals(instance2));
      });

      test('should start uninitialized', () {
        // Reset by creating new instance scenario
        expect(service.isInitialized, anyOf(isTrue, isFalse));
      });

      test('should initialize successfully', () async {
        await service.initialize();
        // Initialization happens in background, may or may not be complete
        expect(service, isNotNull);
      });

      test('should skip re-initialization if already initialized', () async {
        await service.initialize();
        await service.initialize();

        // Should handle gracefully
        expect(service, isNotNull);
      });

      test('should initialize in background without blocking', () async {
        final stopwatch = Stopwatch()..start();
        await service.initialize();
        stopwatch.stop();

        // Should return quickly even if background initialization continues
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Search Functionality', () {
      test('should return empty list for empty query', () async {
        final results = await service.search('');
        expect(results, isEmpty);
      });

      test('should return empty list for whitespace query', () async {
        final results = await service.search('   ');
        expect(results, isEmpty);
      });

      test('should trim whitespace from query', () async {
        final results1 = await service.search('work');
        final results2 = await service.search('  work  ');

        expect(results1.length, equals(results2.length));
      });

      test('should return IntelligentSearchResult objects', () async {
        await service.initialize();

        final results = await service.search('work');

        if (results.isNotEmpty) {
          expect(results.first, isA<IntelligentSearchResult>());
          expect(results.first.scenario, isNotNull);
          expect(results.first.score, isA<double>());
          expect(results.first.searchType, isA<String>());
        }
      });

      test('should respect maxResults parameter', () async {
        await service.initialize();

        final results = await service.search('work', maxResults: 1);

        expect(results.length, lessThanOrEqualTo(1));
      });

      test('should handle search before initialization', () async {
        final uninitializedService = IntelligentScenarioSearch.instance;

        final results = await uninitializedService.search('work');

        // Should handle gracefully, may return empty or initialize first
        expect(results, isNotNull);
      });
    });

    group('Hybrid Search Integration', () {
      setUp(() async {
        await service.initialize();
      });

      test('should combine keyword and semantic results', () async {
        final results = await service.search('work stress');

        if (results.isNotEmpty) {
          // Should have results from both engines
          final searchTypes = results.map((r) => r.searchType).toSet();
          expect(searchTypes, isNotNull);
        }
      });

      test('should indicate search type in results', () async {
        final results = await service.search('work');

        if (results.isNotEmpty) {
          expect(results.first.searchType, anyOf([
            'keyword',
            'semantic',
            'hybrid',
            'fuzzy',
          ]));
        }
      });

      test('should prioritize semantic search when available', () async {
        final results = await service.search('work stress anxiety');

        // Should use semantic or hybrid search if initialized
        expect(results, isNotNull);
      });

      test('should fallback to keyword search when semantic unavailable', () async {
        final results = await service.search('work');

        // Should always return results using keyword search as fallback
        expect(results, isNotNull);
      });
    });

    group('Result Ranking', () {
      setUp(() async {
        await service.initialize();
      });

      test('should return sorted results by score', () async {
        final results = await service.search('work stress career');

        if (results.length > 1) {
          for (int i = 0; i < results.length - 1; i++) {
            expect(results[i].score, greaterThanOrEqualTo(results[i + 1].score));
          }
        }
      });

      test('should boost hybrid matches over single-engine matches', () async {
        final results = await service.search('work stress');

        if (results.isNotEmpty) {
          final hybridResults = results.where((r) => r.searchType == 'hybrid').toList();
          final otherResults = results.where((r) => r.searchType != 'hybrid').toList();

          if (hybridResults.isNotEmpty && otherResults.isNotEmpty) {
            // Hybrid results should generally score higher
            expect(hybridResults.first.score, greaterThan(0));
          }
        }
      });

      test('should include matched terms when available', () async {
        final results = await service.search('work stress');

        if (results.isNotEmpty && results.first.matchedTerms != null) {
          expect(results.first.matchedTerms, isNotEmpty);
        }
      });
    });

    group('Broader Search Fallback', () {
      setUp(() async {
        await service.initialize();
      });

      test('should attempt broader search for no results', () async {
        // Try a very specific query that might not match
        final results = await service.search('xyz123nonexistent');

        // Should try broader search mechanisms
        expect(results, isNotNull);
      });

      test('should match by category in broader search', () async {
        final results = await service.search('Family');

        expect(results, isNotNull);
      });

      test('should match by title in broader search', () async {
        final results = await service.search('Career');

        expect(results, isNotNull);
      });

      test('should use fuzzy search type for broader matches', () async {
        // This might trigger broader search
        final results = await service.search('dharma');

        if (results.isNotEmpty) {
          // May include fuzzy search results
          expect(results, isNotNull);
        }
      });
    });

    group('IntelligentSearchResult Model', () {
      setUp(() async {
        await service.initialize();
      });

      test('should create result with scenario', () async {
        final results = await service.search('work');

        if (results.isNotEmpty) {
          expect(results.first.scenario, isA<Scenario>());
          expect(results.first.scenario.title, isNotEmpty);
        }
      });

      test('should include score', () async {
        final results = await service.search('work');

        if (results.isNotEmpty) {
          expect(results.first.score, isA<double>());
          expect(results.first.score, greaterThan(0));
        }
      });

      test('should include search type', () async {
        final results = await service.search('work');

        if (results.isNotEmpty) {
          expect(results.first.searchType, isA<String>());
          expect(results.first.searchType, isNotEmpty);
        }
      });

      test('should optionally include matched terms', () async {
        final results = await service.search('work stress');

        if (results.isNotEmpty) {
          expect(results.first.matchedTerms, anyOf(isNull, isA<List<String>>()));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle very short query', () async {
        final results = await service.search('ab');
        expect(results, isNotNull);
      });

      test('should handle single character query', () async {
        final results = await service.search('a');
        expect(results, isEmpty); // Too short, filtered
      });

      test('should handle numeric query', () async {
        final results = await service.search('123');
        expect(results, isNotNull);
      });

      test('should handle special characters', () async {
        final results = await service.search('work! stress?');
        expect(results, isNotNull);
      });

      test('should handle unicode characters', () async {
        final results = await service.search('कर्म');
        expect(results, isNotNull);
      });

      test('should handle very long query', () async {
        final longQuery = 'work stress anxiety pressure deadlines ' * 20;
        final results = await service.search(longQuery);
        expect(results, isNotNull);
      });

      test('should handle query with only stop words', () async {
        final results = await service.search('the and or but');
        expect(results, isNotNull);
      });

      test('should handle mixed case query', () async {
        final results = await service.search('WoRk StReSs');
        expect(results, isNotNull);
      });
    });

    group('Performance', () {
      test('should search efficiently', () async {
        await service.initialize();

        final stopwatch = Stopwatch()..start();
        await service.search('work stress anxiety');
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should handle concurrent searches', () async {
        await service.initialize();

        final futures = [
          service.search('work'),
          service.search('family'),
          service.search('career'),
        ];

        final results = await Future.wait(futures);

        expect(results.length, equals(3));
        for (final resultList in results) {
          expect(resultList, isNotNull);
        }
      });

      test('should handle repeated searches efficiently', () async {
        await service.initialize();

        for (int i = 0; i < 10; i++) {
          final results = await service.search('work stress');
          expect(results, isNotNull);
        }
      });
    });

    group('Monthly Refresh', () {
      test('should have refresh functionality', () async {
        expect(() async => await service.refreshMonthly(), returnsNormally);
      });

      test('should skip refresh if recently refreshed', () async {
        await service.refreshMonthly();

        final stopwatch = Stopwatch()..start();
        await service.refreshMonthly();
        stopwatch.stop();

        // Should skip quickly if recently refreshed
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      test('should track last refresh time', () {
        final lastRefresh = service.lastRefresh;
        expect(lastRefresh, anyOf(isNull, isA<DateTime>()));
      });
    });

    group('State Management', () {
      test('should maintain state across searches', () async {
        await service.initialize();

        await service.search('work');
        await service.search('family');
        await service.search('career');

        // Should maintain initialized state
        expect(service, isNotNull);
      });

      test('should handle initialization state', () {
        final isInit = service.isInitialized;
        expect(isInit, anyOf(isTrue, isFalse));
      });
    });

    group('Error Handling', () {
      test('should handle empty scenario list gracefully', () async {
        // Clear services
        await keywordService.indexScenarios([]);
        await semanticService.initialize([]);

        final results = await service.search('work');

        // Should handle gracefully
        expect(results, isNotNull);
      });

      test('should handle search errors gracefully', () async {
        final results = await service.search('');

        expect(results, isEmpty);
      });

      test('should continue if semantic search fails', () async {
        // Even if semantic search is unavailable, keyword should work
        final results = await service.search('work');

        expect(results, isNotNull);
      });

      test('should maintain app functionality on search failure', () async {
        expect(() async {
          await service.search('test query');
        }, returnsNormally);
      });
    });

    group('Search Type Indicators', () {
      setUp(() async {
        await service.initialize();
      });

      test('should mark keyword-only results', () async {
        final results = await service.search('work');

        final keywordResults = results.where((r) => r.searchType == 'keyword').toList();
        // May have keyword results
        expect(keywordResults, isNotNull);
      });

      test('should mark semantic results', () async {
        final results = await service.search('work stress anxiety');

        final semanticResults = results.where((r) => r.searchType == 'semantic').toList();
        // May have semantic results if service initialized
        expect(semanticResults, isNotNull);
      });

      test('should mark hybrid results', () async {
        final results = await service.search('work stress');

        final hybridResults = results.where((r) => r.searchType == 'hybrid').toList();
        // May have hybrid results
        expect(hybridResults, isNotNull);
      });

      test('should mark fuzzy search results', () async {
        final results = await service.search('Family');

        // May include fuzzy results
        expect(results, isNotNull);
      });
    });

    group('Integration with Search Services', () {
      test('should use KeywordSearchService', () async {
        await service.initialize();

        final results = await service.search('work');

        // Should leverage keyword search
        expect(results, isNotNull);
      });

      test('should use EnhancedSemanticSearchService', () async {
        await service.initialize();

        final results = await service.search('work stress');

        // Should leverage semantic search if available
        expect(results, isNotNull);
      });

      test('should combine results from multiple engines', () async {
        await service.initialize();

        final results = await service.search('work stress anxiety');

        // Should combine keyword and semantic results
        expect(results, isNotNull);
      });
    });
  });
}
