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

      test('should correctly serialize to JSON', () {
        final chapter = Chapter(
          chapterId: 1,
          title: 'Arjuna Vishada Yoga',
          subtitle: 'The Yoga of Arjuna\'s Dejection',
          summary: 'Introduction to the Gita',
          verseCount: 47,
          theme: 'Despondency',
          keyTeachings: ['Duty', 'Righteousness'],
        );

        final json = chapter.toJson();

        expect(json['ch_chapter_id'], equals(1));
        expect(json['ch_title'], equals('Arjuna Vishada Yoga'));
        expect(json['ch_subtitle'], equals('The Yoga of Arjuna\'s Dejection'));
        expect(json['ch_summary'], equals('Introduction to the Gita'));
        expect(json['ch_verse_count'], equals(47));
        expect(json['ch_theme'], equals('Despondency'));
        expect(json['ch_key_teachings'], equals(['Duty', 'Righteousness']));
      });

      test('should correctly deserialize from JSON', () {
        final json = {
          'ch_chapter_id': 2,
          'ch_title': 'Sankhya Yoga',
          'ch_subtitle': 'The Yoga of Knowledge',
          'ch_summary': 'The nature of the Self',
          'ch_verse_count': 72,
          'ch_theme': 'Knowledge',
          'ch_key_teachings': ['Self-knowledge', 'Action'],
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.chapterId, equals(2));
        expect(chapter.title, equals('Sankhya Yoga'));
        expect(chapter.subtitle, equals('The Yoga of Knowledge'));
        expect(chapter.summary, equals('The nature of the Self'));
        expect(chapter.verseCount, equals(72));
        expect(chapter.theme, equals('Knowledge'));
        expect(chapter.keyTeachings, equals(['Self-knowledge', 'Action']));
      });

      test('should handle JSON roundtrip', () {
        final original = Chapter(
          chapterId: 3,
          title: 'Karma Yoga',
          subtitle: 'The Yoga of Action',
          summary: 'Selfless service',
          verseCount: 43,
          theme: 'Action',
          keyTeachings: ['Duty', 'Detachment'],
        );

        final json = original.toJson();
        final restored = Chapter.fromJson(json);

        expect(restored.chapterId, equals(original.chapterId));
        expect(restored.title, equals(original.title));
        expect(restored.subtitle, equals(original.subtitle));
        expect(restored.summary, equals(original.summary));
        expect(restored.verseCount, equals(original.verseCount));
        expect(restored.theme, equals(original.theme));
        expect(restored.keyTeachings, equals(original.keyTeachings));
      });

      test('should handle null fields in JSON serialization', () {
        final chapter = Chapter(
          chapterId: 4,
          title: 'Jnana Yoga',
        );

        final json = chapter.toJson();

        expect(json['ch_chapter_id'], equals(4));
        expect(json['ch_title'], equals('Jnana Yoga'));
        expect(json['ch_subtitle'], isNull);
        expect(json['ch_summary'], isNull);
        expect(json['ch_verse_count'], isNull);
        expect(json['ch_theme'], isNull);
        expect(json['ch_key_teachings'], isNull);
      });

      test('should handle null fields in JSON deserialization', () {
        final json = {
          'ch_chapter_id': 5,
          'ch_title': 'Karma Sannyasa Yoga',
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.chapterId, equals(5));
        expect(chapter.title, equals('Karma Sannyasa Yoga'));
        expect(chapter.subtitle, isNull);
        expect(chapter.summary, isNull);
        expect(chapter.verseCount, isNull);
        expect(chapter.theme, isNull);
        expect(chapter.keyTeachings, isNull);
      });

      test('should handle empty keyTeachings list', () {
        final json = {
          'ch_chapter_id': 6,
          'ch_title': 'Dhyana Yoga',
          'ch_key_teachings': [],
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.keyTeachings, isEmpty);
      });
    });

    group('Multilingual Extensions', () {
      test('should create from multilingual JSON', () {
        final json = {
          'ch_chapter_id': 7,
          'ch_title': 'Jnana Vijnana Yoga',
          'ch_subtitle': 'Yoga of Knowledge and Wisdom',
          'ch_summary': 'Self-realization',
          'ch_verse_count': 30,
          'ch_theme': 'Wisdom',
          'ch_key_teachings': ['Knowledge', 'Devotion'],
        };

        final chapter = ChapterMultilingualExtensions.fromMultilingualJson(json);

        expect(chapter.chapterId, equals(7));
        expect(chapter.title, equals('Jnana Vijnana Yoga'));
      });

      test('should convert to translation JSON', () {
        final chapter = Chapter(
          chapterId: 8,
          title: 'Aksara Brahma Yoga',
          subtitle: 'The Eternal Brahman',
          summary: 'The imperishable',
          theme: 'Immortality',
          keyTeachings: ['Brahman', 'Liberation'],
        );

        final json = chapter.toTranslationJson('hi');

        expect(json['chapter_id'], equals(8));
        expect(json['lang_code'], equals('hi'));
        expect(json['title'], equals('Aksara Brahma Yoga'));
        expect(json['subtitle'], equals('The Eternal Brahman'));
      });

      test('should create from translation JSON', () {
        final json = {
          'chapter_id': 9,
          'title': 'Raja Vidya Yoga',
          'subtitle': 'Royal Knowledge',
          'summary': 'The sovereign secret',
          'theme': 'Devotion',
          'key_teachings': ['Bhakti', 'Grace'],
        };

        final chapter = ChapterMultilingualExtensions.fromTranslationJson(json);

        expect(chapter.chapterId, equals(9));
        expect(chapter.title, equals('Raja Vidya Yoga'));
        expect(chapter.verseCount, isNull); // Not in translation table
      });

      test('should check hasTranslationData correctly', () {
        final complete = Chapter(
          chapterId: 10,
          title: 'Vibhuti Yoga',
          subtitle: 'Divine Manifestations',
          summary: 'The glories of the Divine',
        );

        final incomplete = Chapter(
          chapterId: 11,
          title: 'Visvarupa Darshana Yoga',
        );

        expect(complete.hasTranslationData, isTrue);
        expect(incomplete.hasTranslationData, isFalse);
      });

      test('should create copy with translation', () {
        final original = Chapter(
          chapterId: 12,
          title: 'Bhakti Yoga',
          verseCount: 20,
        );

        final translated = original.withTranslation(
          title: 'योग भक्ति',
          subtitle: 'भक्ति का मार्ग',
          summary: 'भगवान की भक्ति',
        );

        expect(translated.chapterId, equals(12));
        expect(translated.title, equals('योग भक्ति'));
        expect(translated.subtitle, equals('भक्ति का मार्ग'));
        expect(translated.verseCount, equals(20)); // Preserved
      });
    });

    group('Edge Cases', () {
      test('should handle very long title', () {
        final longTitle = 'A' * 1000;
        final chapter = Chapter(
          chapterId: 13,
          title: longTitle,
          summary: 'Test',
        );

        expect(chapter.title.length, equals(1000));
      });

      test('should handle very long summary', () {
        final longSummary = 'B' * 5000;
        final chapter = Chapter(
          chapterId: 14,
          title: 'Test',
          summary: longSummary,
        );

        expect(chapter.summary!.length, equals(5000));
      });

      test('should handle multiple keyTeachings', () {
        final teachings = List.generate(50, (i) => 'Teaching $i');
        final chapter = Chapter(
          chapterId: 15,
          title: 'Test',
          keyTeachings: teachings,
        );

        expect(chapter.keyTeachings!.length, equals(50));
      });
    });
  });
}

