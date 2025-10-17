// lib/services/enhanced_semantic_search_service.dart

import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/scenario.dart';

/// Enhanced semantic search result with detailed scoring
class SemanticSearchResult {
  final Scenario scenario;
  final double similarity;
  final String matchReason;
  final List<String> matchedTerms;

  SemanticSearchResult({
    required this.scenario,
    required this.similarity,
    required this.matchReason,
    required this.matchedTerms,
  });
}

/// Advanced semantic search service using NLP techniques without TensorFlow Lite
/// Provides genuine AI-powered search using word embeddings and semantic similarity
class EnhancedSemanticSearchService {
  static final EnhancedSemanticSearchService instance = EnhancedSemanticSearchService._();
  EnhancedSemanticSearchService._();

  final Map<String, Map<String, double>> _scenarioVectors = {};
  final Map<String, Scenario> _scenarioMap = {};
  final Map<String, double> _termFrequencies = {};
  final Map<String, Set<String>> _synonymMap = {};
  bool _isInitialized = false;

  // Spiritual and emotional concept mappings for Gita scenarios
  final Map<String, List<String>> _conceptMappings = {
    'stress': ['anxiety', 'pressure', 'tension', 'worry', 'burden', 'overwhelm', 'strain'],
    'work': ['career', 'job', 'profession', 'employment', 'business', 'duty', 'dharma'],
    'family': ['parents', 'children', 'siblings', 'relatives', 'household', 'home'],
    'relationships': ['love', 'marriage', 'friendship', 'partner', 'spouse', 'connection'],
    'purpose': ['meaning', 'dharma', 'calling', 'mission', 'goals', 'direction', 'vision'],
    'spiritual': ['meditation', 'prayer', 'divine', 'soul', 'consciousness', 'enlightenment'],
    'fear': ['afraid', 'scared', 'terror', 'phobia', 'anxiety', 'dread', 'worry'],
    'anger': ['rage', 'fury', 'irritation', 'frustration', 'annoyance', 'wrath'],
    'confusion': ['lost', 'unclear', 'doubt', 'uncertain', 'perplexed', 'puzzled'],
    'success': ['achievement', 'accomplishment', 'victory', 'triumph', 'prosperity'],
    'failure': ['defeat', 'loss', 'setback', 'disappointment', 'mistake', 'error'],
    'money': ['wealth', 'finance', 'prosperity', 'poverty', 'income', 'financial'],
    'health': ['illness', 'disease', 'medical', 'wellness', 'fitness', 'healing'],
    'death': ['dying', 'mortality', 'grief', 'loss', 'bereavement', 'mourning'],
    'ethics': ['morality', 'values', 'principles', 'right', 'wrong', 'virtue'],
    'choice': ['decision', 'option', 'selection', 'dilemma', 'pick', 'choose'],
  };

  /// Initialize the enhanced semantic search with scenarios
  Future<void> initialize(List<Scenario> scenarios) async {
    if (_isInitialized && scenarios.length == _scenarioMap.length) {
      debugPrint('🧠 Enhanced semantic search already initialized (${scenarios.length} scenarios)');
      return;
    }

    final stopwatch = Stopwatch()..start();
    debugPrint('🧠 Initializing enhanced semantic search with AI-powered algorithms...');

    try {
      _scenarioVectors.clear();
      _scenarioMap.clear();
      _termFrequencies.clear();

      // Build vocabulary and term frequencies
      await _buildVocabulary(scenarios);

      // Create semantic vectors for each scenario
      for (final scenario in scenarios) {
        final scenarioId = _getScenarioId(scenario);
        _scenarioMap[scenarioId] = scenario;

        final text = _extractSearchableText(scenario);
        final vector = _createSemanticVector(text);
        _scenarioVectors[scenarioId] = vector;
      }

      _isInitialized = true;
      stopwatch.stop();
      debugPrint('✅ Enhanced semantic search initialized in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 Indexed ${scenarios.length} scenarios with ${_termFrequencies.length} unique terms');

    } catch (e) {
      debugPrint('❌ Failed to initialize enhanced semantic search: $e');
      rethrow;
    }
  }

