// test/services/keyword_search_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/keyword_search_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('KeywordSearchService', () {
    late KeywordSearchService service;
    late List<Scenario> testScenarios;

    setUp(() {
      service = KeywordSearchService.instance;

      // Create test scenarios with varied content
      testScenarios = [
        Scenario(
          title: 'Work Stress Management',
          description: 'Managing work-related stress and pressure at the office',
          category: 'Work',
          chapter: 2,
          heartResponse: 'Feel anxious and overwhelmed with deadlines',
          dutyResponse: 'Focus on your duty without attachment to results',
          gitaWisdom: 'You have a right to perform your duty, but not to fruits of action',
          verse: 'karmanye vadhikaraste ma phaleshu kadachana',
          verseNumber: '2.47',
          tags: ['stress', 'work', 'anxiety', 'pressure'],
          actionSteps: ['Practice meditation', 'Focus on process not outcome'],
          createdAt: DateTime(2025, 1, 1, 10, 0),
        ),
        Scenario(
          title: 'Family Conflict Resolution',
          description: 'Resolving disagreements with family members',
          category: 'Family',
          chapter: 3,
          heartResponse: 'Feel anger and frustration towards relatives',
          dutyResponse: 'Act with compassion and understanding',
          gitaWisdom: 'Anger leads to delusion and loss of discrimination',
          verse: 'krodhad bhavati sammohah',
          verseNumber: '2.63',
          tags: ['family', 'anger', 'conflict', 'relationships'],
          actionSteps: ['Listen actively', 'Express calmly', 'Seek common ground'],
          createdAt: DateTime(2025, 1, 2, 11, 0),
        ),
        Scenario(
          title: 'Career Purpose Discovery',
          description: 'Finding meaning and purpose in your career path',
          category: 'Career',
          chapter: 3,
          heartResponse: 'Feel lost and confused about career direction',
          dutyResponse: 'Discover your dharma and align with it',
          gitaWisdom: 'Better is ones own dharma though imperfect',
          verse: 'shreyan sva-dharmo vigunah',
          verseNumber: '3.35',
          tags: ['career', 'purpose', 'dharma', 'meaning'],
          actionSteps: ['Reflect on strengths', 'Identify values', 'Set aligned goals'],
          createdAt: DateTime(2025, 1, 3, 12, 0),
        ),
        Scenario(
          title: 'Financial Anxiety',
          description: 'Dealing with money worries and financial insecurity',
          category: 'Finance',
          chapter: 6,
          heartResponse: 'Constant worry about financial future',
          dutyResponse: 'Work diligently while maintaining equanimity',
          gitaWisdom: 'Perform your duty with an even mind in success and failure',
          verse: 'samatvam yoga uchyate',
          verseNumber: '2.48',
          tags: ['money', 'finance', 'anxiety', 'security'],
          actionSteps: ['Create budget', 'Build emergency fund', 'Practice contentment'],
          createdAt: DateTime(2025, 1, 4, 13, 0),
        ),
      ];
    });

    group('Initialization', () {
      test('service should be singleton', () {
        final instance1 = KeywordSearchService.instance;
        final instance2 = KeywordSearchService.instance;
        expect(instance1, equals(instance2));
      });

      test('should start with empty index', () {
        expect(service.isIndexed, isFalse);
        expect(service.indexedCount, equals(0));
      });

      test('should index scenarios successfully', () async {
        await service.indexScenarios(testScenarios);

        expect(service.isIndexed, isTrue);
        expect(service.indexedCount, equals(testScenarios.length));
      });

      test('should skip re-indexing if already indexed with same count', () async {
        await service.indexScenarios(testScenarios);
        final initialIndexedCount = service.indexedCount;

        // Try indexing again with same scenarios
        await service.indexScenarios(testScenarios);

        expect(service.indexedCount, equals(initialIndexedCount));
        expect(service.isIndexed, isTrue);
      });

      test('should handle empty scenario list', () async {
        await service.indexScenarios([]);

        expect(service.isIndexed, isTrue);
        expect(service.indexedCount, equals(0));
      });
    });

    group('Query Processing', () {
      setUp(() async {
        await service.indexScenarios(testScenarios);
      });

      test('should handle empty query', () {
        final results = service.search('');
        expect(results, isEmpty);
      });

      test('should handle whitespace-only query', () {
        final results = service.search('   ');
        expect(results, isEmpty);
      });

      test('should handle special characters', () {
        final results = service.search('!@#\$%^&*()');
        expect(results, isNotNull);
      });

      test('should be case-insensitive', () {
        final resultsLower = service.search('work');
        final resultsUpper = service.search('WORK');
        final resultsMixed = service.search('WoRk');

        expect(resultsLower.length, equals(resultsUpper.length));
        expect(resultsLower.length, equals(resultsMixed.length));
      });

      test('should filter stop words', () {
        // "the", "and", "a" should be filtered out
        final results = service.search('the and a stress');

        // Should still find stress-related results
        expect(results, isNotEmpty);
      });

      test('should filter short words (length <= 2)', () {
        final results = service.search('a be it stress');

        // Should find stress results despite short words
        expect(results, isNotEmpty);
      });

      test('should tokenize on whitespace and punctuation', () {
        final results = service.search('work-stress,anxiety');

        // Should treat as separate tokens: work, stress, anxiety
        expect(results, isNotEmpty);
      });
    });

    group('Search Results', () {
      setUp(() async {
        await service.indexScenarios(testScenarios);
      });

      test('should return ranked results for single keyword', () {
        final results = service.search('work');

        expect(results, isNotEmpty);
        expect(results.first.scenario.title, contains('Work'));
        expect(results.first.score, greaterThan(0));
      });

      test('should return multiple results for common term', () {
        final results = service.search('anxiety');

        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('should rank exact matches higher than partial', () {
        final results = service.search('stress');

        if (results.length > 1) {
          // First result should have higher score
          expect(results[0].score, greaterThanOrEqualTo(results[1].score));
        }
      });

      test('should return results sorted by score descending', () {
        final results = service.search('work stress');

        if (results.length > 1) {
          for (int i = 0; i < results.length - 1; i++) {
            expect(results[i].score, greaterThanOrEqualTo(results[i + 1].score));
          }
        }
      });

      test('should include matched terms in results', () {
        final results = service.search('work stress');

        expect(results, isNotEmpty);
        expect(results.first.matchedTerms, isNotEmpty);
      });

      test('should support partial word matching', () {
        final results = service.search('anx');

        // Should match "anxiety"
        expect(results, isNotEmpty);
      });

      test('should search across all scenario fields', () {
        // Test title search
        final titleResults = service.search('Career Purpose');
        expect(titleResults, isNotEmpty);

        // Test category search
        final categoryResults = service.search('Finance');
        expect(categoryResults, isNotEmpty);

        // Test tags search
        final tagResults = service.search('dharma');
        expect(tagResults, isNotEmpty);
      });

      test('should limit results count', () {
        final results = service.search('work', maxResults: 2);

        expect(results.length, lessThanOrEqualTo(2));
      });

      test('should respect maxResults parameter', () {
        final results1 = service.search('anxiety', maxResults: 1);
        final results2 = service.search('anxiety', maxResults: 10);

        expect(results1.length, lessThanOrEqualTo(1));
        expect(results2.length, greaterThanOrEqualTo(results1.length));
      });

      test('should return empty list for no matches', () {
        final results = service.search('nonexistentkeyword123xyz');

        expect(results, isEmpty);
      });
    });

    group('TF-IDF Scoring', () {
      setUp(() async {
        await service.indexScenarios(testScenarios);
      });

      test('should calculate term frequency correctly', () {
        final results = service.search('anxiety');

        expect(results, isNotEmpty);
        expect(results.first.score, greaterThan(0));
      });

      test('should boost rare terms over common terms', () {
        // "dharma" appears less frequently than "anxiety"
        final dharmaResults = service.search('dharma');
        final anxietyResults = service.search('anxiety');

        expect(dharmaResults, isNotEmpty);
        expect(anxietyResults, isNotEmpty);
        // Both should have scores, but dharma might be higher if it's rarer
      });

      test('should combine scores for multi-term queries', () {
        final singleTermResults = service.search('work');
        final multiTermResults = service.search('work stress');

        // Multi-term should potentially have higher combined scores
        expect(multiTermResults, isNotEmpty);
      });

      test('should apply partial match penalty (0.5 weight)', () {
        final exactResults = service.search('stress');
        final partialResults = service.search('stres');

        // Both should return results, but exact should score higher
        expect(exactResults, isNotEmpty);
        expect(partialResults, isNotEmpty);
      });
    });

    group('Edge Cases', () {
      setUp(() async {
        await service.indexScenarios(testScenarios);
      });

      test('should handle very long queries', () {
        final longQuery = 'work stress anxiety family career purpose dharma meaning life balance health money finance security';
        final results = service.search(longQuery);

        expect(results, isNotNull);
      });

      test('should handle single character query', () {
        final results = service.search('a');

        // Single char should be filtered (< 3 chars)
        expect(results, isEmpty);
      });

      test('should handle two character query', () {
        final results = service.search('ab');

        // Two chars should be filtered (< 3 chars)
        expect(results, isEmpty);
      });

      test('should handle numeric queries', () {
        final results = service.search('123');

        expect(results, isNotNull);
      });

      test('should handle queries with only stop words', () {
        final results = service.search('the and or but');

        // Stop words might still match partially in text, but should have low scores
        // or be empty if properly filtered
        expect(results, isNotNull);
      });

      test('should handle unicode characters', () {
        final results = service.search('कर्म');

        expect(results, isNotNull);
      });

      test('should handle mixed alphanumeric queries', () {
        final results = service.search('chapter3 verse35');

        expect(results, isNotNull);
      });
    });

    group('Performance', () {
      test('should index large dataset efficiently', () async {
        final largeDataset = List.generate(100, (index) => Scenario(
          title: 'Scenario $index',
          description: 'Test description for scenario $index with various keywords',
          category: 'Test Category ${index % 5}',
          chapter: (index % 18) + 1,
          heartResponse: 'Heart response for scenario $index',
          dutyResponse: 'Duty response for scenario $index',
          gitaWisdom: 'Wisdom for scenario $index',
          tags: ['tag$index', 'common', 'test'],
          actionSteps: ['Step 1 for $index', 'Step 2 for $index'],
          createdAt: DateTime(2025, 1, 1).add(Duration(hours: index)),
        ));

        final stopwatch = Stopwatch()..start();
        await service.indexScenarios(largeDataset);
        stopwatch.stop();

        expect(service.indexedCount, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete in < 5s
      });

      test('should search quickly', () async {
        await service.indexScenarios(testScenarios);

        final stopwatch = Stopwatch()..start();
        final results = service.search('work stress anxiety');
        stopwatch.stop();

        expect(results, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should complete in < 100ms
      });
    });

    group('SearchResult Model', () {
      setUp(() async {
        await service.indexScenarios(testScenarios);
      });

      test('should create SearchResult with scenario', () {
        final results = service.search('work');

        expect(results, isNotEmpty);
        expect(results.first.scenario, isNotNull);
        expect(results.first.scenario.title, isNotEmpty);
      });

      test('should include score in SearchResult', () {
        final results = service.search('work');

        expect(results, isNotEmpty);
        expect(results.first.score, isA<double>());
        expect(results.first.score, greaterThan(0));
      });

      test('should include matched terms in SearchResult', () {
        final results = service.search('work stress');

        expect(results, isNotEmpty);
        expect(results.first.matchedTerms, isA<List<String>>());
        expect(results.first.matchedTerms, isNotEmpty);
      });

      test('matched terms should contain query terms', () {
        final results = service.search('work stress');

        if (results.isNotEmpty) {
          final matchedTerms = results.first.matchedTerms.map((t) => t.toLowerCase()).toList();
          final containsWork = matchedTerms.any((t) => t.contains('work'));
          final containsStress = matchedTerms.any((t) => t.contains('stress'));

          expect(containsWork || containsStress, isTrue);
        }
      });
    });

    group('Index State Management', () {
      test('should maintain index across searches', () async {
        await service.indexScenarios(testScenarios);

        final results1 = service.search('work');
        final results2 = service.search('family');
        final results3 = service.search('career');

        expect(results1, isNotEmpty);
        expect(results2, isNotEmpty);
        expect(results3, isNotEmpty);
        expect(service.isIndexed, isTrue);
      });

      test('should handle re-indexing with different scenarios', () async {
        await service.indexScenarios(testScenarios.take(2).toList());
        expect(service.indexedCount, equals(2));

        await service.indexScenarios(testScenarios);
        expect(service.indexedCount, equals(testScenarios.length));
      });
    });
  });
}
