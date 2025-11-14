import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/verse.dart';

void main() {
  group('VerseMultilingualExtensions', () {
    test('fromMultilingualJson should create Verse from JSON', () {
      final json = {
        'gv_verses_id': 1,
        'gv_verses': 'Test verse content',
        'gv_chapter_id': 2,
      };

      final verse = VerseMultilingualExtensions.fromMultilingualJson(json);

      expect(verse.verseId, equals(1));
      expect(verse.description, equals('Test verse content'));
      expect(verse.chapterId, equals(2));
    });

    test('toTranslationJson should convert to translation format', () {
      final verse = Verse(
        verseId: 1,
        description: 'Test description',
        chapterId: 2,
      );

      final json = verse.toTranslationJson(
        'hi',
        translation: 'Hindi translation',
        commentary: 'Hindi commentary',
      );

      expect(json['verse_id'], equals(1));
      expect(json['chapter_id'], equals(2));
      expect(json['lang_code'], equals('hi'));
      expect(json['description'], equals('Test description'));
      expect(json['translation'], equals('Hindi translation'));
      expect(json['commentary'], equals('Hindi commentary'));
    });

    test('fromTranslationJson should create Verse from translation table', () {
      final json = {
        'verse_id': 3,
        'description': 'Translated verse',
        'chapter_id': 4,
      };

      final verse = VerseMultilingualExtensions.fromTranslationJson(json);

      expect(verse.verseId, equals(3));
      expect(verse.description, equals('Translated verse'));
      expect(verse.chapterId, equals(4));
    });

    test('hasTranslationData should return true for non-empty description', () {
      final verse1 = Verse(verseId: 1, description: 'Some text', chapterId: 1);
      final verse2 = Verse(verseId: 2, description: '', chapterId: 1);

      expect(verse1.hasTranslationData, isTrue);
      expect(verse2.hasTranslationData, isFalse);
    });

    test('withTranslation should create copy with updated description', () {
      final original = Verse(
        verseId: 1,
        description: 'Original',
        chapterId: 2,
      );

      final updated = original.withTranslation(
        description: 'Updated description',
      );

      expect(updated.verseId, equals(1));
      expect(updated.description, equals('Updated description'));
      expect(updated.chapterId, equals(2));
    });

    test('withTranslation should preserve original if no changes', () {
      final original = Verse(
        verseId: 1,
        description: 'Original',
        chapterId: 2,
      );

      final updated = original.withTranslation();

      expect(updated.description, equals('Original'));
      expect(updated.verseId, equals(1));
      expect(updated.chapterId, equals(2));
    });

    test('reference should format as chapter.verse', () {
      final verse1 = Verse(verseId: 5, description: 'Test', chapterId: 3);
      final verse2 = Verse(verseId: 10, description: 'Test', chapterId: null);

      expect(verse1.reference, equals('3.5'));
      expect(verse2.reference, equals('10'));
    });

    test('isValid should check for required fields', () {
      final verse1 = Verse(verseId: 1, description: 'Valid', chapterId: 1);
      final verse2 = Verse(verseId: 0, description: 'Invalid ID', chapterId: 1);
      final verse3 = Verse(verseId: 1, description: '', chapterId: 1);

      expect(verse1.isValid, isTrue);
      expect(verse2.isValid, isFalse);
      expect(verse3.isValid, isFalse);
    });

    test('preview should return full text if under 100 chars', () {
      final shortVerse = Verse(
        verseId: 1,
        description: 'Short verse',
        chapterId: 1,
      );

      expect(shortVerse.preview, equals('Short verse'));
      expect(shortVerse.preview.length, lessThanOrEqualTo(100));
    });

    test('preview should truncate long text with ellipsis', () {
      final longText = 'a' * 150;
      final longVerse = Verse(
        verseId: 1,
        description: longText,
        chapterId: 1,
      );

      expect(longVerse.preview.endsWith('...'), isTrue);
      expect(longVerse.preview.length, equals(100));
    });

    test('preview should be exactly 100 chars for long text', () {
      final longText = 'This is a very long verse that exceeds one hundred characters in length and should be truncated with an ellipsis at the end';
      final verse = Verse(
        verseId: 1,
        description: longText,
        chapterId: 1,
      );

      expect(verse.preview.length, equals(100));
      expect(verse.preview, equals(longText.substring(0, 97) + '...'));
    });
  });
}
