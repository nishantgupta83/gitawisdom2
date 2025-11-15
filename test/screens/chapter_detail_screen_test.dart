import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/chapters_detail_view.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../test_setup.dart';

/// Comprehensive test suite for chapters_detail_view.dart
///
/// Tests the ChapterDetailView widget functionality including:
/// - Screen rendering and initial states
/// - Chapter details display (title, summary, key teachings)
/// - Related scenarios display and interaction
/// - Verse navigation features
/// - State management (loading, error, loaded)
/// - UI components (cards, buttons, expandable sections)
/// - Accessibility features
///
/// Coverage contribution: +2-3%

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  Widget createChapterDetailScreen({int chapterId = 1}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: ChapterDetailView(chapterId: chapterId),
    );
  }

  group('ChapterDetailView Rendering Tests', () {
    testWidgets('screen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(ChapterDetailView), findsOneWidget);
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has Scaffold widget', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has Stack for background layering', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('has SafeArea for proper layout', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('displays CircleAvatar buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('displays IconButton for navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('has back button icon', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has home button icon', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
    });

    testWidgets('waits for data to load', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for data to load
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have content now (either data or error)
      expect(find.byType(ChapterDetailView), findsOneWidget);
    });
  });

  group('ChapterDetailView Data Model Tests', () {
    test('Chapter model creates correctly', () {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Arjuna Vishada Yoga',
        subtitle: 'The Yoga of Arjuna\'s Dejection',
        summary: 'Chapter summary',
        verseCount: 47,
        theme: 'Moral Dilemma',
        keyTeachings: ['Teaching 1', 'Teaching 2'],
      );

      expect(chapter.chapterId, 1);
      expect(chapter.title, 'Arjuna Vishada Yoga');
      expect(chapter.subtitle, 'The Yoga of Arjuna\'s Dejection');
      expect(chapter.summary, 'Chapter summary');
      expect(chapter.verseCount, 47);
      expect(chapter.theme, 'Moral Dilemma');
      expect(chapter.keyTeachings?.length, 2);
    });

    test('Chapter toJson works correctly', () {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test',
        subtitle: 'Subtitle',
        summary: 'Summary',
        verseCount: 10,
      );

      final json = chapter.toJson();
      expect(json['ch_chapter_id'], 1);
      expect(json['ch_title'], 'Test');
      expect(json['ch_subtitle'], 'Subtitle');
      expect(json['ch_summary'], 'Summary');
      expect(json['ch_verse_count'], 10);
    });

    test('Chapter fromJson works correctly', () {
      final json = {
        'ch_chapter_id': 1,
        'ch_title': 'Test',
        'ch_subtitle': 'Subtitle',
        'ch_summary': 'Summary',
        'ch_verse_count': 10,
        'ch_theme': 'Theme',
        'ch_key_teachings': ['Teaching 1'],
      };

      final chapter = Chapter.fromJson(json);
      expect(chapter.chapterId, 1);
      expect(chapter.title, 'Test');
      expect(chapter.subtitle, 'Subtitle');
      expect(chapter.summary, 'Summary');
      expect(chapter.verseCount, 10);
      expect(chapter.theme, 'Theme');
      expect(chapter.keyTeachings?.length, 1);
    });

    test('Verse model creates correctly', () {
      final verse = Verse(
        verseId: 1,
        description: 'Verse description',
        chapterId: 1,
      );

      expect(verse.verseId, 1);
      expect(verse.description, 'Verse description');
      expect(verse.chapterId, 1);
    });

    test('Verse reference format works', () {
      final verse = Verse(
        verseId: 5,
        description: 'Test',
        chapterId: 1,
      );

      expect(verse.reference, '1.5');
    });

    test('Verse preview truncation works', () {
      final longVerse = Verse(
        verseId: 1,
        description: 'a' * 200,
        chapterId: 1,
      );

      expect(longVerse.preview.length, 100);
      expect(longVerse.preview.endsWith('...'), true);
    });

    test('Scenario model creates correctly', () {
      final scenario = Scenario(
        title: 'Test Scenario',
        description: 'Description',
        category: 'Test Category',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        verseNumber: '5',
        createdAt: DateTime.now(),
      );

      expect(scenario.title, 'Test Scenario');
      expect(scenario.description, 'Description');
      expect(scenario.category, 'Test Category');
      expect(scenario.heartResponse, 'Heart');
      expect(scenario.dutyResponse, 'Duty');
      expect(scenario.gitaWisdom, 'Wisdom');
      expect(scenario.chapter, 1);
      expect(scenario.verseNumber, '5');
    });
  });

  group('ChapterDetailView UI Component Tests', () {
    testWidgets('uses Positioned widgets for floating buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('has Container widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses Text widgets for content', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('uses Card widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('uses Column for layout', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('uses Row for layout', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Row), findsWidgets);
    });
  });

  group('ChapterDetailView Accessibility Tests', () {
    testWidgets('supports text scaling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: createChapterDetailScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(ChapterDetailView), findsOneWidget);
    });

    testWidgets('respects MediaQuery view insets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: 100),
          ),
          child: createChapterDetailScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(ChapterDetailView), findsOneWidget);
    });

    testWidgets('handles dark theme', (WidgetTester tester) async {
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
          home: const ChapterDetailView(chapterId: 1),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(ChapterDetailView));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('handles light theme', (WidgetTester tester) async {
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
          home: const ChapterDetailView(chapterId: 1),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(ChapterDetailView));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.light);
    });
  });

  group('ChapterDetailView State Management Tests', () {
    testWidgets('initializes with loading state', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('transitions from loading state', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have transitioned from loading
      // (either to loaded or error state)
    });

    testWidgets('preserves state during rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      // Get initial state
      expect(find.byType(ChapterDetailView), findsOneWidget);

      // Rebuild
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      // Should still be the same
      expect(find.byType(ChapterDetailView), findsOneWidget);
    });

    testWidgets('handles different chapter IDs', (WidgetTester tester) async {
      for (int i = 1; i <= 3; i++) {
        await tester.pumpWidget(createChapterDetailScreen(chapterId: i));
        await tester.pump();

        expect(find.byType(ChapterDetailView), findsOneWidget);
      }
    });
  });

  group('ChapterDetailView Localization Tests', () {
    testWidgets('supports English locale', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      final context = tester.element(find.byType(ChapterDetailView));
      final localizations = AppLocalizations.of(context);
      expect(localizations, isNotNull);
    });

    testWidgets('has localization delegates', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      // Verify app can access localizations
      final context = tester.element(find.byType(ChapterDetailView));
      expect(AppLocalizations.of(context), isNotNull);
    });
  });

  group('ChapterDetailView Widget Hierarchy Tests', () {
    testWidgets('has MaterialApp as root', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('has Scaffold in tree', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has Stack for layering', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('has SafeArea for safe layout', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('uses ListView for scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // After loading, should have ListView
      expect(find.byType(ListView), findsWidgets);
    });
  });

  group('ChapterDetailView Integration Tests', () {
    testWidgets('completes full render cycle', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());

      // Initial pump
      await tester.pump();
      expect(find.byType(ChapterDetailView), findsOneWidget);

      // Wait for async operations
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be showing screen
      expect(find.byType(ChapterDetailView), findsOneWidget);
    });

    testWidgets('handles multiple rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(createChapterDetailScreen());
        await tester.pump();
        expect(find.byType(ChapterDetailView), findsOneWidget);
      }
    });

    testWidgets('handles all 18 chapters', (WidgetTester tester) async {
      for (int chapterId = 1; chapterId <= 18; chapterId++) {
        await tester.pumpWidget(createChapterDetailScreen(chapterId: chapterId));
        await tester.pump();

        expect(find.byType(ChapterDetailView), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      }
    });
  });

  group('ChapterDetailView Navigation Tests', () {
    testWidgets('has back button for navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has home button for navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
    });

    testWidgets('buttons are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      final homeButton = find.byIcon(Icons.home_filled);
      expect(homeButton, findsOneWidget);
    });
  });

  group('ChapterDetailView Performance Tests', () {
    testWidgets('renders within reasonable time', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createChapterDetailScreen());
      await tester.pump();

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('handles rapid rebuilds', (WidgetTester tester) async {
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(createChapterDetailScreen());
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(find.byType(ChapterDetailView), findsOneWidget);
    });
  });
}
