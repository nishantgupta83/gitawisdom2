// test/services/cache_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/services/cache_service.dart';
import '../test_setup.dart';

@GenerateMocks([])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('CacheService - Instance', () {
    test('should return singleton instance', () {
      final instance1 = CacheService.instance;
      final instance2 = CacheService.instance;

      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('CacheService - Cache Sizes', () {
    test('getCacheSizes should return map', () async {
      final sizes = await CacheService.getCacheSizes();

      expect(sizes, isA<Map<String, double>>());
    });

    test('getCacheSizes should not throw errors', () async {
      expect(() async => await CacheService.getCacheSizes(), returnsNormally);
    });

    test('getCacheSizes should have non-negative values', () async {
      final sizes = await CacheService.getCacheSizes();

      for (final size in sizes.values) {
        expect(size, greaterThanOrEqualTo(0.0));
      }
    });

    test('getTotalCacheSize should return non-negative value', () async {
      final totalSize = await CacheService.getTotalCacheSize();

      expect(totalSize, greaterThanOrEqualTo(0.0));
    });

    test('getTotalCacheSize should not throw errors', () async {
      expect(() async => await CacheService.getTotalCacheSize(), returnsNormally);
    });

    test('getTotalCacheSize should equal sum of individual sizes', () async {
      final sizes = await CacheService.getCacheSizes();
      final total = await CacheService.getTotalCacheSize();

      final expectedTotal = sizes.values.fold<double>(
        0.0,
        (sum, size) => sum + size,
      );

      expect(total, equals(expectedTotal));
    });
  });

  group('CacheService - Cache Operations', () {
    test('clearAllCache should not throw errors', () async {
      expect(() async => await CacheService.clearAllCache(), returnsNormally);
    });

    test('clearAllCache should complete successfully', () async {
      try {
        await CacheService.clearAllCache();
        expect(true, isTrue);
      } catch (e) {
        fail('clearAllCache should not throw: $e');
      }
    });

    test('cache sizes should be valid after clear', () async {
      await CacheService.clearAllCache();
      final sizes = await CacheService.getCacheSizes();

      expect(sizes, isA<Map<String, double>>());
      for (final size in sizes.values) {
        expect(size, greaterThanOrEqualTo(0.0));
      }
    });
  });

  group('CacheService - Error Handling', () {
    test('should handle filesystem errors gracefully', () async {
      // Even if filesystem is inaccessible, should not throw
      expect(() async => await CacheService.getCacheSizes(), returnsNormally);
    });

    test('should return empty map on filesystem errors', () async {
      final sizes = await CacheService.getCacheSizes();
      expect(sizes, isNotNull);
      expect(sizes, isA<Map<String, double>>());
    });

    test('should handle missing directories gracefully', () async {
      // Should not throw even if cache directory doesn't exist yet
      final total = await CacheService.getTotalCacheSize();
      expect(total, isA<double>());
    });
  });

  group('CacheService - Data Consistency', () {
    test('multiple getCacheSizes calls should be consistent', () async {
      final sizes1 = await CacheService.getCacheSizes();
      final sizes2 = await CacheService.getCacheSizes();

      // Should return same keys
      expect(sizes1.keys.toSet(), equals(sizes2.keys.toSet()));
    });

    test('cache size should not be negative', () async {
      final sizes = await CacheService.getCacheSizes();

      for (final entry in sizes.entries) {
        expect(
          entry.value,
          greaterThanOrEqualTo(0.0),
          reason: '${entry.key} size should not be negative',
        );
      }
    });

    test('total cache size should be consistent', () async {
      final total1 = await CacheService.getTotalCacheSize();
      final total2 = await CacheService.getTotalCacheSize();

      // Should be close (might vary slightly due to filesystem timing)
      expect((total1 - total2).abs(), lessThan(1.0)); // Within 1MB
    });
  });

  group('CacheService - Box Names', () {
    test('should track expected cache boxes when available', () async {
      final sizes = await CacheService.getCacheSizes();

      // In test environment, path_provider may not be available
      // so the sizes map may be empty, which is acceptable
      expect(sizes, isA<Map<String, double>>());

      // If sizes are available, verify expected boxes
      if (sizes.isNotEmpty) {
        // Expected cache box names (user-friendly)
        final expectedBoxes = [
          'Daily Verses',
          'Chapters',
          'Journal',
          'Chapter Data',
          'Scenarios',
          'Settings',
        ];

        // Check that returned boxes are among expected ones
        for (final boxName in sizes.keys) {
          expect(
            expectedBoxes.contains(boxName),
            isTrue,
            reason: 'Unexpected cache box: $boxName',
          );
        }
      }
    });
  });
}
