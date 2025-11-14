// test/models/chapter_summary_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/chapter_summary.dart';

void main() {
  group('ChapterSummary Model', () {
    group('Constructors', () {
      test('should create with all fields', () {
        final summary = ChapterSummary(
          chapterId: 1,
          title: 'Arjuna Vishada Yoga',
          subtitle: 'The Yoga of Arjuna\'s Dejection',
          scenarioCount: 120,
          verseCount: 47,
        );

        expect(summary.chapterId, equals(1));
        expect(summary.title, equals('Arjuna Vishada Yoga'));
        expect(summary.subtitle, equals('The Yoga of Arjuna\'s Dejection'));
        expect(summary.scenarioCount, equals(120));
        expect(summary.verseCount, equals(47));
      });

      test('should create with null subtitle', () {
        final summary = ChapterSummary(
          chapterId: 2,
          title: 'Sankhya Yoga',
          scenarioCount: 150,
          verseCount: 72,
        );

        expect(summary.subtitle, isNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final summary = ChapterSummary(
          chapterId: 3,
          title: 'Karma Yoga',
          subtitle: 'The Yoga of Action',
          scenarioCount: 90,
          verseCount: 43,
        );

        final json = summary.toJson();

        expect(json['cs_chapter_id'], equals(3));
        expect(json['cs_title'], equals('Karma Yoga'));
        expect(json['cs_subtitle'], equals('The Yoga of Action'));
        expect(json['cs_scenario_count'], equals(90));
        expect(json['cs_verse_count'], equals(43));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'cs_chapter_id': 4,
          'cs_title': 'Jnana Yoga',
          'cs_subtitle': 'The Yoga of Knowledge',
          'cs_scenario_count': 85,
          'cs_verse_count': 42,
        };

        final summary = ChapterSummary.fromJson(json);

        expect(summary.chapterId, equals(4));
        expect(summary.title, equals('Jnana Yoga'));
        expect(summary.subtitle, equals('The Yoga of Knowledge'));
        expect(summary.scenarioCount, equals(85));
        expect(summary.verseCount, equals(42));
      });

      test('should handle JSON roundtrip', () {
        final original = ChapterSummary(
          chapterId: 5,
          title: 'Karma Sannyasa Yoga',
          subtitle: 'Renunciation of Action',
          scenarioCount: 100,
          verseCount: 29,
        );

        final json = original.toJson();
        final restored = ChapterSummary.fromJson(json);

        expect(restored.chapterId, equals(original.chapterId));
        expect(restored.title, equals(original.title));
        expect(restored.subtitle, equals(original.subtitle));
        expect(restored.scenarioCount, equals(original.scenarioCount));
        expect(restored.verseCount, equals(original.verseCount));
      });

      test('should handle string chapter ID in JSON', () {
        final json = {
          'cs_chapter_id': '6',
          'cs_title': 'Dhyana Yoga',
          'cs_scenario_count': '95',
          'cs_verse_count': '47',
        };

        final summary = ChapterSummary.fromJson(json);

        expect(summary.chapterId, equals(6));
        expect(summary.scenarioCount, equals(95));
        expect(summary.verseCount, equals(47));
      });

      test('should handle int chapter ID in JSON', () {
        final json = {
          'cs_chapter_id': 7,
          'cs_title': 'Jnana Vijnana Yoga',
          'cs_scenario_count': 110,
          'cs_verse_count': 30,
        };

        final summary = ChapterSummary.fromJson(json);

        expect(summary.chapterId, equals(7));
        expect(summary.scenarioCount, equals(110));
        expect(summary.verseCount, equals(30));
      });

      test('should handle null subtitle in JSON', () {
        final json = {
          'cs_chapter_id': 8,
          'cs_title': 'Aksara Brahma Yoga',
          'cs_scenario_count': 75,
          'cs_verse_count': 28,
        };

        final summary = ChapterSummary.fromJson(json);

        expect(summary.subtitle, isNull);
      });
    });

    group('Validation', () {
      test('should handle all 18 chapters', () {
        for (int id = 1; id <= 18; id++) {
          final summary = ChapterSummary(
            chapterId: id,
            title: 'Chapter $id',
            scenarioCount: 100,
            verseCount: 50,
          );

          expect(summary.chapterId, equals(id));
        }
      });

      test('should handle zero counts', () {
        final summary = ChapterSummary(
          chapterId: 1,
          title: 'Test',
          scenarioCount: 0,
          verseCount: 0,
        );

        expect(summary.scenarioCount, equals(0));
        expect(summary.verseCount, equals(0));
      });

      test('should handle large counts', () {
        final summary = ChapterSummary(
          chapterId: 1,
          title: 'Test',
          scenarioCount: 999999,
          verseCount: 999999,
        );

        expect(summary.scenarioCount, equals(999999));
        expect(summary.verseCount, equals(999999));
      });

      test('should handle special characters in title', () {
        final summary = ChapterSummary(
          chapterId: 1,
          title: 'योग "Yoga" (Path)',
          scenarioCount: 50,
          verseCount: 30,
        );

        expect(summary.title, contains('योग'));
        expect(summary.title, contains('"'));
      });
    });

    group('Edge Cases', () {
      test('should handle very long title', () {
        final longTitle = 'A' * 1000;
        final summary = ChapterSummary(
          chapterId: 1,
          title: longTitle,
          scenarioCount: 50,
          verseCount: 30,
        );

        expect(summary.title.length, equals(1000));
      });

      test('should handle very long subtitle', () {
        final longSubtitle = 'B' * 1000;
        final summary = ChapterSummary(
          chapterId: 1,
          title: 'Title',
          subtitle: longSubtitle,
          scenarioCount: 50,
          verseCount: 30,
        );

        expect(summary.subtitle!.length, equals(1000));
      });

      test('should handle Unicode in title and subtitle', () {
        final summary = ChapterSummary(
          chapterId: 1,
          title: 'धर्म क्षेत्र',
          subtitle: 'कुरुक्षेत्र',
          scenarioCount: 50,
          verseCount: 47,
        );

        expect(summary.title, contains('धर्म'));
        expect(summary.subtitle, contains('कुरुक्षेत्र'));
      });
    });
  });
}
