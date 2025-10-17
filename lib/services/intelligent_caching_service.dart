// lib/services/intelligent_caching_service.dart

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/scenario.dart';
import '../services/service_locator.dart';
import '../services/progressive_cache_service.dart';

/// Service that manages intelligent background loading and user activity monitoring
class IntelligentCachingService with WidgetsBindingObserver {
  static final IntelligentCachingService instance = IntelligentCachingService._();
  IntelligentCachingService._();

  // Cache version - increment this to force cache rebuild when architecture changes
  static const int _CACHE_VERSION = 3; // v3: Fixed Supabase pagination (.range() added)
  static const String _VERSION_KEY = 'cache_architecture_version';

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
    if (_isInitialized) return;

    try {
      await _hybridStorage.initialize();
      await _checkAndUpdateCacheVersion();
      WidgetsBinding.instance.addObserver(this);
      _startActivityMonitoring();
      _isInitialized = true;
      await _loadCriticalScenariosForStartup();
      _scheduleBackgroundLoading();
    } catch (e) {
      debugPrint('❌ Error initializing IntelligentCachingService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Load critical scenarios immediately for app startup
  Future<void> _loadCriticalScenariosForStartup() async {
    // Thread-safe check with early return
    if (_isLoadingCritical) {
      // If already loading, wait for the existing operation
      if (_criticalLoadCompleter != null && !_criticalLoadCompleter!.isCompleted) {
        await _criticalLoadCompleter!.future;
      }
      return;
    }

    if (_hybridStorage.hasDataAtLevel(CacheLevel.critical)) return;

    _isLoadingCritical = true;
    _criticalLoadCompleter = Completer<void>();
    _loadingStartTime = DateTime.now();

    try {
      final criticalScenarios = await _loadScenariosBatch(
        offset: 0,
        limit: CacheLevel.critical.count,
        priority: 'critical'
      );

      if (criticalScenarios.isNotEmpty) {
        final scenarioMap = <String, Scenario>{};
        for (int i = 0; i < criticalScenarios.length; i++) {
          scenarioMap['critical_$i'] = criticalScenarios[i];
        }
        await _hybridStorage.storeBatch(scenarioMap, CacheLevel.critical);
      }
    } catch (e) {
      debugPrint('❌ Error loading critical scenarios: $e');
    } finally {
      _isLoadingCritical = false;
      _safeCompleteCompleter();
    }
  }

  /// Safely complete the completer to avoid "Bad state: Future already completed" errors
  void _safeCompleteCompleter() {
    if (_criticalLoadCompleter != null && !_criticalLoadCompleter!.isCompleted) {
      _criticalLoadCompleter!.complete();
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
    try {
      if (!_hybridStorage.hasDataAtLevel(CacheLevel.frequent)) {
        await _loadLevelProgressively(CacheLevel.frequent);
      }
      if (!_hybridStorage.hasDataAtLevel(CacheLevel.complete)) {
        await _loadLevelProgressively(CacheLevel.complete);
      }
    } catch (e) {
      debugPrint('❌ Error in background loading: $e');
    } finally {
      _isBackgroundLoading = false;
    }
  }

  /// Load scenarios for a specific cache level progressively
  Future<void> _loadLevelProgressively(CacheLevel level) async {
    _currentLoadingLevel = level;
    _currentBatch = 0;
    _totalBatches = (level.count / _batchSize).ceil();

    for (int batch = 0; batch < _totalBatches; batch++) {
      if (_shouldPauseLoading()) {
        await _waitForUserIdle();
        if (_shouldPauseLoading()) continue;
      }
      await _loadBatchForLevel(level, batch);
      _currentBatch = batch + 1;
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
      final scenarios = await _loadScenariosBatch(
        offset: offset,
        limit: _batchSize,
        priority: level.name
      );

      if (scenarios.isNotEmpty) {
        final scenarioMap = <String, Scenario>{};
        for (int i = 0; i < scenarios.length; i++) {
          scenarioMap['${level.name}_${offset + i}'] = scenarios[i];
        }
        await _hybridStorage.storeBatch(scenarioMap, level);
        _batchLoadTimes.add(DateTime.now().difference(batchStartTime));
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
      return await _supabaseService.fetchScenarios(offset: offset, limit: limit);
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
    // If currently loading, wait for completion
    if (_isLoadingCritical && _criticalLoadCompleter != null && !_criticalLoadCompleter!.isCompleted) {
      await _criticalLoadCompleter!.future;
    }
    // If not loading and no data exists, trigger loading
    else if (!_isLoadingCritical && !_hybridStorage.hasDataAtLevel(CacheLevel.critical)) {
      await _loadCriticalScenariosForStartup();
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
      return _hybridStorage.getCriticalScenariosSync();
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
      return countsByChapter;
    } catch (e) {
      debugPrint('❌ Error getting scenario counts by chapter: $e');
      return {};
    }
  }

  /// Search scenarios across all loaded levels
  Future<List<Scenario>> searchScenarios(String query, {int? maxResults}) async {
    final results = <Scenario>[];
    final seenTitles = <String>{};

    // Search critical first (instant)
    if (_hybridStorage.hasDataAtLevel(CacheLevel.critical)) {
      final criticalScenarios = await _hybridStorage.getScenariosByLevel(CacheLevel.critical);
      final filtered = _filterScenarios(criticalScenarios, query);
      for (final scenario in filtered) {
        if (!seenTitles.contains(scenario.title)) {
          seenTitles.add(scenario.title);
          results.add(scenario);
        }
      }
    }

    // If we need more results and have frequent scenarios loaded
    if ((maxResults == null || results.length < maxResults) &&
        _hybridStorage.hasDataAtLevel(CacheLevel.frequent)) {
      final frequentScenarios = await _hybridStorage.getScenariosByLevel(CacheLevel.frequent);
      final filtered = _filterScenarios(frequentScenarios, query);
      for (final scenario in filtered) {
        if (!seenTitles.contains(scenario.title)) {
          seenTitles.add(scenario.title);
          results.add(scenario);
        }
      }
    }

    // Finally search complete if needed
    if ((maxResults == null || results.length < maxResults) &&
        _hybridStorage.hasDataAtLevel(CacheLevel.complete)) {
      final completeScenarios = await _hybridStorage.getScenariosByLevel(CacheLevel.complete);
      final filtered = _filterScenarios(completeScenarios, query);
      for (final scenario in filtered) {
        if (!seenTitles.contains(scenario.title)) {
          seenTitles.add(scenario.title);
          results.add(scenario);
        }
      }
    }

    // Limit results if needed
    if (maxResults != null && results.length > maxResults) {
      return results.take(maxResults).toList();
    }

    // Log removed - was spamming console on every search/navigation
    return results;
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
    for (final level in CacheLevel.values) {
      await _hybridStorage.clearLevel(level);
    }
    await _loadCriticalScenariosForStartup();
    _scheduleBackgroundLoading();
  }

  /// Dispose resources
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTimer?.cancel();
    _activityMonitorTimer?.cancel();
    await _hybridStorage.dispose();
  }

  /// Check cache version and clear if outdated
  Future<void> _checkAndUpdateCacheVersion() async {
    try {
      final box = await Hive.openBox('app_metadata');
      final storedVersion = box.get(_VERSION_KEY, defaultValue: 0) as int;

      if (storedVersion < _CACHE_VERSION) {
        for (final level in CacheLevel.values) {
          await _hybridStorage.clearLevel(level);
        }
        await box.put(_VERSION_KEY, _CACHE_VERSION);
      }
    } catch (e) {
      debugPrint('⚠️ Error checking cache version: $e');
    }
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