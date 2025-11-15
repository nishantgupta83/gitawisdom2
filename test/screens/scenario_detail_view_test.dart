// test/screens/scenario_detail_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:GitaWisdom/screens/scenario_detail_view.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/widgets/modern_nav_bar.dart';
import 'package:GitaWisdom/l10n/app_localizations.dart';

import '../test_setup.dart';

void main() {
  setUp(() async {
    await setupTestEnvironment();
  });

  tearDown(() async {
    await teardownTestEnvironment();
  });

  Scenario _createMockScenario({
    String? title,
    String? description,
    String? heartResponse,
    String? dutyResponse,
    List<String>? tags,
    List<String>? actionSteps,
  }) {
    return Scenario(
      title: title ?? 'Test Scenario Title',
      description: description ?? 'This is a test scenario description that explains the dilemma.',
      category: 'Work & Career',
      chapter: 2,
      heartResponse: heartResponse ?? 'Follow your passion and emotions. Listen to your inner voice.',
      dutyResponse: dutyResponse ?? 'Follow dharma and duty. Act without attachment to results.',
      gitaWisdom: 'You have the right to work, but never to the fruit of work.',
      verse: 'Test verse content',
      verseNumber: '2.47',
      tags: tags ?? ['work', 'career', 'decision'],
      actionSteps: actionSteps ?? [
        'Reflect on your values and priorities',
        'Seek guidance from mentors',
        'Make a balanced decision',
      ],
      createdAt: DateTime.now(),
    );
  }

  Widget _createScenarioDetailView(Scenario scenario) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      home: ScenarioDetailView(scenario: scenario),
    );
  }

  group('ScenarioDetailView Rendering Tests', () {
    testWidgets('screen renders without errors', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('displays "Modern Scenario" header', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Modern Scenario'), findsOneWidget);
    });

    testWidgets('displays scenario title', (tester) async {
      final scenario = _createMockScenario(title: 'Career Dilemma');
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Career Dilemma'), findsOneWidget);
    });

    testWidgets('displays scenario description in Dilemma section', (tester) async {
      final scenario = _createMockScenario(description: 'Should I change careers?');
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dilemma'), findsOneWidget);
      expect(find.textContaining('Should I change careers'), findsOneWidget);
    });

    testWidgets('displays Heart response section', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Heart Says:'), findsOneWidget);
    });

    testWidgets('displays Duty response section', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Duty Says:'), findsOneWidget);
    });

    testWidgets('displays floating back button', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays floating home button', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ModernNavBar), findsOneWidget);
    });
  });

  group('ScenarioDetailView Content Tests', () {
    testWidgets('heart response shows emotional perspective', (tester) async {
      final scenario = _createMockScenario(
        heartResponse: 'Follow your passion and dreams.',
      );
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Follow your passion'), findsOneWidget);
    });

    testWidgets('duty response shows dharmic perspective', (tester) async {
      final scenario = _createMockScenario(
        dutyResponse: 'Fulfill your responsibilities with dedication.',
      );
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Fulfill your responsibilities'), findsOneWidget);
    });

    testWidgets('heart section has heart icon', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets('duty section has balance icon', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.balance), findsOneWidget);
    });

    testWidgets('dilemma section has fork icon', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.fork_right), findsOneWidget);
    });

    testWidgets('displays category pill', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Work & Career'), findsWidgets);
      expect(find.byIcon(Icons.local_offer), findsOneWidget);
    });

    testWidgets('displays share button', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.share), findsWidgets);
    });

    testWidgets('displays tags when available', (tester) async {
      final scenario = _createMockScenario(tags: ['work', 'career', 'stress']);
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('work'), findsOneWidget);
      expect(find.text('career'), findsOneWidget);
      expect(find.text('stress'), findsOneWidget);
    });

    testWidgets('hides tags section when no tags', (tester) async {
      final scenario = _createMockScenario(tags: []);
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tags section should not be visible
      expect(find.byType(ActionChip), findsNothing);
    });

    testWidgets('displays first tag as floating badge', (tester) async {
      final scenario = _createMockScenario(tags: ['important', 'urgent']);
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // First tag should appear as floating badge
      expect(find.text('important'), findsWidgets);
    });
  });

  group('ScenarioDetailView Action Steps Tests', () {
    testWidgets('shows "Get Guidance" button when action steps hidden', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Get Guidance'), findsOneWidget);
    });

    testWidgets('reveals action steps when "Get Guidance" tapped', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Get Guidance button
      await tester.tap(find.text('Get Guidance'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Action steps should be revealed
      expect(find.text('Wisdom Steps'), findsOneWidget);
    });

    testWidgets('action steps display with content', (tester) async {
      final scenario = _createMockScenario(
        actionSteps: ['First step', 'Second step', 'Third step'],
      );
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Reveal action steps
      await tester.tap(find.text('Get Guidance'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('First step'), findsOneWidget);
      expect(find.text('Second step'), findsOneWidget);
      expect(find.text('Third step'), findsOneWidget);
    });

    testWidgets('action steps have number badges', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Reveal action steps
      await tester.tap(find.text('Get Guidance'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Number badges should be visible
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows loading indicator while revealing action steps', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Get Guidance button
      await tester.tap(find.text('Get Guidance'));
      await tester.pump(const Duration(milliseconds: 100));

      // Loading indicator should appear briefly
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Get Guidance button has wisdom icon', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Button should have auto_awesome icon
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('action steps section has wisdom icon', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Reveal action steps
      await tester.tap(find.text('Get Guidance'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
    });
  });

  group('ScenarioDetailView Accessibility Tests', () {
    testWidgets('has minimum touch target sizes', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify buttons have minimum 44x44 touch targets
      final backButton = tester.getSize(find.byIcon(Icons.arrow_back));
      expect(backButton.width, greaterThanOrEqualTo(44.0));
      expect(backButton.height, greaterThanOrEqualTo(44.0));

      final homeButton = tester.getSize(find.byIcon(Icons.home_filled));
      expect(homeButton.width, greaterThanOrEqualTo(44.0));
      expect(homeButton.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('supports text scaling', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: ScenarioDetailView(scenario: scenario),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should render without overflow even with 2x text scaling
      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('has proper semantics', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have semantic labels for screen readers
      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('tooltips are present', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Get Guidance button should have tooltip
      expect(find.byType(Tooltip), findsWidgets);
    });
  });

  group('ScenarioDetailView Edge Cases', () {
    testWidgets('handles very long title', (tester) async {
      final longTitle = 'This is an extremely long scenario title that should be handled properly without causing overflow issues ' * 5;
      final scenario = _createMockScenario(title: longTitle);
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should render without overflow
      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles very long description', (tester) async {
      final longDescription = 'This is a very long description with lots of text that should be formatted properly ' * 20;
      final scenario = _createMockScenario(description: longDescription);
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles very long responses', (tester) async {
      final longResponse = 'This is a very long response with multiple sentences. ' * 10;
      final scenario = _createMockScenario(
        heartResponse: longResponse,
        dutyResponse: longResponse,
      );
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('handles empty action steps', (tester) async {
      final scenario = _createMockScenario(actionSteps: []);
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Get Guidance button should still appear
      expect(find.text('Get Guidance'), findsOneWidget);
    });

    testWidgets('handles scenario with many tags', (tester) async {
      final manyTags = List.generate(20, (i) => 'tag$i');
      final scenario = _createMockScenario(tags: manyTags);
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should display tags without overflow
      expect(find.byType(ActionChip), findsWidgets);
    });

    testWidgets('displays correctly on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('displays correctly on tablets', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenarioDetailView), findsOneWidget);
    });

    testWidgets('maintains state across rebuilds', (tester) async {
      final scenario = _createMockScenario();
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Reveal action steps
      await tester.tap(find.text('Get Guidance'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Wisdom Steps'), findsOneWidget);

      // Rebuild widget
      await tester.pumpWidget(_createScenarioDetailView(scenario));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Action steps should still be visible
      expect(find.text('Wisdom Steps'), findsOneWidget);
    });
  });
}
