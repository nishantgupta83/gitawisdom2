import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/scenario.dart';

class SearchResult {
  final Scenario scenario;
  final double score;
  final List<String> matchedTerms;

  SearchResult({
    required this.scenario,
    required this.score,
    required this.matchedTerms,
  });
}

class KeywordSearchService {
  static final KeywordSearchService instance = KeywordSearchService._();
  KeywordSearchService._();

  final Map<String, Map<String, double>> _scenarioIndex = {};
  final Map<String, double> _idfScores = {};
  final Map<String, Scenario> _scenarioMap = {};
  bool _isIndexed = false;

  static final Set<String> _stopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from',
    'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the',
    'to', 'was', 'will', 'with', 'you', 'your', 'this', 'these', 'those',
    'i', 'we', 'they', 'what', 'which', 'who', 'when', 'where', 'why', 'how',
  };

  Future<void> indexScenarios(List<Scenario> scenarios) async {
    if (_isIndexed && scenarios.length == _scenarioMap.length) {
      debugPrint('📇 Scenario index already up-to-date (${scenarios.length} scenarios)');
      return;
    }

    final stopwatch = Stopwatch()..start();
    debugPrint('📇 Building keyword index for ${scenarios.length} scenarios...');

    _scenarioIndex.clear();
    _idfScores.clear();
    _scenarioMap.clear();

    final Map<String, int> documentFrequency = {};
    final totalDocs = scenarios.length;

    for (final scenario in scenarios) {
      final scenarioId = _getScenarioId(scenario);
      _scenarioMap[scenarioId] = scenario;

      final text = _extractSearchableText(scenario);
      final terms = _tokenize(text);
      final termFreq = _calculateTermFrequency(terms);

      _scenarioIndex[scenarioId] = termFreq;

      for (final term in termFreq.keys) {
        documentFrequency[term] = (documentFrequency[term] ?? 0) + 1;
      }
    }

    for (final entry in documentFrequency.entries) {
      final term = entry.key;
      final df = entry.value;
      _idfScores[term] = log(totalDocs / df);
    }

    _isIndexed = true;
    stopwatch.stop();
    debugPrint('✅ Keyword index built in ${stopwatch.elapsedMilliseconds}ms');
  }

  List<SearchResult> search(String query, {int maxResults = 20}) {
    if (!_isIndexed || _scenarioIndex.isEmpty) {
      debugPrint('⚠️ Keyword index not ready');
      return [];
    }

    final stopwatch = Stopwatch()..start();

    final queryTerms = _tokenize(query.toLowerCase());
    if (queryTerms.isEmpty) {
      return [];
    }

    final scores = <String, double>{};
    final matchedTerms = <String, Set<String>>{};

    for (final scenarioId in _scenarioIndex.keys) {
      final termFreq = _scenarioIndex[scenarioId]!;
      double score = 0.0;

      for (final queryTerm in queryTerms) {
        if (termFreq.containsKey(queryTerm)) {
          final tf = termFreq[queryTerm]!;
          final idf = _idfScores[queryTerm] ?? 0.0;
          score += tf * idf;

          matchedTerms.putIfAbsent(scenarioId, () => {});
          matchedTerms[scenarioId]!.add(queryTerm);
        }

        for (final term in termFreq.keys) {
          if (term.contains(queryTerm) || queryTerm.contains(term)) {
            final partialMatch = 0.5;
            final tf = termFreq[term]!;
            final idf = _idfScores[term] ?? 0.0;
            score += tf * idf * partialMatch;

            matchedTerms.putIfAbsent(scenarioId, () => {});
            matchedTerms[scenarioId]!.add(term);
          }
        }
      }

      if (score > 0) {
        scores[scenarioId] = score;
      }
    }

    final results = scores.entries
        .map((e) => SearchResult(
              scenario: _scenarioMap[e.key]!,
              score: e.value,
              matchedTerms: matchedTerms[e.key]?.toList() ?? [],
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final topResults = results.take(maxResults).toList();
    stopwatch.stop();

    debugPrint('🔍 Keyword search: "${query}" → ${topResults.length}/${results.length} results in ${stopwatch.elapsedMilliseconds}ms');
    return topResults;
  }

  String _getScenarioId(Scenario scenario) {
    return '${scenario.chapter}_${scenario.title}_${scenario.createdAt.millisecondsSinceEpoch}';
  }

  String _extractSearchableText(Scenario scenario) {
    final parts = [
      scenario.title,
      scenario.description,
      scenario.category,
      scenario.heartResponse,
      scenario.dutyResponse,
      scenario.gitaWisdom,
      if (scenario.tags != null) scenario.tags!.join(' '),
      if (scenario.actionSteps != null) scenario.actionSteps!.join(' '),
    ];

    return parts.join(' ').toLowerCase();
  }

  List<String> _tokenize(String text) {
    final words = text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2 && !_stopWords.contains(word))
        .toList();

    return words;
  }

  Map<String, double> _calculateTermFrequency(List<String> terms) {
    if (terms.isEmpty) return {};

    final freq = <String, int>{};
    for (final term in terms) {
      freq[term] = (freq[term] ?? 0) + 1;
    }

    final maxFreq = freq.values.reduce(max);
    final termFreq = <String, double>{};

    for (final entry in freq.entries) {
      termFreq[entry.key] = entry.value / maxFreq;
    }

    return termFreq;
  }

  bool get isIndexed => _isIndexed;
  int get indexedCount => _scenarioMap.length;
}