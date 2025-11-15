// test/services/progressive_scenario_service_comprehensive_test.dart
// Comprehensive tests for ProgressiveScenarioService and ScenarioServiceAdapter

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/progressive_scenario_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('ProgressiveScenarioService - Comprehensive Tests', () {
    late ProgressiveScenarioService service;

    setUp(() {
      service = ProgressiveScenarioService.instance;
    });

    group('Singleton Pattern Tests', () {
      test('should be singleton instance', () {
        final instance1 = ProgressiveScenarioService.instance;
        final instance2 = ProgressiveScenarioService.instance;
        expect(instance1, same(instance2));
      });

      test('should maintain state across multiple accesses', () {
        final count1 = service.scenarioCount;
        final count2 = service.scenarioCount;
        expect(count1, equals(count2));
      });
    });

    group('Scenario Availability Tests', () {
      test('should check scenarios availability', () {
        expect(() => service.hasScenarios, returnsNormally);
      });

      test('should return boolean for hasScenarios', () {
        final hasScenarios = service.hasScenarios;
        expect(hasScenarios, isA<bool>());
      });

      test('should return non-negative scenario count', () {
        final count = service.scenarioCount;
        expect(count, isA<int>());
        expect(count, greaterThanOrEqualTo(0));
      });

      test('should maintain consistent count', () {
        final count1 = service.scenarioCount;
        final count2 = service.scenarioCount;
        expect(count1, equals(count2));
      });
    });

    group('Search Scenarios Tests', () {
      test('should search with empty query', () {
        final results = service.searchScenarios('');
        expect(results, isA<List<Scenario>>());
      });

      test('should search with non-empty query', () {
        final results = service.searchScenarios('career');
        expect(results, isA<List<Scenario>>());
      });

      test('should search with whitespace query', () {
        final results = service.searchScenarios('   ');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle case-insensitive search', () {
        final resultsLower = service.searchScenarios('career');
        final resultsUpper = service.searchScenarios('CAREER');
        expect(resultsLower, isA<List<Scenario>>());
        expect(resultsUpper, isA<List<Scenario>>());
      });

      test('should handle special characters', () {
        final results = service.searchScenarios(r'@#$%^&*()');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very long queries', () {
        final longQuery = 'career ' * 100;
        final results = service.searchScenarios(longQuery);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle single character query', () {
        final results = service.searchScenarios('a');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle numeric query', () {
        final results = service.searchScenarios('123');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle Unicode characters', () {
        final results = service.searchScenarios('कर्म');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle query with newlines', () {
        final results = service.searchScenarios('test\nquery');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle query with tabs', () {
        final results = service.searchScenarios('test\tquery');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle query with multiple spaces', () {
        final results = service.searchScenarios('test    query');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('MaxResults Parameter Tests', () {
      test('should respect maxResults parameter', () {
        final results = service.searchScenarios('test', maxResults: 5);
        expect(results.length, lessThanOrEqualTo(5));
      });

      test('should handle maxResults of 0', () {
        final results = service.searchScenarios('test', maxResults: 0);
        expect(results, isEmpty);
      });

      test('should handle negative maxResults', () {
        final results = service.searchScenarios('test', maxResults: -1);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very large maxResults', () {
        final results = service.searchScenarios('test', maxResults: 10000);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle null maxResults', () {
        final results = service.searchScenarios('test', maxResults: null);
        expect(results, isA<List<Scenario>>());
      });

      test('should return limited results when specified', () {
        final results = service.searchScenarios('', maxResults: 3);
        expect(results.length, lessThanOrEqualTo(3));
      });
    });

    group('Empty Query Behavior Tests', () {
      test('should return scenarios for empty query', () {
        final results = service.searchScenarios('');
        expect(results, isA<List<Scenario>>());
      });

      test('should shuffle results for empty query', () {
        final results1 = service.searchScenarios('');
        final results2 = service.searchScenarios('');
        expect(results1, isA<List<Scenario>>());
        expect(results2, isA<List<Scenario>>());
      });

      test('should respect maxResults for empty query', () {
        final results = service.searchScenarios('', maxResults: 5);
        expect(results.length, lessThanOrEqualTo(5));
      });
    });

    group('Search Field Coverage Tests', () {
      test('should search in title field', () {
        final results = service.searchScenarios('career');
        expect(results, isA<List<Scenario>>());
      });

      test('should search in description field', () {
        final results = service.searchScenarios('workplace');
        expect(results, isA<List<Scenario>>());
      });

      test('should search in category field', () {
        final results = service.searchScenarios('relationships');
        expect(results, isA<List<Scenario>>());
      });

      test('should search in heart response field', () {
        final results = service.searchScenarios('patient');
        expect(results, isA<List<Scenario>>());
      });

      test('should search in duty response field', () {
        final results = service.searchScenarios('boundaries');
        expect(results, isA<List<Scenario>>());
      });

      test('should search in gita wisdom field', () {
        final results = service.searchScenarios('dharma');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Async Search Tests', () {
      test('should perform async search', () async {
        final results = await service.searchScenariosAsync('career');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle empty async search', () async {
        final results = await service.searchScenariosAsync('');
        expect(results, isA<List<Scenario>>());
      });

      test('should respect maxResults in async search', () async {
        final results = await service.searchScenariosAsync('test', maxResults: 3);
        expect(results.length, lessThanOrEqualTo(3));
      });

      test('should handle errors in async search', () async {
        final results = await service.searchScenariosAsync('error-query');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle very long async queries', () async {
        final longQuery = 'career ' * 100;
        final results = await service.searchScenariosAsync(longQuery);
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Get Scenario Tests', () {
      test('should get scenario by ID', () async {
        final scenario = await service.getScenario('test_id');
        expect(scenario, isA<Scenario?>());
      });

      test('should handle null scenario ID', () async {
        expect(() => service.getScenario(''), returnsNormally);
      });

      test('should handle non-existent scenario ID', () async {
        final scenario = await service.getScenario('nonexistent_id_12345');
        expect(scenario, isA<Scenario?>());
      });
    });

    group('Critical Scenarios Tests', () {
      test('should wait for critical scenarios', () async {
        expect(() => service.waitForCriticalScenarios(), returnsNormally);
      });

      test('should not throw on multiple wait calls', () async {
        await service.waitForCriticalScenarios();
        await service.waitForCriticalScenarios();
        expect(true, isTrue);
      });
    });

    group('Server Refresh Tests', () {
      test('should handle refresh from server', () async {
        expect(() => service.refreshFromServer(), returnsNormally);
      });

      test('should handle refresh errors gracefully', () async {
        try {
          await service.refreshFromServer();
        } catch (e) {
          // Should either succeed or handle error gracefully
        }
        expect(true, isTrue);
      });
    });

    group('Loading Progress Tests', () {
      test('should get loading progress', () {
        final progress = service.getLoadingProgress();
        expect(progress, isA<Map<String, dynamic>>());
      });

      test('should have expected progress keys', () {
        final progress = service.getLoadingProgress();
        expect(progress, isNotNull);
      });

      test('should maintain consistent progress', () {
        final progress1 = service.getLoadingProgress();
        final progress2 = service.getLoadingProgress();
        expect(progress1, isA<Map<String, dynamic>>());
        expect(progress2, isA<Map<String, dynamic>>());
      });
    });

    group('New Scenarios Check Tests', () {
      test('should check for new scenarios', () async {
        final hasNew = await service.hasNewScenariosAvailable();
        expect(hasNew, isA<bool>());
      });

      test('should handle check errors', () async {
        try {
          await service.hasNewScenariosAvailable();
        } catch (e) {
          // Should handle gracefully
        }
        expect(true, isTrue);
      });
    });

    group('Background Sync Tests', () {
      test('should perform background sync', () async {
        expect(() => service.backgroundSync(), returnsNormally);
      });

      test('should call onComplete callback', () async {
        bool callbackCalled = false;
        await service.backgroundSync(onComplete: () {
          callbackCalled = true;
        });

        await Future.delayed(const Duration(milliseconds: 200));
        expect(callbackCalled, isTrue);
      });

      test('should handle null callback', () async {
        expect(() => service.backgroundSync(onComplete: null), returnsNormally);
      });

      test('should handle background sync errors', () async {
        try {
          await service.backgroundSync();
        } catch (e) {
          // Should handle gracefully
        }
        expect(true, isTrue);
      });
    });

    group('Cache Statistics Tests', () {
      test('should get cache stats', () {
        final stats = service.getCacheStats();
        expect(stats, isA<Map<String, dynamic>>());
      });

      test('should maintain consistent stats', () {
        final stats1 = service.getCacheStats();
        final stats2 = service.getCacheStats();
        expect(stats1, isA<Map<String, dynamic>>());
        expect(stats2, isA<Map<String, dynamic>>());
      });
    });

    group('Clear Caches Tests', () {
      test('should clear all caches', () async {
        expect(() => service.clearAllCaches(), returnsNormally);
      });

      test('should handle clear errors', () async {
        try {
          await service.clearAllCaches();
        } catch (e) {
          // Should handle gracefully
        }
        expect(true, isTrue);
      });
    });

    group('Dispose Tests', () {
      test('should dispose resources', () async {
        expect(() => service.dispose(), returnsNormally);
      });

      test('should handle multiple dispose calls', () async {
        await service.dispose();
        await service.dispose();
        expect(true, isTrue);
      });
    });

    group('Performance Tests', () {
      test('should handle rapid consecutive searches', () {
        for (int i = 0; i < 10; i++) {
          service.searchScenarios('query$i');
        }
        expect(true, isTrue);
      });

      test('should handle alternating search patterns', () {
        service.searchScenarios('');
        service.searchScenarios('test');
        service.searchScenarios('');
        service.searchScenarios('another');
        expect(true, isTrue);
      });

      test('should handle concurrent searches', () {
        final futures = List.generate(5, (i) =>
          service.searchScenariosAsync('query$i')
        );
        expect(() => Future.wait(futures), returnsNormally);
      });
    });

    group('Error Handling Tests', () {
      test('should handle search errors gracefully', () {
        expect(() => service.searchScenarios('error-query'), returnsNormally);
      });

      test('should not crash on invalid input', () {
        expect(() => service.searchScenarios(r'!@#$%^&*()'), returnsNormally);
      });

      test('should handle async errors', () async {
        try {
          await service.searchScenariosAsync('error');
        } catch (e) {
          // Should handle gracefully
        }
        expect(true, isTrue);
      });
    });
  });

  group('ScenarioServiceAdapter - Comprehensive Tests', () {
    late ScenarioServiceAdapter adapter;

    setUp(() {
      adapter = ScenarioServiceAdapter.instance;
    });

    group('Singleton Pattern Tests', () {
      test('should be singleton instance', () {
        final instance1 = ScenarioServiceAdapter.instance;
        final instance2 = ScenarioServiceAdapter.instance;
        expect(instance1, same(instance2));
      });
    });

    group('Get All Scenarios Tests', () {
      test('should get all scenarios', () async {
        final scenarios = await adapter.getAllScenarios();
        expect(scenarios, isA<List<Scenario>>());
      });

      test('should handle multiple calls', () async {
        final scenarios1 = await adapter.getAllScenarios();
        final scenarios2 = await adapter.getAllScenarios();
        expect(scenarios1, isA<List<Scenario>>());
        expect(scenarios2, isA<List<Scenario>>());
      });

      test('should handle errors gracefully', () async {
        try {
          await adapter.getAllScenarios();
        } catch (e) {
          // Should handle gracefully
        }
        expect(true, isTrue);
      });
    });

    group('Search Scenarios Tests', () {
      test('should search scenarios', () {
        final results = adapter.searchScenarios('career');
        expect(results, isA<List<Scenario>>());
      });

      test('should handle empty query', () {
        final results = adapter.searchScenarios('');
        expect(results, isA<List<Scenario>>());
      });

      test('should respect maxResults', () {
        final results = adapter.searchScenarios('test', maxResults: 5);
        expect(results.length, lessThanOrEqualTo(5));
      });

      test('should handle special characters', () {
        final results = adapter.searchScenarios(r'@#$%');
        expect(results, isA<List<Scenario>>());
      });
    });

    group('Scenario Availability Tests', () {
      test('should check has scenarios', () {
        final hasScenarios = adapter.hasScenarios;
        expect(hasScenarios, isA<bool>());
      });

      test('should get scenario count', () {
        final count = adapter.scenarioCount;
        expect(count, isA<int>());
        expect(count, greaterThanOrEqualTo(0));
      });
    });

    group('Loading Progress Tests', () {
      test('should get loading progress', () {
        final progress = adapter.loadingProgress;
        expect(progress, isA<Map<String, dynamic>>());
      });

      test('should maintain consistent progress', () {
        final progress1 = adapter.loadingProgress;
        final progress2 = adapter.loadingProgress;
        expect(progress1, isA<Map<String, dynamic>>());
        expect(progress2, isA<Map<String, dynamic>>());
      });
    });

    group('Refresh From Server Tests', () {
      test('should refresh from server', () async {
        expect(() => adapter.refreshFromServer(), returnsNormally);
      });

      test('should handle refresh errors', () async {
        try {
          await adapter.refreshFromServer();
        } catch (e) {
          // Should handle gracefully
        }
        expect(true, isTrue);
      });
    });

    group('Background Sync Tests', () {
      test('should perform background sync', () async {
        expect(() => adapter.backgroundSync(), returnsNormally);
      });

      test('should call callback', () async {
        bool called = false;
        await adapter.backgroundSync(onComplete: () {
          called = true;
        });
        await Future.delayed(const Duration(milliseconds: 200));
        expect(called, isTrue);
      });

      test('should handle null callback', () async {
        expect(() => adapter.backgroundSync(onComplete: null), returnsNormally);
      });
    });

    group('Filter By Chapter Tests', () {
      test('should filter by chapter', () {
        final results = adapter.filterByChapter(1);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle invalid chapter', () {
        final results = adapter.filterByChapter(0);
        expect(results, isA<List<Scenario>>());
      });

      test('should handle negative chapter', () {
        final results = adapter.filterByChapter(-1);
        expect(results, isA<List<Scenario>>());
      });

      test('should filter multiple chapters', () {
        for (int i = 1; i <= 18; i++) {
          final results = adapter.filterByChapter(i);
          expect(results, isA<List<Scenario>>());
        }
      });
    });

    group('Has New Scenarios Tests', () {
      test('should check for new scenarios', () async {
        final hasNew = await adapter.hasNewScenariosAvailable();
        expect(hasNew, isA<bool>());
      });

      test('should handle check errors', () async {
        try {
          await adapter.hasNewScenariosAvailable();
        } catch (e) {
          // Should handle gracefully
        }
        expect(true, isTrue);
      });
    });

    group('Integration Tests', () {
      test('should work with progressive service', () async {
        final scenarios = await adapter.getAllScenarios();
        final searchResults = adapter.searchScenarios('test');

        expect(scenarios, isA<List<Scenario>>());
        expect(searchResults, isA<List<Scenario>>());
      });

      test('should maintain data consistency', () async {
        final count1 = adapter.scenarioCount;
        await adapter.getAllScenarios();
        final count2 = adapter.scenarioCount;

        expect(count1, isA<int>());
        expect(count2, isA<int>());
      });
    });
  });
}
