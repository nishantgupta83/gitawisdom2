import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'dart:math' as math;

import '../models/daily_verse_set.dart';
import '../models/verse.dart';
import '../services/service_locator.dart';

class DailyVerseService {
  static final DailyVerseService instance = DailyVerseService._();
  DailyVerseService._();

  late final _supabaseService = ServiceLocator.instance.enhancedSupabaseService;
  Box<DailyVerseSet>? _box;
  
  static const String boxName = 'daily_verses';
  static const int verseCount = 5; // Number of verses per day

  /// Initialize the service and open Hive box
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        _box = await Hive.openBox<DailyVerseSet>(boxName);
      } else {
        _box = Hive.box<DailyVerseSet>(boxName);
      }
    } catch (e) {
      debugPrint('❌ Error initializing DailyVerseService: $e');
    }
  }

  /// Get today's verses, fetch from cache or generate new ones
  Future<List<Verse>> getTodaysVerses() async {
    try {
      await _ensureInitialized();

      final today = DailyVerseSet.getTodayString();
      final cachedSet = _box?.get(today);

      if (cachedSet != null && cachedSet.isToday) {
        return cachedSet.verses;
      }

      return await _generateVersesForToday();
    } catch (e) {
      debugPrint('❌ Error getting today\'s verses: $e');
      return _box?.values.isNotEmpty == true ? _box!.values.first.verses : [];
    }
  }

  /// Generate new verse set for today
  Future<List<Verse>> _generateVersesForToday() async {
    try {
      final chapterIds = List.generate(verseCount, (_) => math.Random().nextInt(18) + 1);
      final futures = chapterIds.map((id) => _supabaseService.fetchRandomVerseByChapter(id)).toList();
      final verses = await Future.wait(futures);
      final verseSet = DailyVerseSet.forToday(verses: verses, chapterIds: chapterIds);
      await _cacheVerseSet(verseSet);
      return verses;
    } catch (e) {
      debugPrint('❌ Error generating verses for today: $e');
      rethrow;
    }
  }

  /// Cache a verse set
  Future<void> _cacheVerseSet(DailyVerseSet verseSet) async {
    try {
      await _ensureInitialized();
      await _box?.put(verseSet.date, verseSet);
      
      // Clean up old verse sets (keep only last 7 days)
      await _cleanupOldVerses();
      
    } catch (e) {
      debugPrint('❌ Error caching verse set: $e');
    }
  }

  /// Remove old verse sets to keep storage manageable
  Future<void> _cleanupOldVerses() async {
    try {
      if (_box == null) return;

      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final keysToDelete = <String>[];

      for (final key in _box!.keys) {
        if (key is String) {
          try {
            final parts = key.split('-');
            if (parts.length == 3) {
              final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
              if (date.isBefore(sevenDaysAgo)) {
                keysToDelete.add(key);
              }
            }
          } catch (e) {
            keysToDelete.add(key);
          }
        }
      }

      for (final key in keysToDelete) {
        await _box!.delete(key);
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up old verses: $e');
    }
  }

  /// Force refresh today's verses
  Future<List<Verse>> refreshTodaysVerses() async {
    try {
      await _ensureInitialized();
      final today = DailyVerseSet.getTodayString();
      await _box?.delete(today);
      return await _generateVersesForToday();
    } catch (e) {
      debugPrint('❌ Error refreshing today\'s verses: $e');
      rethrow;
    }
  }

  /// Get cached verse count for debugging/info
  int get cachedVerseSetsCount => _box?.length ?? 0;

  /// Get total cached verses count
  int get totalCachedVersesCount {
    if (_box == null) return 0;
    return _box!.values.fold(0, (sum, set) => sum + set.verses.length);
  }

  /// Clear all cached verses
  Future<void> clearCache() async {
    try {
      await _ensureInitialized();
      await _box?.clear();
    } catch (e) {
      debugPrint('❌ Error clearing verse cache: $e');
    }
  }

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (_box == null) {
      await initialize();
    }
  }

  /// Check if we have verses for today
  bool get hasTodaysVerses {
    if (_box == null) return false;
    final today = DailyVerseSet.getTodayString();
    return _box!.containsKey(today);
  }

  /// Get verses for a specific date (for debugging/testing)
  List<Verse>? getVersesForDate(String date) {
    return _box?.get(date)?.verses;
  }
}