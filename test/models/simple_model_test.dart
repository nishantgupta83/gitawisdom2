
// test/models/simple_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:oldwisdom/models/chapter_summary.dart';
import 'package:oldwisdom/models/scenario.dart';
import 'package:oldwisdom/models/verse.dart';

void main() {
  group('Model Tests', () {
    group('ChapterSummary', () {
      test('should create from JSON correctly', () {
        final json = {
          'cs_chapter_id': 1,
          'cs_title': 'Test Chapter',
          'cs_subtitle': 'Test Subtitle',
          'cs_verse_count': 47,
          'cs_scenario_count': 5,
        };

        final chapter = ChapterSummary.fromJson(json);

        expect(chapter.chapterId, equals(1));
        expect(chapter.title, equals('Test Chapter'));
        expect(chapter.subtitle, equals('Test Subtitle'));
        expect(chapter.verseCount, equals(47));
        expect(chapter.scenarioCount, equals(5));
      });

      test('should convert to JSON correctly', () {
        final chapter = ChapterSummary(
          chapterId: 1,
          title: 'Test Chapter',
          subtitle: 'Test Subtitle',
          verseCount: 10,
          scenarioCount: 3,
        );

        final json = chapter.toJson();

        expect(json['cs_chapter_id'], equals(1));
        expect(json['cs_title'], equals('Test Chapter'));
        expect(json['cs_verse_count'], equals(10));
      });

      test('should handle string chapter IDs', () {
        final json = {
          'cs_chapter_id': '2',
          'cs_title': 'Test',
          'cs_subtitle': null,
          'cs_verse_count': '15',
          'cs_scenario_count': '4',
        };

        final chapter = ChapterSummary.fromJson(json);

        expect(chapter.chapterId, equals(2));
        expect(chapter.verseCount, equals(15));
        expect(chapter.scenarioCount, equals(4));
      });
    });

    group('Verse', () {
      test('should create from JSON correctly', () {
        final json = {
          'gv_verses_id': 1,
          'gv_verses': 'dhritarashtra uvacha dharma-kshetre kuru-kshetre',
        };

        final verse = Verse.fromJson(json);

        expect(verse.verseId, equals(1));
        expect(verse.description, equals('dhritarashtra uvacha dharma-kshetre kuru-kshetre'));
      });

      test('should convert to JSON correctly', () {
        final verse = Verse(
          verseId: 1,
          description: 'Test verse content',
        );

        final json = verse.toJson();

        expect(json['gv_verses_id'], equals(1));
        expect(json['gv_verses'], equals('Test verse content'));
      });
    });

    group('Scenario', () {
      test('should create from JSON correctly', () {
        final json = {
          'sc_title': 'Career Dilemma',
          'sc_description': 'Should I take this job?',
          'sc_category': 'Career',
          'sc_chapter': 1,
          'sc_heart_response': 'Follow your passion',
          'sc_duty_response': 'Consider responsibilities',
          'sc_gita_wisdom': 'Perform duty without attachment',
          'sc_verse': 'Test verse',
          'sc_verse_number': '2.47',
          'sc_tags': ['career', 'decision'],
          'sc_action_steps': ['Analyze', 'Decide'],
          'created_at': '2024-01-01T00:00:00Z',
        };

        final scenario = Scenario.fromJson(json);

        expect(scenario.title, equals('Career Dilemma'));
        expect(scenario.description, equals('Should I take this job?'));
        expect(scenario.category, equals('Career'));
        expect(scenario.chapter, equals(1));
        expect(scenario.heartResponse, equals('Follow your passion'));
        expect(scenario.dutyResponse, equals('Consider responsibilities'));
        expect(scenario.gitaWisdom, equals('Perform duty without attachment'));
        expect(scenario.tags, equals(['career', 'decision']));
        expect(scenario.actionSteps, equals(['Analyze', 'Decide']));
      });

      test('should handle null optional fields', () {
        final json = {
          'sc_title': 'Test',
          'sc_description': 'Test desc',
          'sc_category': 'Test cat',
          'sc_chapter': 1,
          'sc_heart_response': 'Heart',
          'sc_duty_response': 'Duty',
          'sc_gita_wisdom': 'Wisdom',
          'sc_verse': null,
          'sc_verse_number': null,
          'sc_tags': null,
          'sc_action_steps': null,
          'created_at': '2024-01-01T00:00:00Z',
        };

        final scenario = Scenario.fromJson(json);

        expect(scenario.verse, isNull);
        expect(scenario.verseNumber, isNull);
        expect(scenario.tags, isNull);
        expect(scenario.actionSteps, isNull);
      });
    });
  });
}
