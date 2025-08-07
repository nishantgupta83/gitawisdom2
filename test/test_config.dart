// Test configuration and utilities
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestConfig {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration networkDelay = Duration(milliseconds: 500);
  
  static Future<void> pumpWithSettle(WidgetTester tester, [Duration? duration]) async {
    await tester.pump(duration);
    await tester.pumpAndSettle();
  }
  
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: child,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

// Common test data
class TestData {
  static const sampleVerseText = "Test verse content for unit testing";
  static const sampleChapterTitle = "Sample Chapter Title";
  static const sampleScenarioDescription = "Sample scenario description for testing";
}
