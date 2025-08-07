
#!/bin/bash

# OldWisdom Test Setup Script
# This script sets up the testing environment for the updated screens

echo "🧪 Setting up OldWisdom Test Environment..."

# Create test directory structure if it doesn't exist
echo "📁 Creating test directory structure..."
mkdir -p test/screens
mkdir -p test/services
mkdir -p test/models
mkdir -p test/widgets
mkdir -p integration_test

# Install dependencies
echo "📦 Installing test dependencies..."
flutter pub add --dev mockito build_runner
flutter pub get

# Generate mock files
echo "🏗️ Generating mock files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Create test configuration file
echo "⚙️ Creating test configuration..."
cat > test/test_config.dart << 'EOF'
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
EOF

# Create test runner script
echo "🏃 Creating test runner script..."
cat > run_tests.sh << 'EOF'
#!/bin/bash

echo "🧪 Running OldWisdom Test Suite..."

# Clean previous test results
echo "🧹 Cleaning previous test results..."
rm -rf coverage/
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run unit tests with coverage
echo "🔬 Running unit tests..."
flutter test --coverage

# Run integration tests
echo "🔗 Running integration tests..."
flutter test integration_test/

# Generate coverage report (optional - requires lcov)
if command -v lcov &> /dev/null; then
    echo "📊 Generating coverage report..."
    genhtml coverage/lcov.info -o coverage/html
    echo "Coverage report generated at coverage/html/index.html"
fi

echo "✅ Test suite completed!"
EOF

chmod +x run_tests.sh

# Create mock file templates
echo "🏗️ Creating mock file templates..."

# Mock for SupabaseService
cat > test/mocks/mock_supabase_service.dart << 'EOF'
import 'package:mockito/annotations.dart';
import 'package:oldwisdom/services/supabase_service.dart';

// This will generate MockSupabaseService class
@GenerateMocks([SupabaseService])
void main() {}
EOF

# Mock for AudioService
cat > test/mocks/mock_audio_service.dart << 'EOF'
import 'package:mockito/annotations.dart';
import 'package:oldwisdom/services/audio_service.dart';

// This will generate MockAudioService class
@GenerateMocks([AudioService])
void main() {}
EOF

# Create test data factory
echo "🏭 Creating test data factory..."
cat > test/factories/test_data_factory.dart << 'EOF'
import 'package:oldwisdom/models/chapter.dart';
import 'package:oldwisdom/models/chapter_summary.dart';
import 'package:oldwisdom/models/scenario.dart';
import 'package:oldwisdom/models/verse.dart';

class TestDataFactory {
  static Chapter createTestChapter({
    int chapterId = 1,
    String title = "Test Chapter",
    String? subtitle = "Test Subtitle",
    String? summary = "Test chapter summary",
    int verseCount = 47,
    List<String>? keyTeachings,
  }) {
    return Chapter(
      chapterId: chapterId,
      title: title,
      subtitle: subtitle,
      summary: summary,
      verseCount: verseCount,
      keyTeachings: keyTeachings ?? ["Teaching 1", "Teaching 2"],
    );
  }
  
  static ChapterSummary createTestChapterSummary({
    int chapterId = 1,
    String title = "Test Chapter",
    String? subtitle = "Test Subtitle",
    int scenarioCount = 5,
    int verseCount = 47,
  }) {
    return ChapterSummary(
      chapterId: chapterId,
      title: title,
      subtitle: subtitle,
      scenarioCount: scenarioCount,
      verseCount: verseCount,
    );
  }
  
  static Scenario createTestScenario({
    String title = "Test Scenario",
    String description = "Test description",
    String category = "Test",
    int chapter = 1,
    String heartResponse = "Test heart response",
    String dutyResponse = "Test duty response", 
    String gitaWisdom = "Test wisdom",
    List<String>? tags,
    List<String>? actionSteps,
  }) {
    return Scenario(
      title: title,
      description: description,
      category: category,
      chapter: chapter,
      heartResponse: heartResponse,
      dutyResponse: dutyResponse,
      gitaWisdom: gitaWisdom,
      tags: tags ?? ["test", "sample"],
      actionSteps: actionSteps ?? ["Step 1", "Step 2"],
      createdAt: DateTime.now(),
    );
  }
  
  static Verse createTestVerse({
    int verseId = 1,
    String description = "Test verse description",
  }) {
    return Verse(
      verseId: verseId,
      description: description,
    );
  }
}
EOF

# Create widget test helpers
echo "🛠️ Creating widget test helpers..."
cat > test/helpers/widget_test_helpers.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetTestHelpers {
  static Future<void> pumpWithAnimation(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pump(duration ?? const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }
  
  static Widget wrapInMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
      theme: ThemeData.light(),
    );
  }
  
  static Future<void> dragToRefresh(WidgetTester tester) async {
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pumpAndSettle();
  }
  
  static Future<void> scrollToBottom(WidgetTester tester) async {
    final listFinder = find.byType(Scrollable);
    if (tester.any(listFinder)) {
      await tester.scrollUntilVisible(
        find.byType(Widget).last,
        500.0,
        scrollable: listFinder,
      );
    }
  }
  
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
    await tester.pumpAndSettle();
  }
}
EOF

# Create performance test utilities
echo "⚡ Creating performance test utilities..."
cat > test/performance/performance_test_utils.dart << 'EOF'
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class PerformanceTestUtils {
  static Future<void> measureScrollPerformance(
    WidgetTester tester,
    Finder scrollableFinder,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    // Perform scroll operation
    await tester.drag(scrollableFinder, const Offset(0, -500));
    await tester.pumpAndSettle();
    
    stopwatch.stop();
    
    // Assert reasonable performance (adjust threshold as needed)
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    
    if (kDebugMode) {
      print('Scroll performance: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
  
  static Future<void> measurePageTransitionPerformance(
    WidgetTester tester,
    VoidCallback navigationAction,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    navigationAction();
    await tester.pumpAndSettle();
    
    stopwatch.stop();
    
    // Assert reasonable navigation performance
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    
    if (kDebugMode) {
      print('Navigation performance: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
EOF

# Update pubspec.yaml with test dependencies (append if not exists)
echo "📝 Updating pubspec.yaml with test dependencies..."
if ! grep -q "mockito:" pubspec.yaml; then
  cat >> pubspec.yaml << 'EOF'

  # Testing dependencies (added by setup script)
  mockito: ^5.4.2
  build_runner: ^2.4.6
EOF
fi

# Generate all mocks
echo "🏗️ Generating all mock files..."
flutter packages pub run build_runner build

echo "✅ Test environment setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Run './run_tests.sh' to execute the full test suite"
echo "2. Run 'flutter test test/screens/' to test specific screens"
echo "3. Run 'flutter test integration_test/' for integration tests"
echo ""
echo "📁 Test structure created:"
echo "  test/"
echo "  ├── screens/           # Screen-specific tests"
echo "  ├── services/          # Service layer tests"
echo "  ├── models/            # Model tests"
echo "  ├── widgets/           # Widget tests"
echo "  ├── mocks/             # Mock classes"
echo "  ├── factories/         # Test data factories"
echo "  ├── helpers/           # Test utilities"
echo "  └── performance/       # Performance tests"
echo ""
echo "🎯 Key files:"
echo "  - run_tests.sh         # Main test runner"
echo "  - test_config.dart     # Test configuration"
echo "  - test_data_factory.dart # Test data generation"
echo ""
echo "Happy testing! 🧪✨"
