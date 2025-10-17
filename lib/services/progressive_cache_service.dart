// lib/services/progressive_cache_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/scenario.dart';

/// Cache levels for progressive loading strategy
enum CacheLevel {
  /// Critical scenarios for immediate home screen use (20-50 items)
  critical(count: 50, priority: 1, boxName: 'scenarios_critical'),

  /// Frequently accessed scenarios (200-500 items)
  frequent(count: 300, priority: 2, boxName: 'scenarios_frequent'),

  /// Complete dataset for full functionality (1000+ items)
  complete(count: 2000, priority: 3, boxName: 'scenarios_complete');

  const CacheLevel({
    required this.count,
    required this.priority,
    required this.boxName,
  });

  final int count;
  final int priority;
  final String boxName;
}

/// Hybrid storage system with intelligent caching layers
class HybridStorage {
  // Hot cache: In-memory for instant access (most used scenarios)
  final Map<String, Scenario> _hotCache = {};

  // Warm cache: Hive boxes for fast local access
  final Map<CacheLevel, Box<Scenario>?> _warmCaches = {};

  // Cold cache: Compressed storage for complete dataset
  Box<String>? _coldCache;

  // Cache statistics and intelligence
  final Map<String, int> _accessFrequency = {};
  final Map<String, DateTime> _lastAccessed = {};

  static const int _hotCacheMaxSize = 100;
  static const String _coldCacheBoxName = 'scenarios_compressed';

  bool _isInitialized = false;

