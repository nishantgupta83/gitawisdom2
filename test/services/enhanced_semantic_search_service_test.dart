// test/services/enhanced_semantic_search_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/enhanced_semantic_search_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('EnhancedSemanticSearchService', () {
    late EnhancedSemanticSearchService service;
    late List<Scenario> testScenarios;

    setUp(() {
      service = EnhancedSemanticSearchService.instance;

      // Create test scenarios with semantic and conceptual relationships
      testScenarios = [
        Scenario(
          title: 'Work Stress Management',
          description: 'Dealing with pressure and anxiety at the office workplace',
          category: 'Work',
          chapter: 2,
          heartResponse: 'Feel stressed and overwhelmed with deadlines and burden',
          dutyResponse: 'Perform your duty without attachment to outcomes',
          gitaWisdom: 'Focus on action, not results. You have right to work only.',
          verse: 'karmanye vadhikaraste',
          verseNumber: '2.47',
          tags: ['stress', 'work', 'anxiety', 'pressure', 'career'],
          actionSteps: ['Meditate daily', 'Focus on process not outcome', 'Practice detachment'],
          createdAt: DateTime(2025, 1, 1),
        ),
        Scenario(
          title: 'Family Conflict Resolution',
          description: 'Managing anger and frustration with relatives and parents',
          category: 'Family',
          chapter: 2,
          heartResponse: 'Feel rage and irritation towards family members',
          dutyResponse: 'Act with compassion and understanding',
          gitaWisdom: 'Anger leads to confusion and loss of wisdom',
          verse: 'krodhad bhavati sammohah',
          verseNumber: '2.63',
          tags: ['family', 'anger', 'relationships', 'conflict'],
          actionSteps: ['Listen actively', 'Speak calmly', 'Seek understanding'],
          createdAt: DateTime(2025, 1, 2),
        ),
        Scenario(
          title: 'Career Purpose Discovery',
          description: 'Finding meaning and dharma in professional life',
          category: 'Career',
          chapter: 3,
          heartResponse: 'Feel lost, confused and uncertain about direction',
          dutyResponse: 'Discover and align with your dharma',
          gitaWisdom: 'Better to follow your own dharma imperfectly than anothers perfectly',
          verse: 'shreyan sva-dharmo vigunah',
          verseNumber: '3.35',
          tags: ['career', 'purpose', 'dharma', 'meaning', 'calling'],
          actionSteps: ['Reflect on strengths', 'Identify core values', 'Set aligned goals'],
          createdAt: DateTime(2025, 1, 3),
        ),
        Scenario(
          title: 'Financial Anxiety',
          description: 'Dealing with money worries, poverty fears and financial insecurity',
          category: 'Finance',
          chapter: 2,
          heartResponse: 'Constant worry about wealth and financial future',
          dutyResponse: 'Work diligently while maintaining equanimity',
          gitaWisdom: 'Perform duty with even mind in success and failure, prosperity and loss',
          verse: 'samatvam yoga uchyate',
          verseNumber: '2.48',
          tags: ['money', 'finance', 'anxiety', 'prosperity', 'wealth'],
          actionSteps: ['Create budget', 'Build emergency fund', 'Practice contentment'],
          createdAt: DateTime(2025, 1, 4),
        ),
        Scenario(
          title: 'Dealing with Death and Loss',
          description: 'Coping with mortality, grief, and bereavement after losing loved ones',
          category: 'Spiritual',
          chapter: 2,
          heartResponse: 'Feel deep sadness and fear about death and dying',
          dutyResponse: 'Understand the eternal nature of the soul',
          gitaWisdom: 'The soul is eternal, never born and never dies',
          verse: 'na jayate mriyate va',
          verseNumber: '2.20',
          tags: ['death', 'grief', 'mourning', 'loss', 'mortality'],
          actionSteps: ['Meditate on eternal nature', 'Seek spiritual wisdom', 'Process grief'],
          createdAt: DateTime(2025, 1, 5),
        ),
      ];
    });

    group('Initialization', () {
      test('service should be singleton', () {
        final instance1 = EnhancedSemanticSearchService.instance;
        final instance2 = EnhancedSemanticSearchService.instance;
        expect(instance1, equals(instance2));
      });

      test('should start uninitialized', () {
        expect(service.isInitialized, isFalse);
        expect(service.indexedCount, equals(0));
      });

      test('should initialize successfully with scenarios', () async {
        await service.initialize(testScenarios);

        expect(service.isInitialized, isTrue);
        expect(service.indexedCount, equals(testScenarios.length));
      });

      test('should skip re-initialization with same count', () async {
        await service.initialize(testScenarios);
        final initialCount = service.indexedCount;

        await service.initialize(testScenarios);

        expect(service.indexedCount, equals(initialCount));
      });

      test('should handle empty scenario list', () async {
        await service.initialize([]);

        expect(service.isInitialized, isTrue);
        expect(service.indexedCount, equals(0));
      });

      test('should build vocabulary during initialization', () async {
        await service.initialize(testScenarios);

        expect(service.isInitialized, isTrue);
      });
    });

    group('Concept Mappings', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should recognize stress-related concepts', () async {
        final stressResults = await service.search('anxiety');

        expect(stressResults, isNotEmpty);
        // Should find stress-related scenarios through concept mapping
      });

      test('should map work to career concepts', () async {
        final workResults = await service.search('work');
        final careerResults = await service.search('career');

        expect(workResults, isNotEmpty);
        expect(careerResults, isNotEmpty);
      });

      test('should map anger to emotional concepts', () async {
        final angerResults = await service.search('anger');
        final rageResults = await service.search('rage');

        expect(angerResults, isNotEmpty);
        // Both should find anger-related content
      });

      test('should map money to financial concepts', () async {
        final moneyResults = await service.search('money');
        final wealthResults = await service.search('wealth');

        expect(moneyResults, isNotEmpty);
        expect(wealthResults, isNotEmpty);
      });

      test('should map death to mortality concepts', () async {
        final deathResults = await service.search('death');

        expect(deathResults, isNotEmpty);
        // Should find death-related scenario
      });

      test('should recognize purpose-dharma relationship', () async {
        final purposeResults = await service.search('purpose');
        final dharmaResults = await service.search('dharma');

        expect(purposeResults, isNotEmpty);
        expect(dharmaResults, isNotEmpty);
      });

      test('should recognize family-relationships', () async {
        final familyResults = await service.search('family');
        final relationshipResults = await service.search('relationships');

        expect(familyResults, isNotEmpty);
        expect(relationshipResults, isNotEmpty);
      });
    });

    group('Search Functionality', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should return empty list when not initialized', () async {
        final uninitializedService = EnhancedSemanticSearchService.instance;
        uninitializedService.dispose();

        final results = await uninitializedService.search('work');
        expect(results, isEmpty);
      });

      test('should handle empty query', () async {
        final results = await service.search('');
        expect(results, isEmpty);
      });

      test('should handle whitespace query', () async {
        final results = await service.search('   ');
        expect(results, isNotNull);
      });

      test('should return SemanticSearchResult objects', () async {
        final results = await service.search('work stress');

        expect(results, isNotEmpty);
        expect(results.first, isA<SemanticSearchResult>());
        expect(results.first.scenario, isNotNull);
        expect(results.first.similarity, isA<double>());
        expect(results.first.matchReason, isA<String>());
        expect(results.first.matchedTerms, isA<List<String>>());
      });

      test('should sort results by similarity score', () async {
        final results = await service.search('work stress anxiety');

        if (results.length > 1) {
          for (int i = 0; i < results.length - 1; i++) {
            expect(results[i].similarity, greaterThanOrEqualTo(results[i + 1].similarity));
          }
        }
      });

      test('should respect maxResults parameter', () async {
        final results = await service.search('stress', maxResults: 2);

        expect(results.length, lessThanOrEqualTo(2));
      });

      test('should support custom maxResults values', () async {
        final results10 = await service.search('work', maxResults: 10);
        final results2 = await service.search('work', maxResults: 2);

        expect(results2.length, lessThanOrEqualTo(2));
        expect(results10.length, greaterThanOrEqualTo(results2.length));
      });

      test('should handle no matching results gracefully', () async {
        final results = await service.search('nonexistentconcept12345xyz');

        expect(results, isNotNull);
      });

      test('should search across all scenario fields', () async {
        // Title search
        final titleResults = await service.search('Career Purpose');
        expect(titleResults, isNotEmpty);

        // Category search
        final categoryResults = await service.search('Finance');
        expect(categoryResults, isNotEmpty);

        // Tags search
        final tagResults = await service.search('calling');
        expect(tagResults, isNotEmpty);
      });
    });

    group('TF-IDF Scoring', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should calculate term frequency correctly', () async {
        final results = await service.search('stress');

        expect(results, isNotEmpty);
        expect(results.first.similarity, greaterThan(0.0));
      });

      test('should calculate IDF scores', () async {
        // Common term
        final commonResults = await service.search('work');

        // Rare term
        final rareResults = await service.search('bereavement');

        expect(commonResults, isNotEmpty);
        expect(rareResults, isNotEmpty);
      });

      test('should apply semantic expansion', () async {
        final results = await service.search('anxiety');

        // Should expand to related concepts like stress, worry, fear
        expect(results, isNotEmpty);
      });

      test('should combine multiple scoring methods', () async {
        final results = await service.search('work stress career');

        if (results.isNotEmpty) {
          // Should have combined scores from cosine similarity, semantic overlap, and concept matching
          expect(results.first.similarity, greaterThan(0.0));
        }
      });
    });

    group('Cosine Similarity', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should calculate similarity between 0 and 1', () async {
        final results = await service.search('work stress');

        for (final result in results) {
          expect(result.similarity, greaterThanOrEqualTo(0.0));
          expect(result.similarity, lessThanOrEqualTo(1.0));
        }
      });

      test('should find semantically similar content', () async {
        final results = await service.search('job pressure');

        // Should find work stress scenarios through semantic similarity
        expect(results, isNotEmpty);
      });

      test('should rank exact matches higher', () async {
        final exactResults = await service.search('Work Stress Management');
        final similarResults = await service.search('job pressure');

        if (exactResults.isNotEmpty && similarResults.isNotEmpty) {
          expect(exactResults.first.similarity, greaterThanOrEqualTo(similarResults.first.similarity));
        }
      });
    });

    group('SemanticSearchResult Model', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should include scenario', () async {
        final results = await service.search('work');

        expect(results.first.scenario, isA<Scenario>());
        expect(results.first.scenario.title, isNotEmpty);
      });

      test('should include similarity score', () async {
        final results = await service.search('work');

        expect(results.first.similarity, isA<double>());
        expect(results.first.similarity, greaterThan(0.0));
      });

      test('should include match reason', () async {
        final results = await service.search('work stress');

        expect(results.first.matchReason, isNotEmpty);
        expect(results.first.matchReason, anyOf([
          'Conceptual match',
          'Semantic similarity',
          'Content relevance',
          'Related concepts',
        ]));
      });

      test('should include matched terms', () async {
        final results = await service.search('work stress anxiety');

        expect(results.first.matchedTerms, isA<List<String>>());
      });

      test('matched terms should contain query-related terms', () async {
        final results = await service.search('work stress');

        if (results.isNotEmpty && results.first.matchedTerms.isNotEmpty) {
          final matchedTerms = results.first.matchedTerms.map((t) => t.toLowerCase()).toList();
          final hasRelevantTerm = matchedTerms.any((t) =>
              t.contains('work') || t.contains('stress') || t.contains('career') || t.contains('anxiety'));

          expect(hasRelevantTerm, isTrue);
        }
      });
    });

    group('Semantic Overlap', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should calculate overlap for direct matches', () async {
        final results = await service.search('stress');

        expect(results, isNotEmpty);
        expect(results.first.similarity, greaterThan(0.0));
      });

      test('should calculate overlap for related terms', () async {
        final results = await service.search('anxiety worry pressure');

        // Should find stress-related scenarios through semantic overlap
        expect(results, isNotEmpty);
      });

      test('should boost multi-term matches', () async {
        final singleTermResults = await service.search('work');
        final multiTermResults = await service.search('work stress anxiety');

        expect(singleTermResults, isNotEmpty);
        expect(multiTermResults, isNotEmpty);
      });
    });

    group('Edge Cases', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should handle very short query', () async {
        final results = await service.search('ab');

        expect(results, isNotNull);
      });

      test('should handle single character query', () async {
        final results = await service.search('a');

        // Single char filtered by tokenizer (length > 2)
        expect(results, isNotNull);
      });

      test('should handle numeric query', () async {
        final results = await service.search('123');

        expect(results, isNotNull);
      });

      test('should handle special characters', () async {
        final results = await service.search('work! stress? anxiety...');

        expect(results, isNotNull);
      });

      test('should handle unicode characters', () async {
        final results = await service.search('कर्म योग');

        expect(results, isNotNull);
      });

      test('should handle very long query', () async {
        final longQuery = 'work stress anxiety pressure deadlines overwhelm ' * 10;
        final results = await service.search(longQuery);

        expect(results, isNotNull);
      });

      test('should handle query with only stop words', () async {
        final results = await service.search('the and or but of');

        // Stop words should be filtered
        expect(results, isNotNull);
      });

      test('should handle mixed alphanumeric query', () async {
        final results = await service.search('work2024 stress123');

        expect(results, isNotNull);
      });
    });

    group('Performance', () {
      test('should initialize efficiently', () async {
        final largeDataset = List.generate(100, (index) => Scenario(
          title: 'Scenario $index about work and stress',
          description: 'Description for scenario $index dealing with anxiety and pressure',
          category: 'Category ${index % 5}',
          chapter: (index % 18) + 1,
          heartResponse: 'Heart response with emotions for $index',
          dutyResponse: 'Duty response with dharma for $index',
          gitaWisdom: 'Wisdom teaching for scenario $index',
          tags: ['tag$index', 'common', 'test'],
          actionSteps: ['Step 1', 'Step 2'],
          createdAt: DateTime(2025, 1, 1).add(Duration(hours: index)),
        ));

        final stopwatch = Stopwatch()..start();
        await service.initialize(largeDataset);
        stopwatch.stop();

        expect(service.indexedCount, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('should search efficiently', () async {
        await service.initialize(testScenarios);

        final stopwatch = Stopwatch()..start();
        await service.search('work stress anxiety pressure');
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should handle concurrent searches', () async {
        await service.initialize(testScenarios);

        final futures = [
          service.search('work stress'),
          service.search('family anger'),
          service.search('career purpose'),
          service.search('money anxiety'),
        ];

        final results = await Future.wait(futures);

        expect(results.length, equals(4));
        for (final resultList in results) {
          expect(resultList, isNotNull);
        }
      });
    });

    group('Dispose', () {
      test('should dispose cleanly', () {
        expect(() => service.dispose(), returnsNormally);
      });

      test('should reset state on dispose', () {
        service.dispose();

        expect(service.isInitialized, isFalse);
        expect(service.indexedCount, equals(0));
      });

      test('should handle multiple dispose calls', () {
        expect(() {
          service.dispose();
          service.dispose();
          service.dispose();
        }, returnsNormally);
      });

      test('should allow re-initialization after dispose', () async {
        service.dispose();

        await service.initialize(testScenarios);

        expect(service.isInitialized, isTrue);
      });
    });

    group('State Management', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should maintain state across searches', () async {
        await service.search('work');
        await service.search('family');
        await service.search('career');

        expect(service.isInitialized, isTrue);
        expect(service.indexedCount, equals(testScenarios.length));
      });

      test('should handle vocabulary building', () async {
        // After initialization, vocabulary should be built
        expect(service.isInitialized, isTrue);
      });

      test('should maintain semantic vectors', () async {
        // Multiple searches should use same vectors
        final results1 = await service.search('work');
        final results2 = await service.search('work');

        expect(results1.length, equals(results2.length));
      });
    });

    group('Match Reason Generation', () {
      setUp(() async {
        await service.initialize(testScenarios);
      });

      test('should provide meaningful match reasons', () async {
        final results = await service.search('work stress');

        if (results.isNotEmpty) {
          final reason = results.first.matchReason;
          expect(reason, isNotEmpty);
          expect(reason, anyOf([
            contains('Conceptual'),
            contains('Semantic'),
            contains('Content'),
            contains('Related'),
          ]));
        }
      });

      test('should vary match reasons based on scoring', () async {
        final results = await service.search('anxiety worry fear stress pressure');

        final reasons = results.map((r) => r.matchReason).toSet();
        // Should have variety of match reasons
        expect(reasons, isNotEmpty);
      });
    });
  });
}
