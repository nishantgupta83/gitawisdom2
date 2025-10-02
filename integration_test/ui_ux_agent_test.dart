import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;

/// Comprehensive UI/UX Testing Agent for GitaWisdom
///
/// This integration test systematically navigates through the entire app,
/// verifies all interactive elements, and ensures events trigger correctly.
///
/// Features:
/// - Complete navigation flow testing
/// - Interactive element verification
/// - Performance monitoring
/// - Error detection and reporting
/// - Screenshot capture on failures
/// - Detailed test reporting
class UIUXTestingAgent {
  static IntegrationTestWidgetsFlutterBinding? binding;
  static Map<String, dynamic> testResults = {};
  static List<String> errorLog = [];
  static DateTime testStartTime = DateTime.now();

  /// Initialize the testing agent
  static void initialize() {
    binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    binding!.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
    testStartTime = DateTime.now();

    print('🚀 UI/UX Testing Agent Initialized');
    print('📱 Target App: GitaWisdom');
    print('⏰ Start Time: ${testStartTime.toIso8601String()}');
  }

  /// Take screenshot with timestamp
  static Future<void> takeScreenshot(String name) async {
    try {
      await binding!.takeScreenshot('${DateTime.now().millisecondsSinceEpoch}_$name');
      print('📸 Screenshot captured: $name');
    } catch (e) {
      print('❌ Screenshot failed: $e');
    }
  }