  /// Initialize all cache layers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      for (final level in CacheLevel.values) {
        if (!Hive.isBoxOpen(level.boxName)) {
          _warmCaches[level] = await Hive.openBox<Scenario>(level.boxName);
        } else {
          _warmCaches[level] = Hive.box<Scenario>(level.boxName);
        }
      }

      if (!Hive.isBoxOpen(_coldCacheBoxName)) {
        _coldCache = await Hive.openBox<String>(_coldCacheBoxName);
      } else {
        _coldCache = Hive.box<String>(_coldCacheBoxName);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Error initializing HybridStorage: $e');
      rethrow;
    }
  }

  /// Get scenario with intelligent cache hierarchy
  Future<Scenario?> getScenario(String id) async {
    await _ensureInitialized();
    _recordAccess(id);

    if (_hotCache.containsKey(id)) {
      return _hotCache[id];
    }

    for (final level in CacheLevel.values) {
      final box = _warmCaches[level];
      if (box != null && box.isOpen) {
        final scenario = box.get(id);
        if (scenario != null) {
          _promoteToHot(id, scenario);
          return scenario;
        }
      }
    }

    if (_coldCache != null && _coldCache!.isOpen) {
      final compressed = _coldCache!.get(id);
      if (compressed != null) {
        try {
          final scenarioJson = jsonDecode(compressed);
          final scenario = Scenario.fromJson(scenarioJson);
          await _promoteToWarm(id, scenario);
          return scenario;
        } catch (e) {
          debugPrint('⚠️ Error decompressing scenario $id: $e');
        }
      }
    }

    return null;
  }

  /// Get scenarios by cache level
  Future<List<Scenario>> getScenariosByLevel(CacheLevel level) async {
    await _ensureInitialized();

    final box = _warmCaches[level];
    if (box == null || !box.isOpen) return [];

    final scenarios = box.values.toList();
    // Log removed - was spamming console on every navigation
    return scenarios;
  }

  /// Store scenario in appropriate cache level
  Future<void> storeScenario(String id, Scenario scenario, CacheLevel level) async {
    await _ensureInitialized();

    try {
      final box = _warmCaches[level];
      if (box != null && box.isOpen) {
        await box.put(id, scenario);
      }

      final compressed = jsonEncode(scenario.toJson());
      if (_coldCache != null && _coldCache!.isOpen) {
        await _coldCache!.put(id, compressed);
      }

      if (_isFrequentlyAccessed(id)) {
        _promoteToHot(id, scenario);
      }
    } catch (e) {
      debugPrint('❌ Error storing scenario $id: $e');
    }
  }

  /// Store multiple scenarios efficiently
  Future<void> storeBatch(Map<String, Scenario> scenarios, CacheLevel level) async {
    await _ensureInitialized();

    try {
      final box = _warmCaches[level];
      if (box != null && box.isOpen) {
        await box.putAll(scenarios);
      }

      final compressedMap = <String, String>{};
      for (final entry in scenarios.entries) {
        compressedMap[entry.key] = jsonEncode(entry.value.toJson());
      }
      if (_coldCache != null && _coldCache!.isOpen) {
        await _coldCache!.putAll(compressedMap);
      }
    } catch (e) {
      debugPrint('❌ Error storing scenario batch: $e');
    }
  }

  /// Check if scenarios exist at a specific level
  bool hasDataAtLevel(CacheLevel level) {
    final box = _warmCaches[level];
    return box != null && box.isOpen && box.isNotEmpty;
  }

  /// Get count of scenarios at each level
  Map<CacheLevel, int> getCacheCounts() {
    final counts = <CacheLevel, int>{};
    for (final level in CacheLevel.values) {
      final box = _warmCaches[level];
      counts[level] = (box != null && box.isOpen) ? box.length : 0;
    }
    return counts;
  }

  /// Clear specific cache level
  Future<void> clearLevel(CacheLevel level) async {
    final box = _warmCaches[level];
    if (box != null && box.isOpen) {
      await box.clear();
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final coldCacheSize = (_coldCache != null && _coldCache!.isOpen) ? _coldCache!.length : 0;
    return {
      'hotCacheSize': _hotCache.length,
      'cacheCounts': getCacheCounts(),
      'totalAccesses': _accessFrequency.length,
      'coldCacheSize': coldCacheSize,
    };
  }

  /// Get critical scenarios synchronously (for immediate UI access)
  List<Scenario> getCriticalScenariosSync() {
    try {
      final criticalBox = _warmCaches[CacheLevel.critical];
      if (criticalBox != null && criticalBox.isOpen) {
        final scenarios = <Scenario>[];
        for (int i = 0; i < criticalBox.length; i++) {
          final scenario = criticalBox.getAt(i);
          if (scenario != null) {
            scenarios.add(scenario);
          }
        }
        return scenarios;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting critical scenarios sync: $e');
      return [];
    }
  }

  /// Get all scenarios from all cache levels
  Future<List<Scenario>> getAllScenarios() async {
    final allScenarios = <Scenario>[];

    // Get from all warm caches
    for (final entry in _warmCaches.entries) {
      final box = entry.value;
      if (box != null && box.isOpen) {
        for (int i = 0; i < box.length; i++) {
          final scenario = box.getAt(i);
          if (scenario != null) {
            allScenarios.add(scenario);
          }
        }
      }
    }

    // Include hot cache scenarios
    allScenarios.addAll(_hotCache.values);

    // Remove duplicates based on title (scenarios don't have ID field)
    final uniqueScenarios = <String, Scenario>{};
    for (final scenario in allScenarios) {
      uniqueScenarios[scenario.title] = scenario;
    }

    return uniqueScenarios.values.toList();
  }

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  void _recordAccess(String id) {
    _accessFrequency[id] = (_accessFrequency[id] ?? 0) + 1;
    _lastAccessed[id] = DateTime.now();
  }

  void _promoteToHot(String id, Scenario scenario) {
    // Manage hot cache size
    if (_hotCache.length >= _hotCacheMaxSize) {
      _evictLeastRecentlyUsed();
    }

    _hotCache[id] = scenario;
  }

  Future<void> _promoteToWarm(String id, Scenario scenario) async {
    // Determine appropriate warm cache level based on access frequency
    final frequency = _accessFrequency[id] ?? 0;

    CacheLevel targetLevel;
    if (frequency > 10) {
      targetLevel = CacheLevel.critical;
    } else if (frequency > 3) {
      targetLevel = CacheLevel.frequent;
    } else {
      targetLevel = CacheLevel.complete;
    }

    await storeScenario(id, scenario, targetLevel);
    _promoteToHot(id, scenario);
  }

  bool _isFrequentlyAccessed(String id) {
    return (_accessFrequency[id] ?? 0) > 2;
  }

  void _evictLeastRecentlyUsed() {
    if (_lastAccessed.isEmpty) return;

    String? oldestId;
    DateTime? oldestTime;

    for (final entry in _lastAccessed.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestId = entry.key;
      }
    }

    if (oldestId != null) {
      _hotCache.remove(oldestId);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _hotCache.clear();
    _accessFrequency.clear();
    _lastAccessed.clear();
  }
}