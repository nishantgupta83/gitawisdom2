// lib/services/search_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/search_result.dart';

/// Advanced search service with full-text search capabilities
class SearchService extends ChangeNotifier {
  static const String _boxName = 'search_cache';
  static const String _tableSearch = 'content_search_index';
  static const String _tableVerses = 'gita_verses';
  static const String _tableChapters = 'chapters';
  static const String _tableScenarios = 'scenarios';
  
  Box<SearchResult>? _searchBox;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<SearchResult> _recentSearches = [];
  List<SearchResult> _currentResults = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = false;
  String? _error;
  String _lastQuery = '';

  // Getters
  List<SearchResult> get recentSearches => List.unmodifiable(_recentSearches);
  List<SearchResult> get currentResults => List.unmodifiable(_currentResults);
  List<String> get searchSuggestions => List.unmodifiable(_searchSuggestions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastQuery => _lastQuery;

  /// Initialize the search service
  Future<void> initialize() async {
    try {
      _searchBox = await Hive.openBox<SearchResult>(_boxName);
      await _loadRecentSearches();
      await _loadSearchSuggestions();
    } catch (e) {
      _error = 'Failed to initialize search: $e';
      if (kDebugMode) print('SearchService initialization error: $e');
      notifyListeners();
    }
  }

  /// Load recent searches from local storage
  Future<void> _loadRecentSearches() async {
    if (_searchBox == null) return;
    
    _recentSearches = _searchBox!.values
        .where((result) => result.searchQuery.isNotEmpty)
        .toList();
    
    // Sort by search date, most recent first
    _recentSearches.sort((a, b) => b.searchDate.compareTo(a.searchDate));
    
    // Keep only last 50 searches
    if (_recentSearches.length > 50) {
      _recentSearches = _recentSearches.take(50).toList();
    }
    
    notifyListeners();
  }

  /// Load search suggestions for autocomplete
  Future<void> _loadSearchSuggestions() async {
    try {
      // Load popular search terms and key concepts from verses
      final suggestions = <String>[];
      
      // Add common Gita concepts
      suggestions.addAll([
        'dharma', 'karma', 'moksha', 'bhakti', 'yoga',
        'arjuna', 'krishna', 'duty', 'righteousness', 'devotion',
        'meditation', 'wisdom', 'action', 'surrender', 'truth',
        'soul', 'consciousness', 'peace', 'love', 'detachment',
        'sacrifice', 'knowledge', 'discipline', 'faith', 'purpose'
      ]);
      
      // Add chapter-specific terms
      for (int i = 1; i <= 18; i++) {
        suggestions.add('chapter $i');
      }
      
      _searchSuggestions = suggestions;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Failed to load search suggestions: $e');
    }
  }

  /// Perform full-text search across all content
  Future<List<SearchResult>> search(String query, {
    List<SearchType> types = const [
      SearchType.verse,
      SearchType.chapter,
      SearchType.scenario,
    ],
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      _currentResults = [];
      notifyListeners();
      return [];
    }

    _setLoading(true);
    _lastQuery = query;
    
    try {
      final results = <SearchResult>[];
      
      // Search in parallel for better performance
      final futures = <Future<List<SearchResult>>>[];
      
      if (types.contains(SearchType.verse)) {
        futures.add(_searchVerses(query, limit: limit ~/ types.length));
      }
      if (types.contains(SearchType.chapter)) {
        futures.add(_searchChapters(query, limit: limit ~/ types.length));
      }
      if (types.contains(SearchType.scenario)) {
        futures.add(_searchScenarios(query, limit: limit ~/ types.length));
      }
      
      final searchResults = await Future.wait(futures);
      for (final resultList in searchResults) {
        results.addAll(resultList);
      }
      
      // Sort by relevance score
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      
      // Limit total results
      final limitedResults = results.take(limit).toList();
      
      // Save search query for recent searches
      await _saveSearchQuery(query, limitedResults.length);
      
      _currentResults = limitedResults;
      _error = null;
      _setLoading(false);
      
      return limitedResults;
    } catch (e) {
      _error = 'Search failed: $e';
      _setLoading(false);
      if (kDebugMode) print('Search error: $e');
      return [];
    }
  }

  /// Search within verses using full-text search
  Future<List<SearchResult>> _searchVerses(String query, {int limit = 20}) async {
    try {
      // Use PostgreSQL full-text search with ranking
      final response = await _supabase
          .from(_tableVerses)
          .select('verse_id, chapter_id, description, translation')
          .textSearch('fts', query, config: 'english')
          .order('verse_id')
          .limit(limit);

      final results = <SearchResult>[];
      
      for (final row in response) {
        final content = row['description'] as String? ?? '';
        final translation = row['translation'] as String? ?? '';
        final combinedText = '$content $translation';
        
        final relevanceScore = _calculateRelevanceScore(query, combinedText);
        final snippet = _generateSnippet(combinedText, query);
        
        results.add(SearchResult(
          id: 'verse_${row['verse_id']}',
          searchQuery: query,
          resultType: SearchType.verse,
          title: 'Verse ${row['verse_id']}',
          content: combinedText,
          snippet: snippet,
          chapterId: row['chapter_id'] as int,
          verseId: row['verse_id'] as int,
          relevanceScore: relevanceScore,
          searchDate: DateTime.now(),
          metadata: {
            'chapter_id': row['chapter_id'],
            'verse_id': row['verse_id'],
          },
        ));
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) print('Verse search error: $e');
      return [];
    }
  }

  /// Search within chapters
  Future<List<SearchResult>> _searchChapters(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from(_tableChapters)
          .select('chapter_id, title, description, summary')
          .or('title.ilike.%$query%,description.ilike.%$query%,summary.ilike.%$query%')
          .order('chapter_id')
          .limit(limit);

      final results = <SearchResult>[];
      
      for (final row in response) {
        final title = row['title'] as String? ?? '';
        final description = row['description'] as String? ?? '';
        final summary = row['summary'] as String? ?? '';
        final combinedText = '$title $description $summary';
        
        final relevanceScore = _calculateRelevanceScore(query, combinedText);
        final snippet = _generateSnippet(combinedText, query);
        
        results.add(SearchResult(
          id: 'chapter_${row['chapter_id']}',
          searchQuery: query,
          resultType: SearchType.chapter,
          title: title,
          content: combinedText,
          snippet: snippet,
          chapterId: row['chapter_id'] as int,
          relevanceScore: relevanceScore,
          searchDate: DateTime.now(),
          metadata: {
            'chapter_id': row['chapter_id'],
            'description': description,
            'summary': summary,
          },
        ));
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) print('Chapter search error: $e');
      return [];
    }
  }

