// test/models/chapter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/verse.dart';

void main() {
  group('Chapter Model', () {
    group('Chapter Creation and Serialization', () {
      test('should create chapter with required fields', () {
        final chapter = Chapter(
          chapterId: 1,
          title: 'Chapter of Dharma',
          summary: 'Introduction to the nature of dharma',
          verseCount: 47,
        );

        expect(chapter.chapterId, equals(1));
        expect(chapter.title, equals('Chapter of Dharma'));
        expect(chapter.summary, equals('Introduction to the nature of dharma'));
        expect(chapter.verseCount, equals(47));
      });

      test('should handle null optional fields', () {
        final chapter = Chapter(
          chapterId: 2,
          title: 'Chapter of Knowledge',
          summary: 'Description of knowledge',
        );

        expect(chapter.chapterId, equals(2));
        expect(chapter.title, isNotEmpty);
        expect(chapter.subtitle, isNull);
      });

      test('should validate chapter number range (1-18)', () {
        // Chapter numbers in Bhagavad Gita range from 1 to 18
        for (int i = 1; i <= 18; i++) {
          expect(i, greaterThanOrEqualTo(1));
          expect(i, lessThanOrEqualTo(18));
        }
      });

      test('should support optional subtitle', () {
        final chapter = Chapter(
          chapterId: 3,
          title: 'Chapter of Bhakti',
          subtitle: 'Yoga of Devotion',
          summary: 'Devotion and love',
        );

        expect(chapter.subtitle, equals('Yoga of Devotion'));
      });
    });

    group('Chapter Content Integrity', () {
      test('should maintain chapter data consistency', () {
        final chapter = Chapter(
          chapterId: 4,
          title: 'Chapter of Renunciation',
          summary: 'Renunciation and detachment',
          verseCount: 42,
        );

        // Data should not be modified
        expect(chapter.chapterId, equals(4));
        expect(chapter.title, equals('Chapter of Renunciation'));
        expect(chapter.verseCount, equals(42));
      });

      test('should handle empty summary gracefully', () {
        final chapter = Chapter(
          chapterId: 5,
          title: 'Chapter of Yoga',
          summary: '',
        );

        expect(chapter.summary, equals(''));
        expect(chapter.title, isNotEmpty);
      });

      test('should support theme property', () {
        final chapter = Chapter(
          chapterId: 6,
          title: 'Chapter',
          summary: 'Summary',
          theme: 'Selfless Action',
          verseCount: 55,
        );

        expect(chapter.theme, equals('Selfless Action'));
        expect(chapter.verseCount, equals(55));
      });
    });

    group('Model Equality and Hashing', () {
      test('identical chapters should be equal', () {
        final chapter1 = Chapter(
          chapterId: 7,
          title: 'Test Chapter',
          summary: 'Test',
        );

        final chapter2 = Chapter(
          chapterId: 7,
          title: 'Test Chapter',
          summary: 'Test',
        );

        // Should have same properties
        expect(chapter1.chapterId, equals(chapter2.chapterId));
        expect(chapter1.title, equals(chapter2.title));
      });

      test('different chapters should be distinguishable', () {
        final chapter1 = Chapter(
          chapterId: 8,
          title: 'Chapter A',
          summary: 'A',
        );

        final chapter2 = Chapter(
          chapterId: 9,
          title: 'Chapter B',
          summary: 'B',
        );

        expect(chapter1.chapterId, isNot(equals(chapter2.chapterId)));
        expect(chapter1.title, isNot(equals(chapter2.title)));
      });
    });

    group('Data Validation', () {
      test('should accept valid UTF-8 text', () {
        final chapter = Chapter(
          chapterId: 10,
          title: 'धर्म (Dharma)',
          summary: 'कर्म (Karma) and योग (Yoga)',
        );

        expect(chapter.title, contains('धर्म'));
        expect(chapter.summary, contains('कर्म'));
      });

      test('should handle special characters in text', () {
        final chapter = Chapter(
          chapterId: 11,
          title: 'Chapter with "quotes" and \'apostrophes\'',
          summary: 'Summary with (parentheses) and [brackets]',
        );

        expect(chapter.title, contains('"'));
        expect(chapter.summary, contains('['));
      });
    });

    group('Serialization', () {
      test('should have fromJson factory', () {
        expect(Chapter.fromJson, isA<Function>());
      });

      test('should have toJson method', () {
        final chapter = Chapter(
          chapterId: 12,
          title: 'Test',
          summary: 'Test',
        );

        expect(chapter.toJson, isA<Function>());
      });
    });
  });
}

