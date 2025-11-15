# Test Implementation Guide for 70% Coverage
**Quick Reference for Creating Comprehensive Service Tests**

## Test Count Summary

### Tests Created This Session
- ✅ **bookmark_service_test.dart**: ~60 tests (needs mocking fix)
- ✅ **daily_verse_service_test.dart**: +40 tests (enhanced from 30 to 70)

### Tests Needed for 70% Coverage

| Service | Current % | Target % | Current Tests | Tests Needed | Priority |
|---------|-----------|----------|---------------|--------------|----------|
| bookmark_service | 0.0% | 70% | ~60 | Fix mocking | CRITICAL |
| daily_verse_service | 0.0% | 70% | ~70 | Fix mocking | CRITICAL |
| enhanced_supabase_service | 14.3% | 70% | ~30 | +50-60 | HIGH |
| supabase_auth_service | 11.7% | 70% | ~20 | +40-50 | HIGH |
| semantic_search_service | 22.7% | 70% | ~15 | +15-20 | HIGH |
| journal_service | 27.9% | 70% | ~25 | +20-25 | HIGH |
| scenario_service | 54.7% | 70% | ~45 | +10-15 | MEDIUM |
| search_service | 57.0% | 70% | ~35 | +10-15 | MEDIUM |

**Total Additional Tests Needed:** 155-210 tests

## Quick Test Templates

### 1. Basic Service Test Structure
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/services/your_service.dart';
import '../test_setup.dart';

@GenerateMocks([SupabaseClient, PostgrestFilterBuilder])
import 'your_service_test.mocks.dart';

void main() {
  late YourService service;
  late MockSupabaseClient mockClient;

  setUp(() async {
    await setupTestEnvironment();
    mockClient = MockSupabaseClient();
    service = YourService();
  });

  tearDown(() async {
    await teardownTestEnvironment();
  });

  group('Initialization', () {
    test('initializes correctly', () {
      expect(service, isNotNull);
    });
  });

  group('Method Name', () {
    test('success case', () async {
      // Test implementation
    });

    test('handles errors gracefully', () async {
      // Test error handling
    });

    test('validates input', () {
      // Test validation
    });
  });
}
```

### 2. Supabase Query Mocking
```dart
// Mock the full Supabase query chain
final mockBuilder = MockPostgrestFilterBuilder();

when(mockClient.from('table_name'))
    .thenReturn(mockBuilder);

when(mockBuilder.select())
    .thenReturn(mockBuilder);

when(mockBuilder.eq('column', 'value'))
    .thenAnswer((_) async => [
      {'id': 1, 'data': 'test'},
    ]);

// Use in test
final result = await service.fetchData();
expect(result, isNotEmpty);
verify(mockClient.from('table_name')).called(1);
```

### 3. Async Error Handling
```dart
test('handles network timeout', () async {
  when(mockClient.from('table'))
      .thenThrow(TimeoutException('Network timeout'));

  expect(
    () => service.fetchData(),
    throwsA(isA<TimeoutException>()),
  );
});

test('handles auth errors', () async {
  when(mockClient.from('table'))
      .thenThrow(AuthException('Unauthorized'));

  final result = await service.fetchData();
  expect(result, isEmpty); // Service handles gracefully
  expect(service.error, isNotNull);
});
```

### 4. Hive Box Testing
```dart
late Box<Model> testBox;

setUp(() async {
  await setupTestEnvironment();

  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(ModelAdapter());
  }

  if (!Hive.isBoxOpen('box_name')) {
    testBox = await Hive.openBox<Model>('box_name');
  } else {
    testBox = Hive.box<Model>('box_name');
  }

  await testBox.clear();
});

tearDown(() async {
  if (Hive.isBoxOpen('box_name')) {
    await testBox.clear();
    await testBox.close();
  }

  await teardownTestEnvironment();
});

