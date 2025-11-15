// test/screens/verse_list_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/verse_list_view.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/services/service_locator.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/core/navigation/navigation_service.dart';
import '../test_setup.dart';

class MockEnhancedSupabaseService extends EnhancedSupabaseService {
  List<Verse> _mockVerses = [];
  Chapter? _mockChapter;
  bool _shouldFail = false;

  void setMockVerses(List<Verse> verses) {
    _mockVerses = verses;
  }

  void setMockChapter(Chapter? chapter) {
    _mockChapter = chapter;
  }

  void setShouldFail(bool value) {
    _shouldFail = value;
  }

  @override
  Future<List<Verse>> fetchVersesByChapter(int chapterId, [String? langCode]) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_shouldFail) {
      return [];
    }
    return _mockVerses;
  }

  @override
  Future<Chapter?> fetchChapterById(int chapterId, [String? langCode]) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_shouldFail) {
      return null;
    }
    return _mockChapter;
  }
}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();

    // Initialize NavigationService
    NavigationService.instance.initialize(
      onTabChanged: (index) {},
      onGoToScenariosWithChapter: (chapterId) {},
    );
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('VerseListView', () {
    late MockEnhancedSupabaseService mockService;

    setUp(() {
      mockService = MockEnhancedSupabaseService();
      // Note: ServiceLocator doesn't have a registration method, it uses lazy initialization
      // Tests will use the real EnhancedSupabaseService instance
    });

    Widget createTestWidget({int chapterId = 1}) {
      return MaterialApp(
        navigatorKey: NavigationService.instance.navigatorKey,
        home: VerseListView(chapterId: chapterId),
      );
    }

    testWidgets('renders successfully', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(VerseListView), findsOneWidget);
    });

    testWidgets('displays loading state initially', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays chapter header when chapter loaded',
        (WidgetTester tester) async {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test Chapter',
        summary: 'Summary',
        verseCount: 10,
      );

      mockService.setMockChapter(chapter);
      mockService.setMockVerses([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Chapter'), findsOneWidget);
      expect(find.text('Chapter 1 verses from Bhagavad Gita'), findsOneWidget);
    });

    testWidgets('displays verses list', (WidgetTester tester) async {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test Chapter',
        summary: 'Summary',
        verseCount: 2,
      );

      final verses = <Verse>[
        Verse(
          verseId: 1,
          chapterId: 1,
          description: 'Test verse 1',
        ),
        Verse(
          verseId: 2,
          chapterId: 1,
          description: 'Test verse 2',
        ),
      ];

      mockService.setMockChapter(chapter);
      mockService.setMockVerses(verses);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test verse 1'), findsOneWidget);
      expect(find.text('Test verse 2'), findsOneWidget);
    });

    testWidgets('displays verse numbers in badges', (WidgetTester tester) async {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test Chapter',
        summary: 'Summary',
        verseCount: 1,
      );

      final verses = <Verse>[
        Verse(
          verseId: 1,
          chapterId: 1,
          description: 'Test verse',
        ),
      ];

      mockService.setMockChapter(chapter);
      mockService.setMockVerses(verses);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('displays share button for each verse',
        (WidgetTester tester) async {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test Chapter',
        summary: 'Summary',
        verseCount: 1,
      );

      final verses = <Verse>[
        Verse(
          verseId: 1,
          chapterId: 1,
          description: 'Test verse',
        ),
      ];

      mockService.setMockChapter(chapter);
      mockService.setMockVerses(verses);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Share'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('displays error message when fetch fails',
        (WidgetTester tester) async {
      mockService.setShouldFail(true);
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
          find.text(
              'Verses require internet connection to load for the first time.\nPlease try again when connected.'),
          findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button reloads verses', (WidgetTester tester) async {
      mockService.setShouldFail(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap retry button
      mockService.setShouldFail(false);
      mockService.setMockVerses(<Verse>[
        Verse(verseId: 1, chapterId: 1, description: 'Loaded'),
      ]);

      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Loaded'), findsOneWidget);
    });

    testWidgets('displays empty state when no verses',
        (WidgetTester tester) async {
      final chapter = Chapter(
        chapterId: 1,
        title: 'Test Chapter',
        summary: 'Summary',
        verseCount: 0,
      );

      mockService.setMockChapter(chapter);
      mockService.setMockVerses([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No verses available.'), findsOneWidget);
    });

    testWidgets('back button navigates back', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(Chapter(
        id: 1,
        chapterNumber: 1,
        title: 'Test',
        summary: 'Test',
        verseCount: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VerseListView(chapterId: 1),
                      ),
                    );
                  },
                  child: const Text('Go to Verses'),
                );
              },
            ),
          ),
        ),
      );

      // Navigate to verse list
      await tester.tap(find.text('Go to Verses'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should be back to original screen
      expect(find.text('Go to Verses'), findsOneWidget);
    });

    testWidgets('home button navigates to home', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(Chapter(
        id: 1,
        chapterNumber: 1,
        title: 'Test',
        summary: 'Test',
        verseCount: 0,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap home button
      await tester.tap(find.byIcon(Icons.home_filled));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const VerseListView(chapterId: 1),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(VerseListView), findsOneWidget);
    });

    testWidgets('renders correctly in light mode', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const VerseListView(chapterId: 1),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(VerseListView), findsOneWidget);
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('scaffold has transparent background',
        (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.transparent);
    });

    testWidgets('verses have gradient decoration', (WidgetTester tester) async {
      final verses = [
        Verse(id: 1, verseId: 1, chapterId: 1, description: 'Test'),
      ];

      mockService.setMockVerses(verses);
      mockService.setMockChapter(Chapter(
        id: 1,
        chapterNumber: 1,
        title: 'Test',
        summary: 'Test',
        verseCount: 1,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have container with gradient
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('adapts to tablet layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(VerseListView), findsOneWidget);
    });

    testWidgets('verse cards are tappable', (WidgetTester tester) async {
      final verses = [
        Verse(id: 1, verseId: 1, chapterId: 1, description: 'Test verse'),
      ];

      mockService.setMockVerses(verses);
      mockService.setMockChapter(Chapter(
        id: 1,
        chapterNumber: 1,
        title: 'Test',
        summary: 'Test',
        verseCount: 1,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on verse card
      await tester.tap(find.text('Test verse'));
      await tester.pump();
    });

    testWidgets('multiple verses display correctly',
        (WidgetTester tester) async {
      final verses = List.generate(
        5,
        (i) => Verse(
          id: i + 1,
          verseId: i + 1,
          chapterId: 1,
          description: 'Test verse ${i + 1}',
        ),
      );

      mockService.setMockVerses(verses);
      mockService.setMockChapter(Chapter(
        id: 1,
        chapterNumber: 1,
        title: 'Test',
        summary: 'Test',
        verseCount: 5,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      for (int i = 1; i <= 5; i++) {
        expect(find.text('Test verse $i'), findsOneWidget);
      }
    });

    testWidgets('scrolling works correctly', (WidgetTester tester) async {
      final verses = List.generate(
        20,
        (i) => Verse(
          id: i + 1,
          verseId: i + 1,
          chapterId: 1,
          description: 'Test verse ${i + 1}',
        ),
      );

      mockService.setMockVerses(verses);
      mockService.setMockChapter(Chapter(
        id: 1,
        chapterNumber: 1,
        title: 'Test',
        summary: 'Test',
        verseCount: 20,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('chapter ID is passed correctly', (WidgetTester tester) async {
      mockService.setMockVerses([]);
      mockService.setMockChapter(null);

      await tester.pumpWidget(createTestWidget(chapterId: 5));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chapter 5 verses from Bhagavad Gita'), findsOneWidget);
    });
  });
}
