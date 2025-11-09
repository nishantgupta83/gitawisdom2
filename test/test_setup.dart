// test/test_setup.dart
// Simple test setup for Gita Wisdom app tests

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Initialize test environment
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for test boxes
  // In tests, Hive will store in-memory
  try {
    // Register adapters if needed
    // Hive adapters for models would go here
  } catch (e) {
    // Adapters might already be registered
  }
}

/// Tear down test environment
Future<void> teardownTestEnvironment() async {
  try {
    // Close all Hive boxes
    await Hive.deleteFromDisk();
  } catch (e) {
    // Boxes might not exist yet
  }
}
