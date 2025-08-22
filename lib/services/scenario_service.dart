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
      
      // Load cached scenarios into memory for fast search (without recursive call)
      if (_box != null && _box!.isNotEmpty) {
        _cachedScenarios = _box!.values.toList();
        _lastLocalFetch = DateTime.now();
        debugPrint('📚 Loaded ${_cachedScenarios.length} scenarios from cache');
      }
      
      _isInitialized = true;
      debugPrint('✅ ScenarioService initialized with ${_cachedScenarios.length} scenarios');
    } catch (e) {
      debugPrint('❌ Error initializing ScenarioService: $e');
    }
  }

  /// Load cached scenarios into memory
  Future<void> _loadCachedScenarios() async {
    try {
      if (_box != null && _box!.isNotEmpty) {
        _cachedScenarios = _box!.values.toList();
        _lastLocalFetch = DateTime.now();
        debugPrint('📚 Loaded ${_cachedScenarios.length} scenarios from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading cached scenarios: $e');
    }
  }

  /// Get all scenarios with cache-first approach
  Future<List<Scenario>> getAllScenarios() async {
    try {
      await _ensureInitialized();
      
      // PERFORMANCE OPTIMIZATION: Return cached scenarios immediately if available
      // This eliminates the loading delay users experience on scenarios screen
      if (_cachedScenarios.isNotEmpty) {
        debugPrint('⚡ Instant cache return: ${_cachedScenarios.length} scenarios');
        
        // Start background refresh if needed (non-blocking)
        if (_shouldRefreshFromServer()) {
          _refreshFromServer().catchError((e) {
            debugPrint('Background refresh failed: $e');
          });
        }
        
        return _cachedScenarios;
      }
      
      // First-time load: fetch from server
      if (_shouldRefreshFromServer()) {
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
  List<Scenario> searchScenarios(String query) {
    if (query.trim().isEmpty) {
      return _cachedScenarios;
    }
    
    final results = _cachedScenarios.where((scenario) => 
      _matchesSearchQuery(scenario, query.trim())
    ).toList();
    
    debugPrint('🔍 Local search for "$query": ${results.length} results');
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

  /// Internal method to refresh from server
  Future<void> _refreshFromServer() async {
    try {
      // Fetch all scenarios from server (increased limit to handle current 699+ scenarios)
      final serverScenarios = await _supabaseService.fetchScenarios(limit: 2000);
      
      if (serverScenarios.isNotEmpty) {
        // Clear existing cache and add new scenarios
        await _box?.clear();
        
        // Cache scenarios with their original keys for easy lookup
        final Map<String, Scenario> scenarioMap = {};
        for (int i = 0; i < serverScenarios.length; i++) {
          final scenario = serverScenarios[i];
          scenarioMap['scenario_$i'] = scenario;
        }
        
        await _box?.putAll(scenarioMap);
        
        // Update in-memory cache
        _cachedScenarios = serverScenarios;
        _lastLocalFetch = DateTime.now();
        
        // Update last sync timestamp
        final settingsBox = Hive.box('settings');
        await settingsBox.put(lastSyncKey, DateTime.now().toIso8601String());
        
        debugPrint('✅ Cached ${serverScenarios.length} scenarios from server');
      } else {
        debugPrint('⚠️ No scenarios received from server');
      }
      
    } catch (e) {
      debugPrint('❌ Error refreshing from server: $e');
      rethrow;
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
  bool _shouldRefreshFromServer() {
    // If no cached data, definitely refresh
    if (_cachedScenarios.isEmpty) return true;
    
    // Check last sync time from settings (30-day validity)
    try {
      final settingsBox = Hive.box('settings');
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
      final settingsBox = Hive.box('settings');
      await settingsBox.delete(lastSyncKey);
      
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
  Future<void> backgroundSync() async {
    try {
      if (_shouldRefreshFromServer()) {
        // Don't await - let it run in background
        _refreshFromServer().catchError((e) {
          debugPrint('Background sync failed: $e');
        });
      }
    } catch (e) {
      debugPrint('Error starting background sync: $e');
    }
  }

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}