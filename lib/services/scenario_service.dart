import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/scenario.dart';
import '../services/supabase_service.dart';

class ScenarioService {
  static final ScenarioService instance = ScenarioService._();
  ScenarioService._();

  final SupabaseService _supabaseService = SupabaseService();
  Box<Scenario>? _box;
  
  static const String boxName = 'scenarios';
  static const String lastSyncKey = 'last_sync_timestamp';
  
  // Cache scenarios for 24 hours before background refresh
  static const Duration cacheValidityDuration = Duration(hours: 24);
  
  List<Scenario> _cachedScenarios = [];
  DateTime? _lastLocalFetch;

  /// Initialize the service and open Hive box
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        _box = await Hive.openBox<Scenario>(boxName);
      } else {
        _box = Hive.box<Scenario>(boxName);
      }
      
      // Load cached scenarios into memory for fast search
      await _loadCachedScenarios();
      
      debugPrint('✅ ScenarioService initialized with ${_cachedScenarios.length} scenarios');
    } catch (e) {
      debugPrint('❌ Error initializing ScenarioService: $e');
    }
  }

  /// Load cached scenarios into memory
  Future<void> _loadCachedScenarios() async {
    try {
      await _ensureInitialized();
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
      
      // Return cached scenarios immediately if available and fresh
      if (_cachedScenarios.isNotEmpty && _isCacheValid()) {
        debugPrint('📚 Using cached scenarios (${_cachedScenarios.length} items)');
        return _cachedScenarios;
      }
      
      // Check if we need to refresh from server
      if (_shouldRefreshFromServer()) {
        debugPrint('🔄 Refreshing scenarios from server...');
        await _refreshFromServer();
      }
      
      // Return cached scenarios (may be empty if first run)
      return _cachedScenarios;
      
    } catch (e) {
      debugPrint('❌ Error getting scenarios: $e');
      // Fallback to cached data if available
      return _cachedScenarios.isNotEmpty ? _cachedScenarios : [];
    }
  }

  /// Search scenarios locally with instant results
  List<Scenario> searchScenarios(String query) {
    if (query.trim().isEmpty) {
      return _cachedScenarios;
    }
    
    final searchLower = query.toLowerCase().trim();
    final results = _cachedScenarios.where((scenario) {
      return scenario.title.toLowerCase().contains(searchLower) ||
             scenario.description.toLowerCase().contains(searchLower) ||
             scenario.category.toLowerCase().contains(searchLower) ||
             scenario.gitaWisdom.toLowerCase().contains(searchLower) ||
             (scenario.tags?.any((tag) => tag.toLowerCase().contains(searchLower)) ?? false);
    }).toList();
    
    debugPrint('🔍 Local search for "$query": ${results.length} results');
    return results;
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

  /// Internal method to refresh from server
  Future<void> _refreshFromServer() async {
    try {
      // Fetch all scenarios from server (no pagination limit for full cache)
      final serverScenarios = await _supabaseService.fetchScenarios(limit: 1000);
      
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

  /// Check if we should refresh from server
  bool _shouldRefreshFromServer() {
    // If no cached data, definitely refresh
    if (_cachedScenarios.isEmpty) return true;
    
    // Check last sync time from settings
    try {
      final settingsBox = Hive.box('settings');
      final lastSyncString = settingsBox.get(lastSyncKey) as String?;
      
      if (lastSyncString == null) return true;
      
      final lastSync = DateTime.parse(lastSyncString);
      final now = DateTime.now();
      final timeSinceLastSync = now.difference(lastSync);
      
      return timeSinceLastSync > cacheValidityDuration;
    } catch (e) {
      debugPrint('Error checking sync time: $e');
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
    if (_box == null) {
      await initialize();
    }
  }
}