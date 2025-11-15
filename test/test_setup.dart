// test/test_setup.dart
// Simple test setup for Gita Wisdom app tests

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GitaWisdom/models/search_result.dart';
import 'dart:io';
import 'dart:async' show TimeoutException;

/// Initialize test environment
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with temporary directory for tests
  final testDir = Directory.systemTemp.createTempSync('hive_test_');
  Hive.init(testDir.path);

  // Setup mock for flutter_secure_storage
  FlutterSecureStorage.setMockInitialValues({});

  // Setup mock for shared_preferences
  SharedPreferences.setMockInitialValues({});

  // Initialize Supabase with dummy credentials for testing
  try {
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-anon-key-for-testing-purposes-only',
      debug: false,
    );
  } catch (e) {
    // Supabase might already be initialized
  }

  // Open settings box for SettingsService
  try {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  } catch (e) {
    // Box might already be open
  }

  // Register adapters if needed
  // Hive adapters for models would go here
  try {
    // Register SearchResult and SearchType adapters
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(SearchResultAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(SearchTypeAdapter());
    }
  } catch (e) {
    // Adapters might already be registered
  }
}

/// Tear down test environment
Future<void> teardownTestEnvironment() async {
  try {
    // Close all open boxes
    final boxNames = [
      'settings',
      'journal_entries',
      'bookmarks',
      'scenarios_critical',
      'scenarios_frequent',
      'scenarios_complete',
      'daily_verses',
      'chapters',
      'chapter_summaries',
      'search_cache',
    ];

    for (final boxName in boxNames) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
    }

    // Delete all data from disk
    await Hive.deleteFromDisk();
  } catch (e) {
    // Boxes might not exist yet
  }
}

// ==================== Additional Test Helpers ====================

/// Setup test environment with specific boxes
Future<void> setupTestEnvironmentWithBoxes(List<String> boxNames) async {
  await setupTestEnvironment();

  for (final boxName in boxNames) {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (e) {
      // Box might already be open
    }
  }
}

/// Create a test Hive box with sample data
Future<Box<T>> createTestBox<T>(
  String boxName, {
  Map<dynamic, T>? initialData,
}) async {
  Box<T> box;

  if (Hive.isBoxOpen(boxName)) {
    box = Hive.box<T>(boxName);
    await box.clear();
  } else {
    box = await Hive.openBox<T>(boxName);
  }

  if (initialData != null) {
    for (final entry in initialData.entries) {
      await box.put(entry.key, entry.value);
    }
  }

  return box;
}

/// Register all Hive adapters for testing
Future<void> registerAllHiveAdapters() async {
  try {
    // Only register if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      // Chapter adapter
      // Hive.registerAdapter(ChapterAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      // Verse adapter
      // Hive.registerAdapter(VerseAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      // Scenario adapter
      // Hive.registerAdapter(ScenarioAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      // JournalEntry adapter
      // Hive.registerAdapter(JournalEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      // Bookmark adapter
      // Hive.registerAdapter(BookmarkAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      // SearchResult adapter
      Hive.registerAdapter(SearchResultAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      // SearchType adapter
      Hive.registerAdapter(SearchTypeAdapter());
    }
  } catch (e) {
    // Adapters might already be registered
  }
}

/// Clean up a specific Hive box
Future<void> cleanupBox(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.clear();
      await box.close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  } catch (e) {
    // Box might not exist
  }
}

/// Clean up all test boxes
Future<void> cleanupAllBoxes() async {
  final boxNames = [
    'settings',
    'journal_entries',
    'bookmarks',
    'scenarios_critical',
    'scenarios_frequent',
    'scenarios_complete',
    'daily_verses',
    'chapters',
    'chapter_summaries',
    'search_cache',
  ];

  for (final boxName in boxNames) {
    await cleanupBox(boxName);
  }
}

// ==================== Service Test Helpers ====================

/// Setup minimal test environment (no Supabase)
Future<void> setupMinimalTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with temporary directory
  final testDir = Directory.systemTemp.createTempSync('hive_test_minimal_');
  Hive.init(testDir.path);

  // Setup mock for flutter_secure_storage
  FlutterSecureStorage.setMockInitialValues({});

  // Setup mock for shared_preferences
  SharedPreferences.setMockInitialValues({});

  // Register essential adapters
  await registerAllHiveAdapters();
}

/// Tear down minimal test environment
Future<void> teardownMinimalTestEnvironment() async {
  try {
    await cleanupAllBoxes();
    await Hive.deleteFromDisk();
  } catch (e) {
    // Ignore cleanup errors
  }
}

// ==================== Test Data Helpers ====================

/// Create test settings data
Map<String, dynamic> createTestSettingsData({
  bool isDarkMode = false,
  String language = 'en',
  String fontSize = 'small',
  bool musicEnabled = true,
  bool textShadowEnabled = false,
  double backgroundOpacity = 1.0,
}) {
  return {
    'isDarkMode': isDarkMode,
    'language': language,
    'fontSize': fontSize,
    'music_enabled': musicEnabled,
    'text_shadow_enabled': textShadowEnabled,
    'background_opacity': backgroundOpacity,
  };
}

/// Wait for async operation with timeout
Future<T> waitForAsync<T>(
  Future<T> Function() operation, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  return await operation().timeout(
    timeout,
    onTimeout: () {
      throw TimeoutException(
        'Operation timed out after ${timeout.inSeconds} seconds',
      );
    },
  );
}

/// Retry an async operation with exponential backoff
Future<T> retryAsync<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(milliseconds: 100),
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (attempt < maxRetries) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        rethrow;
      }
      await Future.delayed(delay);
      delay *= 2; // Exponential backoff
    }
  }

  throw Exception('Failed after $maxRetries retries');
}

// ==================== Mock Data Generators ====================

/// Generate test timestamp
DateTime createTestTimestamp({int daysAgo = 0}) {
  return DateTime.now().subtract(Duration(days: daysAgo));
}

/// Generate random test ID
String generateTestId({String prefix = 'test'}) {
  return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
}

/// Create test tags list
List<String> createTestTags({int count = 3}) {
  return List.generate(count, (index) => 'tag${index + 1}');
}

// ==================== Assertion Helpers ====================

/// Expect future completes successfully
Future<void> expectFutureCompletes<T>(Future<T> future) async {
  try {
    await future;
  } catch (e) {
    fail('Expected future to complete successfully, but got error: $e');
  }
}

/// Expect future throws specific exception
Future<void> expectFutureThrows<T extends Exception>(
  Future<dynamic> future,
) async {
  try {
    await future;
    fail('Expected future to throw $T, but it completed successfully');
  } catch (e) {
    expect(e, isA<T>());
  }
}

/// Expect list contains items in order
void expectListInOrder<T>(List<T> actual, List<T> expected) {
  expect(actual.length, equals(expected.length),
      reason: 'List lengths do not match');

  for (int i = 0; i < expected.length; i++) {
    expect(actual[i], equals(expected[i]),
        reason: 'Item at index $i does not match');
  }
}

/// Expect map contains all entries
void expectMapContainsEntries(
  Map<dynamic, dynamic> actual,
  Map<dynamic, dynamic> expected,
) {
  for (final entry in expected.entries) {
    expect(actual.containsKey(entry.key), isTrue,
        reason: 'Map missing key: ${entry.key}');
    expect(actual[entry.key], equals(entry.value),
        reason: 'Value for key ${entry.key} does not match');
  }
}
