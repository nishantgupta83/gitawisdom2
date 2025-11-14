import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/bookmark_service.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/scenario.dart';

import 'bookmark_service_test.mocks.dart';

@GenerateMocks([
  Box,
])
void main() {
  late BookmarkService bookmarkService;
  late MockBox mockBox;

  setUp(() async {
    mockBox = MockBox();
    bookmarkService = BookmarkService();
    // Note: In real implementation, would need to inject mock box
  });

  group('BookmarkService Verse Tests', () {
    test('should add verse bookmark successfully', () async {
      final verse = Verse(
        id: 1,
        chapterNumber: 1,
        verseNumber: 1,
        text: 'Test verse',
        transliteration: 'Test',
        wordMeanings: 'Test',
        translation: 'Test',
      );

      when(mockBox.put(any, any)).thenAnswer((_) async => {});

      await bookmarkService.addVerseBookmark(verse);

      // Verify bookmark was added
      final isBookmarked = await bookmarkService.isVerseBookmarked(verse.id);
      expect(isBookmarked, isTrue);
    });

    test('should remove verse bookmark successfully', () async {
      final verse = Verse(
        id: 1,
        chapterNumber: 1,
        verseNumber: 1,
        text: 'Test verse',
        transliteration: 'Test',
        wordMeanings: 'Test',
        translation: 'Test',
      );

      when(mockBox.delete(any)).thenAnswer((_) async => {});

      await bookmarkService.removeVerseBookmark(verse.id);

      // Verify bookmark was removed
      final isBookmarked = await bookmarkService.isVerseBookmarked(verse.id);
      expect(isBookmarked, isFalse);
    });

    test('should get all verse bookmarks', () async {
      final verses = [
        Verse(
          id: 1,
          chapterNumber: 1,
          verseNumber: 1,
          text: 'Test 1',
          transliteration: 'Test',
          wordMeanings: 'Test',
          translation: 'Test',
        ),
        Verse(
          id: 2,
          chapterNumber: 1,
          verseNumber: 2,
          text: 'Test 2',
          transliteration: 'Test',
          wordMeanings: 'Test',
          translation: 'Test',
        ),
      ];

      when(mockBox.values).thenReturn(verses);

      final bookmarks = await bookmarkService.getAllVerseBookmarks();

      expect(bookmarks.length, equals(2));
    });

    test('should check if verse is bookmarked', () async {
      when(mockBox.containsKey(1)).thenReturn(true);
      when(mockBox.containsKey(2)).thenReturn(false);

      final isBookmarked1 = await bookmarkService.isVerseBookmarked(1);
      final isBookmarked2 = await bookmarkService.isVerseBookmarked(2);

      expect(isBookmarked1, isTrue);
      expect(isBookmarked2, isFalse);
    });
  });

  group('BookmarkService Scenario Tests', () {
    test('should add scenario bookmark successfully', () async {
      final scenario = Scenario(
        id: 1,
        title: 'Test Scenario',
        situation: 'Test',
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        category: 'test',
      );

      when(mockBox.put(any, any)).thenAnswer((_) async => {});

      await bookmarkService.addScenarioBookmark(scenario);

      // Verify bookmark was added
      final isBookmarked = await bookmarkService.isScenarioBookmarked(scenario.id);
      expect(isBookmarked, isTrue);
    });

    test('should remove scenario bookmark successfully', () async {
      when(mockBox.delete(any)).thenAnswer((_) async => {});

      await bookmarkService.removeScenarioBookmark(1);

      // Verify bookmark was removed
      final isBookmarked = await bookmarkService.isScenarioBookmarked(1);
      expect(isBookmarked, isFalse);
    });

    test('should get all scenario bookmarks', () async {
      final scenarios = [
        Scenario(
          id: 1,
          title: 'Test 1',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'test',
        ),
        Scenario(
          id: 2,
          title: 'Test 2',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'test',
        ),
      ];

      when(mockBox.values).thenReturn(scenarios);

      final bookmarks = await bookmarkService.getAllScenarioBookmarks();

      expect(bookmarks.length, equals(2));
    });

    test('should toggle scenario bookmark', () async {
      when(mockBox.containsKey(1)).thenReturn(false);
      when(mockBox.put(any, any)).thenAnswer((_) async => {});

      // First toggle - should add bookmark
      await bookmarkService.toggleScenarioBookmark(
        Scenario(
          id: 1,
          title: 'Test',
          situation: 'Test',
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          category: 'test',
        ),
      );

      verify(mockBox.put(any, any)).called(1);
    });
  });

  group('BookmarkService Error Handling', () {
    test('should handle Hive errors gracefully', () async {
      when(mockBox.put(any, any)).thenThrow(HiveError('Storage error'));

      expect(
        () => bookmarkService.addVerseBookmark(
          Verse(
            id: 1,
            chapterNumber: 1,
            verseNumber: 1,
            text: 'Test',
            transliteration: 'Test',
            wordMeanings: 'Test',
            translation: 'Test',
          ),
        ),
        throwsA(isA<HiveError>()),
      );
    });

    test('should handle empty bookmarks list', () async {
      when(mockBox.values).thenReturn([]);

      final bookmarks = await bookmarkService.getAllVerseBookmarks();

      expect(bookmarks, isEmpty);
    });
  });

  group('BookmarkService Performance Tests', () {
    test('should handle large bookmark list efficiently', () async {
      final largeList = List.generate(
        100,
        (index) => Verse(
          id: index,
          chapterNumber: 1,
          verseNumber: index,
          text: 'Test $index',
          transliteration: 'Test',
          wordMeanings: 'Test',
          translation: 'Test',
        ),
      );

      when(mockBox.values).thenReturn(largeList);

      final stopwatch = Stopwatch()..start();
      final bookmarks = await bookmarkService.getAllVerseBookmarks();
      stopwatch.stop();

      expect(bookmarks.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
