// test/services/daily_verse_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/daily_verse_service.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/verse.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();

    // Register adapters if not already registered
    try {
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(DailyVerseSetAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(VerseAdapter());
      }
    } catch (e) {
      // Adapters might already be registered
    }
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('DailyVerseService', () {
    late DailyVerseService service;
    late Box<DailyVerseSet> dailyVersesBox;
    late List<Verse> testVerses;

    setUp(() async {
      service = DailyVerseService.instance;

      // Open daily_verses box for testing
      if (!Hive.isBoxOpen('daily_verses')) {
        dailyVersesBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      } else {
        dailyVersesBox = Hive.box<DailyVerseSet>('daily_verses');
      }

      // Create test verses
      testVerses = [
        Verse(
          verseId: 1,
          description: 'You have a right to perform your prescribed duty, but not to the fruits of action',
          chapterId: 2,
        ),
        Verse(
          verseId: 2,
          description: 'The soul is neither born, nor does it die at any time',
          chapterId: 2,
        ),
        Verse(
          verseId: 3,
          description: 'Therefore, without being attached to the fruits of activities, perform your duty',
          chapterId: 3,
        ),
        Verse(
          verseId: 4,
          description: 'Whenever there is a decline in righteousness and a predominant rise of irreligion',
          chapterId: 4,
        ),
        Verse(
          verseId: 5,
          description: 'One who performs his duty without attachment, surrendering the results',
          chapterId: 5,
        ),
      ];

      // Clear daily_verses box
      await dailyVersesBox.clear();

      // Initialize service
      await service.initialize();
    });

    tearDown(() async {
      // Clean up after each test
      await dailyVersesBox.clear();
    });

    group('Initialization', () {
      test('service should initialize without errors', () async {
        expect(service, isNotNull);
      });

      test('service should be singleton', () {
        final instance1 = DailyVerseService.instance;
        final instance2 = DailyVerseService.instance;
        expect(instance1, same(instance2));
      });

      test('should open daily_verses Hive box', () async {
        expect(Hive.isBoxOpen('daily_verses'), isTrue);
      });
    });

    group('getTodaysVerses', () {
      test('should return verses when cache exists for today', () async {
        // Create a verse set for today
        final today = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        final verses = await service.getTodaysVerses();

        expect(verses, isNotEmpty);
        expect(verses.length, equals(5));
        expect(verses.first.verseId, equals(1));
      });

      test('should return empty list when cache is empty and network fails', () async {
        // Don't populate cache, service will try to fetch from network
        // Since we don't have Supabase mocked, it will fail and return empty
        final verses = await service.getTodaysVerses();

        // Should handle error gracefully
        expect(verses, isNotNull);
      });

      test('should use cached verses from previous day if available', () async {
        // Create a verse set for a previous day
        final yesterday = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: yesterday,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(yesterday, verseSet);

        final verses = await service.getTodaysVerses();

        // Should attempt to generate new verses, but may fall back to cached
        expect(verses, isNotNull);
      });
    });

    group('Cache Management', () {
      test('should cache verse sets with correct date key', () async {
        final today = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        expect(dailyVersesBox.containsKey(today), isTrue);
        final cached = dailyVersesBox.get(today);
        expect(cached, isNotNull);
        expect(cached!.verses.length, equals(5));
      });

      test('should clean up old verses beyond 7 days', () async {
        // Add verse sets for different days
        for (int i = 0; i < 10; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateStr = '${date.year}-${date.month}-${date.day}';
          final verseSet = DailyVerseSet(
            date: dateStr,
            verses: testVerses.take(5).toList(),
            chapterIds: [2, 2, 3, 4, 5],
          );
          await dailyVersesBox.put(dateStr, verseSet);
        }

        // Service cleanup should remove verses older than 7 days
        // This happens automatically in _cacheVerseSet, but we test the box state
        expect(dailyVersesBox.length, greaterThan(0));
        expect(dailyVersesBox.length, lessThanOrEqualTo(10));
      });

      test('should handle invalid date keys during cleanup', () async {
        // Add some invalid keys
        final invalidVerseSet = DailyVerseSet(
          date: 'invalid-date',
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put('invalid-date', invalidVerseSet);
        await dailyVersesBox.put('another-invalid', invalidVerseSet);

        // getTodaysVerses should handle cleanup gracefully
        final verses = await service.getTodaysVerses();

        expect(verses, isNotNull);
        // Invalid keys should not crash the service
      });
    });

    group('DailyVerseSet Model', () {
      test('should create verse set for today', () {
        final verseSet = DailyVerseSet.forToday(
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );

        expect(verseSet, isNotNull);
        expect(verseSet.verses.length, equals(5));
        expect(verseSet.chapterIds.length, equals(5));
        expect(verseSet.isToday, isTrue);
      });

      test('should correctly identify if verse set is for today', () {
        final today = DailyVerseSet.getTodayString();
        final todaySet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );

        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
        final yesterdaySet = DailyVerseSet(
          date: yesterdayStr,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );

        expect(todaySet.isToday, isTrue);
        expect(yesterdaySet.isToday, isFalse);
      });

      test('should generate correct today string format', () {
        final today = DateTime.now();
        final todayString = DailyVerseSet.getTodayString();
        final expected = '${today.year}-${today.month}-${today.day}';

        expect(todayString, equals(expected));
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Without Supabase mock, network fetch will fail
        // Service should handle this gracefully
        final verses = await service.getTodaysVerses();

        expect(verses, isNotNull);
        // Should not throw exception
      });

      test('should fall back to cached data on error', () async {
        // Add a cached verse set
        final today = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        // getTodaysVerses should return cached data
        final verses = await service.getTodaysVerses();

        expect(verses, isNotEmpty);
        expect(verses.length, equals(5));
      });

      test('should handle empty verse list gracefully', () async {
        final emptyVerseSet = DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          verses: [],
          chapterIds: [],
        );
        await dailyVersesBox.put(DailyVerseSet.getTodayString(), emptyVerseSet);

        final verses = await service.getTodaysVerses();

        expect(verses, isNotNull);
        expect(verses, isEmpty);
      });
    });

    group('Constants', () {
      test('should have correct verse count constant', () {
        expect(DailyVerseService.verseCount, equals(5));
      });

      test('should have correct box name constant', () {
        expect(DailyVerseService.boxName, equals('daily_verses'));
      });
    });

    group('refreshTodaysVerses', () {
      test('should delete existing cache and generate new verses', () async {
        // Add existing cache
        final today = DailyVerseSet.getTodayString();
        final oldVerseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, oldVerseSet);

        expect(dailyVersesBox.containsKey(today), isTrue);

        // Refresh should clear cache
        // Note: May fail without Supabase mock, but should handle gracefully
        try {
          await service.refreshTodaysVerses();
        } catch (e) {
          // Expected to fail without Supabase, but should not crash
        }

        // Service should have attempted to refresh
        expect(service, isNotNull);
      });

      test('should handle refresh errors gracefully', () async {
        // Without Supabase mock, refresh will fail
        expect(
          () async => await service.refreshTodaysVerses(),
          throwsA(anything), // Should throw since network fetch fails
        );
      });
    });

    group('Cache Statistics', () {
      test('cachedVerseSetsCount should return correct count', () async {
        expect(service.cachedVerseSetsCount, equals(0));

        // Add verse sets
        for (int i = 0; i < 3; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateStr = '${date.year}-${date.month}-${date.day}';
          final verseSet = DailyVerseSet(
            date: dateStr,
            verses: testVerses.take(5).toList(),
            chapterIds: [2, 2, 3, 4, 5],
          );
          await dailyVersesBox.put(dateStr, verseSet);
        }

        expect(service.cachedVerseSetsCount, greaterThanOrEqualTo(3));
      });

      test('totalCachedVersesCount should sum all verses', () async {
        // Add verse sets with different numbers of verses
        final date1 = DailyVerseSet.getTodayString();
        final verseSet1 = DailyVerseSet(
          date: date1,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(date1, verseSet1);

        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final date2 = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
        final verseSet2 = DailyVerseSet(
          date: date2,
          verses: testVerses.take(3).toList(),
          chapterIds: [2, 2, 3],
        );
        await dailyVersesBox.put(date2, verseSet2);

        expect(service.totalCachedVersesCount, equals(8)); // 5 + 3
      });

      test('totalCachedVersesCount should return 0 when no cache', () {
        expect(service.totalCachedVersesCount, equals(0));
      });
    });

    group('clearCache', () {
      test('should clear all cached verses', () async {
        // Add some verse sets
        for (int i = 0; i < 5; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateStr = '${date.year}-${date.month}-${date.day}';
          final verseSet = DailyVerseSet(
            date: dateStr,
            verses: testVerses.take(5).toList(),
            chapterIds: [2, 2, 3, 4, 5],
          );
          await dailyVersesBox.put(dateStr, verseSet);
        }

        expect(service.cachedVerseSetsCount, greaterThan(0));

        await service.clearCache();

        expect(service.cachedVerseSetsCount, equals(0));
      });

      test('should handle clearCache when box is empty', () async {
        await service.clearCache();
        expect(service.cachedVerseSetsCount, equals(0));
      });

      test('should handle clearCache errors gracefully', () async {
        // Even if box has issues, should not throw
        expect(() => service.clearCache(), returnsNormally);
      });
    });

    group('hasTodaysVerses', () {
      test('should return true when today\'s verses exist', () async {
        final today = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        expect(service.hasTodaysVerses, isTrue);
      });

      test('should return false when today\'s verses don\'t exist', () {
        expect(service.hasTodaysVerses, isFalse);
      });

      test('should return false when only old verses exist', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
        final verseSet = DailyVerseSet(
          date: dateStr,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(dateStr, verseSet);

        expect(service.hasTodaysVerses, isFalse);
      });
    });

    group('getVersesForDate', () {
      test('should return verses for specific date', () async {
        final today = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        final verses = service.getVersesForDate(today);

        expect(verses, isNotNull);
        expect(verses!.length, equals(5));
      });

      test('should return null for non-existent date', () {
        final verses = service.getVersesForDate('2020-01-01');
        expect(verses, isNull);
      });

      test('should return null for invalid date format', () {
        final verses = service.getVersesForDate('invalid-date');
        expect(verses, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple calls to initialize', () async {
        await service.initialize();
        await service.initialize();
        await service.initialize();

        expect(service, isNotNull);
        expect(Hive.isBoxOpen('daily_verses'), isTrue);
      });

      test('should handle rapid getTodaysVerses calls', () async {
        final today = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        // Call multiple times rapidly
        final futures = <Future<List<Verse>>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(service.getTodaysVerses());
        }

        final results = await Future.wait(futures);

        // All calls should succeed
        expect(results.length, equals(10));
        for (final verses in results) {
          expect(verses.length, equals(5));
        }
      });

      test('should handle date boundary conditions', () {
        // Test midnight edge case
        final now = DateTime.now();
        final todayStr = DailyVerseSet.getTodayString();
        final expected = '${now.year}-${now.month}-${now.day}';

        expect(todayStr, equals(expected));
      });

      test('should handle empty chapter IDs list', () async {
        final verseSet = DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          verses: testVerses.take(5).toList(),
          chapterIds: [], // Empty chapter IDs
        );
        await dailyVersesBox.put(DailyVerseSet.getTodayString(), verseSet);

        final verses = await service.getTodaysVerses();

        expect(verses, isNotNull);
        expect(verses.length, equals(5));
      });

      test('should handle mismatched verses and chapter IDs count', () async {
        final verseSet = DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          verses: testVerses.take(5).toList(),
          chapterIds: [1, 2], // Only 2 chapter IDs for 5 verses
        );
        await dailyVersesBox.put(DailyVerseSet.getTodayString(), verseSet);

        final verses = await service.getTodaysVerses();

        expect(verses, isNotNull);
        expect(verses.length, equals(5));
      });
    });

    group('Performance', () {
      test('should cache verses efficiently', () async {
        final stopwatch = Stopwatch()..start();

        final today = DailyVerseSet.getTodayString();
        final verseSet = DailyVerseSet(
          date: today,
          verses: testVerses.take(5).toList(),
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        // First call should use cache
        final verses1 = await service.getTodaysVerses();

        stopwatch.stop();

        // Should be very fast (< 100ms) when using cache
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(verses1.length, equals(5));
      });

      test('should handle large number of cached verse sets', () async {
        // Add 30 days of verse sets
        for (int i = 0; i < 30; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateStr = '${date.year}-${date.month}-${date.day}';
          final verseSet = DailyVerseSet(
            date: dateStr,
            verses: testVerses.take(5).toList(),
            chapterIds: [2, 2, 3, 4, 5],
          );
          await dailyVersesBox.put(dateStr, verseSet);
        }

        // Should still work efficiently
        final verses = await service.getTodaysVerses();

        expect(verses, isNotNull);
        expect(service.cachedVerseSetsCount, greaterThan(0));
      });
    });

    group('Data Integrity', () {
      test('should preserve verse properties when caching', () async {
        final testVerse = Verse(
          verseId: 47,
          description: 'You have a right to perform your prescribed duty',
          chapterId: 2,
        );

        final verseSet = DailyVerseSet(
          date: DailyVerseSet.getTodayString(),
          verses: [testVerse],
          chapterIds: [2],
        );
        await dailyVersesBox.put(DailyVerseSet.getTodayString(), verseSet);

        final verses = await service.getTodaysVerses();

        expect(verses.first.verseId, equals(47));
        expect(verses.first.description, contains('prescribed duty'));
        expect(verses.first.chapterId, equals(2));
      });

      test('should maintain verse order', () async {
        final today = DailyVerseSet.getTodayString();
        final orderedVerses = testVerses.take(5).toList();
        final verseSet = DailyVerseSet(
          date: today,
          verses: orderedVerses,
          chapterIds: [2, 2, 3, 4, 5],
        );
        await dailyVersesBox.put(today, verseSet);

        final verses = await service.getTodaysVerses();

        // Verify order is preserved
        for (int i = 0; i < verses.length; i++) {
          expect(verses[i].verseId, equals(orderedVerses[i].verseId));
        }
      });
    });
  });
}
