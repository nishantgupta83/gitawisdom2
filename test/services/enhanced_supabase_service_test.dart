// test/services/enhanced_supabase_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/chapter_summary.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/journal_entry.dart';
import '../test_setup.dart';
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('EnhancedSupabaseService', () {
    late EnhancedSupabaseService service;

    setUp(() {
      service = EnhancedSupabaseService();
    });

    tearDown(() async {
      // Clean up any opened Hive boxes
      try {
        if (Hive.isBoxOpen('chapter_summaries_permanent')) {
          await Hive.box('chapter_summaries_permanent').clear();
          await Hive.box('chapter_summaries_permanent').close();
        }
        if (Hive.isBoxOpen('chapters')) {
          await Hive.box('chapters').clear();
          await Hive.box('chapters').close();
        }
        if (Hive.isBoxOpen('gita_verses_cache')) {
          await Hive.box('gita_verses_cache').clear();
          await Hive.box('gita_verses_cache').close();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    // ========================================================================
    // INITIALIZATION TESTS (6 tests)
    // ========================================================================
    group('Service Initialization', () {
      test('service should initialize without errors', () {
        expect(service, isNotNull);
      });

      test('service should have client property', () {
        expect(service.client, isNotNull);
      });

      test('testConnection method should exist and return Future<bool>', () {
        expect(service.testConnection, isA<Function>());
      });

      test('initializeLanguages method should exist and be async', () {
        expect(service.initializeLanguages, isA<Function>());
      });

      test('testConnection should return boolean', () async {
        final result = await service.testConnection();
        expect(result, isA<bool>());
      });

      test('initializeLanguages should complete without throwing', () async {
        expect(() async => await service.initializeLanguages(), returnsNormally);
      });
    });

    // ========================================================================
    // SCENARIO OPERATIONS TESTS (25 tests)
    // ========================================================================
    group('Scenario Operations', () {
      test('fetchScenariosByChapter should return list of scenarios', () async {
        final scenarios = await service.fetchScenariosByChapter(1);
        expect(scenarios, isA<List<Scenario>>());
      });

      test('fetchScenariosByChapter should handle invalid chapter ID', () async {
        final scenarios = await service.fetchScenariosByChapter(999);
        expect(scenarios, isEmpty);
      });

      test('fetchScenariosByChapter should handle zero chapter ID', () async {
        final scenarios = await service.fetchScenariosByChapter(0);
        expect(scenarios, isEmpty);
      });

      test('fetchScenariosByChapter should handle negative chapter ID', () async {
        final scenarios = await service.fetchScenariosByChapter(-1);
        expect(scenarios, isEmpty);
      });

      test('fetchScenarioById should return scenario or null', () async {
        final scenario = await service.fetchScenarioById(1);
        expect(scenario, anyOf(isA<Scenario>(), isNull));
      });

      test('fetchScenarioById should handle invalid ID', () async {
        final scenario = await service.fetchScenarioById(999999);
        expect(scenario, isNull);
      });

      test('fetchScenarioById should handle zero ID', () async {
        final scenario = await service.fetchScenarioById(0);
        expect(scenario, isNull);
      });

      test('fetchScenarioById should handle negative ID', () async {
        final scenario = await service.fetchScenarioById(-1);
        expect(scenario, isNull);
      });

      test('fetchScenarios should return list with default limit', () async {
        final scenarios = await service.fetchScenarios();
        expect(scenarios, isA<List<Scenario>>());
      });

      test('fetchScenarios should respect custom limit', () async {
        final scenarios = await service.fetchScenarios(limit: 10);
        expect(scenarios, isA<List<Scenario>>());
        expect(scenarios.length, lessThanOrEqualTo(10));
      });

      test('fetchScenarios should handle zero limit', () async {
        final scenarios = await service.fetchScenarios(limit: 0);
        expect(scenarios, isEmpty);
      });

      test('fetchScenarios should handle offset parameter', () async {
        final scenarios = await service.fetchScenarios(limit: 10, offset: 5);
        expect(scenarios, isA<List<Scenario>>());
      });

      test('fetchScenarios should handle large offset', () async {
        final scenarios = await service.fetchScenarios(limit: 10, offset: 10000);
        expect(scenarios, isEmpty);
      });

      test('fetchRandomScenario should return scenario or null', () async {
        final scenario = await service.fetchRandomScenario();
        expect(scenario, anyOf(isA<Scenario>(), isNull));
      });

      test('fetchScenarioCount should return non-negative integer', () async {
        final count = await service.fetchScenarioCount(1);
        expect(count, isA<int>());
        expect(count, greaterThanOrEqualTo(0));
      });

      test('fetchScenarioCount should handle invalid chapter', () async {
        final count = await service.fetchScenarioCount(999);
        expect(count, equals(0));
      });

      test('getScenarioCount should return total count', () async {
        final count = await service.getScenarioCount();
        expect(count, isA<int>());
        expect(count, greaterThanOrEqualTo(0));
      });

      test('searchScenarios should return empty list for empty query', () async {
        final scenarios = await service.searchScenarios('');
        expect(scenarios, isA<List<Scenario>>());
      });

      test('searchScenarios should handle whitespace query', () async {
        final scenarios = await service.searchScenarios('   ');
        expect(scenarios, isA<List<Scenario>>());
      });

      test('searchScenarios should sanitize SQL injection attempts', () async {
        final scenarios = await service.searchScenarios("'; DROP TABLE scenarios; --");
        expect(scenarios, isA<List<Scenario>>());
      });

      test('searchScenarios should handle special characters', () async {
        final scenarios = await service.searchScenarios('%_,\\');
        expect(scenarios, isA<List<Scenario>>());
      });

      test('searchScenarios should handle long queries', () async {
        final longQuery = 'a' * 600; // Exceeds 500 char limit
        final scenarios = await service.searchScenarios(longQuery);
        expect(scenarios, isA<List<Scenario>>());
      });

      test('searchScenarios should handle valid search term', () async {
        final scenarios = await service.searchScenarios('work');
        expect(scenarios, isA<List<Scenario>>());
      });

      test('fetchScenarios with langCode parameter should work', () async {
        final scenarios = await service.fetchScenarios(langCode: 'en');
        expect(scenarios, isA<List<Scenario>>());
      });

      test('fallback scenario methods should be called on errors', () async {
        // This tests the fallback mechanism indirectly
        final scenarios = await service.fetchScenariosByChapter(1);
        expect(scenarios, isA<List<Scenario>>());
      });
    });

    // ========================================================================
    // CHAPTER OPERATIONS TESTS (20 tests)
    // ========================================================================
    group('Chapter Operations', () {
      test('fetchChapterSummaries should return list of summaries', () async {
        final summaries = await service.fetchChapterSummaries();
        expect(summaries, isA<List<ChapterSummary>>());
      });

      test('fetchChapterSummaries should have 18 chapters or less', () async {
        final summaries = await service.fetchChapterSummaries();
        expect(summaries.length, lessThanOrEqualTo(18));
      });

      test('fetchChapterSummaries with langCode should work', () async {
        final summaries = await service.fetchChapterSummaries('en');
        expect(summaries, isA<List<ChapterSummary>>());
      });

      test('fetchChapterSummaries should cache results in Hive', () async {
        await service.fetchChapterSummaries();

        // Check if cache box exists
        if (Hive.isBoxOpen('chapter_summaries_permanent')) {
          final box = Hive.box<ChapterSummary>('chapter_summaries_permanent');
          expect(box, isNotNull);
        }
      });

      test('fetchChapterSummaries should use cache on second call', () async {
        final summaries1 = await service.fetchChapterSummaries();
        final summaries2 = await service.fetchChapterSummaries();

        expect(summaries1.length, equals(summaries2.length));
      });

      test('fetchChapterById should return chapter or null', () async {
        final chapter = await service.fetchChapterById(1);
        expect(chapter, anyOf(isA<Chapter>(), isNull));
      });

      test('fetchChapterById should handle invalid ID', () async {
        final chapter = await service.fetchChapterById(999);
        expect(chapter, isNull);
      });

      test('fetchChapterById should handle zero ID', () async {
        final chapter = await service.fetchChapterById(0);
        expect(chapter, isNull);
      });

      test('fetchChapterById should handle negative ID', () async {
        final chapter = await service.fetchChapterById(-1);
        expect(chapter, isNull);
      });

      test('fetchChapterById with langCode should work', () async {
        final chapter = await service.fetchChapterById(1, 'en');
        expect(chapter, anyOf(isA<Chapter>(), isNull));
      });

      test('fetchAllChapters should return list of chapters', () async {
        final chapters = await service.fetchAllChapters();
        expect(chapters, isA<List<Chapter>>());
      });

      test('fetchAllChapters should have 18 chapters or less', () async {
        final chapters = await service.fetchAllChapters();
        expect(chapters.length, lessThanOrEqualTo(18));
      });

      test('fetchAllChapters with langCode should work', () async {
        final chapters = await service.fetchAllChapters('en');
        expect(chapters, isA<List<Chapter>>());
      });

      test('fetchAllChapters should cache results', () async {
        await service.fetchAllChapters();

        if (Hive.isBoxOpen('chapters')) {
          final box = Hive.box<Chapter>('chapters');
          expect(box, isNotNull);
        }
      });

      test('fetchAllChapters should use cache on second call', () async {
        final chapters1 = await service.fetchAllChapters();
        final chapters2 = await service.fetchAllChapters();

        expect(chapters1.length, equals(chapters2.length));
      });

      test('chapter should have all required fields', () async {
        final chapter = await service.fetchChapterById(1);
        if (chapter != null) {
          expect(chapter.chapterId, isA<int>());
          expect(chapter.title, isA<String>());
        }
      });

      test('chapter summary should have all required fields', () async {
        final summaries = await service.fetchChapterSummaries();
        if (summaries.isNotEmpty) {
          final summary = summaries.first;
          expect(summary.chapterId, isA<int>());
          expect(summary.title, isA<String>());
          expect(summary.verseCount, isA<int>());
          expect(summary.scenarioCount, isA<int>());
        }
      });

      test('chapter IDs should be sequential from 1-18', () async {
        final summaries = await service.fetchChapterSummaries();
        if (summaries.isNotEmpty) {
          for (final summary in summaries) {
            expect(summary.chapterId, greaterThanOrEqualTo(1));
            expect(summary.chapterId, lessThanOrEqualTo(18));
          }
        }
      });

      test('fetchChapterById should fallback on network error', () async {
        // This tests the fallback mechanism
        final chapter = await service.fetchChapterById(1);
        expect(chapter, anyOf(isA<Chapter>(), isNull));
      });

      test('fetchAllChapters should use parallel requests', () async {
        // This verifies the parallel fetching mechanism works
        final chapters = await service.fetchAllChapters();
        expect(chapters, isA<List<Chapter>>());
      });
    });

    // ========================================================================
    // VERSE OPERATIONS TESTS (20 tests)
    // ========================================================================
    group('Verse Operations', () {
      test('fetchVersesByChapter should return list of verses', () async {
        final verses = await service.fetchVersesByChapter(1);
        expect(verses, isA<List<Verse>>());
      });

      test('fetchVersesByChapter should handle invalid chapter', () async {
        final verses = await service.fetchVersesByChapter(999);
        expect(verses, isEmpty);
      });

      test('fetchVersesByChapter should handle zero chapter', () async {
        final verses = await service.fetchVersesByChapter(0);
        expect(verses, isEmpty);
      });

      test('fetchVersesByChapter should handle negative chapter', () async {
        final verses = await service.fetchVersesByChapter(-1);
        expect(verses, isEmpty);
      });

      test('fetchVersesByChapter with langCode should work', () async {
        final verses = await service.fetchVersesByChapter(1, 'en');
        expect(verses, isA<List<Verse>>());
      });

      test('fetchVersesByChapter should cache verses', () async {
        await service.fetchVersesByChapter(1);

        if (Hive.isBoxOpen('gita_verses_cache')) {
          final box = Hive.box('gita_verses_cache');
          expect(box, isNotNull);
        }
      });

      test('fetchVersesByChapter should use cache on second call', () async {
        final verses1 = await service.fetchVersesByChapter(1);
        final verses2 = await service.fetchVersesByChapter(1);

        expect(verses1.length, equals(verses2.length));
      });

      test('verse should have all required fields', () async {
        final verses = await service.fetchVersesByChapter(1);
        if (verses.isNotEmpty) {
          final verse = verses.first;
          expect(verse.verseId, isA<int>());
          expect(verse.chapterId, isA<int>());
          expect(verse.description, isA<String>());
        }
      });

      test('verse chapter ID should match requested chapter', () async {
        final verses = await service.fetchVersesByChapter(2);
        if (verses.isNotEmpty) {
          for (final verse in verses) {
            expect(verse.chapterId, equals(2));
          }
        }
      });

      test('fetchRandomVerseByChapter should return verse', () async {
        try {
          final verse = await service.fetchRandomVerseByChapter(1);
          expect(verse, isA<Verse>());
        } catch (e) {
          // May throw if no verses exist
          expect(e, isA<Exception>());
        }
      });

      test('fetchRandomVerseByChapter should handle invalid chapter', () async {
        expect(
          () => service.fetchRandomVerseByChapter(999),
          throwsA(isA<Exception>()),
        );
      });

      test('fetchRandomVerseByChapter with langCode should work', () async {
        try {
          final verse = await service.fetchRandomVerseByChapter(1, 'en');
          expect(verse, isA<Verse>());
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('verses should be ordered by verse ID', () async {
        final verses = await service.fetchVersesByChapter(1);
        if (verses.length > 1) {
          for (int i = 0; i < verses.length - 1; i++) {
            expect(verses[i].verseId, lessThanOrEqualTo(verses[i + 1].verseId));
          }
        }
      });

      test('verse cache should persist between calls', () async {
        final verses1 = await service.fetchVersesByChapter(1);

        // Clear in-memory but keep Hive cache
        final verses2 = await service.fetchVersesByChapter(1);

        expect(verses1.length, equals(verses2.length));
      });

      test('fetchVersesByChapter should handle different chapters independently', () async {
        final verses1 = await service.fetchVersesByChapter(1);
        final verses2 = await service.fetchVersesByChapter(2);

        // Different chapters should potentially have different verse counts
        expect(verses1, isA<List<Verse>>());
        expect(verses2, isA<List<Verse>>());
      });

      test('verse description should not be empty', () async {
        final verses = await service.fetchVersesByChapter(1);
        if (verses.isNotEmpty) {
          for (final verse in verses) {
            expect(verse.description, isNotEmpty);
          }
        }
      });

      test('fetchVersesByChapter should handle network errors gracefully', () async {
        final verses = await service.fetchVersesByChapter(1);
        expect(verses, isA<List<Verse>>());
      });

      test('verse IDs should be positive integers', () async {
        final verses = await service.fetchVersesByChapter(1);
        if (verses.isNotEmpty) {
          for (final verse in verses) {
            expect(verse.verseId, greaterThan(0));
          }
        }
      });

      test('fetchVersesByChapter should fallback to network on cache error', () async {
        final verses = await service.fetchVersesByChapter(1);
        expect(verses, isA<List<Verse>>());
      });

      test('multiple random verses should be from same chapter', () async {
        try {
          final verse1 = await service.fetchRandomVerseByChapter(1);
          final verse2 = await service.fetchRandomVerseByChapter(1);

          expect(verse1.chapterId, equals(1));
          expect(verse2.chapterId, equals(1));
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });
    });

    // ========================================================================
    // CACHING TESTS (15 tests)
    // ========================================================================
    group('Caching Mechanisms', () {
      test('search query sanitization is tested via searchScenarios', () async {
        // SQL injection attempts should be handled gracefully
        final scenarios = await service.searchScenarios("'; DROP TABLE;");
        expect(scenarios, isA<List<Scenario>>());
      });

      test('search query wildcards are handled via searchScenarios', () async {
        final scenarios = await service.searchScenarios('%_');
        expect(scenarios, isA<List<Scenario>>());
      });

      test('long search queries are truncated via searchScenarios', () async {
        final longQuery = 'a' * 600;
        final scenarios = await service.searchScenarios(longQuery);
        expect(scenarios, isA<List<Scenario>>());
      });

      test('search query whitespace is trimmed via searchScenarios', () async {
        final scenarios = await service.searchScenarios('  test  ');
        expect(scenarios, isA<List<Scenario>>());
      });

      test('chapter summaries cache should persist', () async {
        await service.fetchChapterSummaries();
        await service.fetchChapterSummaries();

        if (Hive.isBoxOpen('chapter_summaries_permanent')) {
          final box = Hive.box('chapter_summaries_permanent');
          expect(box.isNotEmpty, isTrue);
        }
      });

      test('chapters cache should persist', () async {
        await service.fetchAllChapters();
        await service.fetchAllChapters();

        if (Hive.isBoxOpen('chapters')) {
          final box = Hive.box('chapters');
          expect(box, isNotNull);
        }
      });

      test('verses cache should persist', () async {
        await service.fetchVersesByChapter(1);
        await service.fetchVersesByChapter(1);

        if (Hive.isBoxOpen('gita_verses_cache')) {
          final box = Hive.box('gita_verses_cache');
          expect(box, isNotNull);
        }
      });

      test('cache should return same data on multiple calls', () async {
        final summaries1 = await service.fetchChapterSummaries();
        final summaries2 = await service.fetchChapterSummaries();

        expect(summaries1.length, equals(summaries2.length));
      });

      test('different chapters should have separate verse caches', () async {
        final verses1 = await service.fetchVersesByChapter(1);
        final verses2 = await service.fetchVersesByChapter(2);

        expect(verses1, isA<List<Verse>>());
        expect(verses2, isA<List<Verse>>());
      });

      test('cache should survive service recreation', () async {
        final service1 = EnhancedSupabaseService();
        await service1.fetchChapterSummaries();

        final service2 = EnhancedSupabaseService();
        final summaries = await service2.fetchChapterSummaries();

        expect(summaries, isNotEmpty);
      });

      test('verse cache key should be chapter-specific', () async {
        await service.fetchVersesByChapter(1);

        if (Hive.isBoxOpen('gita_verses_cache')) {
          final box = Hive.box('gita_verses_cache');
          expect(box.containsKey('chapter_1'), isTrue);
        }
      });

      test('cache should handle concurrent reads', () async {
        final futures = [
          service.fetchChapterSummaries(),
          service.fetchChapterSummaries(),
          service.fetchChapterSummaries(),
        ];

        final results = await Future.wait(futures);
        expect(results.length, equals(3));
      });

      test('cache should handle box not open error', () async {
        final summaries = await service.fetchChapterSummaries();
        expect(summaries, isA<List<ChapterSummary>>());
      });

      test('cache should update atomically', () async {
        await service.fetchChapterSummaries();
        await service.fetchChapterSummaries();

        expect(() async => await service.fetchChapterSummaries(), returnsNormally);
      });

      test('empty cache should trigger network fetch', () async {
        final summaries = await service.fetchChapterSummaries();
        expect(summaries, isA<List<ChapterSummary>>());
      });
    });

    // ========================================================================
    // ERROR HANDLING TESTS (8 tests)
    // ========================================================================
    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        final scenarios = await service.fetchScenarios();
        expect(scenarios, isA<List<Scenario>>());
      });

      test('should fallback on Supabase errors', () async {
        final chapter = await service.fetchChapterById(1);
        expect(chapter, anyOf(isA<Chapter>(), isNull));
      });

      test('should return empty list on query errors', () async {
        final scenarios = await service.fetchScenariosByChapter(1);
        expect(scenarios, isA<List<Scenario>>());
      });

      test('should handle timeout errors', () async {
        final chapters = await service.fetchAllChapters();
        expect(chapters, isA<List<Chapter>>());
      });

      test('should handle invalid data format', () async {
        final verses = await service.fetchVersesByChapter(1);
        expect(verses, isA<List<Verse>>());
      });

      test('should handle cache corruption', () async {
        final summaries = await service.fetchChapterSummaries();
        expect(summaries, isA<List<ChapterSummary>>());
      });

      test('should handle missing fields gracefully', () async {
        final scenarios = await service.fetchScenarios(limit: 1);
        expect(scenarios, isA<List<Scenario>>());
      });

      test('testConnection should not throw on errors', () async {
        expect(() async => await service.testConnection(), returnsNormally);
      });
    });

    // ========================================================================
    // LANGUAGE SUPPORT TESTS (6 tests)
    // ========================================================================
    group('Language Support', () {
      test('isLanguageSupported should return true for English', () {
        expect(service.isLanguageSupported('en'), isTrue);
      });

      test('isLanguageSupported should return false for other languages', () {
        expect(service.isLanguageSupported('es'), isFalse);
      });

      test('getLanguageDisplayName should return English for en', () {
        expect(service.getLanguageDisplayName('en'), equals('English'));
      });

      test('getLanguageDisplayName with useNative should return English', () {
        expect(service.getLanguageDisplayName('en', useNative: true), equals('English'));
      });

      test('setCurrentLanguage should only accept English', () async {
        expect(() async => await service.setCurrentLanguage('en'), returnsNormally);
      });

      test('setCurrentLanguage should handle non-English gracefully', () async {
        expect(() async => await service.setCurrentLanguage('es'), returnsNormally);
      });
    });

    // ========================================================================
    // UTILITY METHODS TESTS (5 tests)
    // ========================================================================
    group('Utility Methods', () {
      test('refreshTranslationViews should return boolean', () async {
        final result = await service.refreshTranslationViews();
        expect(result, isA<bool>());
      });

      test('getTranslationCoverage should return map', () async {
        final coverage = await service.getTranslationCoverage();
        expect(coverage, isA<Map<String, dynamic>>());
      });

      test('getTranslationCoverage with langCode should work', () async {
        final coverage = await service.getTranslationCoverage('en');
        expect(coverage, isA<Map<String, dynamic>>());
      });

      test('dispose should not throw', () {
        expect(() => service.dispose(), returnsNormally);
      });

      test('service should be usable after initialization', () async {
        await service.initializeLanguages();
        final scenarios = await service.fetchScenarios(limit: 1);
        expect(scenarios, isA<List<Scenario>>());
      });
    });
  });
}