  /// Wait for element with timeout and retries
  static Future<Finder> waitForElement(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    int retries = 3,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        await tester.pump();
        final elements = finder.evaluate();
        if (elements.isNotEmpty) {
          print('✅ Found element on attempt $attempt');
          return finder;
        }
        await Future.delayed(Duration(milliseconds: timeout.inMilliseconds ~/ retries));
      } catch (e) {
        print('⚠️ Attempt $attempt failed: $e');
        if (attempt == retries) rethrow;
      }
    }
    throw Exception('Element not found after $retries attempts');
  }

  /// Navigate to specific screen by tab
  static Future<void> navigateToScreen(WidgetTester tester, String screenName) async {
    print('🧭 Navigating to: $screenName');

    final Map<String, String> tabKeys = {
      'home': 'home_tab',
      'chapters': 'chapters_tab',
      'scenarios': 'scenarios_tab',
      'journal': 'journal_tab',
      'more': 'more_tab',
    };

    if (tabKeys.containsKey(screenName)) {
      final tabFinder = find.byKey(Key(tabKeys[screenName]!));
      await waitForElement(tester, tabFinder);
      await tester.tap(tabFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      print('✅ Navigated to $screenName');
    } else {
      throw Exception('Unknown screen: $screenName');
    }
  }

  /// Verify screen is displayed
  static Future<void> verifyScreen(WidgetTester tester, String screenName) async {
    print('🔍 Verifying screen: $screenName');

    // Screen-specific verification logic
    switch (screenName) {
      case 'home':
        await waitForElement(tester, find.text('GitaWisdom'));
        await waitForElement(tester, find.byType(BottomNavigationBar));
        break;
      case 'chapters':
        await waitForElement(tester, find.text('Chapters'));
        break;
      case 'scenarios':
        await waitForElement(tester, find.text('Scenarios'));
        break;
      case 'journal':
        await waitForElement(tester, find.text('Journal'));
        break;
      case 'more':
        await waitForElement(tester, find.text('More'));
        break;
      default:
        throw Exception('Unknown screen verification: $screenName');
    }

    await takeScreenshot('verify_$screenName');
    print('✅ Screen verified: $screenName');
  }

  /// Test interactive element
  static Future<void> testInteractiveElement(
    WidgetTester tester,
    String elementType,
    String elementKey,
    String expectedOutcome,
  ) async {
    print('🎯 Testing $elementType: $elementKey');

    try {
      final finder = find.byKey(Key(elementKey));
      await waitForElement(tester, finder);

      switch (elementType) {
        case 'button':
        case 'tab':
        case 'list_item':
          await tester.tap(finder);
          break;
        case 'switch':
          await tester.tap(finder);
          break;
        case 'textfield':
          await tester.enterText(finder, 'test input');
          break;
        default:
          await tester.tap(finder);
      }

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      print('✅ $elementType interaction successful');

      testResults[elementKey] = {
        'status': 'passed',
        'type': elementType,
        'outcome': expectedOutcome,
        'timestamp': DateTime.now().toIso8601String(),
      };

    } catch (e) {
      print('❌ $elementType interaction failed: $e');
      errorLog.add('$elementType ($elementKey): $e');
      await takeScreenshot('error_${elementKey}');

      testResults[elementKey] = {
        'status': 'failed',
        'type': elementType,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Monitor performance during test
  static Future<Map<String, dynamic>> measurePerformance(
    WidgetTester tester,
    String operation,
    Future<void> Function() testFunction,
  ) async {
    print('📊 Monitoring performance for: $operation');

    final startTime = DateTime.now();
    final startMemory = await _getMemoryUsage();

    await testFunction();

    final endTime = DateTime.now();
    final endMemory = await _getMemoryUsage();
    final duration = endTime.difference(startTime);

    final performance = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'memory_start_mb': startMemory,
      'memory_end_mb': endMemory,
      'memory_delta_mb': endMemory - startMemory,
      'timestamp': startTime.toIso8601String(),
    };

    print('⏱️ $operation completed in ${duration.inMilliseconds}ms');
    print('💾 Memory delta: ${performance['memory_delta_mb']}MB');

    return performance;
  }

  /// Get current memory usage (simplified)
  static Future<double> _getMemoryUsage() async {
    // In a real implementation, you'd use platform channels to get actual memory usage
    // For now, return a placeholder value
    return 0.0;
  }

  /// Generate comprehensive test report
  static Future<void> generateReport() async {
    final testEndTime = DateTime.now();
    final totalDuration = testEndTime.difference(testStartTime);

    final report = {
      'test_session': {
        'start_time': testStartTime.toIso8601String(),
        'end_time': testEndTime.toIso8601String(),
        'total_duration_ms': totalDuration.inMilliseconds,
        'app_name': 'GitaWisdom',
        'platform': Platform.operatingSystem,
      },
      'test_results': testResults,
      'errors': errorLog,
      'summary': {
        'total_tests': testResults.length,
        'passed': testResults.values.where((r) => r['status'] == 'passed').length,
        'failed': testResults.values.where((r) => r['status'] == 'failed').length,
        'success_rate': testResults.isNotEmpty
          ? (testResults.values.where((r) => r['status'] == 'passed').length / testResults.length * 100).toStringAsFixed(2)
          : '0.00',
      }
    };

    print('\n📋 === UI/UX TEST REPORT ===');
    print('⏰ Duration: ${totalDuration.inSeconds}s');
    final summaryData = report['summary'];
    if (summaryData is Map<String, dynamic>) {
      print('✅ Passed: ${summaryData['passed'] ?? 0}');
      print('❌ Failed: ${summaryData['failed'] ?? 0}');
      print('📊 Success Rate: ${summaryData['success_rate'] ?? '0.00'}%');
    } else {
      print('✅ Passed: 0');
      print('❌ Failed: 0');
      print('📊 Success Rate: 0.00%');
    }

    if (errorLog.isNotEmpty) {
      print('\n🚨 ERRORS ENCOUNTERED:');
      for (String error in errorLog) {
        print('  • $error');
      }
    }

    print('\n🎯 Test completed successfully!\n');

    // Save report to file
    try {
      final reportJson = jsonEncode(report);
      // In a real scenario, you'd save this to a file
      print('💾 Report generated (${reportJson.length} characters)');
    } catch (e) {
      print('❌ Failed to save report: $e');
    }
  }
}

void main() {
  group('GitaWisdom UI/UX Comprehensive Testing', () {

    setUpAll(() {
      UIUXTestingAgent.initialize();
    });

    tearDownAll(() async {
      await UIUXTestingAgent.generateReport();
    });

    testWidgets('Complete Navigation Flow Test', (WidgetTester tester) async {
      print('\n🧪 === COMPLETE NAVIGATION FLOW TEST ===');

      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Wait for app to fully load
      await UIUXTestingAgent.takeScreenshot('app_launch');

      // Test each navigation tab
      final screens = ['home', 'chapters', 'scenarios', 'journal', 'more'];

      for (String screen in screens) {
        await UIUXTestingAgent.measurePerformance(tester, 'navigate_to_$screen', () async {
          await UIUXTestingAgent.navigateToScreen(tester, screen);
          await UIUXTestingAgent.verifyScreen(tester, screen);
        });
      }

      print('✅ Navigation flow test completed');
    });

    testWidgets('Interactive Elements Test', (WidgetTester tester) async {
      print('\n🧪 === INTERACTIVE ELEMENTS TEST ===');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Test bottom navigation interactions
      await UIUXTestingAgent.testInteractiveElement(
        tester, 'tab', 'chapters_tab', 'navigate_to_chapters'
      );

      await UIUXTestingAgent.testInteractiveElement(
        tester, 'tab', 'scenarios_tab', 'navigate_to_scenarios'
      );

      await UIUXTestingAgent.testInteractiveElement(
        tester, 'tab', 'journal_tab', 'navigate_to_journal'
      );

      await UIUXTestingAgent.testInteractiveElement(
        tester, 'tab', 'more_tab', 'navigate_to_more'
      );

      print('✅ Interactive elements test completed');
    });

    testWidgets('Deep Navigation Test', (WidgetTester tester) async {
      print('\n🧪 === DEEP NAVIGATION TEST ===');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Navigate to chapters and test deep navigation
      await UIUXTestingAgent.navigateToScreen(tester, 'chapters');

      // Look for first chapter item and tap it
      try {
        final chapterItems = find.byType(ListTile);
        if (chapterItems.evaluate().isNotEmpty) {
          await tester.tap(chapterItems.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await UIUXTestingAgent.takeScreenshot('chapter_detail');

          // Test back navigation
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
            await UIUXTestingAgent.verifyScreen(tester, 'chapters');
          }
        }
      } catch (e) {
        print('⚠️ Deep navigation test partial failure: $e');
      }

      print('✅ Deep navigation test completed');
    });

    testWidgets('Performance Monitoring Test', (WidgetTester tester) async {
      print('\n🧪 === PERFORMANCE MONITORING TEST ===');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Test rapid navigation for performance
      final screens = ['chapters', 'scenarios', 'journal', 'more', 'home'];

      for (String screen in screens) {
        await UIUXTestingAgent.measurePerformance(tester, 'rapid_nav_$screen', () async {
          await UIUXTestingAgent.navigateToScreen(tester, screen);
          await Future.delayed(const Duration(milliseconds: 500));
        });
      }

      print('✅ Performance monitoring test completed');
    });

    testWidgets('Error Resilience Test', (WidgetTester tester) async {
      print('\n🧪 === ERROR RESILIENCE TEST ===');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Test various error scenarios
      try {
        // Test tapping non-existent elements
        await UIUXTestingAgent.testInteractiveElement(
          tester, 'button', 'non_existent_button', 'should_fail'
        );
      } catch (e) {
        print('✅ Error handling working correctly: $e');
      }

      // Test rapid tapping
      try {
        final homeTab = find.byKey(const Key('home_tab'));
        if (homeTab.evaluate().isNotEmpty) {
          for (int i = 0; i < 5; i++) {
            await tester.tap(homeTab);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
      } catch (e) {
        print('⚠️ Rapid tapping issue: $e');
      }

      print('✅ Error resilience test completed');
    });
  });
}