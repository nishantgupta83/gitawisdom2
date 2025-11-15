// test/services/bookmark_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GitaWisdom/services/bookmark_service.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/bookmark.dart';
import '../test_setup.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
import 'bookmark_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BookmarkService bookmarkService;
  late Box<Bookmark> bookmarksBox;

  setUp(() async {
    await setupTestEnvironment();

    // Register Bookmark adapter if not already registered
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(BookmarkAdapter());
    }

    // Open bookmarks box
    if (!Hive.isBoxOpen('bookmarks')) {
      bookmarksBox = await Hive.openBox<Bookmark>('bookmarks');
    } else {
      bookmarksBox = Hive.box<Bookmark>('bookmarks');
    }

    await bookmarksBox.clear();

    bookmarkService = BookmarkService();
    await bookmarkService.initialize('test_device_123');
  });

  tearDown(() async {
    bookmarkService.dispose();

    if (Hive.isBoxOpen('bookmarks')) {
      await bookmarksBox.clear();
      await bookmarksBox.close();
    }

    await teardownTestEnvironment();
  });

  group('Initialization', () {
    test('initialize() creates bookmarks box if not open', () async {
      if (Hive.isBoxOpen('bookmarks')) {
        await bookmarksBox.close();
      }

      final newService = BookmarkService();
      await newService.initialize('test_device');

      expect(Hive.isBoxOpen('bookmarks'), isTrue);

      newService.dispose();

      // Reopen for cleanup
      if (!Hive.isBoxOpen('bookmarks')) {
        bookmarksBox = await Hive.openBox<Bookmark>('bookmarks');
      }
    });

    test('initialize() loads bookmarks from local storage', () async {
      // Add a bookmark directly to box before initialization
      final bookmark = Bookmark.create(
        userDeviceId: 'test_device',
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test Bookmark',
      );
      await bookmarksBox.put(bookmark.id, bookmark);

      final newService = BookmarkService();
      await newService.initialize('test_device');

      expect(newService.bookmarksCount, equals(1));

      newService.dispose();
    });

    test('getters return correct values', () {
      expect(bookmarkService.bookmarks, isA<List<Bookmark>>());
      expect(bookmarkService.isLoading, isFalse);
      expect(bookmarkService.error, isNull);
      expect(bookmarkService.bookmarksCount, equals(0));
    });
  });

  group('Add Bookmark', () {
    test('addBookmark() adds verse bookmark successfully', () async {
      final result = await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Chapter 1, Verse 1',
        contentPreview: 'Test preview',
      );

      expect(result, isTrue);
      expect(bookmarkService.bookmarksCount, equals(1));
      expect(bookmarkService.isBookmarked(BookmarkType.verse, 1), isTrue);
    });

    test('addBookmark() prevents duplicate bookmarks', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      final result = await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      expect(result, isFalse);
      expect(bookmarkService.error, equals('Already bookmarked'));
      expect(bookmarkService.bookmarksCount, equals(1));
    });

    test('addBookmark() supports notes and tags', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        notes: 'Important verse',
        tags: ['inspiration', 'wisdom'],
      );

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      expect(bookmark?.notes, equals('Important verse'));
      expect(bookmark?.tags, equals(['inspiration', 'wisdom']));
    });

    test('addBookmark() supports highlighting', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        isHighlighted: true,
        highlightColor: HighlightColor.yellow,
      );

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      expect(bookmark?.isHighlighted, isTrue);
      expect(bookmark?.highlightColor, equals(HighlightColor.yellow));
    });

    test('addBookmark() sorts bookmarks by creation date (latest first)', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'First',
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 2,
        chapterId: 1,
        title: 'Second',
      );

      final bookmarks = bookmarkService.bookmarks;
      expect(bookmarks.first.referenceId, equals(2)); // Latest first
      expect(bookmarks.last.referenceId, equals(1));
    });
  });

  group('Convenience Methods', () {
    test('bookmarkVerse() adds verse bookmark', () async {
      final verse = Verse(
        verseId: 1,
        description: 'Test verse description',
        chapterId: 1,
      );

      final result = await bookmarkService.bookmarkVerse(verse, 1);

      expect(result, isTrue);
      expect(bookmarkService.isBookmarked(BookmarkType.verse, 1), isTrue);
    });

    test('bookmarkChapter() adds chapter bookmark', () async {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test Chapter',
        subtitle: 'Subtitle',
        summary: 'A long summary that should be truncated to 100 characters for the preview',
        verseCount: 10,
      );

      final result = await bookmarkService.bookmarkChapter(chapter);

      expect(result, isTrue);
      expect(bookmarkService.isBookmarked(BookmarkType.chapter, 1), isTrue);

      final bookmark = bookmarkService.getBookmark(BookmarkType.chapter, 1);
      expect(bookmark?.contentPreview?.length, equals(100));
    });

    test('bookmarkScenario() adds scenario bookmark', () async {
      final scenario = Scenario(
        title: 'Test Scenario',
        description: 'Test description',
        category: 'work',
        chapter: 2,
        heartResponse: 'Heart response',
        dutyResponse: 'Duty response',
        gitaWisdom: 'Wisdom',
        createdAt: DateTime.now(),
      );

      final result = await bookmarkService.bookmarkScenario(scenario);

      expect(result, isTrue);
      expect(bookmarkService.isBookmarked(BookmarkType.scenario, scenario.hashCode), isTrue);
    });
  });

  group('Remove Bookmark', () {
    test('removeBookmark() removes bookmark successfully', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      final result = await bookmarkService.removeBookmark(bookmark!.id);

      expect(result, isTrue);
      expect(bookmarkService.bookmarksCount, equals(0));
      expect(bookmarkService.isBookmarked(BookmarkType.verse, 1), isFalse);
    });

    test('removeBookmark() handles non-existent bookmark', () async {
      final result = await bookmarkService.removeBookmark('non-existent-id');

      expect(result, isTrue); // Doesn't error, just does nothing
      expect(bookmarkService.bookmarksCount, equals(0));
    });
  });

  group('Update Bookmark', () {
    test('updateBookmark() updates notes and tags', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      final result = await bookmarkService.updateBookmark(
        bookmarkId: bookmark!.id,
        notes: 'Updated notes',
        tags: ['tag1', 'tag2'],
      );

      expect(result, isTrue);

      final updated = bookmarkService.getBookmark(BookmarkType.verse, 1);
      expect(updated?.notes, equals('Updated notes'));
      expect(updated?.tags, equals(['tag1', 'tag2']));
    });

    test('updateBookmark() updates highlighting', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      await bookmarkService.updateBookmark(
        bookmarkId: bookmark!.id,
        isHighlighted: true,
        highlightColor: HighlightColor.green,
      );

      final updated = bookmarkService.getBookmark(BookmarkType.verse, 1);
      expect(updated?.isHighlighted, isTrue);
      expect(updated?.highlightColor, equals(HighlightColor.green));
    });

    test('updateBookmark() handles non-existent bookmark', () async {
      final result = await bookmarkService.updateBookmark(
        bookmarkId: 'non-existent',
        notes: 'New notes',
      );

      expect(result, isFalse);
      expect(bookmarkService.error, equals('Bookmark not found'));
    });

    test('updateBookmark() marks bookmark as pending sync', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      await bookmarkService.updateBookmark(
        bookmarkId: bookmark!.id,
        notes: 'Updated',
      );

      final updated = bookmarkService.getBookmark(BookmarkType.verse, 1);
      expect(updated?.syncStatus, equals(SyncStatus.pending));
    });
  });

  group('Query Methods', () {
    test('isBookmarked() returns correct value', () async {
      expect(bookmarkService.isBookmarked(BookmarkType.verse, 1), isFalse);

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      expect(bookmarkService.isBookmarked(BookmarkType.verse, 1), isTrue);
      expect(bookmarkService.isBookmarked(BookmarkType.verse, 2), isFalse);
    });

    test('getBookmark() returns correct bookmark', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test Title',
      );

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);

      expect(bookmark, isNotNull);
      expect(bookmark?.title, equals('Test Title'));
      expect(bookmark?.referenceId, equals(1));
    });

    test('getBookmark() returns null for non-existent bookmark', () {
      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 999);
      expect(bookmark, isNull);
    });

    test('getBookmarksByType() filters by type', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Verse',
      );

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.chapter,
        referenceId: 1,
        chapterId: 1,
        title: 'Chapter',
      );

      final verses = bookmarkService.getBookmarksByType(BookmarkType.verse);
      final chapters = bookmarkService.getBookmarksByType(BookmarkType.chapter);

      expect(verses.length, equals(1));
      expect(chapters.length, equals(1));
      expect(verses.first.bookmarkType, equals(BookmarkType.verse));
    });

    test('getBookmarksByChapter() filters by chapter', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Chapter 1',
      );

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 2,
        chapterId: 2,
        title: 'Chapter 2',
      );

      final chapter1 = bookmarkService.getBookmarksByChapter(1);
      final chapter2 = bookmarkService.getBookmarksByChapter(2);

      expect(chapter1.length, equals(1));
      expect(chapter2.length, equals(1));
      expect(chapter1.first.chapterId, equals(1));
    });

    test('getRecentBookmarks() returns limited results', () async {
      for (int i = 1; i <= 15; i++) {
        await bookmarkService.addBookmark(
          bookmarkType: BookmarkType.verse,
          referenceId: i,
          chapterId: 1,
          title: 'Bookmark $i',
        );
      }

      final recent5 = bookmarkService.getRecentBookmarks(5);
      final recent10 = bookmarkService.getRecentBookmarks(10);
      final recentDefault = bookmarkService.getRecentBookmarks();

      expect(recent5.length, equals(5));
      expect(recent10.length, equals(10));
      expect(recentDefault.length, equals(10)); // Default limit
    });

    test('getRecentBookmarks() returns in reverse chronological order', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'First',
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 2,
        chapterId: 1,
        title: 'Second',
      );

      final recent = bookmarkService.getRecentBookmarks();

      expect(recent.first.referenceId, equals(2)); // Latest first
      expect(recent.last.referenceId, equals(1));
    });
  });

  group('Search', () {
    test('searchBookmarks() finds by title', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Arjuna Vishada Yoga',
      );

      final results = bookmarkService.searchBookmarks('arjuna');

      expect(results.length, equals(1));
      expect(results.first.title, contains('Arjuna'));
    });

    test('searchBookmarks() finds by content preview', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        contentPreview: 'Krishna teaches Arjuna',
      );

      final results = bookmarkService.searchBookmarks('krishna');

      expect(results.length, equals(1));
    });

    test('searchBookmarks() finds by notes', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        notes: 'Important wisdom about duty',
      );

      final results = bookmarkService.searchBookmarks('duty');

      expect(results.length, equals(1));
    });

    test('searchBookmarks() finds by tags', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
        tags: ['dharma', 'karma', 'yoga'],
      );

      final results = bookmarkService.searchBookmarks('karma');

      expect(results.length, equals(1));
    });

    test('searchBookmarks() is case-insensitive', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'ARJUNA',
      );

      final results = bookmarkService.searchBookmarks('arjuna');

      expect(results.length, equals(1));
    });

    test('searchBookmarks() returns empty for no match', () {
      final results = bookmarkService.searchBookmarks('nonexistent');
      expect(results, isEmpty);
    });
  });

  group('Grouping', () {
    test('getBookmarksGroupedByChapter() groups correctly', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Chapter 1 Verse 1',
      );

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 2,
        chapterId: 1,
        title: 'Chapter 1 Verse 2',
      );

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 2,
        title: 'Chapter 2 Verse 1',
      );

      final grouped = bookmarkService.getBookmarksGroupedByChapter();

      expect(grouped.keys.length, equals(2));
      expect(grouped[1]?.length, equals(2));
      expect(grouped[2]?.length, equals(1));
    });

    test('getBookmarksGroupedByChapter() returns empty for no bookmarks', () {
      final grouped = bookmarkService.getBookmarksGroupedByChapter();
      expect(grouped, isEmpty);
    });
  });

  group('Statistics', () {
    test('getBookmarkStats() returns correct counts', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Verse 1',
      );

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 2,
        chapterId: 1,
        title: 'Verse 2',
        isHighlighted: true,
      );

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.chapter,
        referenceId: 1,
        chapterId: 1,
        title: 'Chapter 1',
      );

      final stats = bookmarkService.getBookmarkStats();

      expect(stats['total'], equals(3));
      expect(stats['verse'], equals(2));
      expect(stats['chapter'], equals(1));
      expect(stats['highlighted'], equals(1));
    });

    test('getBookmarkStats() returns zero for empty bookmarks', () {
      final stats = bookmarkService.getBookmarkStats();

      expect(stats['total'], equals(0));
      expect(stats['highlighted'], equals(0));
    });
  });

  group('Clear and Export', () {
    test('clearAllBookmarks() removes all bookmarks', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test 1',
      );

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 2,
        chapterId: 1,
        title: 'Test 2',
      );

      expect(bookmarkService.bookmarksCount, equals(2));

      final result = await bookmarkService.clearAllBookmarks();

      expect(result, isTrue);
      expect(bookmarkService.bookmarksCount, equals(0));
    });

    test('exportBookmarks() returns correct format', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      final exported = bookmarkService.exportBookmarks();

      expect(exported, containsPair('totalCount', 1));
      expect(exported['bookmarks'], isA<List>());
      expect(exported['exportDate'], isNotNull);
    });

    test('exportBookmarks() includes bookmark data', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test Bookmark',
      );

      final exported = bookmarkService.exportBookmarks();
      final bookmarks = exported['bookmarks'] as List;

      expect(bookmarks.length, equals(1));
      expect(bookmarks.first['title'], equals('Test Bookmark'));
    });
  });

  group('Edge Cases', () {
    test('handles rapid bookmark additions', () async {
      final futures = <Future>[];
      for (int i = 1; i <= 20; i++) {
        futures.add(bookmarkService.addBookmark(
          bookmarkType: BookmarkType.verse,
          referenceId: i,
          chapterId: 1,
          title: 'Bookmark $i',
        ));
      }

      await Future.wait(futures);

      expect(bookmarkService.bookmarksCount, equals(20));
    });

    test('handles scenario with very long description', () async {
      final scenario = Scenario(
        title: 'Test',
        description: 'A' * 200, // 200 characters
        category: 'test',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        createdAt: DateTime.now(),
      );

      final result = await bookmarkService.bookmarkScenario(scenario);

      expect(result, isTrue);

      final bookmark = bookmarkService.getBookmark(
        BookmarkType.scenario,
        scenario.hashCode,
      );

      // Preview should be truncated to 100 chars (97 + '...')
      expect(bookmark?.contentPreview?.length, equals(100));
      expect(bookmark?.contentPreview?.endsWith('...'), isTrue);
    });

    test('handles chapter with null summary', () async {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test Chapter',
        subtitle: 'Subtitle',
        summary: null,
        verseCount: 10,
      );

      final result = await bookmarkService.bookmarkChapter(chapter);

      expect(result, isTrue);
    });

    test('dispose() closes resources properly', () {
      expect(() => bookmarkService.dispose(), returnsNormally);
    });
  });

  group('ChangeNotifier Behavior', () {
    test('notifies listeners on bookmark add', () async {
      bool notified = false;
      bookmarkService.addListener(() {
        notified = true;
      });

      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      expect(notified, isTrue);
    });

    test('notifies listeners on bookmark remove', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      bool notified = false;
      bookmarkService.addListener(() {
        notified = true;
      });

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      await bookmarkService.removeBookmark(bookmark!.id);

      expect(notified, isTrue);
    });

    test('notifies listeners on bookmark update', () async {
      await bookmarkService.addBookmark(
        bookmarkType: BookmarkType.verse,
        referenceId: 1,
        chapterId: 1,
        title: 'Test',
      );

      bool notified = false;
      bookmarkService.addListener(() {
        notified = true;
      });

      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, 1);
      await bookmarkService.updateBookmark(
        bookmarkId: bookmark!.id,
        notes: 'Updated',
      );

      expect(notified, isTrue);
    });
  });
}
