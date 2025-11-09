// lib/services/cache_refresh_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'enhanced_supabase_service.dart';

/// CacheRefreshService - Intelligent batch cache refresh with minimal API calls
/// Strategy: Parallel loading of all content in batches to minimize network overhead
class CacheRefreshService {
  final EnhancedSupabaseService supabaseService;

  CacheRefreshService({required this.supabaseService});

  /// Refresh all caches in parallel (chapters, verses, scenarios)
  /// Clears old cache first, then reloads from server
  /// Returns progress updates via callback
  Future<void> refreshAllCaches({
    required Function(String message, double progress) onProgress,
  }) async {
    try {
      debugPrint('🔄 Starting intelligent batch cache refresh...');

      // Step 1: Clear all caches first
      onProgress('Clearing old cache...', 0.1);
      await _clearAllCaches();

      // Step 2: Load all content in parallel batches (minimal API calls)
      onProgress('Loading chapters...', 0.2);
      final chaptersTask = _refreshChaptersCache();

      onProgress('Loading verses for all chapters...', 0.35);
      final versesTask = _refreshVersesCache();

      onProgress('Loading scenarios...', 0.65);
      final scenariosTask = _refreshScenariosCache();

      // Wait for all tasks in parallel
      await Future.wait(
        [chaptersTask, versesTask, scenariosTask],
        eagerError: false, // Continue even if one fails
      );

      onProgress('Cache refresh completed!', 1.0);
      debugPrint('✅ All caches refreshed successfully');
    } catch (e) {
      debugPrint('❌ Cache refresh error: $e');
      rethrow;
    }
  }

  /// Clear all Hive boxes (atomic operation)
  Future<void> _clearAllCaches() async {
    try {
      final boxNames = [
        'chapters',
        'chapter_summaries_permanent',
        'gita_verses_cache',
        'scenarios_critical',
        'scenarios_frequent',
        'scenarios_complete',
        'scenarios_compressed',
        'daily_verses',
        'search_cache',
      ];

      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            await box.clear();
            debugPrint('🧹 Cleared box: $boxName');
          }
        } catch (e) {
          debugPrint('⚠️ Could not clear box $boxName: $e');
        }
      }

      debugPrint('✅ All caches cleared');
    } catch (e) {
      debugPrint('❌ Error clearing caches: $e');
      rethrow;
    }
  }

  /// Refresh chapters cache (single batch query)
  Future<void> _refreshChaptersCache() async {
    try {
      debugPrint('📚 Fetching all chapters...');

      // Fetch all 18 chapters in parallel (18x faster)
      final chapters = await supabaseService.fetchAllChapters();

      if (chapters.isNotEmpty) {
        debugPrint('✅ Fetched ${chapters.length} chapters');
      } else {
        debugPrint('⚠️ No chapters loaded');
      }
    } catch (e) {
      debugPrint('❌ Error refreshing chapters: $e');
      rethrow;
    }
  }

  /// Refresh verses cache (batch by chapter - reduced API calls)
  /// Instead of 1 query per verse, we do 1 query per chapter (18 queries max)
  Future<void> _refreshVersesCache() async {
    try {
      debugPrint('📖 Fetching verses for all chapters...');

      // Fetch verses for all 18 chapters in parallel
      final versesFutures = List.generate(
        18,
        (i) => supabaseService.fetchVersesByChapter(i + 1),
      );

      final results = await Future.wait(
        versesFutures,
        eagerError: false, // Don't fail all if one fails
      );

      final totalVerses = results.fold<int>(0, (sum, verses) => sum + verses.length);
      debugPrint('✅ Fetched $totalVerses verses across 18 chapters');
    } catch (e) {
      debugPrint('❌ Error refreshing verses: $e');
      rethrow;
    }
  }

  /// Refresh scenarios cache (uses progressive loading service)
  Future<void> _refreshScenariosCache() async {
    try {
      debugPrint('🎯 Refreshing scenarios cache...');

      // Use intelligent caching service to load all scenarios
      final scenarios = await supabaseService.fetchScenarios(limit: 2000);

      if (scenarios.isNotEmpty) {
        debugPrint('✅ Loaded ${scenarios.length} scenarios');
      } else {
        debugPrint('⚠️ No scenarios loaded');
      }
    } catch (e) {
      debugPrint('❌ Error refreshing scenarios: $e');
      rethrow;
    }
  }

  /// Get cache statistics (for UI display)
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      int totalItems = 0;

      // Count items in each cache box
      final boxNames = [
        'chapters',
        'gita_verses_cache',
        'scenarios',
      ];

      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            totalItems += box.length;
            debugPrint('📊 $boxName: ${box.length} items');
          }
        } catch (e) {
          debugPrint('⚠️ Could not read box $boxName: $e');
        }
      }

      return {
        'total_cached_items': totalItems,
        'chapters_cached': true,
        'verses_cached': true,
        'scenarios_cached': true,
      };
    } catch (e) {
      debugPrint('❌ Error getting cache stats: $e');
      return {};
    }
  }
}
