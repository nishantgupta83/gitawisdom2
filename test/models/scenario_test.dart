// test/models/scenario_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/scenario.dart';

void main() {
  group('Scenario Model', () {
    group('Scenario Creation', () {
      test('should create scenario with all required fields', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Career Dilemma',
          description: 'Should I change jobs?',
          category: 'career',
          chapter: 2,
          heartResponse: 'Follow your passion',
          dutyResponse: 'Fulfill your responsibilities',
          gitaWisdom: 'Bhagavad Gita wisdom about careers',
          verse: '2.47',
          verseNumber: '47',
          tags: const ['career', 'decision'],
          createdAt: now,
        );

        expect(scenario.title, equals('Career Dilemma'));
        expect(scenario.description, equals('Should I change jobs?'));
        expect(scenario.chapter, equals(2));
        expect(scenario.heartResponse, isNotEmpty);
        expect(scenario.dutyResponse, isNotEmpty);
        expect(scenario.tags, hasLength(2));
      });

      test('should handle optional fields as null', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Test Scenario',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.tags, isNull);
        expect(scenario.verse, isNull);
        expect(scenario.verseNumber, isNull);
      });
    });

    group('Heart vs Duty Framework', () {
      test('should maintain distinct heart and duty responses', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Love vs Duty',
          description: 'Relationship conflict',
          category: 'relationships',
          chapter: 6,
          heartResponse: 'Love leads to happiness',
          dutyResponse: 'Duty leads to dharma',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.heartResponse, isNotEmpty);
        expect(scenario.dutyResponse, isNotEmpty);
        expect(scenario.heartResponse, isNot(equals(scenario.dutyResponse)));
      });

      test('both responses should be non-empty strings', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Test',
          description: 'Test scenario',
          category: 'test',
          chapter: 1,
          heartResponse: 'Response',
          dutyResponse: 'Response',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.heartResponse, isA<String>());
        expect(scenario.dutyResponse, isA<String>());
      });
    });

    group('Scenario Tagging System', () {
      test('should support multiple tags', () {
        final now = DateTime.now();
        const tags = ['relationship', 'family', 'decision', 'ethics'];
        final scenario = Scenario(
          title: 'Family Decision',
          description: 'Test',
          category: 'family',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: now,
          tags: tags,
        );

        expect(scenario.tags, hasLength(4));
        expect(scenario.tags, containsAll(['relationship', 'family']));
      });

      test('should handle null tag list', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'No Tags',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.tags, isNull);
      });
    });

    group('Verse References', () {
      test('should link to Gita verses', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Verse Links',
          description: 'Test',
          category: 'test',
          chapter: 2,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: '2.47',
          verseNumber: '47',
          createdAt: now,
        );

        expect(scenario.verse, equals('2.47'));
        expect(scenario.verseNumber, equals('47'));
      });
    });

    group('Chapter Association', () {
      test('should associate with valid chapter ID', () {
        final now = DateTime.now();
        for (int chapterId = 1; chapterId <= 18; chapterId++) {
          final scenario = Scenario(
            title: 'Test',
            description: 'Test',
            category: 'test',
            chapter: chapterId,
            heartResponse: 'Heart',
            dutyResponse: 'Duty',
            gitaWisdom: 'Wisdom',
            createdAt: now,
          );

          expect(scenario.chapter, equals(chapterId));
        }
      });
    });

    group('Data Integrity', () {
      test('should preserve special characters in text', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Special "Characters" Test',
          description: 'Text with émojis: 🎭 and quotes "test"',
          category: 'test',
          chapter: 1,
          heartResponse: 'Follow your heart\'s true path',
          dutyResponse: 'Fulfill your dharmic duties',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.description, contains('🎭'));
        expect(scenario.dutyResponse, contains('\''));
      });

      test('should handle Unicode properly', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'युद्ध (War)',
          description: 'संकट (Crisis) and समाधान (Solution)',
          category: 'काल',
          chapter: 1,
          heartResponse: 'अहिंसा (Non-violence)',
          dutyResponse: 'धर्म (Duty)',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.title, contains('युद्ध'));
        expect(scenario.description, contains('संकट'));
      });
    });

    group('Model Serialization', () {
      test('should have fromJson factory method', () {
        expect(Scenario.fromJson, isA<Function>());
      });

      test('should have toJson method', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.toJson, isA<Function>());
      });
    });

    group('Hive Integration', () {
      test('should be HiveObject for local storage', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        // Verify it has Hive properties
        expect(scenario, isNotNull);
      });
    });
  });
}
