// lib/services/intelligent_caching_service.dart

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/scenario.dart';
import '../services/service_locator.dart';
import '../services/progressive_cache_service.dart';

/// Service that manages intelligent background loading and user activity monitoring
class IntelligentCachingService with WidgetsBindingObserver {
  static final IntelligentCachingService instance = IntelligentCachingService._();
  IntelligentCachingService._();

  late final _supabaseService = ServiceLocator.instance.enhancedSupabaseService;
  late final HybridStorage _hybridStorage = HybridStorage();

  // Loading state management
  bool _isInitialized = false;
  bool _isLoadingCritical = false;
  bool _isBackgroundLoading = false;
  bool _userIsActive = false;

  // Background loading control
  Timer? _backgroundTimer;
  Timer? _activityMonitorTimer;
  Completer<void>? _criticalLoadCompleter;

  // Loading progress tracking
  int _currentBatch = 0;
  int _totalBatches = 0;
  CacheLevel _currentLoadingLevel = CacheLevel.critical;

  // Performance monitoring
  DateTime? _loadingStartTime;
  final List<Duration> _batchLoadTimes = [];

  // Configuration
  static const Duration _userActivityTimeout = Duration(seconds: 3);
  static const Duration _batchDelay = Duration(milliseconds: 300);
  static const Duration _backgroundStartDelay = Duration(milliseconds: 800);
  static const int _batchSize = 50;

