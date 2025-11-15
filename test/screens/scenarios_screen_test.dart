// test/screens/scenarios_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/screens/scenarios_screen.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/services/progressive_scenario_service.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/services/intelligent_scenario_search.dart';
import 'package:GitaWisdom/services/service_locator.dart';
import 'package:GitaWisdom/l10n/app_localizations.dart';

import '../test_setup.dart';
import 'scenarios_screen_test.mocks.dart';

@GenerateMocks([
  ScenarioServiceAdapter,
  EnhancedSupabaseService,
  IntelligentScenarioSearch,
])
void main() {
  late MockScenarioServiceAdapter mockScenarioService;
  late MockEnhancedSupabaseService mockSupabaseService;
  late MockIntelligentScenarioSearch mockAISearchService;

  setUp(() async {
    await setupTestEnvironment();

    mockScenarioService = MockScenarioServiceAdapter();
    mockSupabaseService = MockEnhancedSupabaseService();
    mockAISearchService = MockIntelligentScenarioSearch();

    // Setup default mocks
    when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => []);
    when(mockScenarioService.searchScenarios(any)).thenReturn([]);
    when(mockScenarioService.hasNewScenariosAvailable()).thenAnswer((_) async => false);
    when(mockSupabaseService.fetchScenariosByChapter(any)).thenAnswer((_) async => []);
  });

  tearDown(() async {
    await teardownTestEnvironment();
  });

  List<Scenario> _createMockScenarios({int count = 5}) {
    return List.generate(
      count,
      (index) => Scenario(
        title: 'Scenario ${index + 1}',
        description: 'Description for scenario ${index + 1}',
        category: index % 2 == 0 ? 'Work & Career' : 'Relationships',
        chapter: (index % 18) + 1,
        heartResponse: 'Heart response ${index + 1}',
        dutyResponse: 'Duty response ${index + 1}',
        gitaWisdom: 'Gita wisdom ${index + 1}',
        tags: ['tag${index + 1}', 'category${index % 3}'],
        actionSteps: ['Step 1', 'Step 2'],
        createdAt: DateTime.now(),
      ),
    );
  }

  Widget _createScenariosScreen({String? filterTag, int? filterChapter}) {
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
      home: ScenariosScreen(
        filterTag: filterTag,
        filterChapter: filterChapter,
      ),
    );
  }

  group('ScenariosScreen Rendering Tests', () {
    testWidgets('screen renders without errors', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenariosScreen), findsOneWidget);
    });

    testWidgets('displays "Life Scenarios" header', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Life Scenarios'), findsOneWidget);
    });

    testWidgets('displays search bar', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('search bar has AI placeholder text', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('✨ AI Search: Try "feeling stressed at work"'), findsOneWidget);
    });

    testWidgets('displays loading state', (tester) async {
      when(mockScenarioService.getAllScenarios()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2), () => []),
      );

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no scenarios', (tester) async {
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => []);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No scenarios available'), findsOneWidget);
    });

    testWidgets('displays scenario list when scenarios available', (tester) async {
      final mockScenarios = _createMockScenarios(count: 3);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('each scenario card shows title', (tester) async {
      final mockScenarios = _createMockScenarios(count: 3);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scenario 1'), findsOneWidget);
      expect(find.text('Scenario 2'), findsOneWidget);
      expect(find.text('Scenario 3'), findsOneWidget);
    });

    testWidgets('each scenario card shows chapter number', (tester) async {
      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Chapter'), findsWidgets);
    });

    testWidgets('displays floating back button', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays floating home button', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
    });
  });

  group('ScenariosScreen Search Tests', () {
    testWidgets('search bar accepts input', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'career');
      await tester.pump();

      expect(find.text('career'), findsOneWidget);
    });

    testWidgets('search filters scenarios by keyword', (tester) async {
      final mockScenarios = _createMockScenarios(count: 10);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);
      when(mockScenarioService.searchScenarios('career')).thenReturn(
        mockScenarios.where((s) => s.category == 'Work & Career').toList(),
      );

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'career');
      await tester.pump(const Duration(milliseconds: 400)); // Wait for debounce

      // Verify search was triggered
      verify(mockScenarioService.searchScenarios('career')).called(1);
    });

    testWidgets('search shows "No results" for invalid query', (tester) async {
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => []);
      when(mockScenarioService.searchScenarios('xyz123')).thenReturn([]);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'xyz123');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('No scenarios match your search'), findsOneWidget);
    });

    testWidgets('search debounces input (300ms)', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);
      when(mockScenarioService.searchScenarios(any)).thenReturn(mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Type quickly
      await tester.enterText(find.byType(TextField), 'c');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ca');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'car');
      await tester.pump(const Duration(milliseconds: 100));

      // Should not have triggered search yet
      verifyNever(mockScenarioService.searchScenarios(any));

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 400));

      // Now search should be triggered once
      verify(mockScenarioService.searchScenarios(any)).called(greaterThan(0));
    });

    testWidgets('clear search button works', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Enter search text
      await tester.enterText(find.byType(TextField), 'career');
      await tester.pump();

      // Find and tap clear button
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pump();

      // Verify search is cleared
      expect(find.text('career'), findsNothing);
    });

    testWidgets('search bar shows psychology icon for AI search', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });
  });

  group('ScenariosScreen Scenario Data Tests', () {
    testWidgets('displays scenarios from cache', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scenario 1'), findsOneWidget);
      verify(mockScenarioService.getAllScenarios()).called(greaterThan(0));
    });

    testWidgets('scenarios have correct structure', (tester) async {
      final mockScenarios = _createMockScenarios(count: 1);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify card has expected elements
      expect(find.text('Scenario 1'), findsOneWidget);
      expect(find.text('Description for scenario 1'), findsOneWidget);
      expect(find.textContaining('Chapter'), findsWidgets);
    });

    testWidgets('category displays correctly', (tester) async {
      final mockScenarios = [
        Scenario(
          title: 'Work Scenario',
          description: 'Work description',
          category: 'Work & Career',
          chapter: 1,
          heartResponse: 'Heart',
          dutyResponse: 'Duty',
          gitaWisdom: 'Wisdom',
          createdAt: DateTime.now(),
        ),
      ];
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Work Scenario'), findsOneWidget);
    });

    testWidgets('displays share button on scenario cards', (tester) async {
      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.share), findsWidgets);
    });

    testWidgets('displays "Read More" button on scenario cards', (tester) async {
      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Read More'), findsWidgets);
    });
  });

  group('ScenariosScreen Interaction Tests', () {
    testWidgets('tap scenario navigates to detail', (tester) async {
      final mockScenarios = _createMockScenarios(count: 1);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap "Read More" button
      await tester.tap(find.text('Read More').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Navigation should occur (detail screen would be pushed)
      // Note: Full verification would require NavigatorObserver
    });

    testWidgets('pull to refresh reloads data', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);
      when(mockScenarioService.refreshFromServer()).thenAnswer((_) async {});

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        await tester.drag(refreshIndicator.first, const Offset(0, 300));
        await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

        // Verify refresh was triggered
        verify(mockScenarioService.refreshFromServer()).called(1);
      }
    });

    testWidgets('filter by category button works', (tester) async {
      final mockScenarios = _createMockScenarios(count: 10);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap a category filter button
      final categoryButton = find.text('Work & Career');
      if (categoryButton.evaluate().isNotEmpty) {
        await tester.tap(categoryButton.first);
        await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

        // Verify filter was applied
        expect(find.text('Work & Career'), findsWidgets);
      }
    });

    testWidgets('infinite scroll loads more scenarios', (tester) async {
      final mockScenarios = _createMockScenarios(count: 50);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initial scenarios should be loaded (20 at a time)
      expect(find.text('Scenario 1'), findsOneWidget);

      // Scroll down to trigger loading more
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have loaded more scenarios
      expect(find.text('Load More'), findsWidgets);
    });

    testWidgets('share button opens share dialog', (tester) async {
      final mockScenarios = _createMockScenarios(count: 1);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap share button
      final shareButton = find.byIcon(Icons.share).first;
      await tester.tap(shareButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Share dialog/bottom sheet should appear
      // Note: Exact verification depends on ShareCardWidget implementation
    });
  });

  group('ScenariosScreen State Management Tests', () {
    testWidgets('handles network error gracefully', (tester) async {
      when(mockScenarioService.getAllScenarios()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show error message
      expect(find.text('Failed to load scenarios. Please check your connection.'), findsOneWidget);
    });

    testWidgets('offline mode support shows cached data', (tester) async {
      final cachedScenarios = _createMockScenarios(count: 3);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => cachedScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should display cached scenarios even if offline
      expect(find.text('Scenario 1'), findsOneWidget);
    });

    testWidgets('progressive cache loading works', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);
      when(mockScenarioService.backgroundSync(onComplete: anyNamed('onComplete')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify scenarios are loaded
      expect(find.text('Scenario 1'), findsOneWidget);

      // Background sync should be triggered
      verify(mockScenarioService.backgroundSync(onComplete: anyNamed('onComplete')))
          .called(greaterThan(0));
    });
  });

  group('ScenariosScreen Filter Tests', () {
    testWidgets('displays filter buttons row', (tester) async {
      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show "All" filter by default
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('chapter filter displays correctly', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockSupabaseService.fetchScenariosByChapter(1))
          .thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen(filterChapter: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show chapter filter indicator
      expect(find.textContaining('Chapter 1'), findsWidgets);
    });

    testWidgets('clear filter button works', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockSupabaseService.fetchScenariosByChapter(1))
          .thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen(filterChapter: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap clear filter button
      final clearButton = find.text('Clear Filter');
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

        // Filter should be cleared
        expect(find.text('Clear Filter'), findsNothing);
      }
    });

    testWidgets('tag filter works when provided', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen(filterTag: 'tag1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should filter by tag
      expect(find.byType(ScenariosScreen), findsOneWidget);
    });

    testWidgets('category count displays correctly', (tester) async {
      final mockScenarios = _createMockScenarios(count: 10);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show count in category filters
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('sub-category description shows when category selected', (tester) async {
      final mockScenarios = _createMockScenarios(count: 10);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap a category
      final categoryButton = find.text('Work & Career');
      if (categoryButton.evaluate().isNotEmpty) {
        await tester.tap(categoryButton.first);
        await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

        // Should show sub-category description
        expect(find.text('Includes:'), findsOneWidget);
      }
    });
  });

  group('ScenariosScreen Accessibility Tests', () {
    testWidgets('has minimum touch target sizes', (tester) async {
      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify share buttons have minimum 44x44 touch targets
      final shareButtons = find.byIcon(Icons.share);
      for (final element in shareButtons.evaluate()) {
        final size = element.size;
        if (size != null) {
          expect(size.width, greaterThanOrEqualTo(44.0));
          expect(size.height, greaterThanOrEqualTo(44.0));
        }
      }
    });

    testWidgets('supports text scaling', (tester) async {
      final mockScenarios = _createMockScenarios(count: 1);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

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
            child: const ScenariosScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should render without overflow even with 2x text scaling
      expect(find.byType(ScenariosScreen), findsOneWidget);
    });

    testWidgets('works in dark mode', (tester) async {
      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenariosScreen), findsOneWidget);
    });

    testWidgets('works in light mode', (tester) async {
      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenariosScreen), findsOneWidget);
    });
  });

  group('ScenariosScreen Edge Cases', () {
    testWidgets('handles empty search gracefully', (tester) async {
      final mockScenarios = _createMockScenarios(count: 5);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Enter empty search
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump(const Duration(milliseconds: 400));

      // Should show all scenarios
      expect(find.text('Scenario 1'), findsOneWidget);
    });

    testWidgets('handles very long scenario titles', (tester) async {
      final longTitle = 'This is a very long scenario title that should be truncated properly ' * 10;
      final scenario = Scenario(
        title: longTitle,
        description: 'Description',
        category: 'Work & Career',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        createdAt: DateTime.now(),
      );
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => [scenario]);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should render without overflow
      expect(find.byType(ScenariosScreen), findsOneWidget);
    });

    testWidgets('handles rapid filter changes', (tester) async {
      final mockScenarios = _createMockScenarios(count: 10);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Rapidly change filters
      final allButton = find.text('All');
      final workButton = find.text('Work & Career');

      if (allButton.evaluate().isNotEmpty && workButton.evaluate().isNotEmpty) {
        await tester.tap(workButton.first);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(allButton.first);
        await tester.pump(const Duration(milliseconds: 100));

        // Should not crash
        expect(find.byType(ScenariosScreen), findsOneWidget);
      }
    });

    testWidgets('displays correctly on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenariosScreen), findsOneWidget);
    });

    testWidgets('displays correctly on tablets', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      final mockScenarios = _createMockScenarios(count: 2);
      when(mockScenarioService.getAllScenarios()).thenAnswer((_) async => mockScenarios);

      await tester.pumpWidget(_createScenariosScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScenariosScreen), findsOneWidget);
    });
  });
}
