// test/models/journal_entry_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/journal_entry.dart';

void main() {
  group('JournalEntry Model', () {
    group('Constructors', () {
      test('should create with all fields', () {
        final now = DateTime.now();
        final entry = JournalEntry(
          id: 'test-id-123',
          reflection: 'My spiritual reflection',
          rating: 4,
          dateCreated: now,
          scenarioId: 42,
          category: 'Meditation',
        );

        expect(entry.id, equals('test-id-123'));
        expect(entry.reflection, equals('My spiritual reflection'));
        expect(entry.rating, equals(4));
        expect(entry.dateCreated, equals(now));
        expect(entry.scenarioId, equals(42));
        expect(entry.category, equals('Meditation'));
      });

      test('should create with default category', () {
        final entry = JournalEntry(
          id: 'id',
          reflection: 'Text',
          rating: 3,
          dateCreated: DateTime.now(),
        );

        expect(entry.category, equals('General'));
      });

      test('should create with null scenarioId', () {
        final entry = JournalEntry(
          id: 'id',
          reflection: 'Text',
          rating: 5,
          dateCreated: DateTime.now(),
        );

        expect(entry.scenarioId, isNull);
      });
    });

    group('Factory create', () {
      test('should generate UUID', () {
        final entry = JournalEntry.create(
          reflection: 'Test reflection',
          rating: 4,
        );

        expect(entry.id, isNotEmpty);
        expect(entry.id.length, equals(36)); // UUID length
        expect(entry.id.contains('-'), isTrue);
      });

      test('should set current timestamp', () {
        final before = DateTime.now();
        final entry = JournalEntry.create(
          reflection: 'Test',
          rating: 3,
        );
        final after = DateTime.now();

        expect(entry.dateCreated.isAfter(before) || entry.dateCreated.isAtSameMomentAs(before), isTrue);
        expect(entry.dateCreated.isBefore(after) || entry.dateCreated.isAtSameMomentAs(after), isTrue);
      });

      test('should use provided scenario ID', () {
        final entry = JournalEntry.create(
          reflection: 'Test',
          rating: 5,
          scenarioId: 123,
        );

        expect(entry.scenarioId, equals(123));
      });

      test('should use provided category', () {
        final entry = JournalEntry.create(
          reflection: 'Test',
          rating: 4,
          category: 'Daily Reflection',
        );

        expect(entry.category, equals('Daily Reflection'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final entry = JournalEntry(
          id: 'uuid-123',
          reflection: 'My thoughts',
          rating: 5,
          dateCreated: DateTime(2024, 1, 15, 10, 30),
          scenarioId: 42,
          category: 'Personal Growth',
        );

        final json = entry.toJson();

        expect(json['id'], equals('uuid-123'));
        expect(json['reflection'], equals('My thoughts'));
        expect(json['rating'], equals(5));
        expect(json['category'], equals('Personal Growth'));
        expect(json['sync_status'], equals('synced'));
        expect(json.containsKey('created_at'), isTrue);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'test-id',
          'reflection': 'Test reflection',
          'rating': 4,
          'created_at': '2024-01-15T14:30:00.000Z',
          'category': 'Meditation',
        };

        final entry = JournalEntry.fromJson(json);

        expect(entry.id, equals('test-id'));
        expect(entry.reflection, equals('Test reflection'));
        expect(entry.rating, equals(4));
        expect(entry.category, equals('Meditation'));
      });

      test('should handle default category in fromJson', () {
        final json = {
          'id': 'test-id',
          'reflection': 'Test',
          'rating': 3,
          'created_at': '2024-01-15T14:30:00.000Z',
        };

        final entry = JournalEntry.fromJson(json);

        expect(entry.category, equals('General'));
      });

      test('should handle JSON roundtrip', () {
        final original = JournalEntry(
          id: 'original-id',
          reflection: 'Original reflection',
          rating: 5,
          dateCreated: DateTime(2024, 1, 15, 10, 30),
          category: 'Test',
        );

        final json = original.toJson();
        final restored = JournalEntry.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.reflection, equals(original.reflection));
        expect(restored.rating, equals(original.rating));
        expect(restored.category, equals(original.category));
      });
    });

    group('Validation', () {
      test('should accept valid ratings 1-5', () {
        for (int rating = 1; rating <= 5; rating++) {
          final entry = JournalEntry(
            id: 'id',
            reflection: 'Text',
            rating: rating,
            dateCreated: DateTime.now(),
          );

          expect(entry.rating, equals(rating));
          expect(entry.rating, greaterThanOrEqualTo(1));
          expect(entry.rating, lessThanOrEqualTo(5));
        }
      });

      test('should handle very long reflection', () {
        final longReflection = 'A' * 10000;
        final entry = JournalEntry(
          id: 'id',
          reflection: longReflection,
          rating: 4,
          dateCreated: DateTime.now(),
        );

        expect(entry.reflection.length, equals(10000));
      });

      test('should handle empty reflection', () {
        final entry = JournalEntry(
          id: 'id',
          reflection: '',
          rating: 3,
          dateCreated: DateTime.now(),
        );

        expect(entry.reflection, equals(''));
      });

      test('should handle special characters in reflection', () {
        final entry = JournalEntry(
          id: 'id',
          reflection: 'Reflection with "quotes" and \'apostrophes\'',
          rating: 4,
          dateCreated: DateTime.now(),
        );

        expect(entry.reflection, contains('"'));
        expect(entry.reflection, contains('\''));
      });

      test('should handle Unicode in reflection', () {
        final entry = JournalEntry(
          id: 'id',
          reflection: 'आज का चिंतन: धर्म और कर्म',
          rating: 5,
          dateCreated: DateTime.now(),
        );

        expect(entry.reflection, contains('आज'));
        expect(entry.reflection, contains('धर्म'));
      });
    });

    group('Categories', () {
      test('should support common categories', () {
        final categories = [
          'Personal Growth',
          'Meditation',
          'Daily Reflection',
          'Gita Study',
          'Spiritual Practice',
        ];

        for (final category in categories) {
          final entry = JournalEntry(
            id: 'id',
            reflection: 'Test',
            rating: 4,
            dateCreated: DateTime.now(),
            category: category,
          );

          expect(entry.category, equals(category));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle scenario ID edge cases', () {
        final entry1 = JournalEntry(
          id: 'id',
          reflection: 'Test',
          rating: 4,
          dateCreated: DateTime.now(),
          scenarioId: 0,
        );

        final entry2 = JournalEntry(
          id: 'id',
          reflection: 'Test',
          rating: 4,
          dateCreated: DateTime.now(),
          scenarioId: 999999,
        );

        expect(entry1.scenarioId, equals(0));
        expect(entry2.scenarioId, equals(999999));
      });

      test('should handle various date formats', () {
        final dates = [
          DateTime(2024, 1, 1),
          DateTime(2024, 12, 31, 23, 59, 59),
          DateTime.now(),
          DateTime.utc(2024, 6, 15),
        ];

        for (final date in dates) {
          final entry = JournalEntry(
            id: 'id',
            reflection: 'Test',
            rating: 4,
            dateCreated: date,
          );

          expect(entry.dateCreated, equals(date));
        }
      });
    });
  });
}