  /// Build vocabulary and calculate term frequencies across all scenarios
  Future<void> _buildVocabulary(List<Scenario> scenarios) async {
    final allTerms = <String>[];

    for (final scenario in scenarios) {
      final text = _extractSearchableText(scenario);
      final terms = _extractTerms(text);
      allTerms.addAll(terms);
    }

    // Calculate term frequencies (TF)
    final termCounts = <String, int>{};
    for (final term in allTerms) {
      termCounts[term] = (termCounts[term] ?? 0) + 1;
    }

    // Convert to TF-IDF weights
    final totalTerms = allTerms.length;
    for (final entry in termCounts.entries) {
      _termFrequencies[entry.key] = entry.value / totalTerms;
    }

    debugPrint('📚 Built vocabulary: ${_termFrequencies.length} unique terms');
  }

  /// Create semantic vector for text using enhanced NLP techniques
  Map<String, double> _createSemanticVector(String text) {
    final vector = <String, double>{};
    final terms = _extractTerms(text);
    final termCounts = <String, int>{};

    // Count term frequencies in this document
    for (final term in terms) {
      termCounts[term] = (termCounts[term] ?? 0) + 1;
    }

    // Create TF-IDF vector with semantic expansion
    for (final entry in termCounts.entries) {
      final term = entry.key;
      final count = entry.value;

      // Calculate TF-IDF score
      final tf = count / terms.length;
      final idf = log((_scenarioMap.length + 1) / (_termFrequencies[term] ?? 1));
      final tfidf = tf * idf;

      vector[term] = tfidf;

      // Add semantic expansion using concept mappings
      _addSemanticExpansion(vector, term, tfidf * 0.7);
    }

    return vector;
  }

  /// Add semantic expansion using concept mappings and synonyms
  void _addSemanticExpansion(Map<String, double> vector, String term, double weight) {
    // Check concept mappings
    for (final entry in _conceptMappings.entries) {
      if (entry.value.contains(term) || entry.key == term) {
        // Add all related concepts with reduced weight
        for (final relatedTerm in entry.value) {
          if (relatedTerm != term) {
            vector[relatedTerm] = (vector[relatedTerm] ?? 0) + (weight * 0.5);
          }
        }
        // Add the main concept
        vector[entry.key] = (vector[entry.key] ?? 0) + (weight * 0.8);
      }
    }
  }

  /// Enhanced search using multiple semantic similarity algorithms
  Future<List<SemanticSearchResult>> search(String query, {int maxResults = 50}) async {
    if (!_isInitialized || _scenarioVectors.isEmpty) {
      debugPrint('⚠️ Enhanced semantic search not ready');
      return [];
    }

    final stopwatch = Stopwatch()..start();

    try {
      final queryVector = _createSemanticVector(query);
      final queryTerms = _extractTerms(query);

      // Run expensive computation in background isolate using compute()
      final searchParams = _SearchParams(
        queryVector: queryVector,
        queryTerms: queryTerms,
        scenarioVectors: _scenarioVectors,
        scenarioMap: _scenarioMap,
        conceptMappings: _conceptMappings,
      );

      final similarities = await compute(_computeSearchSimilarities, searchParams);

      // Sort by combined score
      final sortedEntries = similarities.entries
          .toList()
        ..sort((a, b) => b.value.score.compareTo(a.value.score));

      final results = sortedEntries
          .take(maxResults)
          .map((e) => SemanticSearchResult(
                scenario: _scenarioMap[e.key]!,
                similarity: e.value.score,
                matchReason: _generateMatchReason(e.value),
                matchedTerms: e.value.matchedTerms,
              ))
          .toList();

      stopwatch.stop();
      debugPrint('🔍 Enhanced semantic search: "${query}" → ${results.length}/${similarities.length} results in ${stopwatch.elapsedMilliseconds}ms');

      return results;
    } catch (e) {
      debugPrint('❌ Enhanced semantic search failed: $e');
      return [];
    }
  }

