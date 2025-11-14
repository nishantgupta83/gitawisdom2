// test/models/daily_verse_set_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/verse.dart';

void main() {
  group('DailyVerseSet Model', () {
    final sampleVerses = [
      Verse(verseId: 1, description: 'Verse 1', chapterId: 1),
      Verse(verseId: 2, description: 'Verse 2', chapterId: 2),
      Verse(verseId: 3, description: 'Verse 3', chapterId: 3),
    ];

    group('Constructors', () {
      test('should create with all fields', () {
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: sampleVerses,
          chapterIds: [1, 2, 3],
        );

        expect(verseSet.date, equals('2024-01-15'));
        expect(verseSet.verses, hasLength(3));
        expect(verseSet.chapterIds, equals([1, 2, 3]));
        expect(verseSet.createdAt, isNotNull);
      });

      test('should create with provided createdAt', () {
        final specificTime = DateTime(2024, 1, 15, 10, 30);
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: sampleVerses,
          chapterIds: [1, 2, 3],
          createdAt: specificTime,
        );

        expect(verseSet.createdAt, equals(specificTime));
      });

      test('should auto-generate createdAt if not provided', () {
        final before = DateTime.now();
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: sampleVerses,
          chapterIds: [1, 2, 3],
        );
        final after = DateTime.now();

        expect(verseSet.createdAt.isAfter(before) || verseSet.createdAt.isAtSameMomentAs(before), isTrue);
        expect(verseSet.createdAt.isBefore(after) || verseSet.createdAt.isAtSameMomentAs(after), isTrue);
      });
    });

    group('Factory forToday', () {
      test('should create verse set for today', () {
        final verseSet = DailyVerseSet.forToday(
          verses: sampleVerses,
          chapterIds: [1, 2, 3],
        );

        final today = DateTime.now();
        final expectedDate = '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';

        expect(verseSet.date, equals(expectedDate));
      });

      test('should mark as today when checked', () {
        final verseSet = DailyVerseSet.forToday(
          verses: sampleVerses,
          chapterIds: [1, 2, 3],
        );

        expect(verseSet.isToday, isTrue);
      });
    });

    group('Helper Methods', () {
      test('getTodayString should return correct format', () {
        final todayString = DailyVerseSet.getTodayString();
        final today = DateTime.now();
        final expected = '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';

        expect(todayString, equals(expected));
        expect(todayString, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      });

      test('isToday should return true for today', () {
        final today = DailyVerseSet.forToday(
          verses: sampleVerses,
          chapterIds: [1],
        );

        expect(today.isToday, isTrue);
      });

      test('isToday should return false for past date', () {
        final past = DailyVerseSet(
          date: '2023-01-01',
          verses: sampleVerses,
          chapterIds: [1],
        );

        expect(past.isToday, isFalse);
      });

      test('isToday should return false for future date', () {
        final future = DailyVerseSet(
          date: '2099-12-31',
          verses: sampleVerses,
          chapterIds: [1],
        );

        expect(future.isToday, isFalse);
      });
    });

    group('Date Formatting', () {
      test('should handle single-digit months and days', () {
        final verseSet = DailyVerseSet(
          date: '2024-01-05',
          verses: sampleVerses,
          chapterIds: [1],
        );

        expect(verseSet.date, equals('2024-01-05'));
        expect(verseSet.date.length, equals(10));
      });

      test('should handle double-digit months and days', () {
        final verseSet = DailyVerseSet(
          date: '2024-12-25',
          verses: sampleVerses,
          chapterIds: [1],
        );

        expect(verseSet.date, equals('2024-12-25'));
      });

      test('should handle year boundaries', () {
        final newYear = DailyVerseSet(
          date: '2024-01-01',
          verses: sampleVerses,
          chapterIds: [1],
        );

        final yearEnd = DailyVerseSet(
          date: '2024-12-31',
          verses: sampleVerses,
          chapterIds: [1],
        );

        expect(newYear.date, equals('2024-01-01'));
        expect(yearEnd.date, equals('2024-12-31'));
      });
    });

    group('Verse Management', () {
      test('should handle empty verse list', () {
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: [],
          chapterIds: [],
        );

        expect(verseSet.verses, isEmpty);
        expect(verseSet.chapterIds, isEmpty);
      });

      test('should handle single verse', () {
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: [sampleVerses[0]],
          chapterIds: [1],
        );

        expect(verseSet.verses, hasLength(1));
        expect(verseSet.chapterIds, hasLength(1));
      });

      test('should handle multiple verses', () {
        final manyVerses = List.generate(
          10,
          (i) => Verse(verseId: i + 1, description: 'Verse ${i + 1}', chapterId: (i % 18) + 1),
        );

        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: manyVerses,
          chapterIds: List.generate(10, (i) => (i % 18) + 1),
        );

        expect(verseSet.verses, hasLength(10));
        expect(verseSet.chapterIds, hasLength(10));
      });

      test('should preserve verse order', () {
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: sampleVerses,
          chapterIds: [1, 2, 3],
        );

        expect(verseSet.verses[0].verseId, equals(1));
        expect(verseSet.verses[1].verseId, equals(2));
        expect(verseSet.verses[2].verseId, equals(3));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: sampleVerses,
          chapterIds: [1, 2, 3],
        );

        final str = verseSet.toString();

        expect(str, contains('2024-01-15'));
        expect(str, contains('3')); // Number of verses
        expect(str, contains('[1, 2, 3]')); // Chapter IDs
      });
    });

    group('Edge Cases', () {
      test('should handle verses from all 18 chapters', () {
        final allChapters = List.generate(
          18,
          (i) => Verse(verseId: 1, description: 'Verse', chapterId: i + 1),
        );

        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: allChapters,
          chapterIds: List.generate(18, (i) => i + 1),
        );

        expect(verseSet.verses, hasLength(18));
        expect(verseSet.chapterIds, hasLength(18));
        expect(verseSet.chapterIds.first, equals(1));
        expect(verseSet.chapterIds.last, equals(18));
      });

      test('should handle duplicate chapter IDs', () {
        final verses = [
          Verse(verseId: 1, description: 'V1', chapterId: 1),
          Verse(verseId: 2, description: 'V2', chapterId: 1),
          Verse(verseId: 3, description: 'V3', chapterId: 1),
        ];

        final verseSet = DailyVerseSet(
          date: '2024-01-15',
          verses: verses,
          chapterIds: [1, 1, 1],
        );

        expect(verseSet.chapterIds, equals([1, 1, 1]));
      });
    });
  });
}
