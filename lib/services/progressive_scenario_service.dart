// lib/services/progressive_scenario_service.dart

import 'package:flutter/foundation.dart';

import '../models/scenario.dart';
import '../services/intelligent_caching_service.dart';
import '../services/progressive_cache_service.dart';

/// Progressive ScenarioService that provides instant startup and background loading
/// This service replaces the monolithic ScenarioService with intelligent caching
class ProgressiveScenarioService {
  static final ProgressiveScenarioService instance = ProgressiveScenarioService._();
  ProgressiveScenarioService._();

  late final IntelligentCachingService _cachingService = IntelligentCachingService.instance;

  bool _isInitialized = false;

  /// Initialize the progressive service - instant startup with critical scenarios
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _cachingService.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Error initializing ProgressiveScenarioService: $e');
      rethrow;
    }
  }

  /// Check if scenarios are available for immediate use (critical scenarios)
  /// This allows home screen to work instantly without waiting for full dataset
  bool get hasScenarios => _cachingService.hasCriticalScenarios;

  /// Get scenarios count from currently loaded cache levels
  int get scenarioCount {
    final counts = _cachingService.getProgress()['cacheCounts'] as Map<CacheLevel, int>? ?? {};
    return counts.values.fold(0, (sum, count) => sum + count);
  }

  /// Get scenarios for immediate use (home screen dilemmas)
  /// Returns critical scenarios instantly, no waiting for full dataset
  List<Scenario> searchScenarios(String query, {int? maxResults}) {
    // For home screen dilemmas (empty query), return critical scenarios
    if (query.trim().isEmpty) {
      // If maxResults is not specified, return ALL available scenarios from critical cache
      // If maxResults is specified, respect the limit
      return _getInstantScenarios(maxResults: maxResults);
    }

    // For actual search queries, use intelligent search with NO LIMITS
    return _searchInLoadedScenarios(query, maxResults: maxResults);
  }

  /// Get scenarios instantly from all available cache levels for home screen
  List<Scenario> _getInstantScenarios({int? maxResults}) {
    try {
      final allScenarios = _getAllLoadedScenariosSync();
      if (allScenarios.isEmpty) return [];

      final shuffled = List<Scenario>.from(allScenarios)..shuffle();
      return maxResults != null ? shuffled.take(maxResults).toList() : shuffled;
    } catch (e) {
      debugPrint('❌ Error getting instant scenarios: $e');
      return [];
    }
  }

  /// Get critical scenarios synchronously for instant access
  List<Scenario> _getCriticalScenariosSync() {
    try {
      // Get critical scenarios synchronously from intelligent caching service
      return _cachingService.getCriticalScenariosSync();
    } catch (e) {
      debugPrint('❌ Error getting critical scenarios sync: $e');
      return [];
    }
  }

  /// Get ALL loaded scenarios synchronously from ALL cache levels
  List<Scenario> _getAllLoadedScenariosSync() {
    try {
      return _getCriticalScenariosSync();
    } catch (e) {
      debugPrint('❌ Error getting all loaded scenarios sync: $e');
      return [];
    }
  }

  /// Search in currently loaded scenarios (synchronous with available data)
  List<Scenario> _searchInLoadedScenarios(String query, {int? maxResults}) {
    try {
      final allAvailable = _getAllLoadedScenariosSync();
      final filteredResults = _filterScenariosByQuery(allAvailable, query);
      return maxResults != null && maxResults > 0
          ? filteredResults.take(maxResults).toList()
          : filteredResults;
    } catch (e) {
      debugPrint('❌ Error searching scenarios: $e');
      return [];
    }
  }

  /// Filter scenarios by search query using multiple criteria
  List<Scenario> _filterScenariosByQuery(List<Scenario> scenarios, String query) {
    if (query.trim().isEmpty) return scenarios;

    final lowerQuery = query.toLowerCase();
    return scenarios.where((scenario) {
      return scenario.title.toLowerCase().contains(lowerQuery) ||
             scenario.description.toLowerCase().contains(lowerQuery) ||
             scenario.category.toLowerCase().contains(lowerQuery) ||
             (scenario.heartResponse?.toLowerCase().contains(lowerQuery) ?? false) ||
             (scenario.dutyResponse?.toLowerCase().contains(lowerQuery) ?? false) ||
             (scenario.gitaWisdom?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Async search across all loaded cache levels
  Future<List<Scenario>> searchScenariosAsync(String query, {int? maxResults}) async {
    try {
      return await _cachingService.searchScenarios(query, maxResults: maxResults);
    } catch (e) {
      debugPrint('❌ Error in async search: $e');
      return [];
    }
  }

  /// Get specific scenario by ID
  Future<Scenario?> getScenario(String id) async {
    try {
      return await _cachingService.getScenario(id);
    } catch (e) {
      debugPrint('❌ Error getting scenario $id: $e');
      return null;
    }
  }

  /// Wait for critical scenarios to be ready (for app startup)
  Future<void> waitForCriticalScenarios() async {
    await _cachingService.waitForCriticalScenarios();
  }

  /// Force refresh all scenarios from server
  Future<void> refreshFromServer() async {
    try {
      await _cachingService.refreshFromServer();
    } catch (e) {
      debugPrint('❌ Error refreshing from server: $e');
      rethrow;
    }
  }

  /// Get loading progress for UI indicators
  Map<String, dynamic> getLoadingProgress() {
    return _cachingService.getProgress();
  }

  /// Check if new scenarios are available on server
  Future<bool> hasNewScenariosAvailable() async {
    try {
      final localCount = scenarioCount;
      return localCount < 1000;
    } catch (e) {
      debugPrint('❌ Error checking for new scenarios: $e');
      return false;
    }
  }

  /// Background sync - non-blocking refresh check
  Future<void> backgroundSync({VoidCallback? onComplete}) async {
    try {
      final hasNew = await hasNewScenariosAvailable();
      if (hasNew) {
        refreshFromServer().then((_) {
          onComplete?.call();
        }).catchError((e) {
          debugPrint('❌ Background refresh failed: $e');
          onComplete?.call();
        });
      } else {
        onComplete?.call();
      }
    } catch (e) {
      debugPrint('❌ Background sync failed: $e');
      onComplete?.call();
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return _cachingService.getProgress();
  }

  /// Clear all caches (for testing/development)
  Future<void> clearAllCaches() async {
    try {
      await _cachingService.refreshFromServer();
      _isInitialized = false;
      await initialize();
    } catch (e) {
      debugPrint('❌ Error clearing caches: $e');
      rethrow;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _cachingService.dispose();
  }
}

/// Legacy compatibility layer for existing code
/// This allows gradual migration from old ScenarioService to ProgressiveScenarioService
class ScenarioServiceAdapter {
  static final ScenarioServiceAdapter instance = ScenarioServiceAdapter._();
  ScenarioServiceAdapter._();

  late final ProgressiveScenarioService _progressiveService = ProgressiveScenarioService.instance;

  /// Initialize - delegates to progressive service
  Future<void> initialize() async {
    await _progressiveService.initialize();
  }

  /// Get all scenarios - returns progressively loaded scenarios from ALL cache levels
  /// Note: This accesses the complete dataset, not just critical scenarios
  Future<List<Scenario>> getAllScenarios() async {
    // Wait for critical scenarios to be ready
    await _progressiveService.waitForCriticalScenarios();

    // Use intelligent caching service to get ALL scenarios across all cache levels
    return await _progressiveService.searchScenariosAsync(''); // Empty query with async search across all levels
  }

  /// Search scenarios - works with progressively loaded data
  List<Scenario> searchScenarios(String query, {int? maxResults}) {
    return _progressiveService.searchScenarios(query, maxResults: maxResults);
  }

  /// Check if scenarios are available - now returns true for critical scenarios
  bool get hasScenarios => _progressiveService.hasScenarios;

  /// Get scenario count - returns count of currently loaded scenarios
  int get scenarioCount => _progressiveService.scenarioCount;

  /// Get loading progress for UI indicators (splash screen, progress bars)
  /// Returns map with keys: 'loaded', 'total', 'percentage'
  Map<String, dynamic> get loadingProgress => _progressiveService.getLoadingProgress();

  /// Refresh from server
  Future<void> refreshFromServer() async {
    await _progressiveService.refreshFromServer();
  }

  /// Background sync with optional completion callback
  Future<void> backgroundSync({VoidCallback? onComplete}) async {
    await _progressiveService.backgroundSync(onComplete: onComplete);
  }

  /// Filter scenarios by chapter
  List<Scenario> filterByChapter(int chapterId) {
    // Get all available scenarios and filter by chapter
    final allScenarios = _progressiveService.searchScenarios('');
    return allScenarios.where((scenario) =>
      scenario.chapter == chapterId
    ).toList();
  }

  /// Check if new scenarios are available
  Future<bool> hasNewScenariosAvailable() async {
    return await _progressiveService.hasNewScenariosAvailable();
  }
}