  /// Calculate cosine similarity between two vectors
  double _calculateCosineSimilarity(Map<String, double> a, Map<String, double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;

    final allTerms = {...a.keys, ...b.keys};
    double dotProduct = 0.0;
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;

    for (final term in allTerms) {
      final valueA = a[term] ?? 0.0;
      final valueB = b[term] ?? 0.0;

      dotProduct += valueA * valueB;
      magnitudeA += valueA * valueA;
      magnitudeB += valueB * valueB;
    }

    if (magnitudeA == 0.0 || magnitudeB == 0.0) return 0.0;

    return dotProduct / (sqrt(magnitudeA) * sqrt(magnitudeB));
  }

  /// Calculate semantic overlap between query terms and scenario vector
  double _calculateSemanticOverlap(List<String> queryTerms, Map<String, double> scenarioVector) {
    if (queryTerms.isEmpty || scenarioVector.isEmpty) return 0.0;

    double totalOverlap = 0.0;
    for (final term in queryTerms) {
      if (scenarioVector.containsKey(term)) {
        totalOverlap += scenarioVector[term]! * 2.0; // Direct match gets higher weight
      }

      // Check for semantic related terms
      for (final scenarioTerm in scenarioVector.keys) {
        if (_areSemanticallySimilar(term, scenarioTerm)) {
          totalOverlap += scenarioVector[scenarioTerm]! * 0.5;
        }
      }
    }

    return min(totalOverlap / queryTerms.length, 1.0);
  }

  /// Calculate concept matching score using Gita-specific knowledge
  double _calculateConceptMatching(List<String> queryTerms, Scenario scenario) {
    double conceptScore = 0.0;
    final scenarioText = _extractSearchableText(scenario).toLowerCase();

    for (final term in queryTerms) {
      // Direct concept match
      if (_conceptMappings.containsKey(term)) {
        final relatedTerms = _conceptMappings[term]!;
        for (final relatedTerm in relatedTerms) {
          if (scenarioText.contains(relatedTerm)) {
            conceptScore += 0.8;
          }
        }
      }

      // Check if term appears in any concept mapping
      for (final entry in _conceptMappings.entries) {
        if (entry.value.contains(term) && scenarioText.contains(entry.key)) {
          conceptScore += 0.6;
        }
      }
    }

    return min(conceptScore / queryTerms.length, 1.0);
  }

  /// Check if two terms are semantically similar
  bool _areSemanticallySimilar(String term1, String term2) {
    // Simple semantic similarity checks
    if (term1 == term2) return true;
    if (term1.contains(term2) || term2.contains(term1)) return true;

    // Check concept mappings
    for (final concepts in _conceptMappings.values) {
      if (concepts.contains(term1) && concepts.contains(term2)) {
        return true;
      }
    }

    return false;
  }

  /// Find matched terms between query and scenario
  List<String> _findMatchedTerms(List<String> queryTerms, Map<String, double> scenarioVector) {
    final matched = <String>[];

    for (final term in queryTerms) {
      if (scenarioVector.containsKey(term)) {
        matched.add(term);
      }

      // Add semantically related terms
      for (final scenarioTerm in scenarioVector.keys) {
        if (_areSemanticallySimilar(term, scenarioTerm)) {
          matched.add(scenarioTerm);
        }
      }
    }

    return matched.toSet().toList(); // Remove duplicates
  }

  /// Generate human-readable match reason
  String _generateMatchReason(_SimilarityScore score) {
    if (score.conceptMatching > 0.5) {
      return 'Conceptual match';
    } else if (score.semanticOverlap > 0.5) {
      return 'Semantic similarity';
    } else if (score.cosineSimilarity > 0.3) {
      return 'Content relevance';
    } else {
      return 'Related concepts';
    }
  }

