// test/models/annotation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/annotation.dart';

void main() {
  group('Annotation Constructor', () {
    test('should create annotation with required fields', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: 'Your right is to perform your duty',
        startIndex: 0,
        endIndex: 35,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.id, equals('test-id'));
      expect(annotation.verseId, equals('2.47'));
      expect(annotation.selectedText, equals('Your right is to perform your duty'));
      expect(annotation.startIndex, equals(0));
      expect(annotation.endIndex, equals(35));
      expect(annotation.highlightColor, equals(HighlightColors.yellow));
      expect(annotation.createdAt, equals(now));
      expect(annotation.updatedAt, equals(now));
      expect(annotation.note, isNull);
    });

    test('should create annotation with optional note', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: 'Selected text',
        startIndex: 0,
        endIndex: 13,
        highlightColor: HighlightColors.green,
        note: 'This is an important verse about duty',
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.note, equals('This is an important verse about duty'));
    });

    test('should handle verse ID in chapterId.verseId format', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.blue,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.verseId, equals('1.1'));
      expect(annotation.verseId, contains('.'));
    });

    test('should handle different verse formats', () {
      final now = DateTime.now();

      final formats = ['1.1', '2.47', '18.78', '10.20'];
      for (final verseId in formats) {
        final annotation = Annotation(
          id: 'test-$verseId',
          verseId: verseId,
          selectedText: 'Text',
          startIndex: 0,
          endIndex: 4,
          highlightColor: HighlightColors.yellow,
          createdAt: now,
          updatedAt: now,
        );

        expect(annotation.verseId, equals(verseId));
      }
    });
  });

  group('Text Selection Indices', () {
    test('should correctly store start and end indices', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: 'duty',
        startIndex: 30,
        endIndex: 34,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.startIndex, equals(30));
      expect(annotation.endIndex, equals(34));
      expect(annotation.endIndex - annotation.startIndex, equals(4));
      expect(annotation.selectedText.length, equals(4));
    });

    test('should handle zero start index', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Beginning',
        startIndex: 0,
        endIndex: 9,
        highlightColor: HighlightColors.green,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.startIndex, equals(0));
      expect(annotation.endIndex, equals(9));
    });

    test('should handle large indices for long verses', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '11.11',
        selectedText: 'text',
        startIndex: 1000,
        endIndex: 1004,
        highlightColor: HighlightColors.blue,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.startIndex, equals(1000));
      expect(annotation.endIndex, equals(1004));
    });

    test('should handle single character selection', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'A',
        startIndex: 10,
        endIndex: 11,
        highlightColor: HighlightColors.pink,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.selectedText.length, equals(1));
      expect(annotation.endIndex - annotation.startIndex, equals(1));
    });

    test('should handle full verse selection', () {
      final now = DateTime.now();
      final fullVerse = 'Your right is to perform your duty only, but never to its fruits';
      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: fullVerse,
        startIndex: 0,
        endIndex: fullVerse.length,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.selectedText, equals(fullVerse));
      expect(annotation.startIndex, equals(0));
      expect(annotation.endIndex, equals(fullVerse.length));
    });
  });

  group('HighlightColors Constants', () {
    test('should have all predefined colors', () {
      expect(HighlightColors.yellow, equals('#FFF59D'));
      expect(HighlightColors.green, equals('#C8E6C9'));
      expect(HighlightColors.blue, equals('#BBDEFB'));
      expect(HighlightColors.pink, equals('#F8BBD9'));
      expect(HighlightColors.orange, equals('#FFE0B2'));
      expect(HighlightColors.purple, equals('#E1BEE7'));
    });

    test('should have colors list with all colors', () {
      expect(HighlightColors.colors, hasLength(6));
      expect(HighlightColors.colors, contains(HighlightColors.yellow));
      expect(HighlightColors.colors, contains(HighlightColors.green));
      expect(HighlightColors.colors, contains(HighlightColors.blue));
      expect(HighlightColors.colors, contains(HighlightColors.pink));
      expect(HighlightColors.colors, contains(HighlightColors.orange));
      expect(HighlightColors.colors, contains(HighlightColors.purple));
    });

    test('should have color names map', () {
      expect(HighlightColors.colorNames, hasLength(6));
      expect(HighlightColors.colorNames[HighlightColors.yellow], equals('Yellow'));
      expect(HighlightColors.colorNames[HighlightColors.green], equals('Green'));
      expect(HighlightColors.colorNames[HighlightColors.blue], equals('Blue'));
      expect(HighlightColors.colorNames[HighlightColors.pink], equals('Pink'));
      expect(HighlightColors.colorNames[HighlightColors.orange], equals('Orange'));
      expect(HighlightColors.colorNames[HighlightColors.purple], equals('Purple'));
    });

    test('should use valid hex color format', () {
      final hexPattern = RegExp(r'^#[0-9A-F]{6}$', caseSensitive: false);

      for (final color in HighlightColors.colors) {
        expect(color, matches(hexPattern));
      }
    });
  });

  group('JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30, 0);
      final annotation = Annotation(
        id: 'test-123',
        verseId: '2.47',
        selectedText: 'Your right is to perform your duty',
        startIndex: 0,
        endIndex: 35,
        highlightColor: HighlightColors.yellow,
        note: 'Important verse',
        createdAt: now,
        updatedAt: now,
      );

      final json = annotation.toJson();

      expect(json['id'], equals('test-123'));
      expect(json['verseId'], equals('2.47'));
      expect(json['selectedText'], equals('Your right is to perform your duty'));
      expect(json['startIndex'], equals(0));
      expect(json['endIndex'], equals(35));
      expect(json['highlightColor'], equals(HighlightColors.yellow));
      expect(json['note'], equals('Important verse'));
      expect(json['createdAt'], contains('2024-01-15'));
      expect(json['updatedAt'], contains('2024-01-15'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-456',
        'verseId': '3.14',
        'selectedText': 'Selected text from verse',
        'startIndex': 10,
        'endIndex': 33,
        'highlightColor': HighlightColors.green,
        'note': 'My note here',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-16T12:00:00.000Z',
      };

      final annotation = Annotation.fromJson(json);

      expect(annotation.id, equals('test-456'));
      expect(annotation.verseId, equals('3.14'));
      expect(annotation.selectedText, equals('Selected text from verse'));
      expect(annotation.startIndex, equals(10));
      expect(annotation.endIndex, equals(33));
      expect(annotation.highlightColor, equals(HighlightColors.green));
      expect(annotation.note, equals('My note here'));
    });

    test('should handle JSON roundtrip', () {
      final now = DateTime.now();
      final original = Annotation(
        id: 'roundtrip-test',
        verseId: '5.10',
        selectedText: 'Test text',
        startIndex: 5,
        endIndex: 14,
        highlightColor: HighlightColors.blue,
        note: 'Test note',
        createdAt: now,
        updatedAt: now,
      );

      final json = original.toJson();
      final restored = Annotation.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.verseId, equals(original.verseId));
      expect(restored.selectedText, equals(original.selectedText));
      expect(restored.startIndex, equals(original.startIndex));
      expect(restored.endIndex, equals(original.endIndex));
      expect(restored.highlightColor, equals(original.highlightColor));
      expect(restored.note, equals(original.note));
    });

    test('should handle null note in serialization', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      final json = annotation.toJson();

      expect(json['note'], isNull);
    });

    test('should handle null note in deserialization', () {
      final json = {
        'id': 'test-id',
        'verseId': '1.1',
        'selectedText': 'Text',
        'startIndex': 0,
        'endIndex': 4,
        'highlightColor': HighlightColors.yellow,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final annotation = Annotation.fromJson(json);

      expect(annotation.note, isNull);
    });
  });

  group('copyWith Method', () {
    test('should create copy with updated fields', () {
      final now = DateTime.now();
      final original = Annotation(
        id: 'original-id',
        verseId: '1.1',
        selectedText: 'Original text',
        startIndex: 0,
        endIndex: 13,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(
        note: 'Added note',
        highlightColor: HighlightColors.green,
      );

      expect(copy.id, equals('original-id'));
      expect(copy.selectedText, equals('Original text'));
      expect(copy.note, equals('Added note'));
      expect(copy.highlightColor, equals(HighlightColors.green));
    });

    test('should copy all fields individually', () {
      final now = DateTime.now();
      final later = DateTime.now().add(const Duration(hours: 1));
      final original = Annotation(
        id: 'original',
        verseId: '1.1',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(
        id: 'new-id',
        verseId: '2.2',
        selectedText: 'New text',
        startIndex: 10,
        endIndex: 18,
        highlightColor: HighlightColors.blue,
        note: 'New note',
        createdAt: later,
        updatedAt: later,
      );

      expect(copy.id, equals('new-id'));
      expect(copy.verseId, equals('2.2'));
      expect(copy.selectedText, equals('New text'));
      expect(copy.startIndex, equals(10));
      expect(copy.endIndex, equals(18));
      expect(copy.highlightColor, equals(HighlightColors.blue));
      expect(copy.note, equals('New note'));
      expect(copy.createdAt, equals(later));
      expect(copy.updatedAt, equals(later));
    });

    test('should preserve unchanged fields', () {
      final now = DateTime.now();
      final original = Annotation(
        id: 'test-id',
        verseId: '3.14',
        selectedText: 'Original',
        startIndex: 5,
        endIndex: 13,
        highlightColor: HighlightColors.pink,
        note: 'Original note',
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(note: 'Updated note');

      expect(copy.id, equals(original.id));
      expect(copy.verseId, equals(original.verseId));
      expect(copy.selectedText, equals(original.selectedText));
      expect(copy.startIndex, equals(original.startIndex));
      expect(copy.endIndex, equals(original.endIndex));
      expect(copy.highlightColor, equals(original.highlightColor));
      expect(copy.note, equals('Updated note'));
    });
  });

  group('Edge Cases', () {
    test('should handle very long selected text', () {
      final now = DateTime.now();
      final longText = 'A' * 10000;
      final annotation = Annotation(
        id: 'test-id',
        verseId: '11.11',
        selectedText: longText,
        startIndex: 0,
        endIndex: 10000,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.selectedText.length, equals(10000));
    });

    test('should handle very long notes', () {
      final now = DateTime.now();
      final longNote = 'B' * 5000;
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.green,
        note: longNote,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.note!.length, equals(5000));
    });

    test('should handle Unicode characters in selected text', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन',
        startIndex: 0,
        endIndex: 37,
        highlightColor: HighlightColors.blue,
        note: 'महत्वपूर्ण श्लोक',
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.selectedText, contains('कर्मण्येवाधिकारस्ते'));
      expect(annotation.note, contains('महत्वपूर्ण'));
    });

    test('should handle special characters in text', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text with "quotes" and \'apostrophes\'',
        startIndex: 0,
        endIndex: 38,
        highlightColor: HighlightColors.pink,
        note: 'Note with <html> & special chars',
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.selectedText, contains('"'));
      expect(annotation.note, contains('&'));
    });

    test('should handle emojis in text', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text with emojis 🙏 📿 🕉️',
        startIndex: 0,
        endIndex: 24,
        highlightColor: HighlightColors.orange,
        note: 'Important! 🌟',
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.selectedText, contains('🙏'));
      expect(annotation.note, contains('🌟'));
    });

    test('should handle all chapters 1-18 in verseId', () {
      final now = DateTime.now();
      for (int chapter = 1; chapter <= 18; chapter++) {
        final annotation = Annotation(
          id: 'test-$chapter',
          verseId: '$chapter.1',
          selectedText: 'Text',
          startIndex: 0,
          endIndex: 4,
          highlightColor: HighlightColors.yellow,
          createdAt: now,
          updatedAt: now,
        );

        expect(annotation.verseId, equals('$chapter.1'));
      }
    });

    test('should handle all highlight colors', () {
      final now = DateTime.now();
      for (final color in HighlightColors.colors) {
        final annotation = Annotation(
          id: 'test-$color',
          verseId: '1.1',
          selectedText: 'Text',
          startIndex: 0,
          endIndex: 4,
          highlightColor: color,
          createdAt: now,
          updatedAt: now,
        );

        expect(annotation.highlightColor, equals(color));
      }
    });

    test('should handle empty string note', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.yellow,
        note: '',
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.note, equals(''));
      expect(annotation.note!.isEmpty, isTrue);
    });

    test('should handle multiline selected text', () {
      final now = DateTime.now();
      final multilineText = '''Your right is to perform your duty only,
but never to its fruits.
Let not the fruits of action be your motive,
nor let your attachment be to inaction.''';

      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: multilineText,
        startIndex: 0,
        endIndex: multilineText.length,
        highlightColor: HighlightColors.purple,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.selectedText, contains('\n'));
      expect(annotation.selectedText, equals(multilineText));
    });

    test('should handle multiline notes', () {
      final now = DateTime.now();
      final multilineNote = '''This is a very important verse.
It teaches about detachment.
Krishna explains the path of karma yoga.''';

      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.green,
        note: multilineNote,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.note, contains('\n'));
      expect(annotation.note, equals(multilineNote));
    });
  });

  group('Timestamp Management', () {
    test('should track creation and update times separately', () {
      final created = DateTime(2024, 1, 15, 10, 0, 0);
      final updated = DateTime(2024, 1, 16, 15, 30, 0);

      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.yellow,
        createdAt: created,
        updatedAt: updated,
      );

      expect(annotation.createdAt, equals(created));
      expect(annotation.updatedAt, equals(updated));
      expect(annotation.updatedAt.isAfter(annotation.createdAt), isTrue);
    });

    test('should maintain timestamp precision', () {
      final precise = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);

      final annotation = Annotation(
        id: 'test-id',
        verseId: '1.1',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.yellow,
        createdAt: precise,
        updatedAt: precise,
      );

      expect(annotation.createdAt.year, equals(2024));
      expect(annotation.createdAt.month, equals(1));
      expect(annotation.createdAt.day, equals(15));
      expect(annotation.createdAt.hour, equals(10));
      expect(annotation.createdAt.minute, equals(30));
      expect(annotation.createdAt.second, equals(45));
    });
  });

  group('Verse ID Formats', () {
    test('should handle standard verse ID format', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '2.47',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.verseId, matches(RegExp(r'^\d+\.\d+$')));
    });

    test('should handle verse IDs with multiple digits', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'test-id',
        verseId: '18.78',
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        highlightColor: HighlightColors.yellow,
        createdAt: now,
        updatedAt: now,
      );

      expect(annotation.verseId, equals('18.78'));
    });
  });
}
