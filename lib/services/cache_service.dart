import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/daily_verse_set.dart';
import '../models/chapter_summary.dart';
import '../models/journal_entry.dart';
import '../models/chapter.dart';
import '../models/scenario.dart';
import '../services/settings_service.dart';

class CacheService {
  static final CacheService instance = CacheService._();
  CacheService._();

  /// Get sizes of all Hive cache boxes in MB
  static Future<Map<String, double>> getCacheSizes() async {
    final sizes = <String, double>{};
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory('${appDir.path}');
      
      if (!hiveDir.existsSync()) {
        return sizes;
      }
      
      // Map box names to user-friendly names
      final boxNames = {
        'daily_verses': 'Daily Verses',
        'chapter_summaries': 'Chapters',
        'journal_entries': 'Journal',
        'chapters': 'Chapter Data',
        'scenarios': 'Scenarios',
        'settings': 'Settings',
      };
      
      // Calculate size for each box
      for (final entry in boxNames.entries) {
        final boxName = entry.key;
        final displayName = entry.value;
        double boxSize = 0;
        
        // Look for .hive files (data) and .lock files (metadata)
        final files = hiveDir.listSync().where((file) {
          final fileName = file.path.split('/').last;
          return fileName.startsWith(boxName) && 
                 (fileName.endsWith('.hive') || fileName.endsWith('.lock'));
        });
        
        for (final file in files) {
          if (file is File) {
            try {
              final stat = file.statSync();
              boxSize += stat.size;
            } catch (e) {
              debugPrint('Error getting size for ${file.path}: $e');
            }
          }
        }
        
        // Convert bytes to MB
        sizes[displayName] = boxSize / (1024 * 1024);
      }
      
    } catch (e) {
      debugPrint('Error calculating cache sizes: $e');
    }
    
