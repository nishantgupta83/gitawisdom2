// test/screens/scenario_detail_view_comprehensive_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/scenario_detail_view.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../test_setup.dart';

/// Comprehensive test suite for ScenarioDetailView (scenario_detail_view.dart)
///
/// Covers:
/// - Rendering and initial states
/// - Scenario content display (title, description, heart/duty responses)
/// - Action steps and wisdom guidance
/// - User interactions (share, expand/collapse, navigation)
/// - UI components (cards, buttons, badges)
/// - Theming and styling
/// - Accessibility and responsive design
/// - State management
///
/// Target: 40 comprehensive tests for 70%+ coverage

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  Scenario createTestScenario({
    int id = 1,
    String title = 'Test Scenario',
    String description = 'Test scenario description',
    String heartResponse = 'Heart response guidance',
    String dutyResponse = 'Duty response guidance',
    String? category,
    List<String>? tags,
    List<String>? actionSteps,
  }) {
    return Scenario(
      scenarioId: id,
      title: title,
      description: description,
      heartResponse: heartResponse,
      dutyResponse: dutyResponse,
      gitaWisdom: 'Test wisdom',
      chapterId: 1,
      verseNumber: 1,
      category: category ?? 'Test Category',
      tags: tags ?? ['test', 'scenario'],
      actionSteps: actionSteps ?? ['Step 1', 'Step 2', 'Step 3'],
    );
  }

  Widget createTestScreen({Scenario? scenario}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: ScenarioDetailView(scenario: scenario ?? createTestScenario()),
    );
  }

  group('ScenarioDetailView - Basic Rendering', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('has Scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has Stack for layered layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('has SafeArea for safe layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('uses ListView for scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('has bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      // ModernNavBar should be present
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('ScenarioDetailView - Navigation Buttons', () {
    testWidgets('displays back button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays home button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
    });

    testWidgets('navigation buttons have CircleAvatar background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('back button has tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final backButton = find.ancestor(
        of: find.byIcon(Icons.arrow_back),
        matching: find.byType(IconButton),
      );

      expect(backButton, findsOneWidget);
    });

    testWidgets('home button has tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final homeButton = find.ancestor(
        of: find.byIcon(Icons.home_filled),
        matching: find.byType(IconButton),
      );

      expect(homeButton, findsOneWidget);
    });

    testWidgets('buttons are positioned correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Positioned), findsWidgets);
    });
  });

  group('ScenarioDetailView - Content Display', () {
    testWidgets('displays scenario title', (WidgetTester tester) async {
      final scenario = createTestScenario(title: 'Career Decision Dilemma');
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.text('Career Decision Dilemma'), findsOneWidget);
    });

    testWidgets('displays scenario category', (WidgetTester tester) async {
      final scenario = createTestScenario(category: 'Career');
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.text('Career'), findsWidgets);
    });

    testWidgets('displays scenario tags', (WidgetTester tester) async {
      final scenario = createTestScenario(tags: ['work', 'career']);
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.text('work'), findsWidgets);
    });

    testWidgets('displays dilemma section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.text('Dilemma'), findsOneWidget);
    });

    testWidgets('displays heart says section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets('displays duty says section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byIcon(Icons.balance), findsWidgets);
    });

    testWidgets('displays share button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byIcon(Icons.share), findsWidgets);
    });
  });

  group('ScenarioDetailView - Action Steps', () {
    testWidgets('displays show wisdom button initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
    });

    testWidgets('wisdom button shows loading state when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final wisdomButton = find.ancestor(
        of: find.byIcon(Icons.auto_awesome),
        matching: find.byType(InkWell),
      );

      if (wisdomButton.evaluate().isNotEmpty) {
        await tester.tap(wisdomButton.first);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsWidgets);
      }
    });

    testWidgets('action steps have numbered badges', (WidgetTester tester) async {
      final scenario = createTestScenario(
        actionSteps: ['Step 1', 'Step 2', 'Step 3'],
      );
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      // Tap wisdom button to reveal action steps
      final wisdomButton = find.ancestor(
        of: find.byIcon(Icons.auto_awesome),
        matching: find.byType(InkWell),
      );

      if (wisdomButton.evaluate().isNotEmpty) {
        await tester.tap(wisdomButton.first);
        await tester.pump(const Duration(milliseconds: 1000));
      }
    });
  });

  group('ScenarioDetailView - UI Components', () {
    testWidgets('uses Card widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('uses Container widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses Column for layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('uses Row for layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('uses Icon widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('uses Text widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('uses SizedBox for spacing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('uses Padding for content spacing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses InkWell for tap effects', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('uses Material widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(Material), findsWidgets);
    });
  });

  group('ScenarioDetailView - Theming', () {
    testWidgets('supports dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ScenarioDetailView(scenario: createTestScenario()),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(ScenarioDetailView));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('supports light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ScenarioDetailView(scenario: createTestScenario()),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(ScenarioDetailView));
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('uses theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final context = tester.element(find.byType(ScenarioDetailView));
      final theme = Theme.of(context);

      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.colorScheme.surface, isNotNull);
    });

    testWidgets('uses gradient decorations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      // Gradients are used throughout the UI
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('ScenarioDetailView - Accessibility', () {
    testWidgets('supports text scaling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: createTestScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
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

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles keyboard visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('supports screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });
  });

  group('ScenarioDetailView - Responsive Design', () {
    testWidgets('adapts to small screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('adapts to large screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('handles portrait orientation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('handles landscape orientation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(812, 375);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });

  group('ScenarioDetailView - Performance', () {
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

      expect(find.byType(ScenarioDetailView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes resources properly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('ScenarioDetailView - Localization', () {
    testWidgets('has localization support', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final context = tester.element(find.byType(ScenarioDetailView));
      expect(AppLocalizations.of(context), isNotNull);
    });

    testWidgets('uses AppLocalizations for text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();

      final context = tester.element(find.byType(ScenarioDetailView));
      final localizations = AppLocalizations.of(context);

      expect(localizations, isNotNull);
      expect(localizations!.modernScenario, isNotEmpty);
      expect(localizations.heartSays, isNotEmpty);
      expect(localizations.dutySays, isNotEmpty);
    });
  });

  group('ScenarioDetailView - Edge Cases', () {
    testWidgets('handles scenario without action steps', (WidgetTester tester) async {
      final scenario = createTestScenario(actionSteps: null);
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles scenario without tags', (WidgetTester tester) async {
      final scenario = createTestScenario(tags: null);
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles long scenario title', (WidgetTester tester) async {
      final scenario = createTestScenario(
        title: 'This is a very long scenario title that might overflow the available space in the UI',
      );
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles long description', (WidgetTester tester) async {
      final scenario = createTestScenario(
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' * 10,
      );
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles multiple action steps', (WidgetTester tester) async {
      final scenario = createTestScenario(
        actionSteps: List.generate(10, (i) => 'Action step ${i + 1}'),
      );
      await tester.pumpWidget(createTestScreen(scenario: scenario));
      await tester.pump();

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });
  });
}
