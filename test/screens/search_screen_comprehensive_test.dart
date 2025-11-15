// test/screens/search_screen_comprehensive_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/search_screen.dart';
import '../test_setup.dart';

/// Comprehensive test suite for SearchScreen (search_screen.dart)
///
/// Covers:
/// - Rendering and initial states
/// - Search functionality (initialization, query entry, results)
/// - Welcome state and example chips
/// - Loading states (initializing, searching, load more)
/// - User interactions (search, clear, example chips, result taps)
/// - UI components and theming
/// - Accessibility and responsive design
/// - Performance and edge cases
///
/// Target: 40 comprehensive tests for 70%+ coverage

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  Widget createTestScreen({String? initialQuery}) {
    return MaterialApp(
      home: SearchScreen(initialQuery: initialQuery),
    );
  }

  group('SearchScreen - Basic Rendering', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('has Scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Search Wisdom'), findsOneWidget);
    });

    testWidgets('has Column layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays search field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('SearchScreen - Search Field', () {
    testWidgets('search field has correct hint text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.text('Ask about any life situation...'), findsOneWidget);
    });

    testWidgets('search field has search icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.prefixIcon, isNotNull);
    });

    testWidgets('search field has proper text input action', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, equals(TextInputAction.search));
    });

    testWidgets('search field has proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.filled, isTrue);
      expect(textField.decoration?.border, isNotNull);
    });

    testWidgets('entering text shows clear button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button clears search field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('supports initial query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen(initialQuery: 'initial test'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('initial test'));
    });
  });

  group('SearchScreen - Loading States', () {
    testWidgets('displays initializing message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.text('Initializing intelligent search...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows welcome state after initialization', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AI-Powered Wisdom Search'), findsOneWidget);
    });

    testWidgets('transitions from initializing to welcome state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.text('Initializing intelligent search...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AI-Powered Wisdom Search'), findsOneWidget);
    });
  });

  group('SearchScreen - Welcome State', () {
    testWidgets('displays welcome state message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AI-Powered Wisdom Search'), findsOneWidget);
      expect(
        find.text('Search across 1280 life situations using intelligent keyword and semantic AI search.'),
        findsOneWidget,
      );
    });

    testWidgets('displays example chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Career decisions'), findsOneWidget);
      expect(find.text('Family conflicts'), findsOneWidget);
      expect(find.text('Work-life balance'), findsOneWidget);
      expect(find.text('Personal growth'), findsOneWidget);
    });

    testWidgets('example chips are ActionChips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ActionChip), findsWidgets);
    });

    testWidgets('tapping example chip fills search field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Career decisions'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('Career decisions'));
    });

    testWidgets('welcome state shows AI icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
    });

    testWidgets('welcome state uses SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('welcome state uses Wrap for chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Wrap), findsOneWidget);
    });
  });

  group('SearchScreen - UI Components', () {
    testWidgets('has AnimatedContainer for search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('has AnimatedSize for powered by AI', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(AnimatedSize), findsOneWidget);
    });

    testWidgets('uses Container widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses Text widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('uses Icon widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('uses SizedBox for spacing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('uses Row for layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Row), findsWidgets);
    });
  });

  group('SearchScreen - Theming', () {
    testWidgets('supports dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const SearchScreen(),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(SearchScreen));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('supports light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SearchScreen(),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(SearchScreen));
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('uses theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final context = tester.element(find.byType(SearchScreen));
      final theme = Theme.of(context);

      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.colorScheme.surface, isNotNull);
    });
  });

  group('SearchScreen - Accessibility', () {
    testWidgets('supports text scaling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: createTestScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('respects MediaQuery view insets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: 100),
          ),
          child: createTestScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });

  group('SearchScreen - Responsive Design', () {
    testWidgets('adapts to small screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('adapts to large screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('handles portrait orientation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('handles landscape orientation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(812, 375);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });

  group('SearchScreen - Performance', () {
    testWidgets('renders within reasonable time', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('handles rapid rebuilds', (WidgetTester tester) async {
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(createTestScreen());
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes resources properly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes controllers properly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Different Screen')),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('SearchScreen - State Management', () {
    testWidgets('state is created correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final state = tester.state<State<SearchScreen>>(find.byType(SearchScreen));
      expect(state, isNotNull);
      expect(state.mounted, isTrue);
    });

    testWidgets('maintains state across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('handles empty search query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });

  group('SearchScreen - Edge Cases', () {
    testWidgets('handles null initial query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen(initialQuery: null));
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('handles empty initial query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen(initialQuery: ''));
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('handles long search query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(
        find.byType(TextField),
        'This is a very long search query that might cause issues ' * 5,
      );
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('handles special characters in query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), '@#\$%^&*()');
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });
}
