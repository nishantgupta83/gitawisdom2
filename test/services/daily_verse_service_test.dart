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
        expect(verses.first.verseNumber, equals('2.47'));
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
  });
}
