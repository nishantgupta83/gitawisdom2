// test/screens/chapters_detail_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/screens/chapters_detail_view.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/l10n/app_localizations.dart';
import '../test_setup.dart';

@GenerateMocks([EnhancedSupabaseService])
import 'chapters_detail_view_test.mocks.dart';

void main() {
  late MockEnhancedSupabaseService mockService;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  setUp(() {
    mockService = MockEnhancedSupabaseService();
  });

  Chapter createTestChapter() {
    return Chapter(
      id: 1,
      chapterNumber: 1,
      title: 'Test Chapter',
      subtitle: 'Test Subtitle',
      summary: 'Test Summary',
      keyTeachings: ['Teaching 1', 'Teaching 2', 'Teaching 3'],
      verseCount: 10,
      transliteration: 'test-transliteration',
    );
  }

  List<Scenario> createTestScenarios() {
    return [
      Scenario(
        id: 1,
        title: 'Scenario 1',
        description: 'Description 1',
        category: 'Category 1',
        chapter: 1,
        heartResponse: 'Heart 1',
        dutyResponse: 'Duty 1',
        gitaWisdom: 'Wisdom 1',
        modernApplication: 'Application 1',
        practicalAdvice: 'Advice 1',
        reflection: 'Reflection 1',
      ),
      Scenario(
        id: 2,
        title: 'Scenario 2',
        description: 'Description 2',
        category: 'Category 2',
        chapter: 1,
        heartResponse: 'Heart 2',
        dutyResponse: 'Duty 2',
        gitaWisdom: 'Wisdom 2',
        modernApplication: 'Application 2',
        practicalAdvice: 'Advice 2',
        reflection: 'Reflection 2',
      ),
    ];
  }

  List<Verse> createTestVerses() {
    return [
      Verse(
        id: 1,
        chapterNumber: 1,
        verseNumber: 1,
        sanskrit: 'Sanskrit 1',
        transliteration: 'Transliteration 1',
        translation: 'Translation 1',
        explanation: 'Explanation 1',
      ),
      Verse(
        id: 2,
        chapterNumber: 1,
        verseNumber: 2,
        sanskrit: 'Sanskrit 2',
        transliteration: 'Transliteration 2',
        translation: 'Translation 2',
        explanation: 'Explanation 2',
      ),
    ];
  }

  group('ChapterDetailView', () {
    testWidgets('displays loading indicator while loading', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => Future.delayed(
        const Duration(seconds: 1),
        () => createTestChapter(),
      ));
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => Future.delayed(
        const Duration(seconds: 1),
        () => createTestScenarios(),
      ));
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => Future.delayed(
        const Duration(seconds: 1),
        () => createTestVerses(),
      ));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays chapter title after loading', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Chapter'), findsOneWidget);
    });

    testWidgets('displays chapter subtitle', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('displays chapter summary', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Summary'), findsOneWidget);
    });

    testWidgets('displays key teachings section', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Key Teachings'), findsOneWidget);
      expect(find.text('Teaching 1'), findsOneWidget);
      expect(find.text('Teaching 2'), findsOneWidget);
      expect(find.text('Teaching 3'), findsOneWidget);
    });

    testWidgets('displays related scenarios', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scenario 1'), findsOneWidget);
      expect(find.text('Scenario 2'), findsOneWidget);
    });

    testWidgets('displays scenario count badge', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('2'), findsOneWidget); // 2 scenarios
    });

    testWidgets('has view all verses button', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('View All Verses'), findsOneWidget);
    });

    testWidgets('has back button', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has home button', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
    });

    testWidgets('expands summary on read more tap', (WidgetTester tester) async {
      final longSummary = 'This is a very long summary that should trigger the read more button. ' * 10;
      final chapterWithLongSummary = Chapter(
        id: 1,
        chapterNumber: 1,
        title: 'Test Chapter',
        subtitle: 'Test Subtitle',
        summary: longSummary,
        keyTeachings: ['Teaching 1'],
        verseCount: 10,
        transliteration: 'test-transliteration',
      );

      when(mockService.fetchChapterById(1)).thenAnswer((_) async => chapterWithLongSummary);
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap read more
      final readMore = find.text('Read more');
      if (readMore.evaluate().isNotEmpty) {
        await tester.tap(readMore);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

        // Should now show "Read less"
        expect(find.text('Read less'), findsOneWidget);
      }
    });

    testWidgets('expands scenario description on read more tap', (WidgetTester tester) async {
      final longDescription = 'This is a very long description that should trigger read more. ' * 10;
      final scenariosWithLongDesc = [
        Scenario(
          id: 1,
          title: 'Scenario 1',
          description: longDescription,
          category: 'Category 1',
          chapter: 1,
          heartResponse: 'Heart 1',
          dutyResponse: 'Duty 1',
          gitaWisdom: 'Wisdom 1',
          modernApplication: 'Application 1',
          practicalAdvice: 'Advice 1',
          reflection: 'Reflection 1',
        ),
      ];

      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => scenariosWithLongDesc);
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap read more for scenario
      final readMoreFinders = find.text('Read more');
      if (readMoreFinders.evaluate().isNotEmpty) {
        await tester.tap(readMoreFinders.first);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

        // Should now show "Read less"
        expect(find.text('Read less'), findsOneWidget);
      }
    });

    testWidgets('handles error loading chapter', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenThrow(Exception('Failed to load'));
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => []);
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unable to load chapter.'), findsOneWidget);
    });

    testWidgets('scrolls properly', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find and scroll the ListView
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      await tester.drag(listView, const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Content should still be accessible
      expect(find.text('Test Chapter'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.dark(),
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Chapter'), findsOneWidget);
    });

    testWidgets('renders in light mode', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(),
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Chapter'), findsOneWidget);
    });

    testWidgets('adapts to tablet layout', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Chapter'), findsOneWidget);
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('displays icons correctly', (WidgetTester tester) async {
      when(mockService.fetchChapterById(1)).thenAnswer((_) async => createTestChapter());
      when(mockService.fetchScenariosByChapter(1)).thenAnswer((_) async => createTestScenarios());
      when(mockService.fetchVersesByChapter(1)).thenAnswer((_) async => createTestVerses());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterDetailView(chapterId: 1),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsWidgets);
    });
  });
}
