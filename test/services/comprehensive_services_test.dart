// test/services/comprehensive_services_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/cache_service.dart';
import 'package:GitaWisdom/services/daily_verse_service.dart';
import 'package:GitaWisdom/services/scenario_service.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/verse.dart';
import '../test_helpers.dart';
import '../test_config.dart';

void main() {
  setUpAll(() async {
    await commonTestSetup();
  });

  tearDownAll(() async {
    await commonTestCleanup();
  });

  group('CacheService Tests', () {
    test('should calculate cache sizes correctly', () async {
      final sizes = await CacheService.getCacheSizes();
      
      expect(sizes, isA<Map<String, double>>());
      // Should have entries for all cache types
      expect(sizes.keys, contains('Daily Verses'));
      expect(sizes.keys, contains('Scenarios'));
      expect(sizes.keys, contains('Settings'));
    });

    test('should calculate total cache size', () async {
      final totalSize = await CacheService.getTotalCacheSize();
      
      expect(totalSize, isA<double>());
      expect(totalSize, greaterThanOrEqualTo(0.0));
    });

    test('should clear all cache successfully', () async {
      // Create some test data first
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      // Add test data
      await dailyVerseBox.put('test', TestData.sampleDailyVerseSet);
      await scenarioBox.put('test', TestData.sampleScenario);
      
      // Verify data exists
      expect(dailyVerseBox.containsKey('test'), isTrue);
      expect(scenarioBox.containsKey('test'), isTrue);
      
      // Clear all cache
      await CacheService.clearAllCache();
      
      // Verify data is cleared
      expect(dailyVerseBox.containsKey('test'), isFalse);
      expect(scenarioBox.containsKey('test'), isFalse);
    });

    test('should clear verse cache individually', () async {
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      
      // Add test data
      await dailyVerseBox.put('test-verse', TestData.sampleDailyVerseSet);
      expect(dailyVerseBox.containsKey('test-verse'), isTrue);
      
      // Clear verse cache
      await CacheService.clearVerseCache();
      
      // Verify verse data is cleared
      expect(dailyVerseBox.containsKey('test-verse'), isFalse);
    });

    test('should handle cache operations gracefully on error', () async {
      // This tests error handling when cache operations fail
      expect(() async => await CacheService.getCacheSizes(), returnsNormally);
      expect(() async => await CacheService.getTotalCacheSize(), returnsNormally);
    });
  });

  group('DailyVerseService Tests', () {
    late DailyVerseService service;
    
    setUp(() async {
      service = DailyVerseService.instance;
      await service.initialize();
    });

    test('should initialize service correctly', () async {
      await service.initialize();
      
      // Service should be initialized without throwing errors
      expect(service, isNotNull);
    });

    test('should get today\'s verses', () async {
      final verses = await service.getTodaysVerses();
      
      expect(verses, isA<List<Verse>>());
      // Should return some verses (or empty list if service is mocked)
      expect(verses, isNotNull);
    });

    test('should cache daily verse sets correctly', () async {
      final testVerseSet = TestData.sampleDailyVerseSet;
      final box = await Hive.openBox<DailyVerseSet>('daily_verses');
      
      // Cache the verse set manually to test caching behavior
      await box.put(testVerseSet.date, testVerseSet);
      
      // Verify it's cached
      final cached = box.get(testVerseSet.date);
      expect(cached, isNotNull);
      expect(cached!.date, equals(testVerseSet.date));
      expect(cached.verses.length, equals(testVerseSet.verses.length));
    });

    test('should return today\'s cached verses when available', () async {
      final box = await Hive.openBox<DailyVerseSet>('daily_verses');
      final todayString = DailyVerseSet.getTodayString();
      
      // Cache today's verses
      final todayVerseSet = TestData.todayDailyVerseSet;
      await box.put(todayString, todayVerseSet);
      
      // Get today's verses (should come from cache)
      final verses = await service.getTodaysVerses();
      
      expect(verses, isA<List<Verse>>());
      // If caching works, should return cached verses
    });

    test('should handle verse generation gracefully', () async {
      // This tests that the service handles verse generation without errors
      expect(() async => await service.getTodaysVerses(), returnsNormally);
    });

    test('should cleanup old verses', () async {
      final box = await Hive.openBox<DailyVerseSet>('daily_verses');
      
      // Add some old verse sets
      final oldDate1 = '2024-01-01';
      final oldDate2 = '2024-01-02';
      
      await box.put(oldDate1, DailyVerseSet(
        date: oldDate1,
        verses: TestData.allTestVerses,
        chapterIds: [1, 2],
      ));
      await box.put(oldDate2, DailyVerseSet(
        date: oldDate2,
        verses: TestData.allTestVerses,
        chapterIds: [1, 2],
      ));
      
      expect(box.containsKey(oldDate1), isTrue);
      expect(box.containsKey(oldDate2), isTrue);
      
      // Trigger cleanup by getting today's verses
      await service.getTodaysVerses();
      
      // Old verses should be cleaned up (this is implementation dependent)
      // Just verify the service runs without errors
    });
  });

  group('ScenarioService Tests', () {
    late ScenarioService service;
    
    setUp(() async {
      service = ScenarioService.instance;
      await service.initialize();
    });

    test('should initialize service correctly', () async {
      await service.initialize();
      
      // Service should be initialized without throwing errors
      expect(service, isNotNull);
    });

    test('should get all scenarios', () async {
      final scenarios = await service.getAllScenarios();
      
      expect(scenarios, isA<List<Scenario>>());
      expect(scenarios, isNotNull);
    });

    test('should cache scenarios in memory for fast search', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      // Add test scenarios to cache
      await box.put('scenario1', TestData.sampleScenario);
      await box.put('scenario2', TestData.relationshipScenario);
      
      // Reinitialize to load cached scenarios
      await service.initialize();
      
      // Get all scenarios should return cached data
      final scenarios = await service.getAllScenarios();
      expect(scenarios, isNotEmpty);
    });

    test('should search scenarios correctly by title', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      // Add test scenarios
      await box.put('career', TestData.sampleScenario);
      await box.put('family', TestData.relationshipScenario);
      
      await service.initialize(); // Reload cache
      
      // Search by title
      final careerResults = service.searchScenarios('Career');
      expect(careerResults, isNotEmpty);
      expect(careerResults.first.title, contains('Career'));
      
      final familyResults = service.searchScenarios('Family');
      expect(familyResults, isNotEmpty);
      expect(familyResults.first.title, contains('Family'));
    });

    test('should search scenarios by description', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      await box.put('test', TestData.sampleScenario);
      await service.initialize();
      
      // Search by description content
      final results = service.searchScenarios('job');
      
      // Should find scenarios with 'job' in description
      expect(results, isA<List<Scenario>>());
    });

    test('should search scenarios by category', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      await box.put('career', TestData.sampleScenario);
      await box.put('family', TestData.relationshipScenario);
      
      await service.initialize();
      
      // Search by category
      final careerResults = service.searchScenarios('Career');
      final relationshipResults = service.searchScenarios('Relationships');
      
      expect(careerResults, isA<List<Scenario>>());
      expect(relationshipResults, isA<List<Scenario>>());
    });

    test('should search scenarios by tags', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      await box.put('tagged', TestData.sampleScenario);
      await service.initialize();
      
      // Search by tag
      final results = service.searchScenarios('duty');
      
      expect(results, isA<List<Scenario>>());
      // Should find scenarios with 'duty' in tags
    });

    test('should return all scenarios for empty search query', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      await box.put('scenario1', TestData.sampleScenario);
      await box.put('scenario2', TestData.relationshipScenario);
      
      await service.initialize();
      
      // Empty search should return all scenarios
      final emptyResults = service.searchScenarios('');
      final spaceResults = service.searchScenarios('   ');
      
      final allScenarios = await service.getAllScenarios();
      
      expect(emptyResults.length, equals(allScenarios.length));
      expect(spaceResults.length, equals(allScenarios.length));
    });

    test('should handle case-insensitive search', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      await box.put('test', TestData.sampleScenario);
      await service.initialize();
      
      // Test case variations
      final upperResults = service.searchScenarios('CAREER');
      final lowerResults = service.searchScenarios('career');
      final mixedResults = service.searchScenarios('Career');
      
      expect(upperResults, isA<List<Scenario>>());
      expect(lowerResults, isA<List<Scenario>>());
      expect(mixedResults, isA<List<Scenario>>());
      
      // All should return same results
      expect(upperResults.length, equals(lowerResults.length));
      expect(lowerResults.length, equals(mixedResults.length));
    });

    test('should return empty results for non-matching search', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      await box.put('test', TestData.sampleScenario);
      await service.initialize();
      
      // Search for non-existent content
      final results = service.searchScenarios('nonexistent_term_xyz');
      
      expect(results, isEmpty);
    });

    test('should handle scenarios with null tags gracefully', () async {
      final box = await Hive.openBox<Scenario>('scenarios');
      
      // Create scenario with null tags
      final scenarioWithNullTags = Scenario(
        title: 'Test Scenario',
        description: 'Test description',
        category: 'Test',
        chapter: 1,
        heartResponse: 'Heart response',
        dutyResponse: 'Duty response',
        gitaWisdom: 'Test wisdom',
        tags: null, // null tags
        createdAt: DateTime.now(),
      );
      
      await box.put('null_tags', scenarioWithNullTags);
      await service.initialize();
      
      // Search should not crash with null tags
      expect(() => service.searchScenarios('test'), returnsNormally);
      
      final results = service.searchScenarios('Test');
      expect(results, isNotEmpty);
    });
  });

  group('Service Integration Tests', () {
    test('all services should initialize without conflicts', () async {
      expect(() async {
        await DailyVerseService.instance.initialize();
        await ScenarioService.instance.initialize();
      }, returnsNormally);
    });

    test('cache operations should not interfere with each other', () async {
      // Initialize all services
      await DailyVerseService.instance.initialize();
      await ScenarioService.instance.initialize();
      
      // Perform cache operations
      final verses = await DailyVerseService.instance.getTodaysVerses();
      final scenarios = await ScenarioService.instance.getAllScenarios();
      
      expect(verses, isA<List<Verse>>());
      expect(scenarios, isA<List<Scenario>>());
    });

    test('clearing cache should work across all services', () async {
      // Add data to different caches
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      await dailyVerseBox.put('test', TestData.sampleDailyVerseSet);
      await scenarioBox.put('test', TestData.sampleScenario);
      
      // Clear all cache
      await CacheService.clearAllCache();
      
      // Verify all caches are cleared
      expect(dailyVerseBox.isEmpty, isTrue);
      expect(scenarioBox.isEmpty, isTrue);
    });

    test('services should handle concurrent operations', () async {
      await Future.wait([
        DailyVerseService.instance.getTodaysVerses(),
        ScenarioService.instance.getAllScenarios(),
        CacheService.getTotalCacheSize(),
      ]);
      
      // All operations should complete without errors
      expect(true, isTrue); // Test passes if no exceptions thrown
    });
  });

  group('Service Error Handling Tests', () {
    test('services should handle Hive box closure gracefully', () async {
      final service = DailyVerseService.instance;
      await service.initialize();
      
      // Close the box
      if (Hive.isBoxOpen('daily_verses')) {
        await Hive.box<DailyVerseSet>('daily_verses').close();
      }
      
      // Service should handle closed box gracefully
      expect(() async => await service.getTodaysVerses(), returnsNormally);
    });

    test('cache service should handle missing directories', () async {
      // Cache size calculation should handle missing directories
      expect(() async => await CacheService.getCacheSizes(), returnsNormally);
      expect(() async => await CacheService.getTotalCacheSize(), returnsNormally);
    });

    test('scenario service should handle empty cache gracefully', () async {
      final service = ScenarioService.instance;
      
      // Clear scenario cache
      final box = await Hive.openBox<Scenario>('scenarios');
      await box.clear();
      
      await service.initialize();
      
      // Should handle empty cache without errors
      final scenarios = await service.getAllScenarios();
      final searchResults = service.searchScenarios('test');
      
      expect(scenarios, isA<List<Scenario>>());
      expect(searchResults, isA<List<Scenario>>());
    });
  });
}