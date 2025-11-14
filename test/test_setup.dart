// test/test_setup.dart
// Simple test setup for Gita Wisdom app tests

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

/// Initialize test environment
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with temporary directory for tests
  final testDir = Directory.systemTemp.createTempSync('hive_test_');
  Hive.init(testDir.path);

  // Setup mock for flutter_secure_storage
  FlutterSecureStorage.setMockInitialValues({});

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
    // Register any custom Hive adapters here
  } catch (e) {
    // Adapters might already be registered
  }
}

/// Tear down test environment
Future<void> teardownTestEnvironment() async {
  try {
    // Close settings box
    if (Hive.isBoxOpen('settings')) {
      await Hive.box('settings').close();
    }

    // Delete all data from disk
    await Hive.deleteFromDisk();
  } catch (e) {
    // Boxes might not exist yet
  }
}
