
// test/models/simple_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/chapter_summary.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/journal_entry.dart';

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
          'gv_chapter_id': 2,
        };

        final verse = Verse.fromJson(json);

        expect(verse.verseId, equals(1));
        expect(verse.description, equals('dhritarashtra uvacha dharma-kshetre kuru-kshetre'));
        expect(verse.chapterId, equals(2));
      });

      test('should create from JSON without chapterId', () {
        final json = {
          'gv_verses_id': 1,
          'gv_verses': 'Test verse',
        };

        final verse = Verse.fromJson(json);

        expect(verse.verseId, equals(1));
        expect(verse.description, equals('Test verse'));
        expect(verse.chapterId, isNull);
      });

      test('should convert to JSON correctly with chapterId', () {
        final verse = Verse(
          verseId: 1,
          description: 'Test verse content',
          chapterId: 3,
        );

        final json = verse.toJson();

        expect(json['gv_verses_id'], equals(1));
        expect(json['gv_verses'], equals('Test verse content'));
        expect(json['gv_chapter_id'], equals(3));
      });

      test('should convert to JSON correctly without chapterId', () {
        final verse = Verse(
          verseId: 1,
          description: 'Test verse content',
        );

        final json = verse.toJson();

        expect(json['gv_verses_id'], equals(1));
        expect(json['gv_verses'], equals('Test verse content'));
        expect(json.containsKey('gv_chapter_id'), isFalse);
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

    group('DailyVerseSet', () {
      test('should create DailyVerseSet correctly', () {
        final verses = [
          Verse(verseId: 1, description: 'Test verse 1', chapterId: 1),
          Verse(verseId: 2, description: 'Test verse 2', chapterId: 2),
        ];
        final chapterIds = [1, 2];
        final testDate = DateTime(2024, 1, 15);

        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: verses,
          chapterIds: chapterIds,
          createdAt: testDate,
        );

        expect(verseSet.date, equals('2024-01-15'));
        expect(verseSet.verses.length, equals(2));
        expect(verseSet.chapterIds, equals([1, 2]));
        expect(verseSet.createdAt, equals(testDate));
      });

      test('should create from factory method forToday', () {
        final verses = [
          Verse(verseId: 1, description: 'Test verse 1', chapterId: 1),
        ];
        final chapterIds = [1];

        final verseSet = DailyVerseSet.forToday(
          verses: verses,
          chapterIds: chapterIds,
        );

        final today = DateTime.now();
        final expectedDate = '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';

        expect(verseSet.date, equals(expectedDate));
        expect(verseSet.verses.length, equals(1));
        expect(verseSet.chapterIds, equals([1]));
        expect(verseSet.isToday, isTrue);
      });

      test('should correctly identify if verse set is for today', () {
        final today = DateTime.now();
        final todayString = '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';

        final todayVerseSet = DailyVerseSet(
          date: todayString,
          verses: [],
          chapterIds: [],
        );

        final yesterdayVerseSet = DailyVerseSet(
          date: '2024-01-01',
          verses: [],
          chapterIds: [],
        );

        expect(todayVerseSet.isToday, isTrue);
        expect(yesterdayVerseSet.isToday, isFalse);
      });

      test('should generate correct today string', () {
        final todayString = DailyVerseSet.getTodayString();
        final today = DateTime.now();
        final expectedString = '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';

        expect(todayString, equals(expectedString));
      });

      test('should have meaningful toString representation', () {
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: [
            Verse(verseId: 1, description: 'Test', chapterId: 1),
            Verse(verseId: 2, description: 'Test2', chapterId: 2),
          ],
          chapterIds: [1, 2],
        );

        final stringRep = verseSet.toString();

        expect(stringRep, contains('2024-01-15'));
        expect(stringRep, contains('verses: 2'));
        expect(stringRep, contains('chapters: [1, 2]'));
      });
    });

    group('JournalEntry', () {
      test('should create JournalEntry correctly', () {
        final testDate = DateTime(2024, 1, 15, 12, 30);
        final entry = JournalEntry(
          id: 'test-id-123',
          reflection: 'Today I learned about detachment',
          rating: 4,
          dateCreated: testDate,
        );

        expect(entry.id, equals('test-id-123'));
        expect(entry.reflection, equals('Today I learned about detachment'));
        expect(entry.rating, equals(4));
        expect(entry.dateCreated, equals(testDate));
      });

      test('should validate rating bounds', () {
        final testDate = DateTime.now();
        
        // Valid ratings should work
        final validEntry = JournalEntry(
          id: 'test',
          reflection: 'Test',
          rating: 3,
          dateCreated: testDate,
        );
        expect(validEntry.rating, equals(3));

        // Test edge cases
        final minEntry = JournalEntry(
          id: 'test',
          reflection: 'Test',
          rating: 1,
          dateCreated: testDate,
        );
        expect(minEntry.rating, equals(1));

        final maxEntry = JournalEntry(
          id: 'test',
          reflection: 'Test',
          rating: 5,
          dateCreated: testDate,
        );
        expect(maxEntry.rating, equals(5));
      });
    });

    group('Chapter', () {
      test('should create Chapter from JSON correctly', () {
        final json = {
          'ch_chapter_id': 1,
          'ch_title': 'Observing the Armies',
          'ch_subtitle': 'Arjuna Vishada Yoga',
          'ch_summary': 'Arjuna\'s moral dilemma...',
          'ch_verse_count': 47,
          'ch_theme': 'Duty and righteousness',
          'ch_key_teachings': ['dharma', 'duty', 'righteousness'],
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.chapterId, equals(1));
        expect(chapter.title, equals('Observing the Armies'));
        expect(chapter.subtitle, equals('Arjuna Vishada Yoga'));
        expect(chapter.summary, contains('dilemma'));
        expect(chapter.verseCount, equals(47));
        expect(chapter.theme, equals('Duty and righteousness'));
        expect(chapter.keyTeachings, equals(['dharma', 'duty', 'righteousness']));
      });

      test('should handle empty or null key teachings', () {
        final json = {
          'ch_chapter_id': 2,
          'ch_title': 'Test Chapter',
          'ch_subtitle': 'Test Subtitle',
          'ch_summary': 'Test summary',
          'ch_verse_count': 20,
          'ch_theme': 'Test theme',
          'ch_key_teachings': null,
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.keyTeachings, isNull);
      });
    });
  });
}