test('caches data correctly', () async {
  final model = Model(id: 1, data: 'test');
  await testBox.put(model.id, model);

  expect(testBox.length, equals(1));
  expect(testBox.get(1), isNotNull);
});
```

## Essential Test Categories

### For Every Service, Test:

#### 1. Initialization (2-3 tests)
```dart
group('Initialization', () {
  test('service initializes correctly', () {
    expect(service, isNotNull);
  });

  test('initial state is correct', () {
    expect(service.isLoading, isFalse);
    expect(service.error, isNull);
  });

  test('handles multiple initializations', () async {
    await service.initialize();
    await service.initialize();
    expect(service, isNotNull);
  });
});
```

#### 2. CRUD Operations (12-15 tests)
```dart
group('Create', () {
  test('creates successfully', () async {
    final result = await service.create(data);
    expect(result, isTrue);
  });

  test('validates required fields', () async {
    final result = await service.create(invalidData);
    expect(result, isFalse);
    expect(service.error, contains('required'));
  });

  test('handles creation errors', () async {
    when(mockClient.from('table').insert(any))
        .thenThrow(Exception('Insert failed'));

    final result = await service.create(data);
    expect(result, isFalse);
  });
});

group('Read', () {
  test('reads existing data', () async {
    final result = await service.read(id);
    expect(result, isNotNull);
  });

  test('returns null for non-existent', () async {
    final result = await service.read(999);
    expect(result, isNull);
  });

  test('uses cache when available', () async {
    // First call - from network
    final result1 = await service.read(id);

    // Second call - from cache
    final result2 = await service.read(id);

    expect(result1, equals(result2));
    verify(mockClient.from('table')).called(1); // Only once
  });
});

group('Update', () {
  test('updates successfully', () async {
    final result = await service.update(id, newData);
    expect(result, isTrue);
  });

  test('handles non-existent records', () async {
    final result = await service.update(999, newData);
    expect(result, isFalse);
  });
});