  /// Search within scenarios
  Future<List<SearchResult>> _searchScenarios(String query, {int limit = 15}) async {
    try {
      final response = await _supabase
          .from(_tableScenarios)
          .select('scenario_id, title, description, heart_response, duty_response, gita_wisdom')
          .or('title.ilike.%$query%,description.ilike.%$query%,heart_response.ilike.%$query%,duty_response.ilike.%$query%,gita_wisdom.ilike.%$query%')
          .order('scenario_id')
          .limit(limit);

      final results = <SearchResult>[];
      
      for (final row in response) {
        final title = row['title'] as String? ?? '';
        final description = row['description'] as String? ?? '';
        final heartResponse = row['heart_response'] as String? ?? '';
        final dutyResponse = row['duty_response'] as String? ?? '';
        final gitaWisdom = row['gita_wisdom'] as String? ?? '';
        final combinedText = '$title $description $heartResponse $dutyResponse $gitaWisdom';
        
        final relevanceScore = _calculateRelevanceScore(query, combinedText);
        final snippet = _generateSnippet(combinedText, query);
        
        results.add(SearchResult(
          id: 'scenario_${row['scenario_id']}',
          searchQuery: query,
          resultType: SearchType.scenario,
          title: title,
          content: combinedText,
          snippet: snippet,
          scenarioId: row['scenario_id'] as int,
          relevanceScore: relevanceScore,
          searchDate: DateTime.now(),
          metadata: {
            'scenario_id': row['scenario_id'],
            'description': description,
            'heart_response': heartResponse,
            'duty_response': dutyResponse,
            'gita_wisdom': gitaWisdom,
          },
        ));
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) print('Scenario search error: $e');
      return [];
    }
  }