  /// Initialize the service and start critical loading
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🧠 IntelligentCachingService already initialized');
      return;
    }

    try {
      debugPrint('🧠 Initializing IntelligentCachingService...');

      // Initialize hybrid storage
      await _hybridStorage.initialize();

      // Set up user activity monitoring
      WidgetsBinding.instance.addObserver(this);
      _startActivityMonitoring();

      _isInitialized = true;

      // Start critical loading immediately for home screen
      await _loadCriticalScenariosForStartup();

      // Schedule background loading after UI settles
      _scheduleBackgroundLoading();

      debugPrint('✅ IntelligentCachingService initialized successfully');

    } catch (e) {
      debugPrint('❌ Error initializing IntelligentCachingService: $e');
      rethrow;
    }
  }

  /// Load critical scenarios immediately for app startup
  Future<void> _loadCriticalScenariosForStartup() async {
    if (_isLoadingCritical) return;

    _isLoadingCritical = true;
    _criticalLoadCompleter = Completer<void>();
    _loadingStartTime = DateTime.now();

    try {
      debugPrint('🚀 Loading critical scenarios for immediate startup...');

      // Check if we already have critical scenarios cached
      if (_hybridStorage.hasDataAtLevel(CacheLevel.critical)) {
        debugPrint('⚡ Critical scenarios already cached - instant startup!');
        _isLoadingCritical = false;
        if (_criticalLoadCompleter != null && !_criticalLoadCompleter!.isCompleted) {
          _criticalLoadCompleter!.complete();
        }
        return;
      }

      // Load critical scenarios from server with high priority
      final criticalScenarios = await _loadScenariosBatch(
        offset: 0,
        limit: CacheLevel.critical.count,
        priority: 'critical'
      );

      if (criticalScenarios.isNotEmpty) {
        // Store in critical cache for instant access
        final scenarioMap = <String, Scenario>{};
        for (int i = 0; i < criticalScenarios.length; i++) {
          scenarioMap['critical_$i'] = criticalScenarios[i];
        }

        await _hybridStorage.storeBatch(scenarioMap, CacheLevel.critical);

        final loadTime = DateTime.now().difference(_loadingStartTime!);
        debugPrint('✅ Critical scenarios loaded in ${loadTime.inMilliseconds}ms');
      }

    } catch (e) {
      debugPrint('❌ Error loading critical scenarios: $e');
    } finally {
      _isLoadingCritical = false;
      if (_criticalLoadCompleter != null && !_criticalLoadCompleter!.isCompleted) {
        _criticalLoadCompleter!.complete();
      }
    }
  }

  /// Schedule background loading after critical scenarios are ready
  void _scheduleBackgroundLoading() {
    _backgroundTimer = Timer(_backgroundStartDelay, () {
      if (!_userIsActive && !_isBackgroundLoading) {
        _startProgressiveBackgroundLoading();
      }
    });
  }

  /// Start progressive background loading when user is idle
  Future<void> _startProgressiveBackgroundLoading() async {
    if (_isBackgroundLoading) return;

    _isBackgroundLoading = true;
    debugPrint('🔄 Starting progressive background loading...');

    try {
      // Load frequent scenarios first
      if (!_hybridStorage.hasDataAtLevel(CacheLevel.frequent)) {
        await _loadLevelProgressively(CacheLevel.frequent);
      }

      // Then load complete dataset
      if (!_hybridStorage.hasDataAtLevel(CacheLevel.complete)) {
        await _loadLevelProgressively(CacheLevel.complete);
      }

      debugPrint('🎉 Progressive background loading completed!');

    } catch (e) {
      debugPrint('❌ Error in background loading: $e');
    } finally {
      _isBackgroundLoading = false;
    }
  }

  /// Load scenarios for a specific cache level progressively
  Future<void> _loadLevelProgressively(CacheLevel level) async {
    debugPrint('📦 Loading ${level.name} scenarios progressively...');

    _currentLoadingLevel = level;
    _currentBatch = 0;
    _totalBatches = (level.count / _batchSize).ceil();

    for (int batch = 0; batch < _totalBatches; batch++) {
      // Check if user became active - pause loading
      if (_shouldPauseLoading()) {
        debugPrint('⏸️ Pausing background loading - user is active');
        await _waitForUserIdle();
        if (_shouldPauseLoading()) continue; // Still active, skip this batch
      }

      await _loadBatchForLevel(level, batch);
      _currentBatch = batch + 1;

      // Breathing room between batches
      if (batch < _totalBatches - 1) {
        await Future.delayed(_batchDelay);
      }
    }
  }

  /// Load a specific batch for a cache level
  Future<void> _loadBatchForLevel(CacheLevel level, int batchNumber) async {
    final batchStartTime = DateTime.now();

    try {
      final offset = batchNumber * _batchSize;
      final limit = _batchSize;

      // Offset for different levels to avoid overlap
      final adjustedOffset = offset + (level.priority - 1) * 1000;

      final scenarios = await _loadScenariosBatch(
        offset: adjustedOffset,
        limit: limit,
        priority: level.name
      );

      if (scenarios.isNotEmpty) {
        final scenarioMap = <String, Scenario>{};
        for (int i = 0; i < scenarios.length; i++) {
          scenarioMap['${level.name}_${offset + i}'] = scenarios[i];
        }

        await _hybridStorage.storeBatch(scenarioMap, level);

        final batchTime = DateTime.now().difference(batchStartTime);
        _batchLoadTimes.add(batchTime);

        debugPrint('📦 Loaded batch ${batchNumber + 1}/${_totalBatches} for ${level.name} (${scenarios.length} scenarios in ${batchTime.inMilliseconds}ms)');
      }

    } catch (e) {
      debugPrint('❌ Error loading batch $batchNumber for ${level.name}: $e');
    }
  }

  /// Load scenarios from server with error handling
  Future<List<Scenario>> _loadScenariosBatch({
    required int offset,
    required int limit,
    required String priority
  }) async {
    try {
      final scenarios = await _supabaseService.fetchScenarios(
        offset: offset,
        limit: limit
      );

      debugPrint('🌐 Loaded ${scenarios.length} scenarios from server (offset: $offset, priority: $priority)');
      return scenarios;

    } catch (e) {
      debugPrint('❌ Error loading scenarios batch: $e');
      return [];
    }
  }

  /// User activity monitoring
  void _startActivityMonitoring() {
    _activityMonitorTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) => _checkUserActivity()
    );
  }

  void _checkUserActivity() {
    // This will be enhanced with actual gesture detection
    // For now, we use a simple heuristic
    _userIsActive = false; // Placeholder
  }

  /// Check if background loading should be paused
  bool _shouldPauseLoading() {
    return _userIsActive || _isLoadingCritical;
  }

  /// Wait for user to become idle
  Future<void> _waitForUserIdle() async {
    final completer = Completer<void>();

    Timer? idleTimer;
    void resetTimer() {
      idleTimer?.cancel();
      idleTimer = Timer(_userActivityTimeout, () {
        _userIsActive = false;
        completer.complete();
      });
    }

    resetTimer();
    return completer.future;
  }

  /// Public API methods

  /// Wait for critical scenarios to be loaded
  Future<void> waitForCriticalScenarios() async {
    if (_criticalLoadCompleter != null && !_criticalLoadCompleter!.isCompleted) {
      await _criticalLoadCompleter!.future;
    }
  }

  /// Check if critical scenarios are available
  bool get hasCriticalScenarios => _hybridStorage.hasDataAtLevel(CacheLevel.critical);

  /// Get scenarios by level
  Future<List<Scenario>> getScenariosByLevel(CacheLevel level) async {
    return await _hybridStorage.getScenariosByLevel(level);
  }

  /// Get a specific scenario
  Future<Scenario?> getScenario(String id) async {
    return await _hybridStorage.getScenario(id);
  }

  /// Get critical scenarios synchronously (for immediate UI access)
  List<Scenario> getCriticalScenariosSync() {
    try {
      final scenarios = _hybridStorage.getCriticalScenariosSync();
      debugPrint('⚡ Got ${scenarios.length} critical scenarios synchronously');
      return scenarios;
    } catch (e) {
      debugPrint('❌ Error getting critical scenarios sync: $e');
      return [];
    }
  }

  /// Get scenario counts grouped by chapter
  Future<Map<int, int>> getScenarioCountsByChapter() async {
    try {
      final allScenarios = await _hybridStorage.getAllScenarios();
      final countsByChapter = <int, int>{};

      for (final scenario in allScenarios) {
        final chapter = scenario.chapter ?? 0;
        countsByChapter[chapter] = (countsByChapter[chapter] ?? 0) + 1;
      }

      debugPrint('📊 Calculated scenario counts for ${countsByChapter.length} chapters');
      return countsByChapter;
    } catch (e) {
      debugPrint('❌ Error getting scenario counts by chapter: $e');
      return {};
    }
  }

  /// Search scenarios across all loaded levels
  Future<List<Scenario>> searchScenarios(String query, {int? maxResults}) async {
    final results = <Scenario>[];

    // Search critical first (instant)
    if (_hybridStorage.hasDataAtLevel(CacheLevel.critical)) {
      final criticalScenarios = await _hybridStorage.getScenariosByLevel(CacheLevel.critical);
      results.addAll(_filterScenarios(criticalScenarios, query));
    }

    // If we need more results and have frequent scenarios loaded
    if ((maxResults == null || results.length < maxResults) &&
        _hybridStorage.hasDataAtLevel(CacheLevel.frequent)) {
      final frequentScenarios = await _hybridStorage.getScenariosByLevel(CacheLevel.frequent);
      results.addAll(_filterScenarios(frequentScenarios, query));
    }

    // Finally search complete if needed
    if ((maxResults == null || results.length < maxResults) &&
        _hybridStorage.hasDataAtLevel(CacheLevel.complete)) {
      final completeScenarios = await _hybridStorage.getScenariosByLevel(CacheLevel.complete);
      results.addAll(_filterScenarios(completeScenarios, query));
    }

    // Remove duplicates and limit results
    final uniqueResults = results.toSet().toList();
    if (maxResults != null && uniqueResults.length > maxResults) {
      return uniqueResults.take(maxResults).toList();
    }

    return uniqueResults;
  }

  /// Filter scenarios by search query
  List<Scenario> _filterScenarios(List<Scenario> scenarios, String query) {
    if (query.trim().isEmpty) return scenarios;

    final lowerQuery = query.toLowerCase();
    return scenarios.where((scenario) {
      return scenario.title.toLowerCase().contains(lowerQuery) ||
             scenario.description.toLowerCase().contains(lowerQuery) ||
             scenario.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get loading progress
  Map<String, dynamic> getProgress() {
    return {
      'isLoading': _isBackgroundLoading,
      'currentLevel': _currentLoadingLevel.name,
      'currentBatch': _currentBatch,
      'totalBatches': _totalBatches,
      'progress': _totalBatches > 0 ? _currentBatch / _totalBatches : 0.0,
      'cacheCounts': _hybridStorage.getCacheCounts(),
      'averageBatchTime': _batchLoadTimes.isNotEmpty
          ? _batchLoadTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / _batchLoadTimes.length
          : 0,
    };
  }

  /// Force refresh from server
  Future<void> refreshFromServer() async {
    debugPrint('🔄 Force refreshing scenarios from server...');

    // Clear existing caches
    for (final level in CacheLevel.values) {
      await _hybridStorage.clearLevel(level);
    }

    // Restart critical loading
    await _loadCriticalScenariosForStartup();

    // Restart background loading
    _scheduleBackgroundLoading();
  }

  /// Dispose resources
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);

    _backgroundTimer?.cancel();
    _activityMonitorTimer?.cancel();

    await _hybridStorage.dispose();

    debugPrint('🧠 IntelligentCachingService disposed');
  }

  // WidgetsBindingObserver overrides for better user activity detection
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _userIsActive = false;
        break;
      case AppLifecycleState.resumed:
        _userIsActive = true;
        break;
      case AppLifecycleState.inactive:
        // Don't change state for inactive
        break;
      case AppLifecycleState.hidden:
        _userIsActive = false;
        break;
    }
  }
}