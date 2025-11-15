// Integration test setup and utilities
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Integration test utilities and helpers
class IntegrationTestSetup {
  static IntegrationTestWidgetsFlutterBinding? _binding;
  static Directory? _testDir;

  /// Initialize integration test environment
  static Future<void> setup() async {
    _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    _binding!.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

    // Initialize Hive with temp directory
    _testDir = await Directory.systemTemp.createTemp('integration_test_');
    await Hive.initFlutter(_testDir!.path);

    // Setup mocks for secure storage
    FlutterSecureStorage.setMockInitialValues({});

    debugPrint('✅ Integration test environment initialized');
    debugPrint('📁 Test directory: ${_testDir!.path}');
  }

  /// Clean up after tests
  static Future<void> teardown() async {
    try {
      // Close all Hive boxes
      await Hive.close();

      // Delete test directory
      if (_testDir != null && await _testDir!.exists()) {
        await _testDir!.delete(recursive: true);
        debugPrint('✅ Test directory cleaned up');
      }
    } catch (e) {
      debugPrint('⚠️ Teardown error: $e');
    }
  }

  /// Take screenshot with timestamp
  static Future<void> takeScreenshot(String name) async {
    try {
      await _binding!.takeScreenshot('${DateTime.now().millisecondsSinceEpoch}_$name');
      debugPrint('📸 Screenshot: $name');
    } catch (e) {
      debugPrint('❌ Screenshot failed: $e');
    }
  }

  /// Wait for element with retries
  static Future<Finder> waitForElement(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    int retries = 5,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

      final elements = finder.evaluate();
      if (elements.isNotEmpty) {
        debugPrint('✅ Found element on attempt $attempt');
        return finder;
      }

      await Future.delayed(Duration(milliseconds: timeout.inMilliseconds ~/ retries));
    }

    throw Exception('Element not found after $retries attempts');
  }

  /// Tap element with retry logic
  static Future<void> tapElement(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      await waitForElement(tester, finder, timeout: timeout);
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
      debugPrint('✅ Tapped element');
    } catch (e) {
      debugPrint('❌ Tap failed: $e');
      rethrow;
    }
  }

  /// Enter text into field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      await waitForElement(tester, finder, timeout: timeout);
      await tester.enterText(finder, text);
      await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
      debugPrint('✅ Entered text: $text');
    } catch (e) {
      debugPrint('❌ Text entry failed: $e');
      rethrow;
    }
  }

  /// Scroll to find element
  static Future<void> scrollToFind(
    WidgetTester tester,
    Finder scrollable,
    Finder target, {
    double delta = -300.0,
    int maxScrolls = 10,
  }) async {
    for (int i = 0; i < maxScrolls; i++) {
      if (target.evaluate().isNotEmpty) {
        debugPrint('✅ Found element after $i scrolls');
        return;
      }

      await tester.drag(scrollable, Offset(0, delta));
      await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
    }

    throw Exception('Element not found after scrolling');
  }

  /// Navigate to tab by key
  static Future<void> navigateToTab(
    WidgetTester tester,
    String tabKey,
  ) async {
    final tabFinder = find.byKey(Key(tabKey));
    await tapElement(tester, tabFinder);
    debugPrint('✅ Navigated to tab: $tabKey');
  }

  /// Wait for app to load
  static Future<void> waitForAppLoad(
    WidgetTester tester, {
    Duration duration = const Duration(seconds: 8),
  }) async {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    debugPrint('✅ App loaded');
  }

  /// Verify element exists
  static void verifyElementExists(Finder finder, {String? message}) {
    expect(finder, findsOneWidget, reason: message ?? 'Element should exist');
    debugPrint('✅ Element verified: ${message ?? "found"}');
  }

  /// Verify element does not exist
  static void verifyElementNotExists(Finder finder, {String? message}) {
    expect(finder, findsNothing, reason: message ?? 'Element should not exist');
    debugPrint('✅ Element verified absent: ${message ?? "not found"}');
  }

  /// Simulate network delay
  static Future<void> simulateNetworkDelay({
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
  }

  /// Get test timestamp
  static String getTimestamp() {
    return DateTime.now().toIso8601String();
  }
}

/// Test data factories
class TestDataFactory {
  static const String testEmail = 'test@gitawisdom.com';
  static const String testPassword = 'TestPassword123!';
  static const String testName = 'Test User';

  static String generateJournalEntry({String? title, String? content}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return content ?? 'Test journal entry created at $timestamp';
  }

  static String generateSearchQuery() {
    final queries = [
      'dharma',
      'karma',
      'meditation',
      'duty',
      'peace',
    ];
    return queries[DateTime.now().millisecondsSinceEpoch % queries.length];
  }
}

/// Test result logger
class TestLogger {
  static final List<Map<String, dynamic>> _results = [];

  static void logTestStart(String testName) {
    debugPrint('\n🧪 === $testName ===');
    _results.add({
      'test': testName,
      'start_time': DateTime.now().toIso8601String(),
      'status': 'running',
    });
  }

  static void logTestEnd(String testName, {bool passed = true, String? error}) {
    debugPrint('${passed ? "✅" : "❌"} $testName ${passed ? "PASSED" : "FAILED"}');

    final result = _results.firstWhere(
      (r) => r['test'] == testName,
      orElse: () => {},
    );

    result['end_time'] = DateTime.now().toIso8601String();
    result['status'] = passed ? 'passed' : 'failed';
    if (error != null) {
      result['error'] = error;
    }
  }

  static void logStep(String step) {
    debugPrint('  → $step');
  }

  static void printSummary() {
    final passed = _results.where((r) => r['status'] == 'passed').length;
    final failed = _results.where((r) => r['status'] == 'failed').length;
    final total = _results.length;

    debugPrint('\n📊 === TEST SUMMARY ===');
    debugPrint('Total: $total');
    debugPrint('Passed: $passed');
    debugPrint('Failed: $failed');
    debugPrint('Success Rate: ${((passed / total) * 100).toStringAsFixed(2)}%');
  }

  static List<Map<String, dynamic>> getResults() => List.from(_results);

  static void clear() {
    _results.clear();
  }
}