  /// Calculate relevance score based on query match
  double _calculateRelevanceScore(String query, String content) {
    if (content.isEmpty) return 0.0;
    
    final queryLower = query.toLowerCase();
    final contentLower = content.toLowerCase();
    final queryWords = queryLower.split(RegExp(r'\s+'));
    
    double score = 0.0;
    
    // Exact phrase match gets highest score
    if (contentLower.contains(queryLower)) {
      score += 100.0;
    }
    
    // Individual word matches
    for (final word in queryWords) {
      if (word.length < 2) continue;
      
      final wordCount = RegExp(r'\b' + RegExp.escape(word) + r'\b')
          .allMatches(contentLower)
          .length;
      score += wordCount * 10.0;
    }
    
    // Boost score based on content length (shorter content with matches is more relevant)
    if (score > 0) {
      final lengthPenalty = content.length / 1000.0;
      score = score / (1 + lengthPenalty);
    }
    
    return score;
  }

  /// Generate snippet with highlighted query terms
  String _generateSnippet(String content, String query, {int maxLength = 200}) {
    if (content.length <= maxLength) return content;
    
    final queryLower = query.toLowerCase();
    final contentLower = content.toLowerCase();
    
    // Find the best position to start the snippet
    final queryIndex = contentLower.indexOf(queryLower);
    int startIndex = 0;
    
    if (queryIndex >= 0) {
      // Center the snippet around the query match
      startIndex = (queryIndex - maxLength ~/ 2).clamp(0, content.length - maxLength);
    }
    
    final snippet = content.substring(startIndex, (startIndex + maxLength).clamp(0, content.length));
    
    // Add ellipsis if needed
    return (startIndex > 0 ? '...' : '') + 
           snippet + 
           (startIndex + maxLength < content.length ? '...' : '');
  }

  /// Save search query to recent searches
  Future<void> _saveSearchQuery(String query, int resultCount) async {
    if (_searchBox == null || query.trim().isEmpty) return;
    
    try {
      final searchResult = SearchResult(
        id: 'search_${DateTime.now().millisecondsSinceEpoch}',
        searchQuery: query,
        resultType: SearchType.query,
        title: query,
        content: 'Search query',
        snippet: '$resultCount results',
        relevanceScore: 0.0,
        searchDate: DateTime.now(),
        metadata: {'result_count': resultCount},
      );
      
      await _searchBox!.put(searchResult.id, searchResult);
      await _loadRecentSearches();
    } catch (e) {
      if (kDebugMode) print('Failed to save search query: $e');
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _searchBox?.clear();
      _recentSearches = [];
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Failed to clear recent searches: $e');
    }
  }

  /// Get search suggestions based on partial query
  List<String> getSuggestions(String partialQuery) {
    if (partialQuery.trim().isEmpty) return [];
    
    final query = partialQuery.toLowerCase();
    return _searchSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .take(10)
        .toList();
  }

  /// Get filtered results by type
  List<SearchResult> getResultsByType(SearchType type) {
    return _currentResults.where((result) => result.resultType == type).toList();
  }

  /// Clear current search results
  void clearResults() {
    _currentResults = [];
    _lastQuery = '';
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchBox?.close();
    super.dispose();
  }
}