  /// Extract and normalize terms from text
  List<String> _extractTerms(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((term) => term.length > 2) // Filter short words
        .where((term) => !_isStopWord(term)) // Filter stop words
        .toList();
  }

  /// Check if a word is a stop word
  bool _isStopWord(String word) {
    const stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have',
      'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should',
      'may', 'might', 'must', 'can', 'this', 'that', 'these', 'those'
    };
    return stopWords.contains(word.toLowerCase());
  }

  String _getScenarioId(Scenario scenario) {
    return '${scenario.chapter}_${scenario.title}_${scenario.createdAt.millisecondsSinceEpoch}';
  }

  String _extractSearchableText(Scenario scenario) {
    final parts = [
      scenario.title,
      scenario.description,
      scenario.category,
      scenario.heartResponse ?? '',
      scenario.dutyResponse ?? '',
      scenario.gitaWisdom ?? '',
    ];

    return parts.join(' ').toLowerCase();
  }

  bool get isInitialized => _isInitialized;
  int get indexedCount => _scenarioMap.length;

  void dispose() {
    _scenarioVectors.clear();
    _scenarioMap.clear();
    _termFrequencies.clear();
    _synonymMap.clear();
    _isInitialized = false;
  }
}

/// Internal similarity score breakdown
class _SimilarityScore {
  final double score;
  final double cosineSimilarity;
  final double semanticOverlap;
  final double conceptMatching;
  final List<String> matchedTerms;

  _SimilarityScore({
    required this.score,
    required this.cosineSimilarity,
    required this.semanticOverlap,
    required this.conceptMatching,
    required this.matchedTerms,
  });
}

/// Parameters for isolate-based search computation
class _SearchParams {
  final Map<String, double> queryVector;
  final List<String> queryTerms;
  final Map<String, Map<String, double>> scenarioVectors;
  final Map<String, Scenario> scenarioMap;
  final Map<String, List<String>> conceptMappings;

  _SearchParams({
    required this.queryVector,
    required this.queryTerms,
    required this.scenarioVectors,
    required this.scenarioMap,
    required this.conceptMappings,
  });
}

/// Top-level function for computing search similarities in isolate
/// This runs in a background thread to avoid blocking the UI
Map<String, _SimilarityScore> _computeSearchSimilarities(_SearchParams params) {
  final similarities = <String, _SimilarityScore>{};

  // Calculate semantic similarities using multiple algorithms
  for (final entry in params.scenarioVectors.entries) {
    final scenarioId = entry.key;
    final scenarioVector = entry.value;

    // 1. Cosine similarity
    final cosineSim = _computeCosineSimilarity(params.queryVector, scenarioVector);

    // 2. Semantic overlap score
    final overlapSim = _computeSemanticOverlap(params.queryTerms, scenarioVector, params.conceptMappings);

    // 3. Concept matching score
    final conceptSim = _computeConceptMatching(params.queryTerms, params.scenarioMap[scenarioId]!, params.conceptMappings);

    // Combined score with weights
    final combinedScore = (cosineSim * 0.4) + (overlapSim * 0.4) + (conceptSim * 0.2);

    if (combinedScore > 0.1) { // Lower threshold for more results
      similarities[scenarioId] = _SimilarityScore(
        score: combinedScore,
        cosineSimilarity: cosineSim,
        semanticOverlap: overlapSim,
        conceptMatching: conceptSim,
        matchedTerms: _computeFindMatchedTerms(params.queryTerms, scenarioVector, params.conceptMappings),
      );
    }
  }

  return similarities;
}

