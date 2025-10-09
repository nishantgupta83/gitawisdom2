import 'package:flutter/foundation.dart';

import '../models/scenario.dart';
import 'keyword_search_service.dart';
import 'enhanced_semantic_search_service.dart';
import 'progressive_scenario_service.dart';


class IntelligentSearchResult {
  final Scenario scenario;
  final double score;
  final List<String>? matchedTerms;
  final String searchType;

  IntelligentSearchResult({
    required this.scenario,
    required this.score,
    this.matchedTerms,
    required this.searchType,
  });
}

class IntelligentScenarioSearch {
  static final IntelligentScenarioSearch instance = IntelligentScenarioSearch._();
  IntelligentScenarioSearch._();

  final KeywordSearchService _keywordService = KeywordSearchService.instance;
  final EnhancedSemanticSearchService _semanticService = EnhancedSemanticSearchService.instance;
  final ProgressiveScenarioService _scenarioService = ProgressiveScenarioService.instance;

  bool _isInitialized = false;
  DateTime? _lastRefresh;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔍 Intelligent search already initialized');
      return;
    }

    // Start initialization in background to prevent main thread blocking
    _initializeInBackground();
  }

  /// Initialize search system in background isolate to prevent frame drops
  void _initializeInBackground() async {
    final stopwatch = Stopwatch()..start();
    debugPrint('🔍 Starting intelligent search initialization in background...');

    try {
      // Wait for critical scenarios without blocking UI
      await _scenarioService.waitForCriticalScenarios();

      final scenarios = await _getAllScenarios();
      if (scenarios.isEmpty) {
        debugPrint('⚠️ No scenarios available for indexing');
        return;
      }

      // Initialize search services - will optimize with Supabase indexing later
      await Future.wait([
        _keywordService.indexScenarios(scenarios),
        _semanticService.initialize(scenarios).catchError((e) {
          debugPrint('⚠️ Semantic search unavailable (will use keyword-only): $e');
        }),
      ]);

      _isInitialized = true;
      _lastRefresh = DateTime.now();
      stopwatch.stop();

      debugPrint('✅ Intelligent search initialized in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 Index stats: ${scenarios.length} scenarios, keyword=${_keywordService.isIndexed}, semantic=${_semanticService.isInitialized}');
    } catch (e) {
      debugPrint('❌ Failed to initialize intelligent search: $e');
    }
  }


  Future<List<IntelligentSearchResult>> search(String query, {int maxResults = 10}) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Intelligent search not initialized yet');
      await initialize();
    }

    if (query.trim().isEmpty) {
      return [];
    }

    final stopwatch = Stopwatch()..start();

    try {
      // ALWAYS use AI semantic search for best results
      if (_semanticService.isInitialized) {
        debugPrint('🧠 Using AI semantic search...');

        // Run keyword search in parallel to boost matching results
        final keywordResults = _keywordService.search(query, maxResults: maxResults * 2);
        final semanticResults = await _semanticService.search(query, maxResults: maxResults);

        if (semanticResults.isNotEmpty) {
          // Combine AI results with keyword boosting for best accuracy
          final combined = _combineResults(keywordResults, semanticResults, maxResults);
          stopwatch.stop();
          debugPrint('✅ AI-powered hybrid search: ${combined.length} results in ${stopwatch.elapsedMilliseconds}ms');
          return combined;
        } else {
          // If AI returns no results, use keyword search as fallback
          debugPrint('⚠️ AI search returned no results, using keyword fallback');
          stopwatch.stop();
          final keywordOnly = _convertKeywordResults(keywordResults, maxResults);
          debugPrint('✅ Keyword fallback: ${keywordOnly.length} results in ${stopwatch.elapsedMilliseconds}ms');
          return keywordOnly;
        }
      } else {
        // AI not initialized yet - use keyword search only
        debugPrint('⚠️ AI semantic search not initialized, using keyword search');
        final keywordResults = _keywordService.search(query, maxResults: maxResults * 2);

        if (keywordResults.isEmpty) {
          // Try broader keyword search if no results
          debugPrint('🔍 Trying broader keyword search...');
          final broaderResults = await _tryBroaderSearch(query, maxResults);
          if (broaderResults.isNotEmpty) {
            stopwatch.stop();
            debugPrint('✅ Broader search: ${broaderResults.length} results in ${stopwatch.elapsedMilliseconds}ms');
            return broaderResults;
          }
        }

        stopwatch.stop();
        final keywordOnly = _convertKeywordResults(keywordResults, maxResults);
        debugPrint('✅ Keyword-only search: ${keywordOnly.length} results in ${stopwatch.elapsedMilliseconds}ms');
        return keywordOnly;
      }

    } catch (e) {
      debugPrint('❌ Search failed: $e');
      return [];
    }
  }

  bool _hasHighQualityMatches(List<SearchResult> results) {
    if (results.isEmpty) return false;
    // More reasonable quality threshold: accept results with any decent score
    return results.first.score > 0.1 || results.length >= 2;
  }

  List<IntelligentSearchResult> _convertKeywordResults(
    List<SearchResult> keywordResults,
    int maxResults,
  ) {
    return keywordResults.take(maxResults).map((r) {
      return IntelligentSearchResult(
        scenario: r.scenario,
        score: r.score,
        matchedTerms: r.matchedTerms,
        searchType: 'keyword',
      );
    }).toList();
  }

  List<IntelligentSearchResult> _combineResults(
    List<SearchResult> keywordResults,
    List<SemanticSearchResult> semanticResults,
    int maxResults,
  ) {
    final combined = <String, IntelligentSearchResult>{};

    for (final result in keywordResults) {
      final id = _getScenarioId(result.scenario);
      combined[id] = IntelligentSearchResult(
        scenario: result.scenario,
        score: result.score * 0.6,
        matchedTerms: result.matchedTerms,
        searchType: 'keyword',
      );
    }

    for (final result in semanticResults) {
      final id = _getScenarioId(result.scenario);
      final semanticScore = result.similarity * 10.0;

      if (combined.containsKey(id)) {
        final existingScore = combined[id]!.score;
        final combinedMatchedTerms = [
          ...(combined[id]!.matchedTerms ?? []),
          ...(result.matchedTerms ?? []),
        ].cast<String>().toSet().toList();

        combined[id] = IntelligentSearchResult(
          scenario: result.scenario,
          score: existingScore + semanticScore * 0.4,
          matchedTerms: combinedMatchedTerms.cast<String>(),
          searchType: 'hybrid',
        );
      } else {
        combined[id] = IntelligentSearchResult(
          scenario: result.scenario,
          score: semanticScore,
          matchedTerms: result.matchedTerms,
          searchType: 'semantic',
        );
      }
    }

    final sortedResults = combined.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return sortedResults.take(maxResults).toList();
  }

  Future<List<Scenario>> _getAllScenarios() async {
    try {
      return await _scenarioService.searchScenariosAsync('', maxResults: 2000);
    } catch (e) {
      debugPrint('❌ Failed to fetch scenarios: $e');
      return [];
    }
  }

  /// Try broader search with relaxed matching when no results found
  Future<List<IntelligentSearchResult>> _tryBroaderSearch(String query, int maxResults) async {
    try {
      // Get all scenarios and try category-based matching
      final allScenarios = _scenarioService.searchScenarios('');
      if (allScenarios.isEmpty) return [];

      final queryLower = query.toLowerCase();
      final results = <IntelligentSearchResult>[];

      // Check if query matches common categories or concepts
      for (final scenario in allScenarios.take(maxResults * 5)) {
        double score = 0.0;
        final matchedTerms = <String>[];

        // Category matching
        if (scenario.category.toLowerCase().contains(queryLower)) {
          score += 2.0;
          matchedTerms.add(scenario.category);
        }

        // Title partial matching
        if (scenario.title.toLowerCase().contains(queryLower)) {
          score += 1.5;
          matchedTerms.add('title');
        }

        // Description partial matching
        if (scenario.description.toLowerCase().contains(queryLower)) {
          score += 1.0;
          matchedTerms.add('description');
        }

        // Chapter-based matching for numbers
        if (queryLower.contains(RegExp(r'\d+')) &&
            scenario.chapter.toString().contains(queryLower)) {
          score += 0.5;
          matchedTerms.add('chapter');
        }

        if (score > 0) {
          results.add(IntelligentSearchResult(
            scenario: scenario,
            score: score,
            matchedTerms: matchedTerms,
            searchType: 'fuzzy',
          ));
        }
      }

      // Sort and return top results
      results.sort((a, b) => b.score.compareTo(a.score));
      return results.take(maxResults).toList();
    } catch (e) {
      debugPrint('❌ Broader search failed: $e');
      return [];
    }
  }

  String _getScenarioId(Scenario scenario) {
    return '${scenario.chapter}_${scenario.title}_${scenario.createdAt.millisecondsSinceEpoch}';
  }

  Future<void> refreshMonthly() async {
    if (_lastRefresh != null) {
      final daysSinceRefresh = DateTime.now().difference(_lastRefresh!).inDays;
      if (daysSinceRefresh < 30) {
        debugPrint('📅 Last refresh was $daysSinceRefresh days ago - skipping monthly refresh');
        return;
      }
    }

    debugPrint('🔄 Performing monthly scenario refresh...');

    try {
      await _scenarioService.refreshFromServer();

      final scenarios = await _getAllScenarios();
      await Future.wait([
        _keywordService.indexScenarios(scenarios),
        _semanticService.initialize(scenarios).catchError((e) {
          debugPrint('⚠️ Semantic search refresh failed: $e');
        }),
      ]);

      _lastRefresh = DateTime.now();
      debugPrint('✅ Monthly refresh completed - ${scenarios.length} scenarios indexed');
    } catch (e) {
      debugPrint('❌ Monthly refresh failed: $e');
    }
  }

  bool get isInitialized => _isInitialized;
  DateTime? get lastRefresh => _lastRefresh;
}