    return sizes;
  }
  
  /// Get total cache size across all boxes in MB
  static Future<double> getTotalCacheSize() async {
    final sizes = await getCacheSizes();
    return sizes.values.fold<double>(0.0, (double sum, double size) => sum + size);
  }
  
  /// Clear all cache except user settings
  static Future<void> clearAllCache() async {
    try {
      final results = await Future.wait([
        clearVerseCache(),
        clearChapterCache(),
        clearJournalCache(),
        clearScenarioCache(),
      ]);
      
      debugPrint('🗑️ Cleared all cache successfully');
    } catch (e) {
      debugPrint('❌ Error clearing all cache: $e');
      rethrow;
    }
  }
  
  /// Clear daily verse cache
  static Future<void> clearVerseCache() async {
    try {
      if (Hive.isBoxOpen('daily_verses')) {
        await Hive.box<DailyVerseSet>('daily_verses').clear();
      } else {
        await Hive.deleteBoxFromDisk('daily_verses');
      }
      debugPrint('🗑️ Cleared verse cache');
    } catch (e) {
      debugPrint('❌ Error clearing verse cache: $e');
      rethrow;
    }
  }
  
  /// Clear chapter summaries cache
  static Future<void> clearChapterCache() async {
    try {
      if (Hive.isBoxOpen('chapter_summaries')) {
        await Hive.box<ChapterSummary>('chapter_summaries').clear();
      } else {
        await Hive.deleteBoxFromDisk('chapter_summaries');
      }
      
      if (Hive.isBoxOpen('chapters')) {
        await Hive.box<Chapter>('chapters').clear();
      } else {
        await Hive.deleteBoxFromDisk('chapters');
      }
      
      debugPrint('🗑️ Cleared chapter cache');
    } catch (e) {
      debugPrint('❌ Error clearing chapter cache: $e');
      rethrow;
    }
  }
  
  /// Clear journal entries cache
  static Future<void> clearJournalCache() async {
    try {
      if (Hive.isBoxOpen('journal_entries')) {
        await Hive.box<JournalEntry>('journal_entries').clear();
      } else {
        await Hive.deleteBoxFromDisk('journal_entries');
      }
      debugPrint('🗑️ Cleared journal cache');
    } catch (e) {
      debugPrint('❌ Error clearing journal cache: $e');
      rethrow;
    }
  }
  
  /// Clear scenarios cache
  static Future<void> clearScenarioCache() async {
    try {
      if (Hive.isBoxOpen('scenarios')) {
        await Hive.box<Scenario>('scenarios').clear();
      } else {
        await Hive.deleteBoxFromDisk('scenarios');
      }
      debugPrint('🗑️ Cleared scenario cache');
    } catch (e) {
      debugPrint('❌ Error clearing scenario cache: $e');
      rethrow;
    }
  }
  
  /// Get cache statistics for debugging
  static Future<Map<String, int>> getCacheStats() async {
    final stats = <String, int>{};
    
    try {
      // Daily verses count
      if (Hive.isBoxOpen('daily_verses')) {
        final box = Hive.box<DailyVerseSet>('daily_verses');
        stats['Daily Verse Sets'] = box.length;
        stats['Total Verses'] = box.values.fold(0, (sum, set) => sum + set.verses.length);
      }
      
      // Chapter summaries count
      if (Hive.isBoxOpen('chapter_summaries')) {
        stats['Chapter Summaries'] = Hive.box<ChapterSummary>('chapter_summaries').length;
      }
      
      // Journal entries count
      if (Hive.isBoxOpen('journal_entries')) {
        stats['Journal Entries'] = Hive.box<JournalEntry>('journal_entries').length;
      }
      
      // Chapters count
      if (Hive.isBoxOpen('chapters')) {
        stats['Chapters'] = Hive.box<Chapter>('chapters').length;
      }
      
      // Scenarios count
      if (Hive.isBoxOpen('scenarios')) {
        stats['Scenarios'] = Hive.box<Scenario>('scenarios').length;
      }
      
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
    }
    
    return stats;
  }
  
  /// Check if cache is healthy (no corrupted boxes)
  static Future<bool> isCacheHealthy() async {
    try {
      final boxNames = ['daily_verses', 'chapter_summaries', 'journal_entries', 'chapters', 'scenarios', 'settings'];
      
      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          // Try to access the box
          final box = Hive.box(boxName);
          box.length; // This will throw if corrupted
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Cache health check failed: $e');
      return false;
    }
  }
  
  /// Repair corrupted cache by clearing damaged boxes
  static Future<void> repairCache() async {
    try {
      final boxNames = ['daily_verses', 'chapter_summaries', 'journal_entries', 'chapters', 'scenarios'];
      
      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            box.length; // Test access
          }
        } catch (e) {
          debugPrint('Repairing corrupted box: $boxName');
          await Hive.deleteBoxFromDisk(boxName);
        }
      }
      
      debugPrint('✅ Cache repair completed');
    } catch (e) {
      debugPrint('❌ Error repairing cache: $e');
      rethrow;
    }
  }
  
  /// Get formatted cache size string
  static String formatCacheSize(double sizeInMB) {
    if (sizeInMB < 0.1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }
  
  /// Auto-cleanup old cache entries
  static Future<void> performAutoCleanup() async {
    try {
      // Clean up old verse sets (older than 30 days)
      if (Hive.isBoxOpen('daily_verses')) {
        final box = Hive.box<DailyVerseSet>('daily_verses');
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        
        final keysToDelete = <String>[];
        
        for (final key in box.keys) {
          if (key is String) {
            try {
              final parts = key.split('-');
              if (parts.length == 3) {
                final date = DateTime(
                  int.parse(parts[0]),
                  int.parse(parts[1]),
                  int.parse(parts[2]),
                );
                
                if (date.isBefore(thirtyDaysAgo)) {
                  keysToDelete.add(key);
                }
              }
            } catch (e) {
              // Invalid date format, mark for deletion
              keysToDelete.add(key);
            }
          }
        }
        
        for (final key in keysToDelete) {
          await box.delete(key);
        }
        
        if (keysToDelete.isNotEmpty) {
          debugPrint('🧹 Auto-cleaned ${keysToDelete.length} old verse sets');
        }
      }
      
    } catch (e) {
      debugPrint('❌ Error in auto-cleanup: $e');
    }
  }
}