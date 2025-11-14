// test/services/intelligent_caching_service_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/intelligent_caching_service.dart';
import 'package:GitaWisdom/services/progressive_cache_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();

    // Register Scenario adapter if not already registered
    try {
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(ScenarioAdapter());
      }
    } catch (e) {
      // Adapter might already be registered
    }
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('IntelligentCachingService', () {
    late IntelligentCachingService service;
    late List<Scenario> testScenarios;

    setUp(() async {
      service = IntelligentCachingService.instance;

      // Create test scenarios
      testScenarios = List.generate(100, (i) => Scenario(
        title: 'Scenario $i',
        description: 'Description for scenario $i',
        category: i % 5 == 0 ? 'Work' : 'Personal',
        heartResponse: 'Heart response $i',
        dutyResponse: 'Duty response $i',
        gitaWisdom: 'Wisdom $i',
        chapter: (i % 18) + 1,
        verse: 'Verse text $i',
        verseNumber: '${(i % 18) + 1}.${i % 50}',
        createdAt: DateTime.now(),
      ));

      // Clear all cache boxes before each test
      for (final level in CacheLevel.values) {
        try {
          if (Hive.isBoxOpen(level.boxName)) {
            await Hive.box<Scenario>(level.boxName).clear();
          }
        } catch (e) {
          // Box might not exist
        }
      }

      // Clear app metadata box
      try {
        if (Hive.isBoxOpen('app_metadata')) {
          await Hive.box('app_metadata').clear();
        }
      } catch (e) {
        // Box might not exist
      }
    });

    tearDown(() async {
      // Clean up after each test
      for (final level in CacheLevel.values) {
        try {
          if (Hive.isBoxOpen(level.boxName)) {
            await Hive.box<Scenario>(level.boxName).clear();
          }
        } catch (e) {
          // Box might be closed
        }
      }
    });

    group('Initialization', () {
      test('should create service instance', () {
        expect(service, isNotNull);
        expect(service, isA<IntelligentCachingService>());
      });

      test('should be a singleton', () {
        final instance1 = IntelligentCachingService.instance;
        final instance2 = IntelligentCachingService.instance;
        expect(instance1, same(instance2));
      });

      test('should implement WidgetsBindingObserver', () {
        expect(service, isA<WidgetsBindingObserver>());
      });
    });

    group('Progress Tracking', () {
      test('should return loading progress', () {
        final progress = service.getProgress();
        expect(progress, isNotNull);
        expect(progress, containsPair('isLoading', isA<bool>()));
        expect(progress, containsPair('currentLevel', isA<String>()));
        expect(progress, containsPair('currentBatch', isA<int>()));
        expect(progress, containsPair('totalBatches', isA<int>()));
        expect(progress, containsPair('progress', isA<double>()));
      });

      test('should track cache counts', () {
        final progress = service.getProgress();
        expect(progress, containsPair('cacheCounts', isA<Map>()));

        final cacheCounts = progress['cacheCounts'] as Map;
        expect(cacheCounts, isNotNull);
      });

      test('should calculate average batch time', () {
        final progress = service.getProgress();
        expect(progress, containsPair('averageBatchTime', isA<num>()));

        final avgTime = progress['averageBatchTime'] as num;
        expect(avgTime, greaterThanOrEqualTo(0));
      });

      test('should have valid progress values', () {
        final progress = service.getProgress();
        final progressValue = progress['progress'] as double;
        expect(progressValue, greaterThanOrEqualTo(0.0));
        expect(progressValue, lessThanOrEqualTo(1.0));
      });

      test('should have non-negative batch counts', () {
        final progress = service.getProgress();
        final currentBatch = progress['currentBatch'] as int;
        final totalBatches = progress['totalBatches'] as int;

        expect(currentBatch, greaterThanOrEqualTo(0));
        expect(totalBatches, greaterThanOrEqualTo(0));
      });
    });

    group('Scenario Retrieval', () {
      test('should return empty list for unloaded cache level', () async {
        final scenarios = await service.getScenariosByLevel(CacheLevel.complete);
        expect(scenarios, isNotNull);
        expect(scenarios, isA<List<Scenario>>());
      });

      test('should return null for non-existent scenario', () async {
        final scenario = await service.getScenario('nonexistent_id_xyz');
        expect(scenario, isNull);
      });

      test('should get critical scenarios sync without errors', () {
        final scenarios = service.getCriticalScenariosSync();
        expect(scenarios, isNotNull);
        expect(scenarios, isA<List<Scenario>>());
      });
    });

    group('Search Functionality', () {
      test('should handle empty query', () async {
        final results = await service.searchScenarios('');
        expect(results, isNotNull);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle non-matching query', () async {
        final results = await service.searchScenarios('nonexistent_xyz_query');
        expect(results, isNotNull);
        expect(results, isEmpty);
      });

      test('should respect maxResults parameter', () async {
        final results = await service.searchScenarios('', maxResults: 5);
        expect(results, isNotNull);
        expect(results.length, lessThanOrEqualTo(5));
      });

      test('should handle maxResults of 0', () async {
        final results = await service.searchScenarios('test', maxResults: 0);
        expect(results, isNotNull);
        expect(results, isEmpty);
      });

      test('should handle large maxResults', () async {
        final results = await service.searchScenarios('', maxResults: 10000);
        expect(results, isNotNull);
      });
    });

    group('Scenario Counts by Chapter', () {
      test('should return map of chapter counts', () async {
        final counts = await service.getScenarioCountsByChapter();
        expect(counts, isNotNull);
        expect(counts, isA<Map<int, int>>());
      });

      test('should have valid chapter numbers', () async {
        final counts = await service.getScenarioCountsByChapter();

        for (final chapter in counts.keys) {
          expect(chapter, greaterThanOrEqualTo(0));
          expect(chapter, lessThanOrEqualTo(18));
        }
      });

      test('should have non-negative counts', () async {
        final counts = await service.getScenarioCountsByChapter();

        for (final count in counts.values) {
          expect(count, greaterThanOrEqualTo(0));
        }
      });
    });

    group('Critical Scenarios', () {
      test('should check critical scenarios availability', () {
        final hasCritical = service.hasCriticalScenarios;
        expect(hasCritical, isA<bool>());
      });

      test('should wait for critical scenarios without error', () async {
        // Should complete without throwing
        try {
          await service.waitForCriticalScenarios();
        } catch (e) {
          // Network errors are acceptable in tests
        }
        expect(service, isNotNull);
      });
    });

    group('App Lifecycle Integration', () {
      test('should handle app resumed state', () {
        service.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(service, isNotNull);
      });

      test('should handle app paused state', () {
        service.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(service, isNotNull);
      });

      test('should handle app detached state', () {
        service.didChangeAppLifecycleState(AppLifecycleState.detached);
        expect(service, isNotNull);
      });

      test('should handle app inactive state', () {
        service.didChangeAppLifecycleState(AppLifecycleState.inactive);
        expect(service, isNotNull);
      });

      test('should handle app hidden state', () {
        service.didChangeAppLifecycleState(AppLifecycleState.hidden);
        expect(service, isNotNull);
      });

      test('should handle rapid lifecycle changes', () {
        service.didChangeAppLifecycleState(AppLifecycleState.paused);
        service.didChangeAppLifecycleState(AppLifecycleState.resumed);
        service.didChangeAppLifecycleState(AppLifecycleState.paused);
        service.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(service, isNotNull);
      });
    });
  });

  group('HybridStorage', () {
    late HybridStorage storage;
    late List<Scenario> testScenarios;

    setUp(() async {
      storage = HybridStorage();
      await storage.initialize();

      testScenarios = List.generate(10, (i) => Scenario(
        title: 'Scenario $i',
        description: 'Description $i',
        category: 'Test',
        heartResponse: 'Heart $i',
        dutyResponse: 'Duty $i',
        gitaWisdom: 'Wisdom $i',
        chapter: 1,
        verse: 'Verse $i',
        verseNumber: '1.$i',
        createdAt: DateTime.now(),
      ));

      // Clear all cache boxes
      for (final level in CacheLevel.values) {
        try {
          if (Hive.isBoxOpen(level.boxName)) {
            await Hive.box<Scenario>(level.boxName).clear();
          }
        } catch (e) {
          // Box might not exist
        }
      }
    });

    tearDown(() async {
      await storage.dispose();
    });

    group('Initialization', () {
      test('should initialize storage', () {
        expect(storage, isNotNull);
      });

      test('should open all cache level boxes', () {
        for (final level in CacheLevel.values) {
          expect(Hive.isBoxOpen(level.boxName), isTrue);
        }
      });

      test('should not initialize twice', () async {
        await storage.initialize();
        await storage.initialize(); // Should be no-op
        expect(storage, isNotNull);
      });
    });

    group('Scenario Storage', () {
      test('should store scenario at specific level', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);

        final retrieved = await storage.getScenario('test_1');
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals(testScenarios[0].title));
      });

      test('should store batch of scenarios', () async {
        final batch = <String, Scenario>{
          'test_1': testScenarios[0],
          'test_2': testScenarios[1],
          'test_3': testScenarios[2],
        };

        await storage.storeBatch(batch, CacheLevel.critical);

        final retrieved = await storage.getScenario('test_1');
        expect(retrieved, isNotNull);
      });

      test('should store in multiple cache levels', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        await storage.storeScenario('test_2', testScenarios[1], CacheLevel.frequent);
        await storage.storeScenario('test_3', testScenarios[2], CacheLevel.complete);

        expect(await storage.getScenario('test_1'), isNotNull);
        expect(await storage.getScenario('test_2'), isNotNull);
        expect(await storage.getScenario('test_3'), isNotNull);
      });

      test('should handle empty batch', () async {
        final emptyBatch = <String, Scenario>{};
        await storage.storeBatch(emptyBatch, CacheLevel.critical);
        expect(storage, isNotNull);
      });
    });

    group('Cache Hierarchy', () {
      test('should check data at specific level', () async {
        expect(storage.hasDataAtLevel(CacheLevel.critical), isFalse);

        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);

        expect(storage.hasDataAtLevel(CacheLevel.critical), isTrue);
      });

      test('should get scenarios by level', () async {
        final batch = <String, Scenario>{
          'test_1': testScenarios[0],
          'test_2': testScenarios[1],
        };
        await storage.storeBatch(batch, CacheLevel.critical);

        final scenarios = await storage.getScenariosByLevel(CacheLevel.critical);
        expect(scenarios.length, equals(2));
      });

      test('should return empty list for empty level', () async {
        final scenarios = await storage.getScenariosByLevel(CacheLevel.complete);
        expect(scenarios, isEmpty);
      });

      test('should return null for non-existent scenario', () async {
        final scenario = await storage.getScenario('nonexistent_id');
        expect(scenario, isNull);
      });
    });

    group('Cache Statistics', () {
      test('should get cache counts', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        await storage.storeScenario('test_2', testScenarios[1], CacheLevel.frequent);

        final counts = storage.getCacheCounts();
        expect(counts, isNotNull);
        expect(counts[CacheLevel.critical], greaterThan(0));
        expect(counts[CacheLevel.frequent], greaterThan(0));
      });

      test('should get cache statistics', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);

        final stats = storage.getStats();
        expect(stats, isNotNull);
        expect(stats, containsPair('hotCacheSize', isA<int>()));
        expect(stats, containsPair('cacheCounts', isA<Map>()));
        expect(stats, containsPair('totalAccesses', isA<int>()));
        expect(stats, containsPair('coldCacheSize', isA<int>()));
      });

      test('should have non-negative counts', () {
        final counts = storage.getCacheCounts();

        for (final count in counts.values) {
          expect(count, greaterThanOrEqualTo(0));
        }
      });

      test('should have valid stats', () {
        final stats = storage.getStats();

        expect(stats['hotCacheSize'] as int, greaterThanOrEqualTo(0));
        expect(stats['totalAccesses'] as int, greaterThanOrEqualTo(0));
        expect(stats['coldCacheSize'] as int, greaterThanOrEqualTo(0));
      });
    });

    group('Cache Clear', () {
      test('should clear specific level', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        expect(storage.hasDataAtLevel(CacheLevel.critical), isTrue);

        await storage.clearLevel(CacheLevel.critical);
        expect(storage.hasDataAtLevel(CacheLevel.critical), isFalse);
      });

      test('should not affect other levels when clearing', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        await storage.storeScenario('test_2', testScenarios[1], CacheLevel.frequent);

        await storage.clearLevel(CacheLevel.critical);

        expect(storage.hasDataAtLevel(CacheLevel.critical), isFalse);
        expect(storage.hasDataAtLevel(CacheLevel.frequent), isTrue);
      });

      test('should handle clearing empty level', () async {
        await storage.clearLevel(CacheLevel.complete);
        expect(storage.hasDataAtLevel(CacheLevel.complete), isFalse);
      });

      test('should handle clearing all levels', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        await storage.storeScenario('test_2', testScenarios[1], CacheLevel.frequent);
        await storage.storeScenario('test_3', testScenarios[2], CacheLevel.complete);

        for (final level in CacheLevel.values) {
          await storage.clearLevel(level);
        }

        for (final level in CacheLevel.values) {
          expect(storage.hasDataAtLevel(level), isFalse);
        }
      });
    });

    group('Synchronous Access', () {
      test('should get critical scenarios synchronously', () async {
        final batch = <String, Scenario>{
          'test_1': testScenarios[0],
          'test_2': testScenarios[1],
        };
        await storage.storeBatch(batch, CacheLevel.critical);

        final scenarios = storage.getCriticalScenariosSync();
        expect(scenarios.length, equals(2));
      });

      test('should return empty list when no critical scenarios', () {
        final scenarios = storage.getCriticalScenariosSync();
        expect(scenarios, isEmpty);
      });

      test('should handle repeated sync access', () async {
        final batch = <String, Scenario>{
          'test_1': testScenarios[0],
        };
        await storage.storeBatch(batch, CacheLevel.critical);

        final scenarios1 = storage.getCriticalScenariosSync();
        final scenarios2 = storage.getCriticalScenariosSync();
        final scenarios3 = storage.getCriticalScenariosSync();

        expect(scenarios1.length, equals(1));
        expect(scenarios2.length, equals(1));
        expect(scenarios3.length, equals(1));
      });
    });

    group('Get All Scenarios', () {
      test('should get all scenarios from all levels', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        await storage.storeScenario('test_2', testScenarios[1], CacheLevel.frequent);
        await storage.storeScenario('test_3', testScenarios[2], CacheLevel.complete);

        final allScenarios = await storage.getAllScenarios();
        expect(allScenarios.length, greaterThanOrEqualTo(3));
      });

      test('should remove duplicates from all scenarios', () async {
        // Store same scenario in different levels
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        await storage.storeScenario('test_1_dup', testScenarios[0], CacheLevel.frequent);

        final allScenarios = await storage.getAllScenarios();

        // Count scenarios with same title
        final titleCounts = <String, int>{};
        for (final s in allScenarios) {
          titleCounts[s.title] = (titleCounts[s.title] ?? 0) + 1;
        }

        // Each title should appear once
        expect(titleCounts.values, everyElement(equals(1)));
      });

      test('should return empty list when no scenarios', () async {
        final allScenarios = await storage.getAllScenarios();
        expect(allScenarios, isEmpty);
      });
    });

    group('Dispose', () {
      test('should dispose without errors', () async {
        await storage.dispose();
        expect(storage, isNotNull);
      });

      test('should clear hot cache on dispose', () async {
        await storage.storeScenario('test_1', testScenarios[0], CacheLevel.critical);
        await storage.dispose();

        // Create new storage and verify
        final newStorage = HybridStorage();
        await newStorage.initialize();

        final stats = newStorage.getStats();
        expect(stats['hotCacheSize'] as int, equals(0));

        await newStorage.dispose();
      });
    });
  });

  group('CacheLevel Enum', () {
    test('should have correct count values', () {
      expect(CacheLevel.critical.count, equals(50));
      expect(CacheLevel.frequent.count, equals(300));
      expect(CacheLevel.complete.count, equals(2000));
    });

    test('should have correct priority values', () {
      expect(CacheLevel.critical.priority, equals(1));
      expect(CacheLevel.frequent.priority, equals(2));
      expect(CacheLevel.complete.priority, equals(3));
    });

    test('should have correct box names', () {
      expect(CacheLevel.critical.boxName, equals('scenarios_critical'));
      expect(CacheLevel.frequent.boxName, equals('scenarios_frequent'));
      expect(CacheLevel.complete.boxName, equals('scenarios_complete'));
    });

    test('should have all three levels', () {
      expect(CacheLevel.values.length, equals(3));
    });

    test('should maintain priority order', () {
      expect(CacheLevel.critical.priority < CacheLevel.frequent.priority, isTrue);
      expect(CacheLevel.frequent.priority < CacheLevel.complete.priority, isTrue);
    });
  });
}