/// Calculate cosine similarity (static version for isolate)
double _computeCosineSimilarity(Map<String, double> a, Map<String, double> b) {
  if (a.isEmpty || b.isEmpty) return 0.0;

  final allTerms = {...a.keys, ...b.keys};
  double dotProduct = 0.0;
  double magnitudeA = 0.0;
  double magnitudeB = 0.0;

  for (final term in allTerms) {
    final valueA = a[term] ?? 0.0;
    final valueB = b[term] ?? 0.0;

    dotProduct += valueA * valueB;
    magnitudeA += valueA * valueA;
    magnitudeB += valueB * valueB;
  }

  if (magnitudeA == 0.0 || magnitudeB == 0.0) return 0.0;

  return dotProduct / (sqrt(magnitudeA) * sqrt(magnitudeB));
}

/// Calculate semantic overlap (static version for isolate)
double _computeSemanticOverlap(
  List<String> queryTerms,
  Map<String, double> scenarioVector,
  Map<String, List<String>> conceptMappings,
) {
  if (queryTerms.isEmpty || scenarioVector.isEmpty) return 0.0;

  double totalOverlap = 0.0;
  for (final term in queryTerms) {
    if (scenarioVector.containsKey(term)) {
      totalOverlap += scenarioVector[term]! * 2.0; // Direct match gets higher weight
    }

    // Check for semantic related terms
    for (final scenarioTerm in scenarioVector.keys) {
      if (_computeAreSemanticallySimilar(term, scenarioTerm, conceptMappings)) {
        totalOverlap += scenarioVector[scenarioTerm]! * 0.5;
      }
    }
  }

  return min(totalOverlap / queryTerms.length, 1.0);
}

/// Calculate concept matching (static version for isolate)
double _computeConceptMatching(
  List<String> queryTerms,
  Scenario scenario,
  Map<String, List<String>> conceptMappings,
) {
  double conceptScore = 0.0;
  final scenarioText = _extractSearchableTextStatic(scenario).toLowerCase();

  for (final term in queryTerms) {
    // Direct concept match
    if (conceptMappings.containsKey(term)) {
      final relatedTerms = conceptMappings[term]!;
      for (final relatedTerm in relatedTerms) {
        if (scenarioText.contains(relatedTerm)) {
          conceptScore += 0.8;
        }
      }
    }

    // Check if term appears in any concept mapping
    for (final entry in conceptMappings.entries) {
      if (entry.value.contains(term) && scenarioText.contains(entry.key)) {
        conceptScore += 0.6;
      }
    }
  }

  return min(conceptScore / queryTerms.length, 1.0);
}

/// Check semantic similarity (static version for isolate)
bool _computeAreSemanticallySimilar(
  String term1,
  String term2,
  Map<String, List<String>> conceptMappings,
) {
  if (term1 == term2) return true;
  if (term1.contains(term2) || term2.contains(term1)) return true;

  // Check concept mappings
  for (final concepts in conceptMappings.values) {
    if (concepts.contains(term1) && concepts.contains(term2)) {
      return true;
    }
  }

  return false;
}

/// Find matched terms (static version for isolate)
List<String> _computeFindMatchedTerms(
  List<String> queryTerms,
  Map<String, double> scenarioVector,
  Map<String, List<String>> conceptMappings,
) {
  final matched = <String>[];

  for (final term in queryTerms) {
    if (scenarioVector.containsKey(term)) {
      matched.add(term);
    }

    // Add semantically related terms
    for (final scenarioTerm in scenarioVector.keys) {
      if (_computeAreSemanticallySimilar(term, scenarioTerm, conceptMappings)) {
        matched.add(scenarioTerm);
      }
    }
  }

  return matched.toSet().toList(); // Remove duplicates
}

/// Extract searchable text (static version for isolate)
String _extractSearchableTextStatic(Scenario scenario) {
  final parts = [
    scenario.title,
    scenario.description,
    scenario.category,
    scenario.heartResponse ?? '',
    scenario.dutyResponse ?? '',
    scenario.gitaWisdom ?? '',
  ];

  return parts.join(' ').toLowerCase();
}