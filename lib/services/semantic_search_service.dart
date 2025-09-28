import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/scenario.dart';

class SemanticSearchResult {
  final Scenario scenario;
  final double similarity;

  SemanticSearchResult({
    required this.scenario,
    required this.similarity,
  });
}

class SemanticSearchService {
  static final SemanticSearchService instance = SemanticSearchService._();
  SemanticSearchService._();

  Interpreter? _interpreter;
  final Map<String, List<double>> _scenarioEmbeddings = {};
  final Map<String, Scenario> _scenarioMap = {};
  bool _isInitialized = false;

  final int _maxSequenceLength = 64;
  final int _embeddingDim = 384;

  Future<void> initialize(List<Scenario> scenarios) async {
    if (_isInitialized && scenarios.length == _scenarioMap.length) {
      debugPrint('🧠 Semantic search already initialized (${scenarios.length} scenarios)');
      return;
    }

    final stopwatch = Stopwatch()..start();
    debugPrint('🧠 Initializing semantic search with TFLite...');

    try {
      await _loadModel();

      _scenarioEmbeddings.clear();
      _scenarioMap.clear();

      for (final scenario in scenarios) {
        final scenarioId = _getScenarioId(scenario);
        _scenarioMap[scenarioId] = scenario;

        final text = _extractSearchableText(scenario);
        final embedding = await _generateEmbedding(text);
        _scenarioEmbeddings[scenarioId] = embedding;
      }

      _isInitialized = true;
      stopwatch.stop();
      debugPrint('✅ Semantic search initialized in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('❌ Failed to initialize semantic search: $e');
      debugPrint('ℹ️ App will continue with keyword-only search');
    }
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions();

      if (Platform.isAndroid) {
        options.addDelegate(XNNPackDelegate());
      }

      if (Platform.isIOS) {
        options.addDelegate(GpuDelegate());
      }

      _interpreter = await Interpreter.fromAsset(
        'assets/models/sentence_encoder.tflite',
        options: options,
      );

      debugPrint('✅ TFLite model loaded successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to load TFLite model: $e');
      debugPrint('ℹ️ Falling back to keyword-only search');
      rethrow;
    }
  }

  Future<List<double>> _generateEmbedding(String text) async {
    if (_interpreter == null) {
      return List.filled(_embeddingDim, 0.0);
    }

    try {
      final tokens = _tokenize(text);
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      final input = _prepareInput(tokens, inputShape);
      final output = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

      _interpreter!.run(input, output);

      final embedding = (output[0] as List).cast<double>();
      return _normalize(embedding);
    } catch (e) {
      debugPrint('❌ Failed to generate embedding: $e');
      return List.filled(_embeddingDim, 0.0);
    }
  }

  List<int> _tokenize(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));

    final tokens = <int>[];
    for (final word in words) {
      if (word.isNotEmpty) {
        tokens.add(word.hashCode.abs() % 30000);
      }
    }

    return tokens.take(_maxSequenceLength).toList();
  }

  List<List<int>> _prepareInput(List<int> tokens, List<int> inputShape) {
    final sequenceLength = inputShape[1];
    final paddedTokens = List<int>.filled(sequenceLength, 0);

    for (int i = 0; i < min(tokens.length, sequenceLength); i++) {
      paddedTokens[i] = tokens[i];
    }

    return [paddedTokens];
  }

  List<double> _normalize(List<double> vector) {
    final magnitude = sqrt(vector.fold<double>(0.0, (sum, val) => sum + val * val));
    if (magnitude == 0) return vector;
    return vector.map((val) => val / magnitude).toList();
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
    }

    return dotProduct;
  }

  Future<List<SemanticSearchResult>> search(String query, {int maxResults = 20}) async {
    if (!_isInitialized || _scenarioEmbeddings.isEmpty) {
      debugPrint('⚠️ Semantic search not ready');
      return [];
    }

    final stopwatch = Stopwatch()..start();

    try {
      final queryEmbedding = await _generateEmbedding(query);

      final similarities = <String, double>{};
      for (final entry in _scenarioEmbeddings.entries) {
        final scenarioId = entry.key;
        final scenarioEmbedding = entry.value;
        final similarity = _cosineSimilarity(queryEmbedding, scenarioEmbedding);

        if (similarity > 0.3) {
          similarities[scenarioId] = similarity;
        }
      }

      final results = similarities.entries
          .map((e) => SemanticSearchResult(
                scenario: _scenarioMap[e.key]!,
                similarity: e.value,
              ))
          .toList()
        ..sort((a, b) => b.similarity.compareTo(a.similarity));

      final topResults = results.take(maxResults).toList();
      stopwatch.stop();

      debugPrint('🔍 Semantic search: "${query}" → ${topResults.length}/${results.length} results in ${stopwatch.elapsedMilliseconds}ms');
      return topResults;
    } catch (e) {
      debugPrint('❌ Semantic search failed: $e');
      return [];
    }
  }

  String _getScenarioId(Scenario scenario) {
    return '${scenario.chapter}_${scenario.title}_${scenario.createdAt.millisecondsSinceEpoch}';
  }

  String _extractSearchableText(Scenario scenario) {
    final parts = [
      scenario.title,
      scenario.description,
      scenario.category,
    ];

    return parts.join(' ').toLowerCase();
  }

  bool get isInitialized => _isInitialized;
  int get indexedCount => _scenarioMap.length;

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _scenarioEmbeddings.clear();
    _scenarioMap.clear();
    _isInitialized = false;
  }
}

class Platform {
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
}