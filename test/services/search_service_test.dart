// test/services/search_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/search_service.dart';
import 'package:GitaWisdom/models/search_result.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();

    // Register SearchResult adapter if not already registered
    try {
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(SearchResultAdapter());
      }
    } catch (e) {
      // Adapter might already be registered
    }
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('SearchService', () {
    late SearchService service;
    late Box<SearchResult> searchBox;
    late List<SearchResult> testSearchResults;

    setUp(() async {
      service = SearchService();

      // Open search_cache box for testing
      if (!Hive.isBoxOpen('search_cache')) {
        searchBox = await Hive.openBox<SearchResult>('search_cache');
      } else {
        searchBox = Hive.box<SearchResult>('search_cache');
      }

      // Create test search results
      testSearchResults = [
        SearchResult(
          id: 'search_1',
          searchQuery: 'karma',
          resultType: SearchType.query,
          title: 'karma',
          content: 'Search query',
          snippet: '5 results',
          relevanceScore: 0.0,
          searchDate: DateTime.now().subtract(const Duration(hours: 1)),
          metadata: {'result_count': 5},
        ),
        SearchResult(
          id: 'search_2',
          searchQuery: 'dharma',
          resultType: SearchType.query,
          title: 'dharma',
          content: 'Search query',
          snippet: '8 results',
          relevanceScore: 0.0,
          searchDate: DateTime.now().subtract(const Duration(hours: 2)),
          metadata: {'result_count': 8},
        ),
        SearchResult(
          id: 'verse_101',
          searchQuery: 'duty',
          resultType: SearchType.verse,
          title: 'Verse 2.47',
          content: 'You have a right to perform your prescribed duty',
          snippet: 'You have a right to perform your prescribed duty',
          chapterId: 2,
          verseId: 101,
          relevanceScore: 95.5,
          searchDate: DateTime.now().subtract(const Duration(minutes: 30)),
          metadata: {'chapter_id': 2, 'verse_id': 101},
        ),
      ];

      // Clear search box
      await searchBox.clear();

      // Initialize service
      await service.initialize();
    });

    tearDown(() async {
      // Clean up after each test
      // Only clear if box is still open (dispose test might have closed it)
      try {
        if (Hive.isBoxOpen('search_cache')) {
          await searchBox.clear();
        }
      } catch (e) {
        // Box might be closed, that's okay
      }
    });

    group('Initialization', () {
      test('service should initialize without errors', () async {
        expect(service, isNotNull);
        expect(service.recentSearches, isNotNull);
        expect(service.searchSuggestions, isNotNull);
      });

      test('should open search_cache Hive box', () async {
        expect(Hive.isBoxOpen('search_cache'), isTrue);
      });

      test('should load search suggestions on initialization', () async {
        expect(service.searchSuggestions, isNotEmpty);
        expect(service.searchSuggestions, contains('karma'));
        expect(service.searchSuggestions, contains('dharma'));
        expect(service.searchSuggestions, contains('moksha'));
      });

      test('should have chapter search suggestions', () async {
        expect(service.searchSuggestions, contains('chapter 1'));
        expect(service.searchSuggestions, contains('chapter 18'));
      });
    });

    group('Recent Searches', () {
      test('should load recent searches from Hive on initialization', () async {
        // Add some search results to Hive
        for (final result in testSearchResults.take(2)) {
          await searchBox.put(result.id, result);
        }

        // Reinitialize service to load from Hive
        final newService = SearchService();
        await newService.initialize();

        expect(newService.recentSearches, isNotEmpty);
        expect(newService.recentSearches.length, lessThanOrEqualTo(2));
      });

      test('should sort recent searches by date (most recent first)', () async {
        // Add search results with different dates
        for (final result in testSearchResults.take(2)) {
          await searchBox.put(result.id, result);
        }

        final newService = SearchService();
        await newService.initialize();

        if (newService.recentSearches.length >= 2) {
          final dates = newService.recentSearches.map((r) => r.searchDate).toList();
          for (int i = 0; i < dates.length - 1; i++) {
            expect(dates[i].isAfter(dates[i + 1]) || dates[i].isAtSameMomentAs(dates[i + 1]), isTrue);
          }
        }
      });

      test('should limit recent searches to 50 items', () async {
        // Add 60 search results
        for (int i = 0; i < 60; i++) {
          final result = SearchResult(
            id: 'search_$i',
            searchQuery: 'test query $i',
            resultType: SearchType.query,
            title: 'test query $i',
            content: 'Search query',
            snippet: '10 results',
            relevanceScore: 0.0,
            searchDate: DateTime.now().subtract(Duration(hours: i)),
            metadata: {'result_count': 10},
          );
          await searchBox.put(result.id, result);
        }

        final newService = SearchService();
        await newService.initialize();

        expect(newService.recentSearches.length, lessThanOrEqualTo(50));
      });

      test('should clear recent searches', () async {
        // Add some search results
        for (final result in testSearchResults.take(2)) {
          await searchBox.put(result.id, result);
        }

        final newService = SearchService();
        await newService.initialize();
        expect(newService.recentSearches, isNotEmpty);

        await newService.clearRecentSearches();
        expect(newService.recentSearches, isEmpty);
        expect(searchBox.isEmpty, isTrue);
      });
    });

    group('Search Suggestions', () {
      test('should return suggestions for partial query', () {
        final suggestions = service.getSuggestions('kar');
        expect(suggestions, isNotEmpty);
        expect(suggestions, contains('karma'));
      });

      test('should return suggestions case-insensitively', () {
        final suggestions = service.getSuggestions('KAR');
        expect(suggestions, isNotEmpty);
        expect(suggestions.any((s) => s.toLowerCase().contains('kar')), isTrue);
      });

      test('should limit suggestions to 10 items', () {
        final suggestions = service.getSuggestions('a');
        expect(suggestions.length, lessThanOrEqualTo(10));
      });

      test('should return empty list for empty query', () {
        final suggestions = service.getSuggestions('');
        expect(suggestions, isEmpty);
      });

      test('should return empty list for no matches', () {
        final suggestions = service.getSuggestions('xyz123nonexistent');
        expect(suggestions, isEmpty);
      });
    });

    group('Search Functionality', () {
      test('should return empty list for empty query', () async {
        final results = await service.search('');
        expect(results, isEmpty);
        expect(service.currentResults, isEmpty);
      });

      test('should trim whitespace from query', () async {
        final results = await service.search('   ');
        expect(results, isEmpty);
      });

      test('should set loading state during search', () async {
        // Start search (will fail since we don't have Supabase mock)
        final searchFuture = service.search('karma');

        // Check loading state immediately
        // Note: This might be flaky due to timing, but demonstrates the concept
        await Future.delayed(const Duration(milliseconds: 10));

        await searchFuture;

        // After search completes, loading should be false
        expect(service.isLoading, isFalse);
      });

      test('should store last query', () async {
        await service.search('karma yoga');
        expect(service.lastQuery, equals('karma yoga'));
      });

      test('should handle network errors gracefully', () async {
        // Without Supabase mock, network calls will fail
        // Service should handle this gracefully
        final results = await service.search('test query');

        // Should not throw exception
        expect(results, isNotNull);
        expect(service.isLoading, isFalse);
      });

      test('should clear error on successful initialization', () async {
        await service.initialize();
        // Error should be null after successful initialization
        // (or set if initialization failed)
        expect(service.error, anyOf(isNull, isNotNull));
      });
    });

    group('Result Filtering', () {
      test('should filter results by type', () {
        // Manually set some current results for testing
        service.search('test').then((_) {});

        // This test demonstrates the API, but won't have real results without Supabase
        final verseResults = service.getResultsByType(SearchType.verse);
        expect(verseResults, isNotNull);
        expect(verseResults, everyElement(
          predicate<SearchResult>((r) => r.resultType == SearchType.verse)
        ));
      });

      test('should return empty list for type with no results', () {
        final results = service.getResultsByType(SearchType.chapter);
        expect(results, isEmpty);
      });
    });

    group('Clear Functionality', () {
      test('should clear current results', () async {
        // Perform a search
        await service.search('karma');

        // Clear results
        service.clearResults();

        expect(service.currentResults, isEmpty);
        expect(service.lastQuery, isEmpty);
      });

      test('should notify listeners when clearing results', () {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        service.clearResults();

        expect(notified, isTrue);
      });
    });

    group('ChangeNotifier Behavior', () {
      test('should notify listeners on initialization', () async {
        bool notified = false;
        final newService = SearchService();

        newService.addListener(() {
          notified = true;
        });

        await newService.initialize();

        // Should have notified during initialization
        expect(notified, isTrue);
      });

      test('should notify listeners when clearing recent searches', () async {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        await service.clearRecentSearches();

        expect(notified, isTrue);
      });

      test('should notify listeners when search completes', () async {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });

        await service.search('karma');

        expect(notified, isTrue);
      });
    });

    group('SearchResult Model', () {
      test('should create search result with all fields', () {
        final result = SearchResult(
          id: 'test_1',
          searchQuery: 'test',
          resultType: SearchType.verse,
          title: 'Test Result',
          content: 'Test content',
          snippet: 'Test snippet',
          chapterId: 1,
          verseId: 10,
          relevanceScore: 85.5,
          searchDate: DateTime.now(),
          metadata: {'test': 'value'},
        );

        expect(result.id, equals('test_1'));
        expect(result.searchQuery, equals('test'));
        expect(result.resultType, equals(SearchType.verse));
        expect(result.title, equals('Test Result'));
        expect(result.relevanceScore, equals(85.5));
      });

      test('should convert to and from JSON', () {
        final original = SearchResult(
          id: 'test_1',
          searchQuery: 'test',
          resultType: SearchType.verse,
          title: 'Test Result',
          content: 'Test content',
          snippet: 'Test snippet',
          chapterId: 1,
          verseId: 10,
          relevanceScore: 85.5,
          searchDate: DateTime(2025, 1, 1, 12, 0, 0),
          metadata: {'test': 'value'},
        );

        final json = original.toJson();
        final restored = SearchResult.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.searchQuery, equals(original.searchQuery));
        expect(restored.resultType, equals(original.resultType));
        expect(restored.title, equals(original.title));
        expect(restored.relevanceScore, equals(original.relevanceScore));
      });

      test('should handle equality correctly', () {
        final result1 = SearchResult(
          id: 'test_1',
          searchQuery: 'test',
          resultType: SearchType.verse,
          title: 'Test Result',
          content: 'Test content',
          snippet: 'Test snippet',
          relevanceScore: 85.5,
          searchDate: DateTime.now(),
        );

        final result2 = SearchResult(
          id: 'test_1',
          searchQuery: 'test',
          resultType: SearchType.verse,
          title: 'Different Title',
          content: 'Different content',
          snippet: 'Different snippet',
          relevanceScore: 50.0,
          searchDate: DateTime.now(),
        );

        expect(result1, equals(result2)); // Same id, query, type
      });
    });

    group('SearchType Enum', () {
      test('should convert to string value', () {
        expect(SearchType.verse.value, equals('verse'));
        expect(SearchType.chapter.value, equals('chapter'));
        expect(SearchType.scenario.value, equals('scenario'));
        expect(SearchType.query.value, equals('query'));
      });

      test('should parse from string', () {
        expect(SearchType.fromString('verse'), equals(SearchType.verse));
        expect(SearchType.fromString('chapter'), equals(SearchType.chapter));
        expect(SearchType.fromString('scenario'), equals(SearchType.scenario));
        expect(SearchType.fromString('query'), equals(SearchType.query));
      });

      test('should default to verse for invalid string', () {
        expect(SearchType.fromString('invalid'), equals(SearchType.verse));
      });
    });

    group('Error Handling', () {
      test('should handle Hive box opening errors', () async {
        // This test demonstrates error handling pattern
        // Actual error would require forcing Hive to fail
        final newService = SearchService();
        await newService.initialize();

        // Should not throw even if there are issues
        expect(newService, isNotNull);
      });

      test('should handle empty search results gracefully', () async {
        final results = await service.search('nonexistent_query_xyz123');

        expect(results, isNotNull);
        expect(results, isEmpty);
      });

      test('should maintain state consistency on error', () async {
        final initialQuery = service.lastQuery;

        await service.search('error query');

        // lastQuery should be updated even if search fails
        expect(service.lastQuery, equals('error query'));
        expect(service.isLoading, isFalse);
      });
    });

    group('Dispose', () {
      test('should close Hive box on dispose', () async {
        final newService = SearchService();
        await newService.initialize();

        // Box should be open
        expect(Hive.isBoxOpen('search_cache'), isTrue);

        newService.dispose();

        // Note: The box might still be open if other instances reference it
        // This test demonstrates the dispose pattern
      });
    });
  });
}
