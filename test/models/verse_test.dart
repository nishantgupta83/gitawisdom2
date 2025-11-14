// test/models/verse_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/verse.dart';

void main() {
  group('Verse Model', () {
    group('Constructors', () {
      test('should create with required fields', () {
        final verse = Verse(
          verseId: 1,
          description: 'Dharmakshetre kurukshetre',
        );

        expect(verse.verseId, equals(1));
        expect(verse.description, equals('Dharmakshetre kurukshetre'));
        expect(verse.chapterId, isNull);
      });

      test('should create with optional chapterId', () {
        final verse = Verse(
          verseId: 47,
          description: 'Your right is to work only',
          chapterId: 2,
        );

        expect(verse.verseId, equals(47));
        expect(verse.chapterId, equals(2));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final verse = Verse(
          verseId: 10,
          description: 'Verse text',
          chapterId: 3,
        );

        final json = verse.toJson();

        expect(json['gv_verses_id'], equals(10));
        expect(json['gv_verses'], equals('Verse text'));
        expect(json['gv_chapter_id'], equals(3));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'gv_verses_id': 5,
          'gv_verses': 'Test verse',
          'gv_chapter_id': 1,
        };

        final verse = Verse.fromJson(json);

        expect(verse.verseId, equals(5));
        expect(verse.description, equals('Test verse'));
        expect(verse.chapterId, equals(1));
      });

      test('should handle JSON roundtrip', () {
        final original = Verse(
          verseId: 20,
          description: 'Original verse text',
          chapterId: 4,
        );

        final json = original.toJson();
        final restored = Verse.fromJson(json);

        expect(restored.verseId, equals(original.verseId));
        expect(restored.description, equals(original.description));
        expect(restored.chapterId, equals(original.chapterId));
      });

      test('should handle null chapterId in serialization', () {
        final verse = Verse(
          verseId: 1,
          description: 'Test',
        );

        final json = verse.toJson();

        expect(json['gv_verses_id'], equals(1));
        expect(json['gv_verses'], equals('Test'));
        expect(json.containsKey('gv_chapter_id'), isFalse);
      });

      test('should handle null chapterId in deserialization', () {
        final json = {
          'gv_verses_id': 1,
          'gv_verses': 'Test',
        };

        final verse = Verse.fromJson(json);

        expect(verse.verseId, equals(1));
        expect(verse.chapterId, isNull);
      });
    });

    group('Multilingual Extensions', () {
      test('should create from multilingual JSON', () {
        final json = {
          'gv_verses_id': 47,
          'gv_verses': 'कर्मण्येवाधिकारस्ते',
          'gv_chapter_id': 2,
        };

        final verse = VerseMultilingualExtensions.fromMultilingualJson(json);

        expect(verse.verseId, equals(47));
        expect(verse.description, contains('कर्मण्येवाधिकारस्ते'));
        expect(verse.chapterId, equals(2));
      });

      test('should convert to translation JSON', () {
        final verse = Verse(
          verseId: 30,
          description: 'Original verse',
          chapterId: 5,
        );

        final json = verse.toTranslationJson(
          'hi',
          translation: 'Hindi translation',
          commentary: 'Commentary text',
        );

        expect(json['verse_id'], equals(30));
        expect(json['chapter_id'], equals(5));
        expect(json['lang_code'], equals('hi'));
        expect(json['description'], equals('Original verse'));
        expect(json['translation'], equals('Hindi translation'));
        expect(json['commentary'], equals('Commentary text'));
      });

      test('should create from translation JSON', () {
        final json = {
          'verse_id': 15,
          'description': 'Translated verse',
          'chapter_id': 6,
        };

        final verse = VerseMultilingualExtensions.fromTranslationJson(json);

        expect(verse.verseId, equals(15));
        expect(verse.description, equals('Translated verse'));
        expect(verse.chapterId, equals(6));
      });

      test('should check hasTranslationData', () {
        final withData = Verse(
          verseId: 1,
          description: 'Valid verse',
          chapterId: 1,
        );

        final empty = Verse(
          verseId: 2,
          description: '',
          chapterId: 2,
        );

        expect(withData.hasTranslationData, isTrue);
        expect(empty.hasTranslationData, isFalse);
      });

      test('should create copy with translation', () {
        final original = Verse(
          verseId: 10,
          description: 'English',
          chapterId: 3,
        );

        final translated = original.withTranslation(
          description: 'हिन्दी',
        );

        expect(translated.verseId, equals(10));
        expect(translated.description, equals('हिन्दी'));
        expect(translated.chapterId, equals(3));
      });
    });

    group('Helper Methods', () {
      test('should return correct reference format', () {
        final verse = Verse(
          verseId: 47,
          description: 'Test',
          chapterId: 2,
        );

        expect(verse.reference, equals('2.47'));
      });

      test('should return verse ID when no chapter', () {
        final verse = Verse(
          verseId: 10,
          description: 'Test',
        );

        expect(verse.reference, equals('10'));
      });

      test('should validate verse correctly', () {
        final valid = Verse(
          verseId: 1,
          description: 'Valid',
          chapterId: 1,
        );

        final invalidId = Verse(
          verseId: 0,
          description: 'Invalid',
          chapterId: 1,
        );

        final emptyDesc = Verse(
          verseId: 1,
          description: '',
          chapterId: 1,
        );

        expect(valid.isValid, isTrue);
        expect(invalidId.isValid, isFalse);
        expect(emptyDesc.isValid, isFalse);
      });

      test('should return preview for long verses', () {
        final longVerse = Verse(
          verseId: 1,
          description: 'A' * 200,
          chapterId: 1,
        );

        final preview = longVerse.preview;

        expect(preview.length, equals(100));
        expect(preview.endsWith('...'), isTrue);
      });

      test('should return full text for short verses', () {
        final shortVerse = Verse(
          verseId: 1,
          description: 'Short verse',
          chapterId: 1,
        );

        expect(shortVerse.preview, equals('Short verse'));
      });
    });

    group('Edge Cases', () {
      test('should handle very long description', () {
        final longText = 'B' * 10000;
        final verse = Verse(
          verseId: 1,
          description: longText,
          chapterId: 1,
        );

        expect(verse.description.length, equals(10000));
      });

      test('should handle special characters', () {
        final verse = Verse(
          verseId: 1,
          description: 'Special "quotes" and \'apostrophes\' test',
          chapterId: 1,
        );

        expect(verse.description, contains('"'));
        expect(verse.description, contains('\''));
      });

      test('should handle Unicode properly', () {
        final verse = Verse(
          verseId: 47,
          description: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन',
          chapterId: 2,
        );

        expect(verse.description, contains('कर्मण्येवाधिकारस्ते'));
      });

      test('should handle all valid chapter IDs', () {
        for (int chapterId = 1; chapterId <= 18; chapterId++) {
          final verse = Verse(
            verseId: 1,
            description: 'Test',
            chapterId: chapterId,
          );

          expect(verse.chapterId, equals(chapterId));
          expect(verse.reference, equals('$chapterId.1'));
        }
      });
    });
  });
}
