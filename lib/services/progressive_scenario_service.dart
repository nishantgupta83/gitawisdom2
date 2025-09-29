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
    if (_isInitialized) {
      debugPrint('📚 ProgressiveScenarioService already initialized');
      return;
    }

    try {
      debugPrint('📚 Initializing ProgressiveScenarioService with instant startup...');

      // Initialize intelligent caching service
      await _cachingService.initialize();

      _isInitialized = true;
      debugPrint('✅ ProgressiveScenarioService initialized - app ready for use!');

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
      // For home screen: limit to 50 for performance, for search: no limit
      final homeScreenLimit = maxResults ?? 50;
      return _getInstantScenarios(maxResults: homeScreenLimit);
    }

    // For actual search queries, use intelligent search with NO LIMITS
    return _searchInLoadedScenarios(query, maxResults: maxResults);
  }

  /// Get scenarios instantly from critical cache for home screen
  List<Scenario> _getInstantScenarios({int? maxResults}) {
    try {
      // Get critical scenarios from cache (synchronous for instant access)
      final criticalScenarios = _getCriticalScenariosSync();

      if (criticalScenarios.isNotEmpty) {
        // Shuffle for variety and limit results
        final shuffled = List<Scenario>.from(criticalScenarios)..shuffle();
        final results = maxResults != null
            ? shuffled.take(maxResults).toList()
            : shuffled;

        debugPrint('⚡ Instant scenarios: ${results.length} from critical cache');
        return results;
      }

      debugPrint('⚠️ No critical scenarios available yet - background loading in progress');
      return [];

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

  /// Search in currently loaded scenarios (synchronous with available data)
  List<Scenario> _searchInLoadedScenarios(String query, {int? maxResults}) {
    try {
      debugPrint('🔍 Searching in loaded scenarios for: "$query"');

      // Get all available scenarios from cache
      final allAvailable = <Scenario>[];

      // Get critical scenarios first (fastest access)
      final criticalScenarios = _getCriticalScenariosSync();
      allAvailable.addAll(criticalScenarios);

      // Filter by search query
      final filteredResults = _filterScenariosByQuery(allAvailable, query);

      // Apply maxResults limit only if specified
      final finalResults = maxResults != null && maxResults > 0
          ? filteredResults.take(maxResults).toList()
          : filteredResults;

      debugPrint('🔍 Search completed: ${finalResults.length} results for "$query"');
      return finalResults;

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
      debugPrint('🔄 Force refreshing scenarios...');
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
      debugPrint('🔍 Checking for new scenarios on server...');

      // Get current local count
      final localCount = scenarioCount;

      // Get server count (simplified check)
      // In real implementation, this would make a lightweight API call
      // For now, we assume there might be new scenarios if local count is low
      if (localCount < 1000) {
        debugPrint('📊 Local scenarios ($localCount) < 1000, might have new content');
        return true;
      }

      debugPrint('📊 Local scenarios ($localCount) seems complete');
      return false;

    } catch (e) {
      debugPrint('❌ Error checking for new scenarios: $e');
      return false;
    }
  }

  /// Background sync - non-blocking refresh check
  /// Optional onComplete callback is called when sync finishes (success or failure)
  Future<void> backgroundSync({VoidCallback? onComplete}) async {
    try {
      // Check if refresh is needed and start background loading if necessary
      // This is non-blocking and won't affect UI performance
      final hasNew = await hasNewScenariosAvailable();
      if (hasNew) {
        debugPrint('🔄 Starting background sync...');
        // Start background refresh without blocking
        refreshFromServer().then((_) {
          debugPrint('✅ Background sync completed successfully');
          onComplete?.call();
        }).catchError((e) {
          debugPrint('❌ Background refresh failed: $e');
          onComplete?.call(); // Still call callback on error so UI can update
        });
      } else {
        debugPrint('⏭️ Background sync skipped - cache is still valid');
        // Cache is valid, but still call callback so UI knows data is ready
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
      debugPrint('🗑️ Clearing all scenario caches...');

      // Clear each cache level through the intelligent caching service
      await _cachingService.refreshFromServer(); // This clears and refreshes all caches

      // Force re-initialization
      _isInitialized = false;
      await initialize();

      debugPrint('✅ All caches cleared and re-initialized');
    } catch (e) {
      debugPrint('❌ Error clearing caches: $e');
      rethrow;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _cachingService.dispose();
    debugPrint('📚 ProgressiveScenarioService disposed');
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

  /// Get all scenarios - returns progressively loaded scenarios
  /// Note: This no longer blocks on loading ALL scenarios
  Future<List<Scenario>> getAllScenarios() async {
    // Wait for critical scenarios to be ready
    await _progressiveService.waitForCriticalScenarios();

    // Return currently available scenarios (may be partial dataset)
    return _progressiveService.searchScenarios(''); // Empty query returns all available
  }

  /// Search scenarios - works with progressively loaded data
  List<Scenario> searchScenarios(String query, {int? maxResults}) {
    return _progressiveService.searchScenarios(query, maxResults: maxResults);
  }

  /// Check if scenarios are available - now returns true for critical scenarios
  bool get hasScenarios => _progressiveService.hasScenarios;

  /// Get scenario count - returns count of currently loaded scenarios
  int get scenarioCount => _progressiveService.scenarioCount;

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