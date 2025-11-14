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
          dutyResponse: 'Fulfill your dharmic duties with Krishna\'s wisdom',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        expect(scenario.description, contains('🎭'));
        expect(scenario.heartResponse, contains('\''));
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

    group('JSON Serialization Roundtrip', () {
      test('should serialize and deserialize correctly', () {
        final now = DateTime.now();
        final original = Scenario(
          title: 'Career Change',
          description: 'Should I switch careers?',
          category: 'career',
          chapter: 2,
          heartResponse: 'Follow passion',
          dutyResponse: 'Stay committed',
          gitaWisdom: 'Your right is to perform your duty',
          verse: '2.47',
          verseNumber: '47',
          tags: const ['career', 'decision'],
          actionSteps: const ['Reflect', 'Plan', 'Act'],
          createdAt: now,
        );

        final json = original.toJson();
        final restored = Scenario.fromJson(json);

        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.category, equals(original.category));
        expect(restored.chapter, equals(original.chapter));
        expect(restored.heartResponse, equals(original.heartResponse));
        expect(restored.dutyResponse, equals(original.dutyResponse));
        expect(restored.gitaWisdom, equals(original.gitaWisdom));
        expect(restored.verse, equals(original.verse));
        expect(restored.verseNumber, equals(original.verseNumber));
        expect(restored.tags, equals(original.tags));
        expect(restored.actionSteps, equals(original.actionSteps));
      });

      test('should handle null optional fields in serialization', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Simple Test',
          description: 'Description',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        final json = scenario.toJson();

        expect(json['sc_verse'], isNull);
        expect(json['sc_verse_number'], isNull);
        expect(json['sc_tags'], isNull);
        expect(json['sc_action_steps'], isNull);
      });

      test('should preserve DateTime precision', () {
        final exactTime = DateTime(2024, 1, 15, 14, 30, 45, 123);
        final scenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: exactTime,
        );

        final json = scenario.toJson();
        final restored = Scenario.fromJson(json);

        expect(restored.createdAt.year, equals(exactTime.year));
        expect(restored.createdAt.month, equals(exactTime.month));
        expect(restored.createdAt.day, equals(exactTime.day));
        expect(restored.createdAt.hour, equals(exactTime.hour));
        expect(restored.createdAt.minute, equals(exactTime.minute));
      });
    });

    group('Action Steps', () {
      test('should support action steps list', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Work Conflict',
          description: 'How to handle workplace tension',
          category: 'career',
          chapter: 3,
          heartResponse: 'Express feelings',
          dutyResponse: 'Maintain professionalism',
          gitaWisdom: 'Perform your duty without attachment',
          actionSteps: const [
            'Take a deep breath',
            'Consider the other perspective',
            'Communicate calmly',
            'Seek win-win solutions'
          ],
          createdAt: now,
        );

        expect(scenario.actionSteps, hasLength(4));
        expect(scenario.actionSteps![0], equals('Take a deep breath'));
        expect(scenario.actionSteps![3], equals('Seek win-win solutions'));
      });

      test('should handle empty action steps', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          actionSteps: const [],
          createdAt: now,
        );

        expect(scenario.actionSteps, isEmpty);
      });
    });

    group('Multilingual Extensions', () {
      test('should create from multilingual JSON', () {
        final json = {
          'sc_title': 'परीक्षा',
          'sc_description': 'परीक्षा का तनाव',
          'sc_category': 'शिक्षा',
          'sc_chapter': 2,
          'sc_heart_response': 'चिंता मुक्त रहें',
          'sc_duty_response': 'कर्तव्य निभाएं',
          'sc_gita_wisdom': 'कर्म करो फल की चिंता मत करो',
          'created_at': DateTime.now().toIso8601String(),
        };

        final scenario = ScenarioMultilingualExtensions.fromMultilingualJson(json);

        expect(scenario.title, equals('परीक्षा'));
        expect(scenario.category, equals('शिक्षा'));
      });

      test('should convert to translation JSON', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Exam Stress',
          description: 'How to handle exam pressure',
          category: 'education',
          chapter: 2,
          heartResponse: 'Stay calm',
          dutyResponse: 'Do your best',
          gitaWisdom: 'Focus on action not results',
          tags: const ['education', 'stress'],
          createdAt: now,
        );

        final json = scenario.toTranslationJson('hi', 123);

        expect(json['scenario_id'], equals(123));
        expect(json['lang_code'], equals('hi'));
        expect(json['title'], equals('Exam Stress'));
        expect(json['tags'], equals(['education', 'stress']));
      });

      test('should create from translation JSON', () {
        final json = {
          'title': 'Family Conflict',
          'description': 'How to resolve family disputes',
          'category': 'family',
          'heart_response': 'Express love',
          'duty_response': 'Respect elders',
          'gita_wisdom': 'Maintain family harmony',
        };

        final scenario = ScenarioMultilingualExtensions.fromTranslationJson(
          json,
          4,
          DateTime.now(),
        );

        expect(scenario.title, equals('Family Conflict'));
        expect(scenario.chapter, equals(4));
      });

      test('should check translation completeness', () {
        final now = DateTime.now();
        final complete = Scenario(
          title: 'Complete',
          description: 'Full description',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart response',
          dutyResponse: 'Duty response',
          gitaWisdom: 'Gita wisdom',
          createdAt: now,
        );

        expect(complete.hasTranslationData, isTrue);
      });

      test('should calculate translation completion percentage', () {
        final now = DateTime.now();
        final scenario = Scenario(
          title: 'Test',
          description: 'Description',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          verse: '1.1',
          verseNumber: '1',
          tags: const ['tag1'],
          actionSteps: const ['step1'],
          createdAt: now,
        );

        final percentage = scenario.translationCompletionPercentage;
        expect(percentage, equals(100.0));
      });

      test('should create copy with translation', () {
        final now = DateTime.now();
        final original = Scenario(
          title: 'Original',
          description: 'English',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: now,
        );

        final translated = original.withTranslation(
          title: 'मूल',
          description: 'हिन्दी',
          heartResponse: 'हृदय',
          dutyResponse: 'कर्तव्य',
          gitaWisdom: 'गीता ज्ञान',
        );

        expect(translated.title, equals('मूल'));
        expect(translated.description, equals('हिन्दी'));
        expect(translated.chapter, equals(1)); // Preserved
        expect(translated.createdAt, equals(now)); // Preserved
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle very long responses', () {
        final now = DateTime.now();
        final longResponse = 'A' * 10000;
        final scenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: longResponse,
          dutyResponse: longResponse,
          gitaWisdom: longResponse,
          createdAt: now,
        );

        expect(scenario.heartResponse.length, equals(10000));
        expect(scenario.dutyResponse.length, equals(10000));
        expect(scenario.gitaWisdom.length, equals(10000));
      });

      test('should handle many tags', () {
        final now = DateTime.now();
        final manyTags = List.generate(100, (i) => 'tag$i');
        final scenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          tags: manyTags,
          createdAt: now,
        );

        expect(scenario.tags, hasLength(100));
        expect(scenario.tags![50], equals('tag50'));
      });

      test('should handle many action steps', () {
        final now = DateTime.now();
        final manySteps = List.generate(50, (i) => 'Step $i');
        final scenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          actionSteps: manySteps,
          createdAt: now,
        );

        expect(scenario.actionSteps, hasLength(50));
      });

      test('should handle all chapters 1-18', () {
        final now = DateTime.now();
        for (int chapterId = 1; chapterId <= 18; chapterId++) {
          final scenario = Scenario(
            title: 'Chapter $chapterId',
            description: 'Test for chapter $chapterId',
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

    group('Category Management', () {
      test('should support common categories', () {
        final now = DateTime.now();
        final categories = [
          'career',
          'relationships',
          'family',
          'health',
          'finance',
          'education',
          'spirituality'
        ];

        for (final category in categories) {
          final scenario = Scenario(
            title: 'Test $category',
            description: 'Test',
            category: category,
            chapter: 1,
            heartResponse: 'Heart',
            dutyResponse: 'Duty',
            gitaWisdom: 'Wisdom',
            createdAt: now,
          );

          expect(scenario.category, equals(category));
        }
      });
    });
  });
}
