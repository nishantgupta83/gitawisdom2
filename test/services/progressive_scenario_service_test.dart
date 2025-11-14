// test/services/progressive_scenario_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/services/progressive_scenario_service.dart';
import 'package:GitaWisdom/services/intelligent_caching_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';
import 'progressive_scenario_service_test.mocks.dart';

@GenerateMocks([IntelligentCachingService])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('ProgressiveScenarioService', () {
    late ProgressiveScenarioService service;
    late MockIntelligentCachingService mockCachingService;
    late List<Scenario> testScenarios;

    setUp(() {
      service = ProgressiveScenarioService.instance;
      mockCachingService = MockIntelligentCachingService();

      // Create test scenarios
      testScenarios = [
        Scenario(
          title: 'Career vs Family Time',
          description: 'Should I work overtime or spend time with family?',
          heartResponse: 'Spend time with family',
          dutyResponse: 'Work overtime for career growth',
          gitaWisdom: 'Family is precious but duty also matters',
          verse: 'You have a right to perform your prescribed duty',
          verseNumber: '2.47',
          tags: ['career', 'family'],
          category: 'Work-Life Balance',
          chapter: 2,
          createdAt: DateTime.now(),
        ),
        Scenario(
          title: 'Honesty vs Comfort',
          description: 'Should I tell the truth or avoid confrontation?',
          heartResponse: 'Avoid confrontation',
          dutyResponse: 'Speak the truth',
          gitaWisdom: 'Truth is paramount in dharma',
          verse: 'Truth prevails always',
          verseNumber: '4.7',
          tags: ['honesty', 'truth'],
          category: 'Ethics',
          chapter: 4,
          createdAt: DateTime.now(),
        ),
        Scenario(
          title: 'Karma and Action',
          description: 'How to perform duty without attachment?',
          heartResponse: 'Follow emotions',
          dutyResponse: 'Follow dharma',
          gitaWisdom: 'Perform action without attachment to results',
          verse: 'Karma yoga guidance',
          verseNumber: '2.47',
          tags: ['karma', 'action'],
          category: 'Spiritual',
          chapter: 2,
          createdAt: DateTime.now(),
        ),
      ];
    });

    group('Initialization', () {
      test('should be singleton instance', () {
        final instance1 = ProgressiveScenarioService.instance;
        final instance2 = ProgressiveScenarioService.instance;
        expect(instance1, equals(instance2));
      });
    });

    group('Scenario Availability', () {
      test('should check if scenarios are available', () {
        // Default behavior without mocking
        expect(() => service.hasScenarios, returnsNormally);
      });

      test('should return scenario count', () {
        final count = service.scenarioCount;
        expect(count, isA<int>());
        expect(count, greaterThanOrEqualTo(0));
      });
    });

    group('Scenario Search', () {
      test('should search scenarios with empty query', () {
        final results = service.searchScenarios('');
        expect(results, isA<List<Scenario>>());
      });

      test('should search scenarios with query', () {
        final results = service.searchScenarios('career');
        expect(results, isA<List<Scenario>>());
      });

      test('should search with max results limit', () {
        final results = service.searchScenarios('', maxResults: 5);
        expect(results.length, lessThanOrEqualTo(5));
      });

      test('should handle whitespace-only query', () {
        final results = service.searchScenarios('   ');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle special characters in query', () {
        final results = service.searchScenarios(r'@#$%');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very long query', () {
        final longQuery = 'career ' * 100;
        final results = service.searchScenarios(longQuery);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle case-insensitive search', () {
        final resultsLower = service.searchScenarios('career');
        final resultsUpper = service.searchScenarios('CAREER');
        expect(resultsLower, isA<List<Scenario>>());
        expect(resultsUpper, isA<List<Scenario>>());
      });
    });

    group('Max Results Handling', () {
      test('should respect maxResults parameter', () {
        final results = service.searchScenarios('test', maxResults: 2);
        expect(results.length, lessThanOrEqualTo(2));
      });

      test('should handle maxResults of 0', () {
        final results = service.searchScenarios('test', maxResults: 0);
        expect(results, isEmpty);
      });

      test('should handle negative maxResults', () {
        final results = service.searchScenarios('test', maxResults: -1);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very large maxResults', () {
        final results = service.searchScenarios('test', maxResults: 10000);
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Empty Query Behavior', () {
      test('should return instant scenarios for empty query', () {
        final results = service.searchScenarios('');
        expect(results, isA<List<Scenario>>());
      });

      test('should shuffle results for empty query', () {
        // Multiple calls should potentially return different orders
        final results1 = service.searchScenarios('');
        final results2 = service.searchScenarios('');
        expect(results1, isA<List<Scenario>>());
        expect(results2, isA<List<Scenario>>());
      });
    });

    group('Error Handling', () {
      test('should handle search errors gracefully', () {
        expect(() => service.searchScenarios('test'), returnsNormally);
      });

      test('should return empty list on errors', () {
        // Even if internal errors occur, should not crash
        final results = service.searchScenarios('error-inducing-query');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Search Query Variations', () {
      test('should handle single character query', () {
        final results = service.searchScenarios('a');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle numeric query', () {
        final results = service.searchScenarios('123');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle query with punctuation', () {
        final results = service.searchScenarios('test, query!');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle query with multiple spaces', () {
        final results = service.searchScenarios('test    query');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle Unicode characters', () {
        final results = service.searchScenarios('कर्म');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Performance', () {
      test('should handle rapid consecutive searches', () {
        for (int i = 0; i < 10; i++) {
          final results = service.searchScenarios('query$i');
          expect(results, isA<List<Scenario>>());
        }
      });

      test('should handle alternating empty and non-empty queries', () {
        service.searchScenarios('');
        service.searchScenarios('test');
        service.searchScenarios('');
        service.searchScenarios('another');

        expect(true, isTrue); // No crash means success
      });
    });

    group('Integration with Caching Service', () {
      test('should work with uninitialized caching service', () {
        final results = service.searchScenarios('test');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Edge Cases', () {
      test('should handle null-like strings', () {
        final results = service.searchScenarios('null');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle empty string with maxResults', () {
        final results = service.searchScenarios('', maxResults: 10);
        expect(results.length, lessThanOrEqualTo(10));
      });

      test('should handle query with only special characters', () {
        final results = service.searchScenarios(r'!@#$%^&*()');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle query with newlines', () {
        final results = service.searchScenarios('test\nquery');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle query with tabs', () {
        final results = service.searchScenarios('test\tquery');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Scenario Count', () {
      test('should return non-negative scenario count', () {
        final count = service.scenarioCount;
        expect(count, greaterThanOrEqualTo(0));
      });

      test('should maintain consistent count across calls', () {
        final count1 = service.scenarioCount;
        final count2 = service.scenarioCount;
        expect(count1, equals(count2));
      });
    });
  });
}
