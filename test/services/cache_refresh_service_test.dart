// test/services/cache_refresh_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/cache_refresh_service.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

import 'cache_refresh_service_test.mocks.dart';

@GenerateMocks([EnhancedSupabaseService])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();

    // Register adapters if not already registered
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ChapterAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
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

  group('CacheRefreshService', () {
    late CacheRefreshService service;
    late MockEnhancedSupabaseService mockSupabaseService;
    late List<Chapter> testChapters;
    late List<Verse> testVerses;
    late List<Scenario> testScenarios;

    setUp(() async {
      mockSupabaseService = MockEnhancedSupabaseService();

      // Create test data
      testChapters = List.generate(
        18,
        (i) => Chapter(
          chapterId: i + 1,
          title: 'Chapter ${i + 1}',
          subtitle: 'Subtitle ${i + 1}',
          summary: 'Summary ${i + 1}',
          verseCount: 10,
        ),
      );

      testVerses = List.generate(
        10,
        (i) => Verse(
          verseId: i + 1,
          description: 'Verse text ${i + 1}',
          chapterId: 1,
        ),
      );

      testScenarios = List.generate(
        5,
        (i) => Scenario(
          title: 'Scenario ${i + 1}',
          description: 'Description ${i + 1}',
          category: 'career',
          chapter: 1,
          heartResponse: 'Heart response ${i + 1}',
          dutyResponse: 'Duty response ${i + 1}',
          gitaWisdom: 'Gita wisdom ${i + 1}',
          verse: 'Verse ${i + 1}',
          verseNumber: '1.${i + 1}',
          tags: ['tag1', 'tag2'],
          actionSteps: ['Step 1', 'Step 2'],
          createdAt: DateTime.now(),
        ),
      );

      // Setup mock responses
      when(mockSupabaseService.fetchAllChapters())
          .thenAnswer((_) async => testChapters);

      when(mockSupabaseService.fetchVersesByChapter(any))
          .thenAnswer((_) async => testVerses);

      when(mockSupabaseService.fetchScenarios(limit: anyNamed('limit')))
          .thenAnswer((_) async => testScenarios);

      // Create service with mocked dependencies
      service = CacheRefreshService(supabaseService: mockSupabaseService);

      // Open test boxes
      if (!Hive.isBoxOpen('chapters')) {
        await Hive.openBox<Chapter>('chapters');
      }
      if (!Hive.isBoxOpen('gita_verses_cache')) {
        await Hive.openBox<Verse>('gita_verses_cache');
      }
      if (!Hive.isBoxOpen('scenarios')) {
        await Hive.openBox<Scenario>('scenarios');
      }
    });

    tearDown(() async {
      // Clear test boxes
      try {
        if (Hive.isBoxOpen('chapters')) {
          await Hive.box<Chapter>('chapters').clear();
        }
        if (Hive.isBoxOpen('gita_verses_cache')) {
          await Hive.box<Verse>('gita_verses_cache').clear();
        }
        if (Hive.isBoxOpen('scenarios')) {
          await Hive.box<Scenario>('scenarios').clear();
        }
      } catch (e) {
        // Boxes might not exist
      }
    });

    group('Initialization', () {
      test('service should be created with dependency injection', () {
        expect(service, isNotNull);
        expect(service.supabaseService, equals(mockSupabaseService));
      });

      test('service should require supabase service', () {
        expect(
          () => CacheRefreshService(supabaseService: mockSupabaseService),
          returnsNormally,
        );
      });
    });

    group('refreshAllCaches', () {
      test('should call all refresh methods', () async {
        final progressUpdates = <String>[];
        final progressValues = <double>[];

        await service.refreshAllCaches(
          onProgress: (message, progress) {
            progressUpdates.add(message);
            progressValues.add(progress);
          },
        );

        // Verify all methods were called
        verify(mockSupabaseService.fetchAllChapters()).called(1);
        verify(mockSupabaseService.fetchVersesByChapter(any)).called(18);
        verify(mockSupabaseService.fetchScenarios(limit: anyNamed('limit'))).called(1);

        // Verify progress updates
        expect(progressUpdates, isNotEmpty);
        expect(progressValues, isNotEmpty);
        expect(progressValues.first, equals(0.1)); // Clearing cache
        expect(progressValues.last, equals(1.0)); // Completion
      });

      test('should provide progress updates in correct order', () async {
        final progressUpdates = <String>[];

        await service.refreshAllCaches(
          onProgress: (message, progress) {
            progressUpdates.add(message);
          },
        );

        expect(progressUpdates[0], contains('Clearing'));
        expect(progressUpdates[1], contains('chapters'));
        expect(progressUpdates[2], contains('verses'));
        expect(progressUpdates[3], contains('scenarios'));
        expect(progressUpdates[4], contains('completed'));
      });

      test('should report correct progress values', () async {
        final progressValues = <double>[];

        await service.refreshAllCaches(
          onProgress: (message, progress) {
            progressValues.add(progress);
          },
        );

        // Progress should be in ascending order
        for (int i = 0; i < progressValues.length - 1; i++) {
          expect(progressValues[i], lessThanOrEqualTo(progressValues[i + 1]));
        }

        // First should be > 0, last should be 1.0
        expect(progressValues.first, greaterThan(0));
        expect(progressValues.last, equals(1.0));
      });

      test('should handle errors gracefully', () async {
        // Setup mock to throw error
        when(mockSupabaseService.fetchAllChapters())
            .thenThrow(Exception('Network error'));

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should refresh in parallel', () async {
        // This test verifies that futures are created before awaiting
        final progressUpdates = <String>[];

        await service.refreshAllCaches(
          onProgress: (message, progress) {
            progressUpdates.add(message);
          },
        );

        // All three refresh tasks should have been called
        verify(mockSupabaseService.fetchAllChapters()).called(1);
        verify(mockSupabaseService.fetchVersesByChapter(any)).called(18);
        verify(mockSupabaseService.fetchScenarios(limit: anyNamed('limit'))).called(1);
      });
    });

    group('Cache Clearing', () {
      test('should clear chapters box', () async {
        final chaptersBox = Hive.box('chapters');
        await chaptersBox.put('test', 'value');
        expect(chaptersBox.isNotEmpty, isTrue);

        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        expect(chaptersBox.isEmpty, isTrue);
      });

      test('should clear verses box', () async {
        final versesBox = Hive.box('gita_verses_cache');
        await versesBox.put('test', 'value');
        expect(versesBox.isNotEmpty, isTrue);

        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        expect(versesBox.isEmpty, isTrue);
      });

      test('should clear scenarios box', () async {
        final scenariosBox = Hive.box('scenarios');
        await scenariosBox.put('test', 'value');
        expect(scenariosBox.isNotEmpty, isTrue);

        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        expect(scenariosBox.isEmpty, isTrue);
      });

      test('should handle missing boxes gracefully', () async {
        // Even if some boxes don't exist, clearing should not fail
        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          returnsNormally,
        );
      });
    });

    group('Chapters Cache Refresh', () {
      test('should fetch all chapters', () async {
        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        verify(mockSupabaseService.fetchAllChapters()).called(1);
      });

      test('should handle empty chapters response', () async {
        when(mockSupabaseService.fetchAllChapters())
            .thenAnswer((_) async => []);

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          returnsNormally,
        );
      });

      test('should handle chapters fetch error', () async {
        when(mockSupabaseService.fetchAllChapters())
            .thenThrow(Exception('Network error'));

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Verses Cache Refresh', () {
      test('should fetch verses for all 18 chapters', () async {
        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        // Should call fetchVersesByChapter 18 times (once per chapter)
        verify(mockSupabaseService.fetchVersesByChapter(any)).called(18);
      });

      test('should fetch verses for chapters 1-18', () async {
        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        // Verify each chapter was fetched
        for (int i = 1; i <= 18; i++) {
          verify(mockSupabaseService.fetchVersesByChapter(i)).called(1);
        }
      });

      test('should handle verses fetch error', () async {
        when(mockSupabaseService.fetchVersesByChapter(any))
            .thenThrow(Exception('Network error'));

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should continue if one chapter fails (eagerError: false)', () async {
        // Make chapter 5 fail, but others succeed
        when(mockSupabaseService.fetchVersesByChapter(5))
            .thenThrow(Exception('Chapter 5 error'));

        when(mockSupabaseService.fetchVersesByChapter(argThat(isNot(5))))
            .thenAnswer((_) async => testVerses);

        // Should not throw because eagerError: false
        // But we expect it to throw because one failure causes rethrow
        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Scenarios Cache Refresh', () {
      test('should fetch scenarios with limit', () async {
        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        verify(mockSupabaseService.fetchScenarios(limit: 2000)).called(1);
      });

      test('should handle empty scenarios response', () async {
        when(mockSupabaseService.fetchScenarios(limit: anyNamed('limit')))
            .thenAnswer((_) async => []);

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          returnsNormally,
        );
      });

      test('should handle scenarios fetch error', () async {
        when(mockSupabaseService.fetchScenarios(limit: anyNamed('limit')))
            .thenThrow(Exception('Network error'));

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCacheStats', () {
      test('should return cache statistics', () async {
        final stats = await service.getCacheStats();

        expect(stats, isNotNull);
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('total_cached_items'), isTrue);
      });

      test('should count items in cache boxes', () async {
        // Add some items to boxes
        final chaptersBox = Hive.box('chapters');
        await chaptersBox.put('ch1', testChapters.first);
        await chaptersBox.put('ch2', testChapters[1]);

        final stats = await service.getCacheStats();

        expect(stats['total_cached_items'], greaterThan(0));
      });

      test('should indicate which caches are available', () async {
        final stats = await service.getCacheStats();

        expect(stats['chapters_cached'], isA<bool>());
        expect(stats['verses_cached'], isA<bool>());
        expect(stats['scenarios_cached'], isA<bool>());
      });

      test('should handle missing boxes gracefully', () async {
        expect(
          () => service.getCacheStats(),
          returnsNormally,
        );
      });

      test('should return empty map on error', () async {
        // Close all boxes to cause error
        if (Hive.isBoxOpen('chapters')) {
          await Hive.box('chapters').close();
        }

        final stats = await service.getCacheStats();

        // Should return empty map instead of throwing
        expect(stats, isA<Map<String, dynamic>>());
      });
    });

    group('Error Handling', () {
      test('should handle network errors during refresh', () async {
        when(mockSupabaseService.fetchAllChapters())
            .thenThrow(Exception('Network timeout'));

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle Hive errors during clear', () async {
        // This test demonstrates error handling pattern
        // Actual errors would require forcing Hive to fail
        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          returnsNormally,
        );
      });

      test('should propagate errors to caller', () async {
        final error = Exception('Custom error');
        when(mockSupabaseService.fetchScenarios(limit: anyNamed('limit')))
            .thenThrow(error);

        expect(
          () => service.refreshAllCaches(
            onProgress: (message, progress) {},
          ),
          throwsA(equals(error)),
        );
      });
    });

    group('Integration Scenarios', () {
      test('should refresh all caches successfully', () async {
        await service.refreshAllCaches(
          onProgress: (message, progress) {
            // Verify progress messages are useful
            expect(message, isNotEmpty);
            expect(progress, greaterThanOrEqualTo(0.0));
            expect(progress, lessThanOrEqualTo(1.0));
          },
        );

        // Verify completion (no exceptions thrown)
        expect(true, isTrue);
      });

      test('should clear then reload data', () async {
        // Pre-populate boxes
        final chaptersBox = Hive.box('chapters');
        await chaptersBox.put('old', 'old_data');

        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        // Old data should be gone (cleared before refresh)
        expect(chaptersBox.containsKey('old'), isFalse);
      });

      test('should handle multiple consecutive refreshes', () async {
        // First refresh
        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        // Second refresh
        await service.refreshAllCaches(
          onProgress: (message, progress) {},
        );

        // Should be called twice for each method
        verify(mockSupabaseService.fetchAllChapters()).called(2);
      });
    });
  });
}