group('Delete', () {
  test('deletes successfully', () async {
    final result = await service.delete(id);
    expect(result, isTrue);
  });

  test('handles deletion errors', () async {
    when(mockClient.from('table').delete().eq('id', any))
        .thenThrow(Exception('Delete failed'));

    final result = await service.delete(id);
    expect(result, isFalse);
  });
});
```

#### 3. Query Methods (8-10 tests)
```dart
group('Query Methods', () {
  test('finds by id', () async {
    final result = await service.findById(1);
    expect(result, isNotNull);
  });

  test('finds by criteria', () async {
    final results = await service.findWhere({'status': 'active'});
    expect(results, isNotEmpty);
  });

  test('returns all items', () async {
    final results = await service.findAll();
    expect(results, isA<List>());
  });

  test('paginates results', () async {
    final results = await service.findAll(limit: 10, offset: 0);
    expect(results.length, lessThanOrEqualTo(10));
  });

  test('sorts results', () async {
    final results = await service.findAll(sortBy: 'created_at');
    // Verify sorting
  });

  test('filters results', () async {
    final results = await service.findAll(filter: {'type': 'important'});
    expect(results.every((r) => r.type == 'important'), isTrue);
  });
});
```

#### 4. Search/Filter (5-7 tests)
```dart
group('Search', () {
  test('finds by exact match', () {
    final results = service.search('exact term');
    expect(results, isNotEmpty);
  });

  test('finds by partial match', () {
    final results = service.search('partial');
    expect(results.length, greaterThan(0));
  });

  test('is case-insensitive', () {
    final results1 = service.search('TERM');
    final results2 = service.search('term');
    expect(results1.length, equals(results2.length));
  });

  test('returns empty for no match', () {
    final results = service.search('nonexistent');
    expect(results, isEmpty);
  });

  test('searches multiple fields', () {
    // Test multi-field search
  });
});
```

#### 5. Caching (6-8 tests)
```dart
group('Caching', () {
  test('caches successfully', () async {
    await service.cache(data);
    expect(service.isCached(data.id), isTrue);
  });

  test('retrieves from cache', () async {
    await service.cache(data);
    final cached = service.getCached(data.id);
    expect(cached, equals(data));
  });

  test('invalidates cache on update', () async {
    await service.cache(data);
    await service.update(data.id, newData);
    expect(service.isCached(data.id), isFalse);
  });

  test('clears cache', () async {
    await service.cache(data);
    await service.clearCache();
    expect(service.cacheSize, equals(0));
  });

  test('respects cache TTL', () async {
    await service.cache(data, ttl: Duration(seconds: 1));
    await Future.delayed(Duration(seconds: 2));
    expect(service.isCached(data.id), isFalse);
  });
});
```

#### 6. Error Handling (8-10 tests)
```dart
group('Error Handling', () {
  test('handles network errors', () async {
    when(mockClient.from('table'))
        .thenThrow(SocketException('No internet'));

    final result = await service.fetch();
    expect(result, isEmpty);
    expect(service.error, contains('network'));
  });

  test('handles auth errors', () async {
    when(mockClient.from('table'))
        .thenThrow(AuthException('Unauthorized'));

    expect(service.isAuthenticated, isFalse);
  });

  test('handles validation errors', () async {
    final result = await service.create(invalidData);
    expect(result, isFalse);
    expect(service.error, isNotNull);
  });

  test('handles rate limiting', () async {
    when(mockClient.from('table'))
        .thenThrow(Exception('Rate limit exceeded'));

    final result = await service.fetch();
    expect(service.error, contains('rate limit'));
  });

  test('clears errors on success', () async {
    service.error = 'Previous error';
    await service.fetch();
    expect(service.error, isNull);
  });
});
```

#### 7. Edge Cases (10-12 tests)
```dart
group('Edge Cases', () {
  test('handles null input', () {
    expect(() => service.process(null), returnsNormally);
  });

  test('handles empty input', () {
    final result = service.process([]);
    expect(result, isEmpty);
  });

  test('handles very large input', () async {
    final largeData = List.generate(10000, (i) => Data(id: i));
    expect(() => service.processAll(largeData), returnsNormally);
  });

  test('handles special characters', () {
    final result = service.search('!@#$%^&*()');
    expect(result, isNotNull);
  });

  test('handles concurrent operations', () async {
    final futures = List.generate(10,
        (i) => service.fetch(i));
    final results = await Future.wait(futures);
    expect(results.length, equals(10));
  });

  test('handles rapid successive calls', () async {
    for (int i = 0; i < 100; i++) {
      await service.fetch(i);
    }
    expect(service, isNotNull);
  });

  test('handles very long strings', () {
    final longString = 'A' * 10000;
    expect(() => service.process(longString), returnsNormally);
  });

  test('handles unicode characters', () {
    final unicode = '你好世界 🌍 مرحبا';
    final result = service.process(unicode);
    expect(result, contains(unicode));
  });
});
```

#### 8. State Management (5-6 tests)
```dart
group('State Management', () {
  test('notifies listeners on change', () {
    int notifyCount = 0;
    service.addListener(() => notifyCount++);

    service.updateState();

    expect(notifyCount, greaterThan(0));
  });

  test('loading state transitions', () async {
    expect(service.isLoading, isFalse);

    final future = service.longOperation();
    expect(service.isLoading, isTrue);

    await future;
    expect(service.isLoading, isFalse);
  });

  test('error state persists until cleared', () {
    service.setError('Test error');
    expect(service.error, isNotNull);

    service.clearError();
    expect(service.error, isNull);
  });
});
```

#### 9. Performance (3-4 tests)
```dart
group('Performance', () {
  test('completes within reasonable time', () async {
    final stopwatch = Stopwatch()..start();

    await service.fetch();

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  });

  test('handles large datasets efficiently', () async {
    final largeData = List.generate(1000, (i) => Data(id: i));

    final stopwatch = Stopwatch()..start();
    service.processAll(largeData);
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
});
```

## Running Tests

### Run Specific Service Test
```bash
flutter test test/services/your_service_test.dart --no-pub
```

### Run All Service Tests
```bash
flutter test test/services/ --no-pub
```

### Generate Coverage
```bash
flutter test --coverage --no-pub
```

### Check Coverage for Specific File
```bash
grep "SF:lib/services/your_service.dart" coverage/lcov.info -A 20
```

## Coverage Verification Script

```bash
python3 << 'EOF'
import re

with open('coverage/lcov.info', 'r') as f:
    content = f.read()

# Find specific service
service_name = 'lib/services/your_service.dart'
files = content.split('SF:')

for file_block in files:
    if service_name in file_block:
        lines = file_block.split('\n')
        lf = lh = 0

        for line in lines:
            if line.startswith('LF:'):
                lf = int(line.split(':')[1])
            elif line.startswith('LH:'):
                lh = int(line.split(':')[1])

        if lf > 0:
            coverage = (lh / lf) * 100
            print(f"{service_name}: {coverage:.1f}% ({lh}/{lf} lines)")
            break
EOF
```

## Test Count Targets by Service

For 70% coverage, aim for these test counts:

| Service | Lines | Target Tests | Test Categories |
|---------|-------|--------------|-----------------|
| enhanced_supabase_service | 525 | 80-100 | Init(3), CRUD(20), Query(15), Cache(10), Error(15), Edge(20), Auth(10), Realtime(5) |
| supabase_auth_service | 386 | 60-80 | Init(3), Auth(25), Session(10), Error(15), Edge(15), State(8), Security(5) |
| bookmark_service | 178 | 60-70 | Init(5), CRUD(20), Query(10), Search(8), Stats(5), Cache(8), Error(10), Edge(8) |
| journal_service | 122 | 40-50 | Init(3), CRUD(15), Query(8), Encryption(8), Cache(6), Error(8), Edge(6) |
| semantic_search_service | 110 | 30-40 | Init(2), Search(15), Ranking(8), Cache(5), Error(6), Edge(6) |
| scenario_service | 298 | 55-65 | Init(3), CRUD(18), Query(12), Filter(10), Cache(8), Error(10), Edge(8) |

## Common Pitfalls to Avoid

1. **Don't forget to await async operations**
   ```dart
   // ❌ Wrong
   test('test', () {
     service.asyncMethod();
     expect(service.data, isNotNull);
   });

   // ✅ Correct
   test('test', () async {
     await service.asyncMethod();
     expect(service.data, isNotNull);
   });
   ```

2. **Always check Hive box status**
   ```dart
   // ❌ Wrong
   final box = Hive.box('name');

   // ✅ Correct
   if (!Hive.isBoxOpen('name')) {
     await Hive.openBox('name');
   }
   final box = Hive.box('name');
   ```

3. **Mock the entire query chain**
   ```dart
   // ❌ Incomplete
   when(mockClient.from('table')).thenReturn(mockBuilder);

   // ✅ Complete
   when(mockClient.from('table')).thenReturn(mockBuilder);
   when(mockBuilder.select()).thenReturn(mockBuilder);
   when(mockBuilder.eq('id', 1)).thenAnswer((_) async => [data]);
   ```

4. **Clean up resources in tearDown**
   ```dart
   tearDown() async {
     if (Hive.isBoxOpen('box')) {
       await box.clear();
       await box.close();
     }
     await teardownTestEnvironment();
   }
   ```

## Conclusion

By following these templates and guidelines, you can systematically create the 155-210 additional tests needed to reach 70% coverage. Focus on critical services first (bookmark, daily_verse, supabase_auth, enhanced_supabase) for maximum impact.

**Priority Order:**
1. Fix existing tests (bookmark, daily_verse)
2. Expand critical services (<30% coverage)
3. Boost medium services (30-60% coverage)
4. Add model/widget tests for final push

**Estimated Timeline:** 22-30 hours of focused work to achieve 70% coverage.
