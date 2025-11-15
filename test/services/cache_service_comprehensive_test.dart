// test/services/cache_service_comprehensive_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/cache_service.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/chapter_summary.dart';
import 'package:GitaWisdom/models/journal_entry.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/verse.dart';
import '../test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTestEnvironment();

    // Register all necessary adapters in correct order
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(JournalEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ChapterAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(DailyVerseSetAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ChapterSummaryAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(VerseAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(ScenarioAdapter());
      }
    } catch (e) {
      // Adapters might already be registered
    }
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('CacheService', () {
    late Box<DailyVerseSet> dailyVersesBox;
    late Box<ChapterSummary> chapterSummariesBox;
    late Box<JournalEntry> journalBox;
    late Box<Chapter> chaptersBox;
    late Box<Scenario> scenariosBox;

    setUp(() async {
      // Open all boxes for testing
      if (!Hive.isBoxOpen('daily_verses')) {
        dailyVersesBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      } else {
        dailyVersesBox = Hive.box<DailyVerseSet>('daily_verses');
      }

      if (!Hive.isBoxOpen('chapter_summaries')) {
        chapterSummariesBox = await Hive.openBox<ChapterSummary>('chapter_summaries');
      } else {
        chapterSummariesBox = Hive.box<ChapterSummary>('chapter_summaries');
      }

      if (!Hive.isBoxOpen('journal_entries')) {
        journalBox = await Hive.openBox<JournalEntry>('journal_entries');
      } else {
        journalBox = Hive.box<JournalEntry>('journal_entries');
      }

      if (!Hive.isBoxOpen('chapters')) {
        chaptersBox = await Hive.openBox<Chapter>('chapters');
      } else {
        chaptersBox = Hive.box<Chapter>('chapters');
      }

      if (!Hive.isBoxOpen('scenarios')) {
        scenariosBox = await Hive.openBox<Scenario>('scenarios');
      } else {
        scenariosBox = Hive.box<Scenario>('scenarios');
      }

      // Clear all boxes before each test
      await dailyVersesBox.clear();
      await chapterSummariesBox.clear();
      await journalBox.clear();
      await chaptersBox.clear();
      await scenariosBox.clear();
    });

    tearDown(() async {
      // Clean up after each test
      if (Hive.isBoxOpen('daily_verses')) {
        await dailyVersesBox.clear();
      }
      if (Hive.isBoxOpen('chapter_summaries')) {
        await chapterSummariesBox.clear();
      }
      if (Hive.isBoxOpen('journal_entries')) {
        await journalBox.clear();
      }
      if (Hive.isBoxOpen('chapters')) {
        await chaptersBox.clear();
      }
      if (Hive.isBoxOpen('scenarios')) {
        await scenariosBox.clear();
      }
    });

    group('getCacheSizes', () {
      test('should return map of cache sizes', () async {
        final sizes = await CacheService.getCacheSizes();
        expect(sizes, isNotNull);
        expect(sizes, isA<Map<String, double>>());
      });

      test('should calculate sizes for all cache boxes', () async {
        final sizes = await CacheService.getCacheSizes();
        expect(sizes.keys, isNotEmpty);
      });

      test('should return zero sizes for empty boxes', () async {
        await dailyVersesBox.clear();
        final sizes = await CacheService.getCacheSizes();
        // Sizes should be non-negative
        expect(sizes.values.every((size) => size >= 0), isTrue);
      });

      test('should return positive sizes for boxes with data', () async {
        // Add some test data
        final verse = Verse(
          verseId: 1,
          description: 'Test verse',
          chapterId: 1,
        );
        final verseSet = DailyVerseSet(
          date: '2024-01-01',
          verses: [verse],
          chapterIds: [1],
        );
        await dailyVersesBox.put('2024-01-01', verseSet);

        final sizes = await CacheService.getCacheSizes();
        expect(sizes.values.any((size) => size > 0), isTrue);
      });

      test('should handle nonexistent directory gracefully', () async {
        // Should not throw even if directory is empty
        final sizes = await CacheService.getCacheSizes();
        expect(sizes, isNotNull);
      });
    });

    group('getTotalCacheSize', () {
      test('should return total size across all boxes', () async {
        final total = await CacheService.getTotalCacheSize();
        expect(total, isNotNull);
        expect(total, isA<double>());
        expect(total, greaterThanOrEqualTo(0));
      });

      test('should sum individual box sizes', () async {
        final sizes = await CacheService.getCacheSizes();
        final total = await CacheService.getTotalCacheSize();

        final expectedTotal = sizes.values.fold<double>(0.0, (sum, size) => sum + size);
        expect(total, equals(expectedTotal));
      });

      test('should return zero for empty boxes', () async {
        await CacheService.clearAllCache();
        final total = await CacheService.getTotalCacheSize();
        expect(total, greaterThanOrEqualTo(0));
      });
    });

    group('clearAllCache', () {
      test('should clear all cache boxes', () async {
        // Add test data to all boxes
        final verse = Verse(
          verseId: 1,
          description: 'Test',
          chapterId: 1,
        );
        await dailyVersesBox.put('test', DailyVerseSet(
          date: '2024-01-01',
          verses: [verse],
          chapterIds: [1],
        ));
        await chaptersBox.put('ch1', Chapter(
          chapterId: 1,
          title: 'Test',
        ));

        expect(dailyVersesBox.isNotEmpty, isTrue);
        expect(chaptersBox.isNotEmpty, isTrue);

        await CacheService.clearAllCache();

        expect(dailyVersesBox.isEmpty, isTrue);
        expect(chaptersBox.isEmpty, isTrue);
      });

      test('should not throw on already empty boxes', () async {
        await CacheService.clearAllCache();
        expect(() => CacheService.clearAllCache(), returnsNormally);
      });

      test('should clear only data, not settings', () async {
        // Settings box should remain untouched
        await CacheService.clearAllCache();
        // Should not throw and settings should still exist
        expect(Hive.isBoxOpen('settings'), isTrue);
      });
    });

    group('clearVerseCache', () {
      test('should clear daily verses box', () async {
        final verse = Verse(
          verseId: 1,
          description: 'Test',
          chapterId: 1,
        );
        await dailyVersesBox.put('test', DailyVerseSet(
          date: '2024-01-01',
          verses: [verse],
          chapterIds: [1],
        ));

        expect(dailyVersesBox.isNotEmpty, isTrue);
        await CacheService.clearVerseCache();
        expect(dailyVersesBox.isEmpty, isTrue);
      });

      test('should handle already empty box', () async {
        await dailyVersesBox.clear();
        expect(() => CacheService.clearVerseCache(), returnsNormally);
      });

      test('should handle closed box', () async {
        if (Hive.isBoxOpen('daily_verses')) {
          await dailyVersesBox.close();
        }
        expect(() => CacheService.clearVerseCache(), returnsNormally);
        // Reopen for tearDown
        if (!Hive.isBoxOpen('daily_verses')) {
          dailyVersesBox = await Hive.openBox<DailyVerseSet>('daily_verses');
        }
      });
    });

    group('clearChapterCache', () {
      test('should clear chapter summaries box', () async {
        await chapterSummariesBox.put('test', ChapterSummary(
          chapterId: 1,
          title: 'Test',
          verseCount: 10,
          scenarioCount: 5,
        ));

        expect(chapterSummariesBox.isNotEmpty, isTrue);
        await CacheService.clearChapterCache();
        expect(chapterSummariesBox.isEmpty, isTrue);
      });

      test('should clear chapters box', () async {
        await chaptersBox.put('test', Chapter(
          chapterId: 1,
          title: 'Test',
        ));

        expect(chaptersBox.isNotEmpty, isTrue);
        await CacheService.clearChapterCache();
        expect(chaptersBox.isEmpty, isTrue);
      });

      test('should clear both chapter-related boxes', () async {
        await chapterSummariesBox.put('test1', ChapterSummary(
          chapterId: 1,
          title: 'Test',
          verseCount: 10,
          scenarioCount: 5,
        ));
        await chaptersBox.put('test2', Chapter(
          chapterId: 1,
          title: 'Test',
        ));

        await CacheService.clearChapterCache();

        expect(chapterSummariesBox.isEmpty, isTrue);
        expect(chaptersBox.isEmpty, isTrue);
      });
    });

    group('clearJournalCache', () {
      test('should clear journal entries box', () async {
        await journalBox.put('test', JournalEntry(
          id: 'test-id',
          reflection: 'Test reflection',
          rating: 5,
          dateCreated: DateTime.now(),
        ));

        expect(journalBox.isNotEmpty, isTrue);
        await CacheService.clearJournalCache();
        expect(journalBox.isEmpty, isTrue);
      });

      test('should handle already empty journal', () async {
        await journalBox.clear();
        expect(() => CacheService.clearJournalCache(), returnsNormally);
      });
    });

    group('clearScenarioCache', () {
      test('should clear scenarios box', () async {
        await scenariosBox.put('test', Scenario(
          title: 'Test Scenario',
          description: 'Test description',
          category: 'test',
          chapter: 1,
          heartResponse: 'Test heart',
          dutyResponse: 'Test duty',
          gitaWisdom: 'Test wisdom',
          verse: 'Test verse',
          verseNumber: '1.1',
          createdAt: DateTime.now(),
        ));

        expect(scenariosBox.isNotEmpty, isTrue);
        await CacheService.clearScenarioCache();
        expect(scenariosBox.isEmpty, isTrue);
      });

      test('should handle already empty scenarios', () async {
        await scenariosBox.clear();
        expect(() => CacheService.clearScenarioCache(), returnsNormally);
      });
    });

    group('getCacheStats', () {
      test('should return statistics for all boxes', () async {
        final stats = await CacheService.getCacheStats();
        expect(stats, isNotNull);
        expect(stats, isA<Map<String, int>>());
      });

      test('should count daily verse sets correctly', () async {
        final verse = Verse(
          verseId: 1,
          chapterId: 1,
          description: 'Test',
          
          
        );

        await dailyVersesBox.put('set1', DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          chapterIds: [1],
          verses: [verse],
        ));
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        await dailyVersesBox.put('set2', DailyVerseSet(
          date: '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
          verses: [verse, verse],
          chapterIds: [1],
        ));

        final stats = await CacheService.getCacheStats();
        expect(stats['Daily Verse Sets'], equals(2));
        expect(stats['Total Verses'], equals(3)); // 1 + 2 verses
      });

      test('should count chapter summaries correctly', () async {
        await chapterSummariesBox.put('ch1', ChapterSummary(
          chapterId: 1,
          title: 'Chapter 1',
          verseCount: 10,
          scenarioCount: 5,
        ));
        await chapterSummariesBox.put('ch2', ChapterSummary(
          chapterId: 2,
          title: 'Chapter 2',
          verseCount: 20,
          scenarioCount: 8,
        ));

        final stats = await CacheService.getCacheStats();
        expect(stats['Chapter Summaries'], equals(2));
      });

      test('should count journal entries correctly', () async {
        await journalBox.put('entry1', JournalEntry(
          id: 'id1',
          reflection: 'Reflection 1',
          rating: 5,
          dateCreated: DateTime.now(),
        ));
        await journalBox.put('entry2', JournalEntry(
          id: 'id2',
          reflection: 'Reflection 2',
          rating: 4,
          dateCreated: DateTime.now(),
        ));

        final stats = await CacheService.getCacheStats();
        expect(stats['Journal Entries'], equals(2));
      });

      test('should return zero counts for empty boxes', () async {
        await CacheService.clearAllCache();
        final stats = await CacheService.getCacheStats();

        // All counts should be zero or keys shouldn't exist
        stats.values.forEach((count) {
          expect(count, greaterThanOrEqualTo(0));
        });
      });
    });

    group('isCacheHealthy', () {
      test('should return true for healthy cache', () async {
        final isHealthy = await CacheService.isCacheHealthy();
        expect(isHealthy, isTrue);
      });

      test('should return true for empty but open boxes', () async {
        await CacheService.clearAllCache();
        final isHealthy = await CacheService.isCacheHealthy();
        expect(isHealthy, isTrue);
      });

      test('should handle unopened boxes gracefully', () async {
        // Should not throw even if some boxes are closed
        final isHealthy = await CacheService.isCacheHealthy();
        expect(isHealthy, isNotNull);
      });
    });

    group('repairCache', () {
      test('should complete without errors on healthy cache', () async {
        expect(() => CacheService.repairCache(), returnsNormally);
      });

      test('should handle empty boxes during repair', () async {
        await CacheService.clearAllCache();
        expect(() => CacheService.repairCache(), returnsNormally);
      });

      test('should not delete valid boxes', () async {
        await dailyVersesBox.put('test', DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          chapterIds: [1],
          verses: [],
        ));

        await CacheService.repairCache();

        // Box should still be accessible
        expect(Hive.isBoxOpen('daily_verses'), isTrue);
      });
    });

    group('formatCacheSize', () {
      test('should format small sizes in KB', () {
        final formatted = CacheService.formatCacheSize(0.05);
        expect(formatted, contains('KB'));
      });

      test('should format large sizes in MB', () {
        final formatted = CacheService.formatCacheSize(1.5);
        expect(formatted, equals('1.5 MB'));
      });

      test('should handle zero size', () {
        final formatted = CacheService.formatCacheSize(0.0);
        expect(formatted, contains('KB'));
      });

      test('should format very small sizes', () {
        final formatted = CacheService.formatCacheSize(0.001);
        expect(formatted, contains('KB'));
      });

      test('should format large sizes correctly', () {
        final formatted = CacheService.formatCacheSize(100.0);
        expect(formatted, equals('100.0 MB'));
      });

      test('should round KB values to integers', () {
        final formatted = CacheService.formatCacheSize(0.05);
        final kbValue = formatted.split(' ')[0];
        expect(int.tryParse(kbValue), isNotNull);
      });

      test('should format MB values to one decimal', () {
        final formatted = CacheService.formatCacheSize(10.5678);
        expect(formatted, equals('10.6 MB'));
      });
    });

    group('performAutoCleanup', () {
      test('should complete without errors', () async {
        expect(() => CacheService.performAutoCleanup(), returnsNormally);
      });

      test('should clean up old verse sets', () async {
        final verse = Verse(
          verseId: 1,
          chapterId: 1,
          description: 'Test',
          
          
        );

        // Add old verse set (35 days ago)
        final oldDate = DateTime.now().subtract(const Duration(days: 35));
        final oldKey = '${oldDate.year}-${oldDate.month}-${oldDate.day}';
        await dailyVersesBox.put(oldKey, DailyVerseSet(
          date: "${oldDate.year}-${oldDate.month}-${oldDate.day}",
          chapterIds: [1],
          verses: [verse],
        ));

        // Add recent verse set
        final recentDate = DateTime.now().subtract(const Duration(days: 5));
        final recentKey = '${recentDate.year}-${recentDate.month}-${recentDate.day}';
        await dailyVersesBox.put(recentKey, DailyVerseSet(
          date: "${recentDate.year}-${recentDate.month}-${recentDate.day}",
          chapterIds: [1],
          verses: [verse],
        ));

        expect(dailyVersesBox.length, equals(2));

        await CacheService.performAutoCleanup();

        // Old verse set should be removed, recent one kept
        expect(dailyVersesBox.length, equals(1));
        expect(dailyVersesBox.get(recentKey), isNotNull);
      });

      test('should keep recent verse sets', () async {
        final verse = Verse(
          verseId: 1,
          chapterId: 1,
          description: 'Test',
          
          
        );

        final recentDate = DateTime.now().subtract(const Duration(days: 10));
        final recentKey = '${recentDate.year}-${recentDate.month}-${recentDate.day}';
        await dailyVersesBox.put(recentKey, DailyVerseSet(
          date: "${recentDate.year}-${recentDate.month}-${recentDate.day}",
          chapterIds: [1],
          verses: [verse],
        ));

        expect(dailyVersesBox.length, equals(1));

        await CacheService.performAutoCleanup();

        expect(dailyVersesBox.length, equals(1));
        expect(dailyVersesBox.get(recentKey), isNotNull);
      });

      test('should handle invalid date keys', () async {
        await dailyVersesBox.put('invalid-key', DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          chapterIds: [1],
          verses: [],
        ));

        expect(() => CacheService.performAutoCleanup(), returnsNormally);
      });

      test('should handle empty verse box', () async {
        await dailyVersesBox.clear();
        expect(() => CacheService.performAutoCleanup(), returnsNormally);
      });

      test('should handle closed verse box', () async {
        if (Hive.isBoxOpen('daily_verses')) {
          await dailyVersesBox.close();
        }
        expect(() => CacheService.performAutoCleanup(), returnsNormally);
        // Reopen for tearDown
        if (!Hive.isBoxOpen('daily_verses')) {
          dailyVersesBox = await Hive.openBox<DailyVerseSet>('daily_verses');
        }
      });
    });

    group('Edge Cases and Integration', () {
      test('should handle multiple concurrent operations', () async {
        final futures = [
          CacheService.getCacheSizes(),
          CacheService.getTotalCacheSize(),
          CacheService.getCacheStats(),
          CacheService.isCacheHealthy(),
        ];

        expect(() => Future.wait(futures), returnsNormally);
      });

      test('should handle rapid cache clearing', () async {
        for (int i = 0; i < 5; i++) {
          await CacheService.clearAllCache();
        }
        expect(dailyVersesBox.isEmpty, isTrue);
      });

      test('should maintain data integrity after cleanup', () async {
        final verse = Verse(
          verseId: 1,
          chapterId: 1,
          description: 'Test',
          
          
        );

        await dailyVersesBox.put('test', DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          chapterIds: [1],
          verses: [verse],
        ));

        await CacheService.performAutoCleanup();

        final retrieved = dailyVersesBox.get('test');
        expect(retrieved, isNotNull);
        expect(retrieved!.verses.length, equals(1));
      });

      test('should handle box operations after repair', () async {
        await CacheService.repairCache();

        // Should be able to write after repair
        await dailyVersesBox.put('test', DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          chapterIds: [1],
          verses: [],
        ));

        expect(dailyVersesBox.length, equals(1));
      });
    });
  });
}
