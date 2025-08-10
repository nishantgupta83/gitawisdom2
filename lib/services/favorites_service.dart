// lib/services/favorites_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/user_favorite.dart';
import '../services/supabase_service.dart';

class FavoritesService {
  static final FavoritesService instance = FavoritesService._();
  FavoritesService._();

  final SupabaseService _supabaseService = SupabaseService();
  Box<UserFavorite>? _box;
  
  static const String boxName = 'user_favorites';
  static const String lastSyncKey = 'favorites_last_sync_timestamp';
  
  // Cache favorites for 1 hour before background refresh
  static const Duration cacheValidityDuration = Duration(hours: 1);
  
  Set<String> _cachedFavorites = {}; // Set for fast lookup
  DateTime? _lastLocalFetch;

  /// Initialize the service and open Hive box
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        _box = await Hive.openBox<UserFavorite>(boxName);
      } else {
        _box = Hive.box<UserFavorite>(boxName);
      }
      
      // Load cached favorites into memory
      await _loadCachedFavorites();
      
      debugPrint('✅ FavoritesService initialized with ${_cachedFavorites.length} favorites');
    } catch (e) {
      debugPrint('❌ Error initializing FavoritesService: $e');
    }
  }

  /// Load cached favorites into memory
  Future<void> _loadCachedFavorites() async {
    try {
      await _ensureInitialized();
      if (_box != null && _box!.isNotEmpty) {
        _cachedFavorites = _box!.values.map((f) => f.scenarioTitle).toSet();
        _lastLocalFetch = DateTime.now();
        debugPrint('💝 Loaded ${_cachedFavorites.length} favorites from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading cached favorites: $e');
    }
  }

  /// Check if a scenario is favorited
  bool isFavorited(String scenarioTitle) {
    return _cachedFavorites.contains(scenarioTitle);
  }

  /// Get all favorited scenario titles
  Set<String> get allFavorites => Set.from(_cachedFavorites);

  /// Toggle favorite status of a scenario
  Future<bool> toggleFavorite(String scenarioTitle) async {
    try {
      await _ensureInitialized();
      
      final isCurrentlyFavorited = isFavorited(scenarioTitle);
      
      if (isCurrentlyFavorited) {
        // Remove from favorites
        await _removeFavorite(scenarioTitle);
        return false;
      } else {
        // Add to favorites
        await _addFavorite(scenarioTitle);
        return true;
      }
    } catch (e) {
      debugPrint('❌ Error toggling favorite for $scenarioTitle: $e');
      rethrow;
    }
  }

  /// Add a scenario to favorites
  Future<void> _addFavorite(String scenarioTitle) async {
    try {
      final favorite = UserFavorite(scenarioTitle: scenarioTitle);
      
      // Store locally first
      await _box!.put(scenarioTitle, favorite);
      _cachedFavorites.add(scenarioTitle);
      
      // Sync to server in background
      try {
        await _supabaseService.insertFavorite(scenarioTitle);
        debugPrint('✅ Favorite synced to server: $scenarioTitle');
      } catch (e) {
        debugPrint('⚠️ Failed to sync favorite to server: $e');
        // Favorite is still saved locally, will sync later
      }
      
    } catch (e) {
      debugPrint('❌ Error adding favorite locally: $e');
      rethrow;
    }
  }

  /// Remove a scenario from favorites
  Future<void> _removeFavorite(String scenarioTitle) async {
    try {
      // Remove locally first
      await _box!.delete(scenarioTitle);
      _cachedFavorites.remove(scenarioTitle);
      
      // Sync to server in background
      try {
        await _supabaseService.removeFavorite(scenarioTitle);
        debugPrint('✅ Favorite removal synced to server: $scenarioTitle');
      } catch (e) {
        debugPrint('⚠️ Failed to sync favorite removal to server: $e');
        // Favorite is still removed locally, will sync later
      }
      
    } catch (e) {
      debugPrint('❌ Error removing favorite locally: $e');
      rethrow;
    }
  }

  /// Force refresh from server
  Future<void> refreshFromServer() async {
    try {
      debugPrint('🔄 Refreshing favorites from server...');
      await _refreshFromServer();
    } catch (e) {
      debugPrint('❌ Error refreshing favorites from server: $e');
      rethrow;
    }
  }

  /// Internal method to refresh from server
  Future<void> _refreshFromServer() async {
    try {
      final serverFavorites = await _supabaseService.fetchFavorites();
      
      // Clear and rebuild cache
      await _box!.clear();
      _cachedFavorites.clear();
      
      // Add server favorites to local cache
      for (final scenarioTitle in serverFavorites) {
        // Create UserFavorite with current timestamp since server doesn't provide it
        final favorite = UserFavorite(
          scenarioTitle: scenarioTitle,
          favoritedAt: DateTime.now(), // Use current time as fallback
        );
        await _box!.put(scenarioTitle, favorite);
        _cachedFavorites.add(scenarioTitle);
      }
      
      _lastLocalFetch = DateTime.now();
      
      // Update last sync timestamp
      final settingsBox = Hive.box('settings');
      await settingsBox.put(lastSyncKey, DateTime.now().toIso8601String());
      
      debugPrint('✅ Synced ${serverFavorites.length} favorites from server');
      
    } catch (e) {
      debugPrint('❌ Error refreshing favorites from server: $e');
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
    if (_cachedFavorites.isEmpty) return true;
    
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

  /// Background sync - refresh if needed without blocking UI
  Future<void> backgroundSync() async {
    try {
      if (_shouldRefreshFromServer()) {
        // Don't await - let it run in background
        _refreshFromServer().catchError((e) {
          debugPrint('Background favorites sync failed: $e');
        });
      }
    } catch (e) {
      debugPrint('Error starting background favorites sync: $e');
    }
  }

  /// Clear all cached favorites
  Future<void> clearCache() async {
    try {
      await _ensureInitialized();
      await _box?.clear();
      _cachedFavorites.clear();
      _lastLocalFetch = null;
      
      // Clear sync timestamp
      final settingsBox = Hive.box('settings');
      await settingsBox.delete(lastSyncKey);
      
      debugPrint('🗑️ Cleared all cached favorites');
    } catch (e) {
      debugPrint('❌ Error clearing favorites cache: $e');
    }
  }

  /// Get favorites count
  int get favoritesCount => _cachedFavorites.length;

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
  }
}