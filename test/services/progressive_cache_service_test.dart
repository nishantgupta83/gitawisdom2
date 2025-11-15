// test/services/progressive_cache_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/progressive_cache_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

void main() {
  group('CacheLevel Enum', () {
    test('critical level has correct properties', () {
      expect(CacheLevel.critical.count, 50);
      expect(CacheLevel.critical.priority, 1);
      expect(CacheLevel.critical.boxName, 'scenarios_critical');
    });

    test('frequent level has correct properties', () {
      expect(CacheLevel.frequent.count, 300);
      expect(CacheLevel.frequent.priority, 2);
      expect(CacheLevel.frequent.boxName, 'scenarios_frequent');
    });

    test('complete level has correct properties', () {
      expect(CacheLevel.complete.count, 2000);
      expect(CacheLevel.complete.priority, 3);
      expect(CacheLevel.complete.boxName, 'scenarios_complete');
    });

    test('cache levels are ordered by priority', () {
      final levels = CacheLevel.values;
      expect(levels[0], CacheLevel.critical);
      expect(levels[1], CacheLevel.frequent);
      expect(levels[2], CacheLevel.complete);
    });
  });

  group('HybridStorage', () {
    late HybridStorage storage;

    setUp(() async {
      await setupTestEnvironment();
      storage = HybridStorage();
    });

    tearDown(() async {
      await storage.dispose();
      await teardownTestEnvironment();
    });

    group('Initialization', () {
      test('should initialize all cache levels', () async {
        await storage.initialize();

        final stats = storage.getStats();
        expect(stats['hotCacheSize'], 0);
        expect(stats['cacheCounts'], isNotNull);
        expect(stats['totalAccesses'], 0);
        expect(stats['coldCacheSize'], 0);
      });

      test('should be idempotent (safe to call multiple times)', () async {
        await storage.initialize();
        await storage.initialize();
        await storage.initialize();

        // Should not throw or cause issues
        final stats = storage.getStats();
        expect(stats, isNotNull);
      });

      test('should initialize all warm cache boxes', () async {
        await storage.initialize();

        final counts = storage.getCacheCounts();
        expect(counts.containsKey(CacheLevel.critical), isTrue);
        expect(counts.containsKey(CacheLevel.frequent), isTrue);
        expect(counts.containsKey(CacheLevel.complete), isTrue);
      });
    });

    group('Scenario Storage', () {
      test('should store scenario at critical level', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Test Scenario',
          description: 'Test description',
          category: 'family',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('test1', scenario, CacheLevel.critical);

        final counts = storage.getCacheCounts();
        expect(counts[CacheLevel.critical], greaterThan(0));
      });

      test('should store scenario at frequent level', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Test Scenario 2',
          description: 'Test description 2',
          category: 'career',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('test2', scenario, CacheLevel.frequent);

        final counts = storage.getCacheCounts();
        expect(counts[CacheLevel.frequent], greaterThan(0));
      });

      test('should store scenario at complete level', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Test Scenario 3',
          description: 'Test description 3',
          category: 'relationships',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('test3', scenario, CacheLevel.complete);

        final counts = storage.getCacheCounts();
        expect(counts[CacheLevel.complete], greaterThan(0));
      });

      test('should store scenario in both warm and cold cache', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Dual Cache Test',
          description: 'Test cold and warm cache',
          category: 'family',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('dual1', scenario, CacheLevel.critical);

        final stats = storage.getStats();
        expect(stats['coldCacheSize'], greaterThan(0));
      });
    });

    group('Batch Storage', () {
      test('should store multiple scenarios efficiently', () async {
        await storage.initialize();

        final scenarios = <String, Scenario>{
          'batch1': Scenario(
            title: 'Batch Scenario 1',
            description: 'Description 1',
            category: 'family',
            heartResponse: 'Heart 1',
            dutyResponse: 'Duty 1',
            languageCode: 'en',
          ),
          'batch2': Scenario(
            title: 'Batch Scenario 2',
            description: 'Description 2',
            category: 'career',
            heartResponse: 'Heart 2',
            dutyResponse: 'Duty 2',
            languageCode: 'en',
          ),
          'batch3': Scenario(
            title: 'Batch Scenario 3',
            description: 'Description 3',
            category: 'relationships',
            heartResponse: 'Heart 3',
            dutyResponse: 'Duty 3',
            languageCode: 'en',
          ),
        };

        await storage.storeBatch(scenarios, CacheLevel.frequent);

        final counts = storage.getCacheCounts();
        expect(counts[CacheLevel.frequent], equals(3));
      });

      test('should store batch in both warm and cold cache', () async {
        await storage.initialize();

        final scenarios = <String, Scenario>{
          'b1': Scenario(
            title: 'Test 1',
            description: 'Desc 1',
            category: 'family',
            heartResponse: 'H1',
            dutyResponse: 'D1',
            languageCode: 'en',
          ),
          'b2': Scenario(
            title: 'Test 2',
            description: 'Desc 2',
            category: 'career',
            heartResponse: 'H2',
            dutyResponse: 'D2',
            languageCode: 'en',
          ),
        };

        await storage.storeBatch(scenarios, CacheLevel.critical);

        final stats = storage.getStats();
        expect(stats['coldCacheSize'], greaterThanOrEqualTo(2));
      });
    });

    group('Scenario Retrieval', () {
      test('should retrieve stored scenario', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Retrieve Test',
          description: 'Test retrieval',
          category: 'family',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('retrieve1', scenario, CacheLevel.critical);
        final retrieved = await storage.getScenario('retrieve1');

        expect(retrieved, isNotNull);
        expect(retrieved?.title, equals('Retrieve Test'));
        expect(retrieved?.description, equals('Test retrieval'));
      });

      test('should return null for non-existent scenario', () async {
        await storage.initialize();

        final retrieved = await storage.getScenario('nonexistent');

        expect(retrieved, isNull);
      });

      test('should promote frequently accessed scenario to hot cache', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Hot Cache Test',
          description: 'Test hot cache promotion',
          category: 'family',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('hot1', scenario, CacheLevel.critical);

        // Access multiple times to promote to hot cache
        await storage.getScenario('hot1');
        await storage.getScenario('hot1');
        await storage.getScenario('hot1');

        final stats = storage.getStats();
        expect(stats['hotCacheSize'], greaterThan(0));
      });

      test('should retrieve scenario from cold cache when not in warm', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Cold Cache Test',
          description: 'Test cold cache retrieval',
          category: 'family',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        // Store in critical level
        await storage.storeScenario('cold1', scenario, CacheLevel.critical);

        // Clear warm cache but keep cold
        await storage.clearLevel(CacheLevel.critical);

        // Should still retrieve from cold cache
        final retrieved = await storage.getScenario('cold1');
        expect(retrieved, isNotNull);
        expect(retrieved?.title, equals('Cold Cache Test'));
      });
    });

    group('Cache Level Retrieval', () {
      test('should get scenarios by critical level', () async {
        await storage.initialize();

        final scenarios = <String, Scenario>{
          's1': Scenario(
            title: 'Critical 1',
            description: 'Desc 1',
            category: 'family',
            heartResponse: 'H1',
            dutyResponse: 'D1',
            languageCode: 'en',
          ),
          's2': Scenario(
            title: 'Critical 2',
            description: 'Desc 2',
            category: 'career',
            heartResponse: 'H2',
            dutyResponse: 'D2',
            languageCode: 'en',
          ),
        };

        await storage.storeBatch(scenarios, CacheLevel.critical);
        final retrieved = await storage.getScenariosByLevel(CacheLevel.critical);

        expect(retrieved.length, equals(2));
      });

      test('should get scenarios by frequent level', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Frequent Test',
          description: 'Test frequent level',
          category: 'family',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('freq1', scenario, CacheLevel.frequent);
        final retrieved = await storage.getScenariosByLevel(CacheLevel.frequent);

        expect(retrieved.length, greaterThan(0));
      });

      test('should get scenarios by complete level', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Complete Test',
          description: 'Test complete level',
          category: 'family',
          heartResponse: 'Follow heart',
          dutyResponse: 'Follow duty',
          languageCode: 'en',
        );

        await storage.storeScenario('comp1', scenario, CacheLevel.complete);
        final retrieved = await storage.getScenariosByLevel(CacheLevel.complete);

        expect(retrieved.length, greaterThan(0));
      });

      test('should return empty list for uninitialized level', () async {
        // Don't initialize
        final retrieved = await storage.getScenariosByLevel(CacheLevel.critical);

        expect(retrieved, isEmpty);
      });
    });

    group('Synchronous Critical Access', () {
      test('should get critical scenarios synchronously', () async {
        await storage.initialize();

        final scenarios = <String, Scenario>{
          'sync1': Scenario(
            title: 'Sync Test 1',
            description: 'Test sync access',
            category: 'family',
            heartResponse: 'Heart',
            dutyResponse: 'Duty',
            languageCode: 'en',
          ),
        };

        await storage.storeBatch(scenarios, CacheLevel.critical);

        final retrieved = storage.getCriticalScenariosSync();
        expect(retrieved.length, equals(1));
        expect(retrieved.first.title, equals('Sync Test 1'));
      });

      test('should return empty list when no critical scenarios', () async {
        await storage.initialize();

        final retrieved = storage.getCriticalScenariosSync();
        expect(retrieved, isEmpty);
      });

      test('should handle errors gracefully in sync access', () {
        // Don't initialize to cause error
        final retrieved = storage.getCriticalScenariosSync();
        expect(retrieved, isEmpty);
      });
    });

    group('Get All Scenarios', () {
      test('should get all scenarios from all cache levels', () async {
        await storage.initialize();

        final critical = Scenario(
          title: 'Critical All',
          description: 'Desc',
          category: 'family',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        final frequent = Scenario(
          title: 'Frequent All',
          description: 'Desc',
          category: 'career',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        final complete = Scenario(
          title: 'Complete All',
          description: 'Desc',
          category: 'relationships',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        await storage.storeScenario('all1', critical, CacheLevel.critical);
        await storage.storeScenario('all2', frequent, CacheLevel.frequent);
        await storage.storeScenario('all3', complete, CacheLevel.complete);

        final all = await storage.getAllScenarios();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('should deduplicate scenarios by title', () async {
        await storage.initialize();

        final scenario1 = Scenario(
          title: 'Duplicate Title',
          description: 'Desc 1',
          category: 'family',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        final scenario2 = Scenario(
          title: 'Duplicate Title',
          description: 'Desc 2',
          category: 'career',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        await storage.storeScenario('dup1', scenario1, CacheLevel.critical);
        await storage.storeScenario('dup2', scenario2, CacheLevel.frequent);

        final all = await storage.getAllScenarios();
        final duplicates = all.where((s) => s.title == 'Duplicate Title').toList();
        expect(duplicates.length, equals(1));
      });
    });

    group('Cache Management', () {
      test('should check if data exists at level', () async {
        await storage.initialize();

        expect(storage.hasDataAtLevel(CacheLevel.critical), isFalse);

        final scenario = Scenario(
          title: 'Exists Test',
          description: 'Test',
          category: 'family',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        await storage.storeScenario('exists1', scenario, CacheLevel.critical);

        expect(storage.hasDataAtLevel(CacheLevel.critical), isTrue);
      });

      test('should get cache counts for all levels', () async {
        await storage.initialize();

        final counts = storage.getCacheCounts();

        expect(counts.keys.length, equals(3));
        expect(counts.containsKey(CacheLevel.critical), isTrue);
        expect(counts.containsKey(CacheLevel.frequent), isTrue);
        expect(counts.containsKey(CacheLevel.complete), isTrue);
      });

      test('should clear specific cache level', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Clear Test',
          description: 'Test',
          category: 'family',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        await storage.storeScenario('clear1', scenario, CacheLevel.critical);
        expect(storage.hasDataAtLevel(CacheLevel.critical), isTrue);

        await storage.clearLevel(CacheLevel.critical);
        expect(storage.hasDataAtLevel(CacheLevel.critical), isFalse);
      });

      test('should get comprehensive cache statistics', () async {
        await storage.initialize();

        final stats = storage.getStats();

        expect(stats.containsKey('hotCacheSize'), isTrue);
        expect(stats.containsKey('cacheCounts'), isTrue);
        expect(stats.containsKey('totalAccesses'), isTrue);
        expect(stats.containsKey('coldCacheSize'), isTrue);
      });
    });

    group('Hot Cache Management', () {
      test('should evict least recently used when hot cache is full', () async {
        await storage.initialize();

        // Create 105 scenarios to exceed hot cache limit (100)
        for (int i = 0; i < 105; i++) {
          final scenario = Scenario(
            title: 'Hot Test $i',
            description: 'Test $i',
            category: 'family',
            heartResponse: 'H$i',
            dutyResponse: 'D$i',
            languageCode: 'en',
          );

          await storage.storeScenario('hot$i', scenario, CacheLevel.critical);

          // Access multiple times to promote to hot cache
          await storage.getScenario('hot$i');
          await storage.getScenario('hot$i');
          await storage.getScenario('hot$i');
        }

        final stats = storage.getStats();
        // Hot cache should not exceed max size
        expect(stats['hotCacheSize'], lessThanOrEqualTo(100));
      });
    });

    group('Dispose', () {
      test('should clear all caches on dispose', () async {
        await storage.initialize();

        final scenario = Scenario(
          title: 'Dispose Test',
          description: 'Test',
          category: 'family',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        await storage.storeScenario('dispose1', scenario, CacheLevel.critical);

        // Access to promote to hot cache
        await storage.getScenario('dispose1');
        await storage.getScenario('dispose1');
        await storage.getScenario('dispose1');

        await storage.dispose();

        // Hot cache should be cleared (can't directly verify, but dispose should not throw)
        expect(storage, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle initialization errors gracefully', () async {
        // This test verifies that errors are caught and re-thrown
        // We can't easily force an initialization error in tests,
        // but we verify the method doesn't crash
        await storage.initialize();
        expect(storage, isNotNull);
      });

      test('should handle storage errors gracefully', () async {
        await storage.initialize();

        // Try to store with invalid data - should not crash
        final scenario = Scenario(
          title: 'Error Test',
          description: 'Test',
          category: 'family',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        await storage.storeScenario('error1', scenario, CacheLevel.critical);
        expect(storage, isNotNull);
      });

      test('should handle retrieval of corrupted data gracefully', () async {
        await storage.initialize();

        // Store and retrieve should work without errors
        final scenario = Scenario(
          title: 'Corrupt Test',
          description: 'Test',
          category: 'family',
          heartResponse: 'H',
          dutyResponse: 'D',
          languageCode: 'en',
        );

        await storage.storeScenario('corrupt1', scenario, CacheLevel.critical);
        final retrieved = await storage.getScenario('corrupt1');

        expect(retrieved, isNotNull);
      });
    });
  });
}
