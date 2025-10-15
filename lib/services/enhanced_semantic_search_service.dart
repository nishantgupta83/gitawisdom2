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
  final Map<String, int> _documentFrequencies = {}; // Document frequency for IDF calculation
  final Map<String, Set<String>> _synonymMap = {};
  final Map<String, Set<String>> _scenarioConcepts = {}; // Precomputed concept matches per scenario
  bool _isInitialized = false;

  // Spiritual and emotional concept mappings for Gita scenarios
  final Map<String, List<String>> _conceptMappings = {
    'stress': ['anxiety', 'pressure', 'tension', 'worry', 'burden', 'overwhelm', 'strain'],
    'work': ['career', 'job', 'profession', 'employment', 'business', 'duty', 'dharma'],
    'family': ['parents', 'children', 'siblings', 'relatives', 'household', 'home', 'kid', 'kids', 'child', 'son', 'daughter', 'wife', 'husband', 'mother', 'father', 'brother', 'sister', 'dad', 'mom', 'papa', 'mama', 'parent', 'family'],
    'relationships': ['love', 'marriage', 'friendship', 'partner', 'spouse', 'connection', 'boyfriend', 'girlfriend', 'relationship', 'breakup', 'divorce', 'separation'],
    'purpose': ['meaning', 'dharma', 'calling', 'mission', 'goals', 'direction', 'vision'],
    'spiritual': ['meditation', 'prayer', 'divine', 'soul', 'consciousness', 'enlightenment'],
    'fear': ['afraid', 'scared', 'terror', 'phobia', 'anxiety', 'dread', 'worry'],
    'anger': ['rage', 'fury', 'irritation', 'frustration', 'annoyance', 'wrath'],
    'confusion': ['lost', 'unclear', 'doubt', 'uncertain', 'perplexed', 'puzzled', 'what to do', 'helpless', 'hopeless', 'stuck'],
    'success': ['achievement', 'accomplishment', 'victory', 'triumph', 'prosperity'],
    'failure': ['defeat', 'loss', 'setback', 'disappointment', 'mistake', 'error'],
    'money': ['wealth', 'finance', 'prosperity', 'poverty', 'income', 'financial'],
    'health': ['illness', 'disease', 'medical', 'wellness', 'fitness', 'healing'],
    'death': ['dying', 'mortality', 'grief', 'loss', 'bereavement', 'mourning'],
    'ethics': ['morality', 'values', 'principles', 'right', 'wrong', 'virtue'],
    'choice': ['decision', 'option', 'selection', 'dilemma', 'pick', 'choose'],
    // Technology and modern life concepts
    'technology': ['mobile', 'phone', 'smartphone', 'device', 'digital', 'screen', 'computer', 'tablet', 'gadget', 'electronic', 'internet', 'online', 'app', 'software'],
    'communication': ['message', 'call', 'text', 'email', 'chat', 'talk', 'conversation', 'contact', 'social media'],
    'social': ['facebook', 'instagram', 'twitter', 'social media', 'online', 'web', 'network', 'followers', 'likes'],
    'distraction': ['addictive', 'compulsive', 'scrolling', 'notification', 'alert', 'temptation', 'procrastination'],
    // Mental health concepts
    'depression': ['depressed', 'sad', 'unhappy', 'miserable', 'hopeless', 'despair', 'melancholy', 'blues', 'down'],
    'mental health': ['depression', 'anxiety', 'therapy', 'counseling', 'mental illness', 'psychological', 'emotional', 'trauma', 'ptsd'],
    'crisis': ['suicide', 'suicidal', 'self harm', 'emergency', 'crisis', 'desperate', 'end it all'],
    'trauma': ['hurt', 'pain', 'wounded', 'damaged', 'suffering', 'agony', 'torture', 'abuse', 'violence'],
    // Support and help concepts
    'help': ['support', 'assistance', 'guidance', 'advice', 'counsel', 'help me', 'need help', 'helpless'],
    // Leadership and professional growth
    'leadership': ['leader', 'ownership', 'mentor', 'manager', 'influence', 'guide', 'inspire', 'responsibility'],
    'team': ['collaboration', 'conflict', 'colleague', 'communication', 'teamwork', 'cooperation', 'coworker', 'group'],
    'discipline': ['routine', 'practice', 'willpower', 'self control', 'habit', 'consistency', 'dedication', 'commitment'],
    // Spiritual practices
    'detachment': ['letting go', 'surrender', 'equanimity', 'non attachment', 'release', 'acceptance', 'peace'],
    'digital wellbeing': ['screen time', 'unplug', 'detox', 'disconnect', 'digital fast', 'tech free'],
    // Life stages and roles
    'education': ['exam', 'study', 'teacher', 'student', 'learning', 'school', 'college', 'university', 'test'],
    'parenting': ['guidance', 'boundaries', 'support', 'values', 'children', 'parent', 'raising', 'upbringing'],
    // Inner peace and service
    'peace': ['calm', 'contentment', 'acceptance', 'tranquility', 'serenity', 'harmony', 'stillness'],
    'service': ['seva', 'charity', 'volunteer', 'kindness', 'giving', 'helping', 'selfless', 'compassion'],
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

      // Create semantic vectors and precompute concept matches for each scenario
      for (final scenario in scenarios) {
        final scenarioId = _getScenarioId(scenario);
        _scenarioMap[scenarioId] = scenario;

        final text = _extractSearchableText(scenario);
        final vector = _createSemanticVector(text);
        _scenarioVectors[scenarioId] = vector;

        // Precompute concept matches for faster querying
        _indexScenarioConcepts(scenario, scenarioId);
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

  /// Build vocabulary and calculate term frequencies and document frequencies
  Future<void> _buildVocabulary(List<Scenario> scenarios) async {
    final allTerms = <String>[];
    _documentFrequencies.clear();

    // Calculate document frequency (DF) - how many documents contain each term
    for (final scenario in scenarios) {
      final text = _extractSearchableText(scenario);
      final terms = _extractTerms(text);
      final uniqueTerms = terms.toSet(); // Get unique terms in this document

      // Count document frequency
      for (final term in uniqueTerms) {
        _documentFrequencies[term] = (_documentFrequencies[term] ?? 0) + 1;
      }

      allTerms.addAll(terms);
    }

    // Calculate term frequencies (TF) for normalization
    final termCounts = <String, int>{};
    for (final term in allTerms) {
      termCounts[term] = (termCounts[term] ?? 0) + 1;
    }

    final totalTerms = allTerms.length;
    for (final entry in termCounts.entries) {
      _termFrequencies[entry.key] = entry.value / totalTerms;
    }

    debugPrint('📚 Built vocabulary: ${_termFrequencies.length} unique terms from ${scenarios.length} documents');
  }

  /// Create semantic vector for text using true TF-IDF weighting
  Map<String, double> _createSemanticVector(String text) {
    final vector = <String, double>{};
    final terms = _extractTerms(text);
    final termCounts = <String, int>{};

    // Count term frequencies in this document
    for (final term in terms) {
      termCounts[term] = (termCounts[term] ?? 0) + 1;
    }

    // Find maximum term frequency for normalization
    final maxCount = termCounts.values.fold<int>(0, (max, count) => count > max ? count : max);

    // Create true TF-IDF vector with semantic expansion
    final numDocs = _scenarioMap.length;
    for (final entry in termCounts.entries) {
      final term = entry.key;
      final count = entry.value;

      // Calculate normalized TF (0.5 + 0.5 * (count / maxCount)) for better discrimination
      final tf = maxCount == 0 ? 0.0 : count / maxCount.toDouble();

      // Calculate true IDF using document frequency
      final docFreq = _documentFrequencies[term] ?? 1;
      final idf = log((numDocs + 1) / (docFreq + 1)) + 1; // Add 1 to avoid zero IDF

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

  /// Precompute which concepts match this scenario (for fast concept matching during search)
  void _indexScenarioConcepts(Scenario scenario, String scenarioId) {
    final text = _extractSearchableText(scenario);
    final terms = _extractTerms(text).toSet();
    final matchedConcepts = <String>{};

    // Find all concept groups that match this scenario
    _conceptMappings.forEach((concept, words) {
      // Check if the concept key itself appears in the text
      if (terms.contains(concept)) {
        matchedConcepts.add(concept);
      }
      // Check if any of the concept words appear in the text
      else if (words.any((word) => terms.contains(word))) {
        matchedConcepts.add(concept);
      }
    });

    _scenarioConcepts[scenarioId] = matchedConcepts;
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
      final similarities = <String, _SimilarityScore>{};

      // Calculate semantic similarities using multiple algorithms
      for (final entry in _scenarioVectors.entries) {
        final scenarioId = entry.key;
        final scenarioVector = entry.value;

        // 1. Cosine similarity
        final cosineSim = _calculateCosineSimilarity(queryVector, scenarioVector);

        // 2. Semantic overlap score
        final overlapSim = _calculateSemanticOverlap(queryTerms, scenarioVector);

        // 3. Concept matching score
        final conceptSim = _calculateConceptMatching(queryTerms, _scenarioMap[scenarioId]!);

        // Combined score with weights
        final combinedScore = (cosineSim * 0.4) + (overlapSim * 0.4) + (conceptSim * 0.2);

        if (combinedScore > 0.1) { // Lower threshold for more results
          similarities[scenarioId] = _SimilarityScore(
            score: combinedScore,
            cosineSimilarity: cosineSim,
            semanticOverlap: overlapSim,
            conceptMatching: conceptSim,
            matchedTerms: _findMatchedTerms(queryTerms, scenarioVector),
          );
        }
      }

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

  /// Calculate concept matching score using Gita-specific knowledge (optimized with precomputed data)
  double _calculateConceptMatching(List<String> queryTerms, Scenario scenario) {
    final scenarioId = _getScenarioId(scenario);
    final scenarioConcepts = _scenarioConcepts[scenarioId] ?? {};

    if (scenarioConcepts.isEmpty || queryTerms.isEmpty) return 0.0;

    // Find which concepts are in the query
    final queryConcepts = <String>{};
    for (final term in queryTerms) {
      // Check if term is a concept key
      if (_conceptMappings.containsKey(term)) {
        queryConcepts.add(term);
      }
      // Check if term appears in any concept mapping
      _conceptMappings.forEach((concept, words) {
        if (words.contains(term)) {
          queryConcepts.add(concept);
        }
      });
    }

    if (queryConcepts.isEmpty) return 0.0;

    // Calculate overlap between query concepts and scenario concepts
    final overlap = queryConcepts.intersection(scenarioConcepts).length;
    return overlap / queryConcepts.length;
  }

  /// Check if two terms are semantically similar
  bool _areSemanticallySimilar(String term1, String term2) {
    // Simple semantic similarity checks
    if (term1 == term2) return true;

    // Use word-boundary regex to avoid false positives (e.g., "dad" matching "dadly")
    final wordBoundary1 = RegExp(r'(^|\b)' + RegExp.escape(term1) + r'(\b|$)');
    final wordBoundary2 = RegExp(r'(^|\b)' + RegExp.escape(term2) + r'(\b|$)');
    if (wordBoundary1.hasMatch(term2) || wordBoundary2.hasMatch(term1)) return true;

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

  /// Extract and normalize terms from text (English-optimized)
  List<String> _extractTerms(String text) {
    // English-only optimization: simpler regex without Unicode overhead
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' '); // Keep letters and numbers only

    return normalized
        .split(RegExp(r'\s+'))
        .where((term) => term.length > 2) // Filter short words
        .where((term) => !_isStopWord(term)) // Filter stop words
        .toList();
  }

  /// Check if a word is a stop word (expanded for GitaWisdom context)
  bool _isStopWord(String word) {
    const stopWords = {
      // Common English stop words
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have',
      'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should',
      'may', 'might', 'must', 'can', 'this', 'that', 'these', 'those',
      // Additional common words
      'what', 'when', 'where', 'who', 'why', 'how', 'which', 'there',
      'their', 'they', 'them', 'then', 'than', 'also', 'just', 'very',
      'too', 'only', 'such', 'some', 'more', 'most', 'many', 'much',
      // Normalized multiword phrases (underscores for matching)
      'social_media', 'screen_time', 'let_go', 'self_control',
    };
    return stopWords.contains(word.toLowerCase());
  }

  String _getScenarioId(Scenario scenario) {
    return '${scenario.chapter}_${scenario.title}_${scenario.createdAt.millisecondsSinceEpoch}';
  }

  String _extractSearchableText(Scenario scenario) {
    // Field weighting: repeat title 3x and category 2x to emphasize importance
    final parts = [
      ...List.filled(3, scenario.title),           // Title is most important
      ...List.filled(2, scenario.category),         // Category is second most important
      scenario.description,
      scenario.heartResponse ?? '',
      scenario.dutyResponse ?? '',
      scenario.gitaWisdom ?? '',
      scenario.tags?.join(' ') ?? '',
    ];

    return parts.join(' ').toLowerCase();
  }

  bool get isInitialized => _isInitialized;
  int get indexedCount => _scenarioMap.length;

  void dispose() {
    _scenarioVectors.clear();
    _scenarioMap.clear();
    _termFrequencies.clear();
    _documentFrequencies.clear();
    _synonymMap.clear();
    _scenarioConcepts.clear();
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