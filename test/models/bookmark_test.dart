// test/models/bookmark_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/bookmark.dart';

void main() {
  group('BookmarkType Enum', () {
    test('should have all bookmark types', () {
      expect(BookmarkType.values, hasLength(3));
      expect(BookmarkType.values, contains(BookmarkType.verse));
      expect(BookmarkType.values, contains(BookmarkType.chapter));
      expect(BookmarkType.values, contains(BookmarkType.scenario));
    });

    test('should convert to string value', () {
      expect(BookmarkType.verse.value, equals('verse'));
      expect(BookmarkType.chapter.value, equals('chapter'));
      expect(BookmarkType.scenario.value, equals('scenario'));
    });

    test('should convert from string value', () {
      expect(BookmarkType.fromString('verse'), equals(BookmarkType.verse));
      expect(BookmarkType.fromString('chapter'), equals(BookmarkType.chapter));
      expect(BookmarkType.fromString('scenario'), equals(BookmarkType.scenario));
    });

    test('should default to verse for invalid string', () {
      expect(BookmarkType.fromString('invalid'), equals(BookmarkType.verse));
      expect(BookmarkType.fromString(''), equals(BookmarkType.verse));
    });
  });

  group('HighlightColor Enum', () {
    test('should have all highlight colors', () {
      expect(HighlightColor.values, hasLength(5));
      expect(HighlightColor.values, contains(HighlightColor.yellow));
      expect(HighlightColor.values, contains(HighlightColor.green));
      expect(HighlightColor.values, contains(HighlightColor.blue));
      expect(HighlightColor.values, contains(HighlightColor.pink));
      expect(HighlightColor.values, contains(HighlightColor.purple));
    });

    test('should convert to string value', () {
      expect(HighlightColor.yellow.value, equals('yellow'));
      expect(HighlightColor.green.value, equals('green'));
      expect(HighlightColor.blue.value, equals('blue'));
      expect(HighlightColor.pink.value, equals('pink'));
      expect(HighlightColor.purple.value, equals('purple'));
    });

    test('should convert from string value', () {
      expect(HighlightColor.fromString('yellow'), equals(HighlightColor.yellow));
      expect(HighlightColor.fromString('green'), equals(HighlightColor.green));
      expect(HighlightColor.fromString('blue'), equals(HighlightColor.blue));
      expect(HighlightColor.fromString('pink'), equals(HighlightColor.pink));
      expect(HighlightColor.fromString('purple'), equals(HighlightColor.purple));
    });

    test('should default to yellow for invalid string', () {
      expect(HighlightColor.fromString('invalid'), equals(HighlightColor.yellow));
      expect(HighlightColor.fromString(''), equals(HighlightColor.yellow));
    });
  });

  group('SyncStatus Enum', () {
    test('should have all sync statuses', () {
      expect(SyncStatus.values, hasLength(3));
      expect(SyncStatus.values, contains(SyncStatus.synced));
      expect(SyncStatus.values, contains(SyncStatus.pending));
      expect(SyncStatus.values, contains(SyncStatus.offline));
    });

    test('should convert to string value', () {
      expect(SyncStatus.synced.value, equals('synced'));
      expect(SyncStatus.pending.value, equals('pending'));
      expect(SyncStatus.offline.value, equals('offline'));
    });

    test('should convert from string value', () {
      expect(SyncStatus.fromString('synced'), equals(SyncStatus.synced));
      expect(SyncStatus.fromString('pending'), equals(SyncStatus.pending));
      expect(SyncStatus.fromString('offline'), equals(SyncStatus.offline));
    });

    test('should default to offline for invalid string', () {
      expect(SyncStatus.fromString('invalid'), equals(SyncStatus.offline));
      expect(SyncStatus.fromString(''), equals(SyncStatus.offline));
    });
  });

  group('Bookmark Constructor', () {
    test('should create bookmark with required fields', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 'test-id',
        userDeviceId: 'device-123',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test Verse',
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.id, equals('test-id'));
      expect(bookmark.userDeviceId, equals('device-123'));
      expect(bookmark.bookmarkType, equals(BookmarkType.verse));
      expect(bookmark.referenceId, equals(1));
      expect(bookmark.chapterId, equals(1));
      expect(bookmark.title, equals('Test Verse'));
      expect(bookmark.createdAt, equals(now));
      expect(bookmark.updatedAt, equals(now));
    });

    test('should create bookmark with default values', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 'test-id',
        userDeviceId: 'device-123',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.tags, isEmpty);
      expect(bookmark.isHighlighted, isFalse);
      expect(bookmark.highlightColor, equals(HighlightColor.yellow));
      expect(bookmark.syncStatus, equals(SyncStatus.offline));
      expect(bookmark.contentPreview, isNull);
      expect(bookmark.notes, isNull);
    });

    test('should create bookmark with all fields', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 'test-id',
        userDeviceId: 'device-123',
        bookmarkType: BookmarkType.verse,
        referenceId: 47,
        chapterId: 2,
        title: 'Karmanye Vadhikaraste',
        contentPreview: 'Your right is to perform your duty only...',
        notes: 'Important verse about duty',
        tags: ['duty', 'karma', 'important'],
        isHighlighted: true,
        highlightColor: HighlightColor.yellow,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      );

      expect(bookmark.contentPreview, equals('Your right is to perform your duty only...'));
      expect(bookmark.notes, equals('Important verse about duty'));
      expect(bookmark.tags, hasLength(3));
      expect(bookmark.tags, contains('karma'));
      expect(bookmark.isHighlighted, isTrue);
      expect(bookmark.syncStatus, equals(SyncStatus.synced));
    });
  });

  group('Bookmark.create Factory', () {
    test('should create new bookmark with generated UUID', () {
      final bookmark = Bookmark.create(
        userDeviceId: 'device-123',
        bookmarkType: BookmarkType.chapter,
        referenceId: 1,
        chapterId: 1,
        title: 'Chapter 1',
      );

      expect(bookmark.id, isNotEmpty);
      expect(bookmark.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')));
      expect(bookmark.syncStatus, equals(SyncStatus.pending));
    });

    test('should set timestamps to current time', () {
      final before = DateTime.now();
      final bookmark = Bookmark.create(
        userDeviceId: 'device-123',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );
      final after = DateTime.now();

      expect(bookmark.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(bookmark.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(bookmark.updatedAt, equals(bookmark.createdAt));
    });

    test('should create with optional parameters', () {
      final bookmark = Bookmark.create(
        userDeviceId: 'device-123',
        bookmarkType: BookmarkType.verse,
        referenceId: 47,
        chapterId: 2,
        title: 'Test Verse',
        contentPreview: 'Preview text',
        notes: 'My notes',
        tags: ['tag1', 'tag2'],
        isHighlighted: true,
        highlightColor: HighlightColor.blue,
      );

      expect(bookmark.contentPreview, equals('Preview text'));
      expect(bookmark.notes, equals('My notes'));
      expect(bookmark.tags, equals(['tag1', 'tag2']));
      expect(bookmark.isHighlighted, isTrue);
      expect(bookmark.highlightColor, equals(HighlightColor.blue));
    });
  });

  group('JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30, 0);
      final bookmark = Bookmark(
        id: 'test-123',
        userDeviceId: 'device-456',
        bookmarkType: BookmarkType.verse,
        referenceId: 47,
        chapterId: 2,
        title: 'Test Verse',
        contentPreview: 'Preview',
        notes: 'Notes',
        tags: ['tag1', 'tag2'],
        isHighlighted: true,
        highlightColor: HighlightColor.green,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      );

      final json = bookmark.toJson();

      expect(json['id'], equals('test-123'));
      expect(json['user_device_id'], equals('device-456'));
      expect(json['bookmark_type'], equals('verse'));
      expect(json['reference_id'], equals(47));
      expect(json['chapter_id'], equals(2));
      expect(json['title'], equals('Test Verse'));
      expect(json['content_preview'], equals('Preview'));
      expect(json['notes'], equals('Notes'));
      expect(json['tags'], equals(['tag1', 'tag2']));
      expect(json['is_highlighted'], equals(true));
      expect(json['highlight_color'], equals('green'));
      expect(json['sync_status'], equals('synced'));
      expect(json['created_at'], contains('2024-01-15'));
      expect(json['updated_at'], contains('2024-01-15'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-789',
        'user_device_id': 'device-abc',
        'bookmark_type': 'scenario',
        'reference_id': 10,
        'chapter_id': 3,
        'title': 'Career Dilemma',
        'content_preview': 'Should I change jobs?',
        'notes': 'Important decision',
        'tags': ['career', 'decision'],
        'is_highlighted': true,
        'highlight_color': 'pink',
        'created_at': '2024-01-15T10:30:00.000Z',
        'updated_at': '2024-01-16T12:00:00.000Z',
        'sync_status': 'pending',
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.id, equals('test-789'));
      expect(bookmark.userDeviceId, equals('device-abc'));
      expect(bookmark.bookmarkType, equals(BookmarkType.scenario));
      expect(bookmark.referenceId, equals(10));
      expect(bookmark.chapterId, equals(3));
      expect(bookmark.title, equals('Career Dilemma'));
      expect(bookmark.contentPreview, equals('Should I change jobs?'));
      expect(bookmark.notes, equals('Important decision'));
      expect(bookmark.tags, equals(['career', 'decision']));
      expect(bookmark.isHighlighted, equals(true));
      expect(bookmark.highlightColor, equals(HighlightColor.pink));
      expect(bookmark.syncStatus, equals(SyncStatus.pending));
    });

    test('should handle JSON roundtrip', () {
      final now = DateTime.now();
      final original = Bookmark(
        id: 'roundtrip-test',
        userDeviceId: 'device-xyz',
        bookmarkType: BookmarkType.chapter,
        referenceId: 5,
        chapterId: 5,
        title: 'Chapter 5',
        contentPreview: 'Karma Sannyasa Yoga',
        notes: 'About renunciation',
        tags: ['renunciation', 'action'],
        isHighlighted: true,
        highlightColor: HighlightColor.purple,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.offline,
      );

      final json = original.toJson();
      final restored = Bookmark.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.userDeviceId, equals(original.userDeviceId));
      expect(restored.bookmarkType, equals(original.bookmarkType));
      expect(restored.referenceId, equals(original.referenceId));
      expect(restored.chapterId, equals(original.chapterId));
      expect(restored.title, equals(original.title));
      expect(restored.contentPreview, equals(original.contentPreview));
      expect(restored.notes, equals(original.notes));
      expect(restored.tags, equals(original.tags));
      expect(restored.isHighlighted, equals(original.isHighlighted));
      expect(restored.highlightColor, equals(original.highlightColor));
      expect(restored.syncStatus, equals(original.syncStatus));
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'minimal-test',
        'user_device_id': 'device-min',
        'bookmark_type': 'verse',
        'reference_id': 1,
        'chapter_id': 1,
        'title': 'Minimal Bookmark',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.contentPreview, isNull);
      expect(bookmark.notes, isNull);
      expect(bookmark.tags, isEmpty);
      expect(bookmark.isHighlighted, isFalse);
      expect(bookmark.highlightColor, equals(HighlightColor.yellow));
      expect(bookmark.syncStatus, equals(SyncStatus.synced));
    });
  });

  group('copyWith Method', () {
    test('should create copy with updated fields', () {
      final now = DateTime.now();
      final original = Bookmark(
        id: 'original-id',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(
        title: 'Updated Title',
        notes: 'New notes',
      );

      expect(copy.id, equals('original-id'));
      expect(copy.title, equals('Updated Title'));
      expect(copy.notes, equals('New notes'));
      expect(copy.referenceId, equals(1));
    });

    test('should update timestamp when copying', () {
      final now = DateTime.now();
      final original = Bookmark(
        id: 'test-id',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      final before = DateTime.now();
      final copy = original.copyWith(title: 'Updated');
      final after = DateTime.now();

      expect(copy.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(copy.updatedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(copy.createdAt, equals(now));
    });

    test('should copy all fields individually', () {
      final now = DateTime.now();
      final original = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(
        id: 'new-id',
        userDeviceId: 'device-2',
        bookmarkType: BookmarkType.chapter,
        referenceId: 2,
        chapterId: 2,
        title: 'New Title',
        contentPreview: 'New Preview',
        notes: 'New Notes',
        tags: ['new', 'tags'],
        isHighlighted: true,
        highlightColor: HighlightColor.blue,
        syncStatus: SyncStatus.synced,
      );

      expect(copy.id, equals('new-id'));
      expect(copy.userDeviceId, equals('device-2'));
      expect(copy.bookmarkType, equals(BookmarkType.chapter));
      expect(copy.referenceId, equals(2));
      expect(copy.chapterId, equals(2));
      expect(copy.title, equals('New Title'));
      expect(copy.contentPreview, equals('New Preview'));
      expect(copy.notes, equals('New Notes'));
      expect(copy.tags, equals(['new', 'tags']));
      expect(copy.isHighlighted, isTrue);
      expect(copy.highlightColor, equals(HighlightColor.blue));
      expect(copy.syncStatus, equals(SyncStatus.synced));
    });
  });

  group('Bookmark Properties', () {
    test('needsSync should return true for non-synced bookmarks', () {
      final now = DateTime.now();

      final pending = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );

      final offline = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.offline,
      );

      expect(pending.needsSync, isTrue);
      expect(offline.needsSync, isTrue);
    });

    test('needsSync should return false for synced bookmarks', () {
      final now = DateTime.now();
      final synced = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      );

      expect(synced.needsSync, isFalse);
    });

    test('isValid should validate required fields', () {
      final now = DateTime.now();

      final valid = Bookmark(
        id: 'valid-id',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Valid Title',
        createdAt: now,
        updatedAt: now,
      );

      expect(valid.isValid, isTrue);
    });

    test('isValid should return false for invalid bookmarks', () {
      final now = DateTime.now();

      final emptyId = Bookmark(
        id: '',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      final emptyDevice = Bookmark(
        id: 'test',
        userDeviceId: '',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      final emptyTitle = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: '',
        createdAt: now,
        updatedAt: now,
      );

      final zeroReference = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 0,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      expect(emptyId.isValid, isFalse);
      expect(emptyDevice.isValid, isFalse);
      expect(emptyTitle.isValid, isFalse);
      expect(zeroReference.isValid, isFalse);
    });

    test('reference should format correctly for verse bookmarks', () {
      final now = DateTime.now();
      final verse = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 47,
        chapterId: 2,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      expect(verse.reference, equals('verse:2.47'));
    });

    test('reference should format correctly for chapter bookmarks', () {
      final now = DateTime.now();
      final chapter = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.chapter,
        referenceId: 5,
        chapterId: 5,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      expect(chapter.reference, equals('chapter:5'));
    });

    test('reference should format correctly for scenario bookmarks', () {
      final now = DateTime.now();
      final scenario = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.scenario,
        referenceId: 123,
        chapterId: 3,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      expect(scenario.reference, equals('scenario:3.123'));
    });
  });

  group('Equality and HashCode', () {
    test('should be equal for same id and user', () {
      final now = DateTime.now();
      final bookmark1 = Bookmark(
        id: 'same-id',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      final bookmark2 = Bookmark(
        id: 'same-id',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Different Title',
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark1, equals(bookmark2));
      expect(bookmark1.hashCode, equals(bookmark2.hashCode));
    });

    test('should not be equal for different ids', () {
      final now = DateTime.now();
      final bookmark1 = Bookmark(
        id: 'id-1',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      final bookmark2 = Bookmark(
        id: 'id-2',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark1, isNot(equals(bookmark2)));
    });
  });

  group('toString Method', () {
    test('should provide meaningful string representation', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 'test-123',
        userDeviceId: 'device-456',
        bookmarkType: BookmarkType.verse,
        referenceId: 47,
        chapterId: 2,
        title: 'Test Verse',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );

      final str = bookmark.toString();

      expect(str, contains('test-123'));
      expect(str, contains('verse'));
      expect(str, contains('Test Verse'));
      expect(str, contains('pending'));
    });
  });

  group('Edge Cases', () {
    test('should handle very long title', () {
      final now = DateTime.now();
      final longTitle = 'A' * 1000;
      final bookmark = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: longTitle,
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.title.length, equals(1000));
    });

    test('should handle very long content preview', () {
      final now = DateTime.now();
      final longPreview = 'B' * 5000;
      final bookmark = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        contentPreview: longPreview,
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.contentPreview!.length, equals(5000));
    });

    test('should handle very long notes', () {
      final now = DateTime.now();
      final longNotes = 'C' * 10000;
      final bookmark = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        notes: longNotes,
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.notes!.length, equals(10000));
    });

    test('should handle many tags', () {
      final now = DateTime.now();
      final manyTags = List.generate(100, (i) => 'tag$i');
      final bookmark = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        tags: manyTags,
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.tags.length, equals(100));
    });

    test('should handle Unicode characters', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'योगेश्वरः कृष्णः',
        contentPreview: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन',
        notes: 'महत्वपूर्ण श्लोक',
        tags: ['कर्म', 'योग', 'धर्म'],
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.title, contains('योगेश्वरः'));
      expect(bookmark.contentPreview, contains('कर्मण्येवाधिकारस्ते'));
      expect(bookmark.notes, contains('महत्वपूर्ण'));
      expect(bookmark.tags, contains('धर्म'));
    });

    test('should handle special characters', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 'test',
        userDeviceId: 'device-1',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test "with" \'quotes\' and (parentheses)',
        contentPreview: 'Content with @#\$%^&*() symbols',
        notes: 'Notes with <html> & special chars',
        createdAt: now,
        updatedAt: now,
      );

      expect(bookmark.title, contains('"'));
      expect(bookmark.contentPreview, contains('&'));
      expect(bookmark.notes, contains('<'));
    });

    test('should handle all chapters 1-18', () {
      final now = DateTime.now();
      for (int chapterId = 1; chapterId <= 18; chapterId++) {
        final bookmark = Bookmark(
          id: 'test-$chapterId',
          userDeviceId: 'device-1',
          bookmarkType: BookmarkType.chapter,
          referenceId: chapterId,
          chapterId: chapterId,
          title: 'Chapter $chapterId',
          createdAt: now,
          updatedAt: now,
        );

        expect(bookmark.chapterId, equals(chapterId));
        expect(bookmark.referenceId, equals(chapterId));
      }
    });

    test('should handle all highlight colors', () {
      final now = DateTime.now();
      for (final color in HighlightColor.values) {
        final bookmark = Bookmark(
          id: 'test-$color',
          userDeviceId: 'device-1',
          bookmarkType: BookmarkType.verse,
          referenceId: 1,
          chapterId: 1,
          title: 'Test',
          highlightColor: color,
          createdAt: now,
          updatedAt: now,
        );

        expect(bookmark.highlightColor, equals(color));
      }
    });

    test('should handle all bookmark types', () {
      final now = DateTime.now();
      for (final type in BookmarkType.values) {
        final bookmark = Bookmark(
          id: 'test-$type',
          userDeviceId: 'device-1',
          bookmarkType: type,
          referenceId: 1,
          chapterId: 1,
          title: 'Test',
          createdAt: now,
          updatedAt: now,
        );

        expect(bookmark.bookmarkType, equals(type));
      }
    });
  });
}
