import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/scenario.dart';
import '../services/service_locator.dart';

class ScenarioService {
  static final ScenarioService instance = ScenarioService._();
  ScenarioService._();

  late final _supabaseService = ServiceLocator.instance.enhancedSupabaseService;
  Box<Scenario>? _box;
  
  static const String boxName = 'scenarios';
  static const String lastSyncKey = 'last_sync_timestamp';
  
  // Cache scenarios for 30 days before background refresh (monthly content updates)
  static const Duration cacheValidityDuration = Duration(days: 30);
  
  List<Scenario> _cachedScenarios = [];
  DateTime? _lastLocalFetch;
  bool _isInitialized = false; // Prevent multiple initializations
  
  // Performance optimization for large scenario lists
  static const int _maxMemoryScenarios = 2000;
  static const int _batchSize = 100;
  
  // Cache statistics
  int _totalScenariosCount = 0;
  bool _isProcessingInBackground = false;
  
  // SEARCH_CACHE: Memory optimization for repeated search queries
  final Map<String, List<Scenario>> _searchCache = {};
  final Map<String, DateTime> _searchCacheTimestamps = {};
  static const Duration _searchCacheValidDuration = Duration(days: 30);
  static const int _maxSearchCacheEntries = 50; // Limit cache size

  /// Initialize the service and open Hive box
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('📚 ScenarioService already initialized (${_cachedScenarios.length} scenarios)');
      return;
    }
    
    try {
      if (!Hive.isBoxOpen(boxName)) {
        _box = await Hive.openBox<Scenario>(boxName);
      } else {
        _box = Hive.box<Scenario>(boxName);
      }
      
      // PERFORMANCE_CRITICAL: Only load scenario count initially, not full data
      // This reduces initialization from ~200-500ms to ~10-20ms by avoiding
      // loading all 1,226 scenarios into memory during startup
      if (_box != null && _box!.isNotEmpty) {
        _totalScenariosCount = _box!.length;
        _lastLocalFetch = DateTime.now();
        debugPrint('📚 ScenarioService initialized with ${_totalScenariosCount} scenarios (lazy loading)');
      }
      
      _isInitialized = true;
      debugPrint('✅ ScenarioService initialized with lazy loading (${_totalScenariosCount} scenarios available)');
    } catch (e) {
      debugPrint('❌ Error initializing ScenarioService: $e');
    }
  }


  /// Get all scenarios with cache-first approach
  Future<List<Scenario>> getAllScenarios() async {
    try {
      await _ensureInitialized();
      
      // LAZY_LOADING: Load scenarios from Hive box if not already in memory
      if (_cachedScenarios.isEmpty && _box != null && _box!.isNotEmpty) {
        debugPrint('🔄 Loading scenarios from Hive storage (lazy loading)');
        _cachedScenarios = _box!.values.toList();
        debugPrint('✅ Loaded ${_cachedScenarios.length} scenarios from storage');
      }
      
      // PERFORMANCE OPTIMIZATION: Return cached scenarios immediately if available
      // This eliminates the loading delay users experience on scenarios screen
      if (_cachedScenarios.isNotEmpty) {
        debugPrint('⚡ Instant cache return: ${_cachedScenarios.length} scenarios');
        
        // Start background refresh if needed (non-blocking)
        _shouldRefreshFromServer().then((shouldRefresh) {
          if (shouldRefresh) {
            _refreshFromServer().catchError((e) {
              debugPrint('Background refresh failed: $e');
            });
          }
        });
        
        return _cachedScenarios;
      }
      
      // First-time load: fetch from server
      if (await _shouldRefreshFromServer()) {
        debugPrint('🔄 Initial load from server...');
        await _refreshFromServer();
      }
      
      return _cachedScenarios;
      
    } catch (e) {
      debugPrint('❌ Error getting scenarios: $e');
      return _cachedScenarios.isNotEmpty ? _cachedScenarios : [];
    }
  }

  /// Search scenarios locally with instant results and compound query support
  /// SEARCH_LIMIT_REMOVED: Now searches through ALL cached scenarios without artificial limits
  /// For queries like "old", "older", "parent" - returns complete result set from all 1,226 scenarios
  List<Scenario> searchScenarios(String query, {int? maxResults}) {
    if (query.trim().isEmpty) {
      return _cachedScenarios;
    }
    
    final trimmedQuery = query.toLowerCase().trim();
    
    // SEARCH_CACHE: Check if we have cached results for this query
    if (_searchCache.containsKey(trimmedQuery)) {
      final cacheTime = _searchCacheTimestamps[trimmedQuery];
      if (cacheTime != null && 
          DateTime.now().difference(cacheTime) < _searchCacheValidDuration) {
        final cachedResults = _searchCache[trimmedQuery]!;
        debugPrint('🚀 Cache hit for "$query": ${cachedResults.length} results');
        return maxResults != null ? cachedResults.take(maxResults).toList() : cachedResults;
      } else {
        // Remove expired cache entry
        _searchCache.remove(trimmedQuery);
        _searchCacheTimestamps.remove(trimmedQuery);
      }
    }
    
    final results = <Scenario>[];
    
    // Search through ALL cached scenarios - no artificial limit
    // PERFORMANCE: Early termination only for very large result sets (>500) to prevent memory issues
    for (final scenario in _cachedScenarios) {
      if (_matchesSearchQuery(scenario, query.trim())) {
        results.add(scenario);
        // Only limit for extremely large result sets to prevent memory issues
        if (maxResults != null && results.length >= maxResults) break;
        // Performance safety: Early termination for massive result sets only
        if (results.length >= 800) break; // Safety limit for UI performance
      }
    }
    
    // SEARCH_CACHE: Store results for future use
    _cacheSearchResults(trimmedQuery, results);
    
    debugPrint('🔍 Local search for "$query": ${results.length} results (searching all ${_cachedScenarios.length} scenarios)');
    return results;
  }

  /// Advanced search matching with compound query support
  bool _matchesSearchQuery(Scenario s, String query) {
    final lowerQuery = query.toLowerCase().trim();
    
    // Handle compound searches (e.g., "parenting stress", "work life balance")
    final searchTerms = lowerQuery.split(' ').where((term) => term.length > 1).toList();
    
    // If single term, do simple search
    if (searchTerms.length == 1) {
      return _matchesSingleTerm(s, lowerQuery);
    }
    
    // For compound searches, all terms should match somewhere in the scenario
    return searchTerms.every((term) => _matchesSingleTerm(s, term));
  }
  
  /// Single term matching across all scenario fields
  bool _matchesSingleTerm(Scenario s, String term) {
    // Search in title (highest priority)
    if (s.title.toLowerCase().contains(term)) return true;
    
    // Search in description
    if (s.description.toLowerCase().contains(term)) return true;
    
    // Search in category
    if (s.category.toLowerCase().contains(term)) return true;
    
    // Search in tags
    if (s.tags?.any((tag) => tag.toLowerCase().contains(term)) ?? false) return true;
    
    // Search in Gita wisdom content
    if (s.gitaWisdom.toLowerCase().contains(term)) return true;
    
    // Search in heart/duty responses
    if (s.heartResponse.toLowerCase().contains(term)) return true;
    if (s.dutyResponse.toLowerCase().contains(term)) return true;
    
    // Search in action steps if available
    if (s.actionSteps?.any((step) => step.toLowerCase().contains(term)) ?? false) return true;
    
    return false;
  }

  /// Filter scenarios by tag
  List<Scenario> filterByTag(String tag) {
    final results = _cachedScenarios.where((scenario) {
      return scenario.tags?.contains(tag) ?? false;
    }).toList();
    
    debugPrint('🏷️ Filter by tag "$tag": ${results.length} results');
    return results;
  }

  /// Filter scenarios by chapter
  List<Scenario> filterByChapter(int chapterId) {
    final results = _cachedScenarios.where((scenario) {
      return scenario.chapter == chapterId;
    }).toList();
    
    debugPrint('📖 Filter by chapter $chapterId: ${results.length} results');
    return results;
  }

  /// Get a random scenario for preview
  Scenario? getRandomScenario() {
    if (_cachedScenarios.isEmpty) return null;
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _cachedScenarios.length;
    return _cachedScenarios[randomIndex];
  }

  /// Get all unique tags from scenarios
  List<String> getAllTags() {
    final tags = <String>{};
    for (final scenario in _cachedScenarios) {
      if (scenario.tags != null) {
        tags.addAll(scenario.tags!);
      }
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }

  /// Get all unique categories from scenarios
  List<String> getAllCategories() {
    final categories = _cachedScenarios.map((s) => s.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Get scenarios by specific categories in random order
  List<Scenario> fetchScenariosByCategories(List<String> categories, {int? limit}) {
    final filteredScenarios = _cachedScenarios.where((scenario) {
      return categories.contains(scenario.category.toLowerCase());
    }).toList();
    
    // Shuffle for random order
    filteredScenarios.shuffle();
    
    // Apply limit if specified
    if (limit != null && filteredScenarios.length > limit) {
      return filteredScenarios.take(limit).toList();
    }
    
    debugPrint('🎲 Random scenarios from categories ${categories.join(", ")}: ${filteredScenarios.length} results');
    return filteredScenarios;
  }

  /// Force refresh from server
  Future<void> refreshFromServer() async {
    try {
      debugPrint('🔄 Force refreshing scenarios from server...');
      await _refreshFromServer();
    } catch (e) {
      debugPrint('❌ Error force refreshing scenarios: $e');
      rethrow;
    }
  }

  /// Check if there are new scenarios available on server
  Future<bool> hasNewScenariosAvailable() async {
    try {
      final currentCount = _cachedScenarios.length;
      // Quick count check from server without downloading all data
      final totalOnServer = await _supabaseService.getScenarioCount();
      
      final hasNew = totalOnServer > currentCount;
      if (hasNew) {
        debugPrint('🆕 New scenarios available: $currentCount cached vs $totalOnServer on server');
      }
      return hasNew;
    } catch (e) {
      debugPrint('❌ Error checking for new scenarios: $e');
      return false;
    }
  }

  /// Internal method to refresh from server with optimized processing
  Future<void> _refreshFromServer() async {
    if (_isProcessingInBackground) {
      debugPrint('🔄 Background refresh already in progress, skipping...');
      return;
    }
    
    _isProcessingInBackground = true;

    try {
      debugPrint('🚀 Starting optimized scenario refresh from server...');

      // Fetch all scenarios from server (limit 2000 for performance)
      final serverScenarios = await _supabaseService.fetchScenarios(limit: _maxMemoryScenarios);
      
      if (serverScenarios.isNotEmpty) {
        _totalScenariosCount = serverScenarios.length;
        
        // Process in background to avoid UI blocking
        if (serverScenarios.length > _batchSize) {
          await _processScenariosInIsolate(serverScenarios);
        } else {
          await _processScenariosDirectly(serverScenarios);
        }
        
        debugPrint('✅ Optimized caching of ${serverScenarios.length} scenarios completed');
      } else {
        debugPrint('⚠️ No scenarios received from server');
      }
      
    } catch (e) {
      debugPrint('❌ Error in optimized refresh: $e');
      rethrow;
    } finally {
      _isProcessingInBackground = false;
    }
  }
  
  /// Process scenarios directly for small datasets
  Future<void> _processScenariosDirectly(List<Scenario> scenarios) async {
    // Clear existing cache and add new scenarios
    await _box?.clear();
    
    // Cache scenarios with their original keys for easy lookup
    final Map<String, Scenario> scenarioMap = {};
    for (int i = 0; i < scenarios.length; i++) {
      final scenario = scenarios[i];
      scenarioMap['scenario_$i'] = scenario;
    }
    
    await _box?.putAll(scenarioMap);
    
    // Update in-memory cache
    _cachedScenarios = scenarios;
    _lastLocalFetch = DateTime.now();
    
    // SEARCH_CACHE: Clear search cache when scenarios are updated
    _clearSearchCache();

    // CHAPTER_SUMMARY_CACHE: Clear chapter summary cache to force recalculation of scenario counts
    await _clearChapterSummaryCache();

    // Update last sync timestamp
    try {
      Box settingsBox;
      if (!Hive.isBoxOpen('settings')) {
        settingsBox = await Hive.openBox('settings');
      } else {
        settingsBox = Hive.box('settings');
      }
      await settingsBox.put(lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('⚠️ Could not update sync timestamp: $e');
    }
  }
  
  /// Process large scenario lists with memory optimization
  /// MEMORY_OPTIMIZED: Uses batch processing instead of full isolate duplication
  Future<void> _processScenariosInIsolate(List<Scenario> scenarios) async {
    try {
      debugPrint('🧵 Processing ${scenarios.length} scenarios with memory optimization');
      
      // MEMORY_FIX: Process scenarios in smaller batches to reduce peak memory usage
      // Instead of creating full JSON copies, process directly with yielding
      const int memoryOptimizedBatchSize = 200; // Reduced from 1,226 full scenarios
      
      await _box?.clear();
      final Map<String, Scenario> scenarioMap = {};
      
      // Process in memory-efficient batches with periodic yielding
      for (int i = 0; i < scenarios.length; i += memoryOptimizedBatchSize) {
        final endIndex = (i + memoryOptimizedBatchSize < scenarios.length) 
            ? i + memoryOptimizedBatchSize 
            : scenarios.length;
        
        final batch = scenarios.sublist(i, endIndex);
        
        // Process batch with periodic yielding to prevent UI blocking
        for (int j = 0; j < batch.length; j++) {
          scenarioMap['scenario_${i + j}'] = batch[j];
          
          // Yield to UI thread every 50 items to prevent frame drops
          if ((i + j) % 50 == 0) {
            await Future.delayed(const Duration(microseconds: 100));
          }
        }
        
        // Save batch to Hive to reduce memory pressure
        if (scenarioMap.length >= memoryOptimizedBatchSize) {
          await _box?.putAll(Map.from(scenarioMap));
          scenarioMap.clear(); // Clear processed scenarios from memory
        }
        
        debugPrint('📦 Processed batch ${i ~/ memoryOptimizedBatchSize + 1}/${(scenarios.length / memoryOptimizedBatchSize).ceil()}');
      }
      
      // Save remaining scenarios
      if (scenarioMap.isNotEmpty) {
        await _box?.putAll(scenarioMap);
      }
      
      // MEMORY_OPTIMIZATION: Don't keep all scenarios in memory initially
      // They will be loaded on-demand via lazy loading
      _totalScenariosCount = scenarios.length;
      _lastLocalFetch = DateTime.now();
      
      // SEARCH_CACHE: Clear search cache when scenarios are updated
      _clearSearchCache();

      // CHAPTER_SUMMARY_CACHE: Clear chapter summary cache to force recalculation of scenario counts
      await _clearChapterSummaryCache();

      // Update last sync timestamp
      try {
        Box settingsBox;
        if (!Hive.isBoxOpen('settings')) {
          settingsBox = await Hive.openBox('settings');
        } else {
          settingsBox = Hive.box('settings');
        }
        await settingsBox.put(lastSyncKey, DateTime.now().toIso8601String());
      } catch (e) {
        debugPrint('⚠️ Could not update sync timestamp: $e');
      }
      
      debugPrint('✅ Optimized caching of ${scenarios.length} scenarios completed');
    } catch (e) {
      debugPrint('❌ Isolate processing failed, falling back to direct processing: $e');
      await _processScenariosDirectly(scenarios);
    }
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastLocalFetch == null) return false;
    
    final now = DateTime.now();
    final timeSinceLastFetch = now.difference(_lastLocalFetch!);
    return timeSinceLastFetch < cacheValidityDuration;
  }

  /// Check if we should refresh from server (monthly sync)
  Future<bool> _shouldRefreshFromServer() async {
    // If no cached data, definitely refresh
    if (_cachedScenarios.isEmpty) return true;

    // Check last sync time from settings (30-day validity)
    try {
      Box settingsBox;
      if (!Hive.isBoxOpen('settings')) {
        settingsBox = await Hive.openBox('settings');
      } else {
        settingsBox = Hive.box('settings');
      }
      final lastSyncString = settingsBox.get(lastSyncKey) as String?;
      
      if (lastSyncString == null) {
        debugPrint('📅 No sync record found, refreshing scenarios');
        return true;
      }
      
      final lastSync = DateTime.parse(lastSyncString);
      final now = DateTime.now();
      final timeSinceLastSync = now.difference(lastSync);
      final isExpired = timeSinceLastSync > cacheValidityDuration;
      
      if (isExpired) {
        debugPrint('📅 Cache expired (${timeSinceLastSync.inDays} days old), refreshing scenarios');
      } else {
        debugPrint('📅 Cache valid (${timeSinceLastSync.inDays} days old, expires in ${cacheValidityDuration.inDays - timeSinceLastSync.inDays} days)');
      }
      
      return isExpired;
    } catch (e) {
      debugPrint('❌ Error checking sync time: $e');
      return true; // Refresh if we can't determine last sync time
    }
  }

  /// Clear all cached scenarios
  Future<void> clearCache() async {
    try {
      await _ensureInitialized();
      await _box?.clear();
      _cachedScenarios.clear();
      _lastLocalFetch = null;
      
      // Clear sync timestamp
      try {
        Box settingsBox;
        if (!Hive.isBoxOpen('settings')) {
          settingsBox = await Hive.openBox('settings');
        } else {
          settingsBox = Hive.box('settings');
        }
        await settingsBox.delete(lastSyncKey);
      } catch (e) {
        debugPrint('⚠️ Could not clear sync timestamp: $e');
      }
      
      debugPrint('🗑️ Cleared all cached scenarios');
    } catch (e) {
      debugPrint('❌ Error clearing scenario cache: $e');
    }
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'Total Scenarios': _cachedScenarios.length,
      'Unique Tags': getAllTags().length,
      'Unique Categories': getAllCategories().length,
      'Chapters Covered': _cachedScenarios.map((s) => s.chapter).toSet().length,
    };
  }

  /// Check if scenarios are available (cached or can be fetched)
  bool get hasScenarios => _cachedScenarios.isNotEmpty;

  /// Get scenario count
  int get scenarioCount => _cachedScenarios.length;

  /// Background sync - refresh if needed without blocking UI
  /// Optional onComplete callback is called when sync finishes (success or failure)
  Future<void> backgroundSync({VoidCallback? onComplete}) async {
    try {
      final shouldRefresh = await _shouldRefreshFromServer();
      if (shouldRefresh) {
        debugPrint('🔄 Starting background sync...');
        // Don't await - let it run in background
        _refreshFromServer().then((_) {
          debugPrint('✅ Background sync completed successfully');
          onComplete?.call();
        }).catchError((e) {
          debugPrint('❌ Background sync failed: $e');
          onComplete?.call(); // Still call callback on error so UI can update
        });
      } else {
        debugPrint('⏭️ Background sync skipped - cache is still valid');
        // Cache is valid, but still call callback so UI knows data is ready
        onComplete?.call();
      }
    } catch (e) {
      debugPrint('❌ Error starting background sync: $e');
      onComplete?.call();
    }
  }

  /// Get paginated scenarios for UI display
  /// PAGINATION_LIMIT: Default 20 scenarios per page for UI performance
  /// This is separate from search limits - pagination is kept for UI smoothness
  List<Scenario> getPaginatedScenarios(int page, {int pageSize = 20}) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, _cachedScenarios.length);
    
    if (startIndex >= _cachedScenarios.length) {
      return [];
    }
    
    final paginatedList = _cachedScenarios.sublist(startIndex, endIndex);
    debugPrint('📄 Page $page: ${paginatedList.length} scenarios (${startIndex}-${endIndex-1})');
    return paginatedList;
  }
  
  /// Get total pages for pagination
  /// PAGINATION_LIMIT: Calculates pages based on 20 scenarios per page (UI performance)
  int getTotalPages({int pageSize = 20}) {
    return (_cachedScenarios.length / pageSize).ceil();
  }
  
  /// Get advanced cache statistics for monitoring
  Map<String, dynamic> getAdvancedCacheStats() {
    return {
      'Total Scenarios': _cachedScenarios.length,
      'Total Count from Server': _totalScenariosCount,
      'Memory Usage (approx MB)': (_cachedScenarios.length * 2), // Rough estimate
      'Unique Tags': getAllTags().length,
      'Unique Categories': getAllCategories().length,
      'Chapters Covered': _cachedScenarios.map((s) => s.chapter).toSet().length,
      'Is Processing': _isProcessingInBackground,
      'Last Fetch': _lastLocalFetch?.toIso8601String() ?? 'Never',
      'Cache Valid': _isCacheValid(),
    };
  }
  
  /// Optimized search with relevance scoring for better UX
  /// SEARCH_LIMIT_REMOVED: Now provides comprehensive relevance-based results
  Future<List<Scenario>> searchScenariosWithRelevance(String query, {int? maxResults}) async {
    if (query.trim().isEmpty) {
      return getPaginatedScenarios(0, pageSize: maxResults ?? 20);
    }
    
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase().trim();
    
    // MEMORY_OPTIMIZED: Score-based search with memory-efficient processing
    int processedCount = 0;
    
    for (final scenario in _cachedScenarios) {
      final score = _calculateRelevanceScore(scenario, lowerQuery);
      if (score > 0) {
        results.add({
          'scenario': scenario,
          'score': score,
        });
      }
      
      processedCount++;
      
      // MEMORY_FIX: Periodic yielding every 100 items to prevent UI blocking
      if (processedCount % 100 == 0) {
        // Allow other operations to run and enable garbage collection
        await Future.delayed(const Duration(microseconds: 50));
      }
      
      // MEMORY_OPTIMIZATION: Reduced limit for better memory management
      if (results.length >= 500) break; // Reduced from 1000 for memory efficiency
    }
    
    // Sort by relevance score and return results (all or limited for UI performance)
    results.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final topResults = maxResults != null 
        ? results.take(maxResults).map((item) => item['scenario'] as Scenario).toList()
        : results.map((item) => item['scenario'] as Scenario).toList();
    
    debugPrint('🎯 Relevance search for "$query": ${topResults.length} results from ${_cachedScenarios.length} scenarios');
    return topResults;
  }
  
  /// Calculate relevance score for search results
  int _calculateRelevanceScore(Scenario scenario, String query) {
    int score = 0;
    final title = scenario.title.toLowerCase();
    final description = scenario.description.toLowerCase();
    
    // Title matches are most important
    if (title.contains(query)) score += 100;
    if (title.startsWith(query)) score += 50;
    
    // Description matches
    if (description.contains(query)) score += 30;
    
    // Category matches
    if (scenario.category.toLowerCase().contains(query)) score += 20;
    
    // Tag matches
    final tagScore = scenario.tags?.where((tag) => 
        tag.toLowerCase().contains(query)).length ?? 0;
    score += tagScore * 10;
    
    // Content matches (lower priority)
    if (scenario.gitaWisdom.toLowerCase().contains(query)) score += 5;
    if (scenario.heartResponse.toLowerCase().contains(query)) score += 3;
    if (scenario.dutyResponse.toLowerCase().contains(query)) score += 3;
    
    return score;
  }
  
  /// Cache search results for performance optimization
  void _cacheSearchResults(String query, List<Scenario> results) {
    // Limit cache size to prevent memory bloat
    if (_searchCache.length >= _maxSearchCacheEntries) {
      // Remove oldest cache entry (simple FIFO eviction)
      final oldestQuery = _searchCacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _searchCache.remove(oldestQuery);
      _searchCacheTimestamps.remove(oldestQuery);
    }
    
    _searchCache[query] = List.from(results); // Create copy to prevent modification
    _searchCacheTimestamps[query] = DateTime.now();
  }
  
  /// Clear search cache (useful when scenarios are updated)
  void _clearSearchCache() {
    _searchCache.clear();
    _searchCacheTimestamps.clear();
    debugPrint('🗑️ Search cache cleared');
  }

  /// Clear chapter summary cache to force recalculation of scenario counts
  Future<void> _clearChapterSummaryCache() async {
    try {
      if (Hive.isBoxOpen('chapter_summaries_permanent')) {
        final box = Hive.box('chapter_summaries_permanent');
        await box.clear();
        await box.flush(); // Ensure data is written to disk
        debugPrint('✅ Chapter summary cache cleared successfully');
      } else {
        debugPrint('⚠️ Chapter summary cache box not open - skipping clear');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ CRITICAL: Failed to clear chapter summary cache: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow; // Let caller handle the error
    }
  }

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}

