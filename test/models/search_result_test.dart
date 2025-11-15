// test/models/search_result_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/search_result.dart';

void main() {
  group('SearchType Enum', () {
    test('should have all search types', () {
      expect(SearchType.values, hasLength(4));
      expect(SearchType.values, contains(SearchType.verse));
      expect(SearchType.values, contains(SearchType.chapter));
      expect(SearchType.values, contains(SearchType.scenario));
      expect(SearchType.values, contains(SearchType.query));
    });

    test('should convert to string value', () {
      expect(SearchType.verse.value, equals('verse'));
      expect(SearchType.chapter.value, equals('chapter'));
      expect(SearchType.scenario.value, equals('scenario'));
      expect(SearchType.query.value, equals('query'));
    });

    test('should convert from string value', () {
      expect(SearchType.fromString('verse'), equals(SearchType.verse));
      expect(SearchType.fromString('chapter'), equals(SearchType.chapter));
      expect(SearchType.fromString('scenario'), equals(SearchType.scenario));
      expect(SearchType.fromString('query'), equals(SearchType.query));
    });

    test('should default to verse for invalid string', () {
      expect(SearchType.fromString('invalid'), equals(SearchType.verse));
      expect(SearchType.fromString(''), equals(SearchType.verse));
      expect(SearchType.fromString('unknown'), equals(SearchType.verse));
    });
  });

  group('SearchResult Constructor', () {
    test('should create with required fields', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'search-123',
        searchQuery: 'karma yoga',
        resultType: SearchType.verse,
        title: 'Verse 2.47',
        content: 'Your right is to work only',
        snippet: '...right is to work only...',
        relevanceScore: 0.95,
        searchDate: now,
      );

      expect(result.id, equals('search-123'));
      expect(result.searchQuery, equals('karma yoga'));
      expect(result.resultType, equals(SearchType.verse));
      expect(result.title, equals('Verse 2.47'));
      expect(result.content, equals('Your right is to work only'));
      expect(result.snippet, equals('...right is to work only...'));
      expect(result.relevanceScore, equals(0.95));
      expect(result.searchDate, equals(now));
    });

    test('should create with default values', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'test-id',
        searchQuery: 'test',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result.metadata, isEmpty);
      expect(result.chapterId, isNull);
      expect(result.verseId, isNull);
      expect(result.scenarioId, isNull);
    });

    test('should create with all optional fields', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'full-result',
        searchQuery: 'dharma',
        resultType: SearchType.verse,
        title: 'Dharma Verse',
        content: 'Full verse content about dharma',
        snippet: 'Highlighted dharma content',
        chapterId: 2,
        verseId: 7,
        scenarioId: null,
        relevanceScore: 0.98,
        searchDate: now,
        metadata: {'highlighted': true, 'cached': true},
      );

      expect(result.chapterId, equals(2));
      expect(result.verseId, equals(7));
      expect(result.scenarioId, isNull);
      expect(result.metadata, hasLength(2));
      expect(result.metadata['highlighted'], isTrue);
    });
  });

  group('JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30, 0);
      final result = SearchResult(
        id: 'json-test',
        searchQuery: 'karma',
        resultType: SearchType.verse,
        title: 'Karma Verse',
        content: 'Content about karma',
        snippet: 'Karma snippet',
        chapterId: 3,
        verseId: 15,
        relevanceScore: 0.87,
        searchDate: now,
        metadata: {'source': 'cache'},
      );

      final json = result.toJson();

      expect(json['id'], equals('json-test'));
      expect(json['search_query'], equals('karma'));
      expect(json['result_type'], equals('verse'));
      expect(json['title'], equals('Karma Verse'));
      expect(json['content'], equals('Content about karma'));
      expect(json['snippet'], equals('Karma snippet'));
      expect(json['chapter_id'], equals(3));
      expect(json['verse_id'], equals(15));
      expect(json['relevance_score'], equals(0.87));
      expect(json['search_date'], contains('2024-01-15'));
      expect(json['metadata'], equals({'source': 'cache'}));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'from-json',
        'search_query': 'yoga',
        'result_type': 'chapter',
        'title': 'Chapter 6',
        'content': 'Dhyana Yoga',
        'snippet': 'Meditation chapter',
        'chapter_id': 6,
        'relevance_score': 0.92,
        'search_date': '2024-01-15T14:30:00.000Z',
        'metadata': {'type': 'chapter'},
      };

      final result = SearchResult.fromJson(json);

      expect(result.id, equals('from-json'));
      expect(result.searchQuery, equals('yoga'));
      expect(result.resultType, equals(SearchType.chapter));
      expect(result.title, equals('Chapter 6'));
      expect(result.content, equals('Dhyana Yoga'));
      expect(result.snippet, equals('Meditation chapter'));
      expect(result.chapterId, equals(6));
      expect(result.relevanceScore, equals(0.92));
      expect(result.metadata, equals({'type': 'chapter'}));
    });

    test('should handle JSON roundtrip', () {
      final now = DateTime.now();
      final original = SearchResult(
        id: 'roundtrip',
        searchQuery: 'devotion',
        resultType: SearchType.scenario,
        title: 'Devotion Scenario',
        content: 'Scenario about bhakti',
        snippet: 'bhakti snippet',
        chapterId: 12,
        scenarioId: 456,
        relevanceScore: 0.85,
        searchDate: now,
        metadata: {'lang': 'en'},
      );

      final json = original.toJson();
      final restored = SearchResult.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.searchQuery, equals(original.searchQuery));
      expect(restored.resultType, equals(original.resultType));
      expect(restored.title, equals(original.title));
      expect(restored.content, equals(original.content));
      expect(restored.snippet, equals(original.snippet));
      expect(restored.chapterId, equals(original.chapterId));
      expect(restored.scenarioId, equals(original.scenarioId));
      expect(restored.relevanceScore, equals(original.relevanceScore));
      expect(restored.metadata, equals(original.metadata));
    });

    test('should handle null optional fields in serialization', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'minimal',
        searchQuery: 'test',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      final json = result.toJson();

      expect(json['id'], equals('minimal'));
      expect(json.containsKey('chapter_id'), isFalse);
      expect(json.containsKey('verse_id'), isFalse);
      expect(json.containsKey('scenario_id'), isFalse);
      expect(json['metadata'], isEmpty);
    });

    test('should handle null optional fields in deserialization', () {
      final json = {
        'id': 'minimal-from-json',
        'title': 'Test',
        'content': 'Content',
      };

      final result = SearchResult.fromJson(json);

      expect(result.id, equals('minimal-from-json'));
      expect(result.searchQuery, equals(''));
      expect(result.resultType, equals(SearchType.verse));
      expect(result.snippet, equals(''));
      expect(result.chapterId, isNull);
      expect(result.verseId, isNull);
      expect(result.scenarioId, isNull);
      expect(result.relevanceScore, equals(0.0));
      expect(result.metadata, isEmpty);
    });

    test('should handle various date formats', () {
      final dates = [
        '2024-01-15T10:30:00.000Z',
        '2024-12-31T23:59:59.999Z',
        DateTime.now().toIso8601String(),
      ];

      for (final dateStr in dates) {
        final json = {
          'id': 'date-test',
          'title': 'Test',
          'content': 'Content',
          'search_date': dateStr,
        };

        final result = SearchResult.fromJson(json);
        expect(result.searchDate, isA<DateTime>());
      }
    });
  });

  group('Search Result Types', () {
    test('should support verse search results', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'verse-result',
        searchQuery: 'karma',
        resultType: SearchType.verse,
        title: 'BG 2.47',
        content: 'Your right is to perform your duty only',
        snippet: '...perform your duty only...',
        chapterId: 2,
        verseId: 47,
        relevanceScore: 0.95,
        searchDate: now,
      );

      expect(result.resultType, equals(SearchType.verse));
      expect(result.chapterId, equals(2));
      expect(result.verseId, equals(47));
      expect(result.scenarioId, isNull);
    });

    test('should support chapter search results', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'chapter-result',
        searchQuery: 'yoga',
        resultType: SearchType.chapter,
        title: 'Chapter 6: Dhyana Yoga',
        content: 'The Yoga of Meditation',
        snippet: 'Meditation and self-control',
        chapterId: 6,
        relevanceScore: 0.90,
        searchDate: now,
      );

      expect(result.resultType, equals(SearchType.chapter));
      expect(result.chapterId, equals(6));
      expect(result.verseId, isNull);
      expect(result.scenarioId, isNull);
    });

    test('should support scenario search results', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'scenario-result',
        searchQuery: 'career decision',
        resultType: SearchType.scenario,
        title: 'Career Change Dilemma',
        content: 'Should I change my job?',
        snippet: 'job change decision',
        chapterId: 3,
        scenarioId: 789,
        relevanceScore: 0.88,
        searchDate: now,
      );

      expect(result.resultType, equals(SearchType.scenario));
      expect(result.chapterId, equals(3));
      expect(result.scenarioId, equals(789));
      expect(result.verseId, isNull);
    });

    test('should support query search results', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'query-result',
        searchQuery: 'dharma duty',
        resultType: SearchType.query,
        title: 'Search Results for "dharma duty"',
        content: 'Multiple results found',
        snippet: 'dharma and duty explained',
        relevanceScore: 0.75,
        searchDate: now,
      );

      expect(result.resultType, equals(SearchType.query));
      expect(result.chapterId, isNull);
      expect(result.verseId, isNull);
      expect(result.scenarioId, isNull);
    });
  });

  group('Relevance Score', () {
    test('should accept valid relevance scores', () {
      final now = DateTime.now();
      final scores = [0.0, 0.25, 0.5, 0.75, 1.0, 0.9999];

      for (final score in scores) {
        final result = SearchResult(
          id: 'score-test',
          searchQuery: 'test',
          resultType: SearchType.verse,
          title: 'Test',
          content: 'Content',
          snippet: 'Snippet',
          relevanceScore: score,
          searchDate: now,
        );

        expect(result.relevanceScore, equals(score));
      }
    });

    test('should handle edge case relevance scores', () {
      final now = DateTime.now();

      final highScore = SearchResult(
        id: 'high',
        searchQuery: 'exact match',
        resultType: SearchType.verse,
        title: 'Exact Match',
        content: 'Perfect match',
        snippet: 'match',
        relevanceScore: 1.0,
        searchDate: now,
      );

      final lowScore = SearchResult(
        id: 'low',
        searchQuery: 'vague query',
        resultType: SearchType.verse,
        title: 'Weak Match',
        content: 'Barely relevant',
        snippet: 'weak',
        relevanceScore: 0.0,
        searchDate: now,
      );

      expect(highScore.relevanceScore, equals(1.0));
      expect(lowScore.relevanceScore, equals(0.0));
    });
  });

  group('Metadata Handling', () {
    test('should support various metadata types', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'metadata-test',
        searchQuery: 'test',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
        metadata: {
          'highlighted': true,
          'cached': false,
          'language': 'en',
          'translation_available': ['hi', 'es'],
          'word_count': 42,
        },
      );

      expect(result.metadata['highlighted'], isTrue);
      expect(result.metadata['cached'], isFalse);
      expect(result.metadata['language'], equals('en'));
      expect(result.metadata['translation_available'], isA<List>());
      expect(result.metadata['word_count'], equals(42));
    });

    test('should handle empty metadata', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'empty-meta',
        searchQuery: 'test',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result.metadata, isEmpty);
    });
  });

  group('Equality and HashCode', () {
    test('should be equal for same id, query, and type', () {
      final now = DateTime.now();
      final result1 = SearchResult(
        id: 'same-id',
        searchQuery: 'same query',
        resultType: SearchType.verse,
        title: 'Title 1',
        content: 'Content 1',
        snippet: 'Snippet 1',
        relevanceScore: 0.5,
        searchDate: now,
      );

      final result2 = SearchResult(
        id: 'same-id',
        searchQuery: 'same query',
        resultType: SearchType.verse,
        title: 'Title 2',
        content: 'Content 2',
        snippet: 'Snippet 2',
        relevanceScore: 0.7,
        searchDate: now,
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('should not be equal for different ids', () {
      final now = DateTime.now();
      final result1 = SearchResult(
        id: 'id-1',
        searchQuery: 'query',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      final result2 = SearchResult(
        id: 'id-2',
        searchQuery: 'query',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result1, isNot(equals(result2)));
    });

    test('should not be equal for different search queries', () {
      final now = DateTime.now();
      final result1 = SearchResult(
        id: 'same-id',
        searchQuery: 'query1',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      final result2 = SearchResult(
        id: 'same-id',
        searchQuery: 'query2',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result1, isNot(equals(result2)));
    });

    test('should not be equal for different result types', () {
      final now = DateTime.now();
      final result1 = SearchResult(
        id: 'same-id',
        searchQuery: 'query',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      final result2 = SearchResult(
        id: 'same-id',
        searchQuery: 'query',
        resultType: SearchType.chapter,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result1, isNot(equals(result2)));
    });
  });

  group('toString Method', () {
    test('should provide meaningful string representation', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'test-123',
        searchQuery: 'karma yoga',
        resultType: SearchType.verse,
        title: 'BG 3.5',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.95,
        searchDate: now,
      );

      final str = result.toString();

      expect(str, contains('test-123'));
      expect(str, contains('karma yoga'));
      expect(str, contains('verse'));
      expect(str, contains('BG 3.5'));
    });
  });

  group('Edge Cases and Validation', () {
    test('should handle very long search query', () {
      final now = DateTime.now();
      final longQuery = 'karma ' * 1000;
      final result = SearchResult(
        id: 'long-query',
        searchQuery: longQuery,
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result.searchQuery.length, greaterThan(5000));
    });

    test('should handle very long content', () {
      final now = DateTime.now();
      final longContent = 'A' * 50000;
      final result = SearchResult(
        id: 'long-content',
        searchQuery: 'test',
        resultType: SearchType.verse,
        title: 'Test',
        content: longContent,
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result.content.length, equals(50000));
    });

    test('should handle special characters', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'special-chars',
        searchQuery: 'karma "yoga" & dharma',
        resultType: SearchType.verse,
        title: 'Test with "quotes"',
        content: 'Content with (parentheses) and [brackets]',
        snippet: 'Snippet with @#\$%',
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result.searchQuery, contains('"'));
      expect(result.title, contains('"'));
      expect(result.content, contains('('));
      expect(result.snippet, contains('@'));
    });

    test('should handle Unicode characters', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'unicode-test',
        searchQuery: 'कर्म योग',
        resultType: SearchType.verse,
        title: 'भगवद् गीता २.४७',
        content: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन',
        snippet: 'कर्मण्येवाधिकारस्ते',
        relevanceScore: 0.98,
        searchDate: now,
      );

      expect(result.searchQuery, contains('कर्म'));
      expect(result.title, contains('गीता'));
      expect(result.content, contains('कर्मण्येवाधिकारस्ते'));
    });

    test('should handle all valid chapter IDs 1-18', () {
      final now = DateTime.now();
      for (int chapterId = 1; chapterId <= 18; chapterId++) {
        final result = SearchResult(
          id: 'chapter-$chapterId',
          searchQuery: 'test',
          resultType: SearchType.chapter,
          title: 'Chapter $chapterId',
          content: 'Content',
          snippet: 'Snippet',
          chapterId: chapterId,
          relevanceScore: 0.5,
          searchDate: now,
        );

        expect(result.chapterId, equals(chapterId));
      }
    });

    test('should handle large verse IDs', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'large-verse',
        searchQuery: 'test',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        chapterId: 11,
        verseId: 55,
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result.verseId, equals(55));
    });

    test('should handle large scenario IDs', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'large-scenario',
        searchQuery: 'test',
        resultType: SearchType.scenario,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        scenarioId: 999999,
        relevanceScore: 0.5,
        searchDate: now,
      );

      expect(result.scenarioId, equals(999999));
    });

    test('should handle empty strings gracefully', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'empty-test',
        searchQuery: '',
        resultType: SearchType.verse,
        title: '',
        content: '',
        snippet: '',
        relevanceScore: 0.0,
        searchDate: now,
      );

      expect(result.searchQuery, equals(''));
      expect(result.title, equals(''));
      expect(result.content, equals(''));
      expect(result.snippet, equals(''));
    });

    test('should handle complex metadata structures', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'complex-meta',
        searchQuery: 'test',
        resultType: SearchType.verse,
        title: 'Test',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.5,
        searchDate: now,
        metadata: {
          'nested': {
            'level1': {
              'level2': 'deep value'
            }
          },
          'list': [1, 2, 3],
          'mixed': ['a', 1, true],
        },
      );

      expect(result.metadata['nested'], isA<Map>());
      expect(result.metadata['list'], isA<List>());
      expect(result.metadata['mixed'], hasLength(3));
    });
  });

  group('Search Query Patterns', () {
    test('should handle single word queries', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'single-word',
        searchQuery: 'karma',
        resultType: SearchType.verse,
        title: 'Karma Verse',
        content: 'About karma',
        snippet: 'karma',
        relevanceScore: 0.9,
        searchDate: now,
      );

      expect(result.searchQuery, equals('karma'));
    });

    test('should handle multi-word queries', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'multi-word',
        searchQuery: 'karma yoga meditation',
        resultType: SearchType.verse,
        title: 'Multi Word Result',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.85,
        searchDate: now,
      );

      expect(result.searchQuery, contains('karma'));
      expect(result.searchQuery, contains('yoga'));
      expect(result.searchQuery, contains('meditation'));
    });

    test('should handle phrase queries', () {
      final now = DateTime.now();
      final result = SearchResult(
        id: 'phrase-query',
        searchQuery: '"right to work only"',
        resultType: SearchType.verse,
        title: 'Phrase Match',
        content: 'Content',
        snippet: 'Snippet',
        relevanceScore: 0.95,
        searchDate: now,
      );

      expect(result.searchQuery, equals('"right to work only"'));
    });
  });
}
