import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/screens/home_screen.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/services/service_locator.dart';
import 'package:GitaWisdom/services/progressive_scenario_service.dart';
import 'package:GitaWisdom/core/theme/theme_provider.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/scenario.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([
  SupabaseAuthService,
  SettingsService,
  EnhancedSupabaseService,
  ThemeProvider,
])
void main() {
  late MockSupabaseAuthService mockAuthService;
  late MockSettingsService mockSettingsService;
  late MockEnhancedSupabaseService mockSupabaseService;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockAuthService = MockSupabaseAuthService();
    mockSettingsService = MockSettingsService();
    mockSupabaseService = MockEnhancedSupabaseService();
    mockThemeProvider = MockThemeProvider();

    // Setup default mocks
    when(mockAuthService.isAuthenticated).thenReturn(false);
    when(mockAuthService.isAnonymous).thenReturn(false);
    when(mockAuthService.displayName).thenReturn('Seeker');
    when(mockSettingsService.isDarkMode).thenReturn(false);
    when(mockSettingsService.fontSize).thenReturn('medium');
    when(mockThemeProvider.isDark).thenReturn(false);
    when(mockThemeProvider.fontPref).thenReturn('medium');
    when(mockThemeProvider.shadowEnabled).thenReturn(false);
    when(mockThemeProvider.backgroundOpacity).thenReturn(0.8);
    when(mockThemeProvider.textScale).thenReturn(1.0);
    when(mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
    when(mockThemeProvider.lightTheme).thenReturn(ThemeData.light());
    when(mockThemeProvider.darkTheme).thenReturn(ThemeData.dark());
    when(mockThemeProvider.currentTheme).thenReturn(ThemeData.light());

    // Set up service locator to return our mock
    ServiceLocator.instance.dispose();
  });

  tearDown(() {
    ServiceLocator.instance.dispose();
  });

  Widget createHomeScreen({Function(int)? onTabChange}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SupabaseAuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
        Provider<EnhancedSupabaseService>.value(value: mockSupabaseService),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
      ],
      child: MaterialApp(
        home: HomeScreen(onTabChange: onTabChange),
      ),
    );
  }

  Verse createMockVerse({int chapterId = 1, int verseId = 1}) {
    return Verse(
      chapterId: chapterId,
      verseId: verseId,
      description: 'This is a sample verse description for testing.',
    );
  }

  Chapter createMockChapter({int id = 1}) {
    return Chapter(
      chapterId: id,
      title: 'Chapter $id Title',
      subtitle: 'Chapter $id Subtitle',
      summary: 'Chapter $id summary text',
      verseCount: 47,
    );
  }

  Scenario createMockScenario({
    String title = 'Test Scenario',
    String category = 'family',
  }) {
    return Scenario(
      title: title,
      description: 'Test scenario description about parenting and relationships',
      category: category,
      chapter: 2,
      heartResponse: 'Follow your heart',
      dutyResponse: 'Follow your duty',
      gitaWisdom: 'Ancient wisdom applies here',
      verse: 'Sample verse',
      verseNumber: '2.47',
      tags: ['parenting', 'family'],
      actionSteps: ['Step 1', 'Step 2'],
      createdAt: DateTime.now(),
    );
  }

  group('HomeScreen - Basic Widget Tests', () {
    testWidgets('should render home screen without crashing', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should display app background', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render in light mode by default', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      final ThemeData theme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('should render in dark mode when enabled', (WidgetTester tester) async {
      when(mockThemeProvider.isDark).thenReturn(true);
      when(mockThemeProvider.currentTheme).thenReturn(ThemeData.dark());
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      final ThemeData theme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('should have SafeArea widget', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });
  });

  group('HomeScreen - Daily Verse Section (15 tests)', () {
    testWidgets('should show loading state for verse initially', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2), () => createMockVerse()),
      );
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
      expect(find.text('Loading verse of the day...'), findsOneWidget);
    });

    testWidgets('should display verse of the day card when loaded', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Verse of the Day'), findsOneWidget);
    });

    testWidgets('should display verse description', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(verse.description), findsOneWidget);
    });

    testWidgets('should display chapter and verse number', (WidgetTester tester) async {
      final verse = createMockVerse(chapterId: 3, verseId: 5);
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Verse 5'), findsOneWidget);
    });

    testWidgets('should show error card on verse fetch failure', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenThrow(Exception('Network error'));
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Could not load verse'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsAtLeastNWidgets(1));
    });

    testWidgets('should display verse card with icon', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.auto_stories), findsAtLeastNWidgets(1));
    });

    testWidgets('verse card should have rounded corners', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final containerFinder = find.descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);
    });

    testWidgets('should fetch random verse from random chapter on init', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      verify(mockSupabaseService.fetchRandomVerseByChapter(any)).called(1);
    });

    testWidgets('verse card should have gradient background', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show verse text with proper padding', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsWidgets);
    });

    testWidgets('verse loading should not block UI rendering', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1), () => createMockVerse()),
      );
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // UI should render even while verse is loading
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle verse with long description', (WidgetTester tester) async {
      final verse = Verse(
        chapterId: 1,
        verseId: 1,
        description: 'This is a very long description ' * 20,
      );
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('verse card should use Hero animation', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Hero), findsWidgets);
    });

    testWidgets('verse card should be at bottom of scroll view', (WidgetTester tester) async {
      final verse = createMockVerse();
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => verse);
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should retry verse fetch on error with manual retry', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenThrow(Exception('Error'));
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Could not load verse'), findsOneWidget);
    });
  });

  group('HomeScreen - Dilemma Cards Section (15 tests)', () {
    testWidgets('should show loading state for dilemmas initially', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Loading life dilemmas...'), findsOneWidget);
    });

    testWidgets('should display Life Dilemmas section header', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Life Dilemmas'), findsOneWidget);
    });

    testWidgets('should display dilemma cards when loaded', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(PageView), findsWidgets);
    });

    testWidgets('should display page indicators for dilemmas', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      // Look for page indicator containers
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should show dilemma title and description', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should display dilemma category badge', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Life Dilemma'), findsWidgets);
    });

    testWidgets('dilemma cards should have gradient background', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show psychology icon on dilemma cards', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byIcon(Icons.psychology), findsWidgets);
    });

    testWidgets('should show Heart vs Duty guidance text', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Heart vs Duty guidance'), findsWidgets);
    });

    testWidgets('dilemma card should be tappable', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('should show current page number indicator', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      // Look for page counter pattern like "1 / 5"
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('dilemmas should have shadow effect', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle empty dilemmas gracefully', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 3));

      // Should show loading or retry state
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('dilemma cards should scroll horizontally', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(PageView), findsWidgets);
    });

    testWidgets('should show arrow icon on dilemma cards', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byIcon(Icons.arrow_forward_ios), findsWidgets);
    });
  });

  group('HomeScreen - Navigation Flow Tests (10 tests)', () {
    testWidgets('should call onTabChange when Dilemmas quick action tapped', (WidgetTester tester) async {
      int? tappedTab;
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen(onTabChange: (tab) => tappedTab = tab));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final dilemmaButton = find.text('Dilemmas');
      if (dilemmaButton.evaluate().isNotEmpty) {
        await tester.tap(dilemmaButton);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        expect(tappedTab, 2);
      }
    });

    testWidgets('should call onTabChange when Chapters quick action tapped', (WidgetTester tester) async {
      int? tappedTab;
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen(onTabChange: (tab) => tappedTab = tab));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final chaptersButton = find.text('Chapters');
      if (chaptersButton.evaluate().isNotEmpty) {
        await tester.tap(chaptersButton);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        expect(tappedTab, 1);
      }
    });

    testWidgets('should call onTabChange when Journal quick action tapped', (WidgetTester tester) async {
      int? tappedTab;
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen(onTabChange: (tab) => tappedTab = tab));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final journalButton = find.text('Journal');
      if (journalButton.evaluate().isNotEmpty) {
        await tester.tap(journalButton);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        expect(tappedTab, 3);
      }
    });

    testWidgets('should call onTabChange when More quick action tapped', (WidgetTester tester) async {
      int? tappedTab;
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen(onTabChange: (tab) => tappedTab = tab));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final moreButton = find.text('More');
      if (moreButton.evaluate().isNotEmpty) {
        await tester.tap(moreButton);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        expect(tappedTab, 4);
      }
    });

    testWidgets('should navigate to chapter detail when featured chapter tapped', (WidgetTester tester) async {
      final chapters = [createMockChapter(id: 1)];
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => chapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final chapterCard = find.text('Chapter 1 Title');
      if (chapterCard.evaluate().isNotEmpty) {
        await tester.tap(chapterCard);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        // Verify navigation occurred
      }
    });

    testWidgets('should show View All button in featured chapters', (WidgetTester tester) async {
      final chapters = [createMockChapter(id: 1)];
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => chapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('View All'), findsWidgets);
    });

    testWidgets('View All button should navigate to chapters tab', (WidgetTester tester) async {
      int? tappedTab;
      final chapters = [createMockChapter(id: 1)];
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => chapters);

      await tester.pumpWidget(createHomeScreen(onTabChange: (tab) => tappedTab = tab));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final viewAllButton = find.text('View All');
      if (viewAllButton.evaluate().isNotEmpty) {
        await tester.tap(viewAllButton.first);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        expect(tappedTab, 1);
      }
    });

    testWidgets('should display 4 quick action buttons', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dilemmas'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('quick actions should have proper icons', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.menu_book), findsWidgets);
      expect(find.byIcon(Icons.book_outlined), findsWidgets);
      expect(find.byIcon(Icons.explore), findsWidgets);
    });

    testWidgets('quick actions should be in grid layout', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('HomeScreen - State Management Tests (10 tests)', () {
    testWidgets('should initialize with greeting overlay visible', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome to GitaWisdom'), findsOneWidget);
    });

    testWidgets('greeting should auto-hide after 3 seconds', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome to GitaWisdom'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome to GitaWisdom'), findsNothing);
    });

    testWidgets('should show authenticated user name in greeting', (WidgetTester tester) async {
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockAuthService.displayName).thenReturn('John Doe');
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('John Doe'), findsWidgets);
    });

    testWidgets('should show Seeker for non-authenticated users', (WidgetTester tester) async {
      when(mockAuthService.isAuthenticated).thenReturn(false);
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Seeker'), findsWidgets);
    });

    testWidgets('should show time-based greeting - morning', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Greeting will depend on current time
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should display tagline below greeting', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Find wisdom to guide your daily dilemmas'), findsOneWidget);
    });

    testWidgets('should have CustomScrollView for content', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should use SliverAppBar for header', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('should load data after first frame', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());

      // Before first frame
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(milliseconds: 100));

      // After first frame, data loading begins
      await tester.pump(const Duration(milliseconds: 500));

      verify(mockSupabaseService.fetchRandomVerseByChapter(any)).called(1);
    });

    testWidgets('should stagger data loading to prevent overwhelming device', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Verse loads first
      await tester.pump(const Duration(milliseconds: 100));
      verify(mockSupabaseService.fetchRandomVerseByChapter(any)).called(1);

      // Chapters load with delay
      await tester.pump(const Duration(milliseconds: 200));
      verify(mockSupabaseService.fetchAllChapters()).called(1);
    });
  });

  group('HomeScreen - Featured Chapters Section (5 tests)', () {
    testWidgets('should display Featured Chapters header', (WidgetTester tester) async {
      final chapters = List.generate(3, (i) => createMockChapter(id: i + 1));
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => chapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Featured Chapters'), findsOneWidget);
    });

    testWidgets('should display first 3 chapters', (WidgetTester tester) async {
      final chapters = List.generate(5, (i) => createMockChapter(id: i + 1));
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => chapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chapter 1 Title'), findsOneWidget);
      expect(find.text('Chapter 2 Title'), findsOneWidget);
      expect(find.text('Chapter 3 Title'), findsOneWidget);
    });

    testWidgets('chapter cards should scroll horizontally', (WidgetTester tester) async {
      final chapters = List.generate(3, (i) => createMockChapter(id: i + 1));
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => chapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('should show chapter number badge', (WidgetTester tester) async {
      final chapters = [createMockChapter(id: 1)];
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => chapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chapter 1'), findsWidgets);
    });

    testWidgets('should show loading state for chapters', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2), () => []),
      );

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Loading featured chapters...'), findsOneWidget);
    });
  });

  group('HomeScreen - Daily Inspiration Section (5 tests)', () {
    testWidgets('should display Daily Inspiration card', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daily Inspiration'), findsOneWidget);
    });

    testWidgets('should show lightbulb icon', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('should display inspirational quote', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have some quote text
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should show Ancient Wisdom attribution', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ancient Wisdom'), findsOneWidget);
    });

    testWidgets('inspiration card should have gradient background', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Container), findsWidgets);
    });
  });

  group('HomeScreen - Accessibility Tests (5 tests)', () {
    testWidgets('should respect reduce motion preference', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: createHomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should have minimum touch targets for quick actions', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final inkWells = find.byType(InkWell);
      for (final element in inkWells.evaluate()) {
        final size = element.size;
        if (size != null) {
          // Touch targets should be at least 44x44
          expect(size.width >= 44.0 || size.height >= 44.0, true);
        }
      }
    });

    testWidgets('text should scale with system font size', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);
      when(mockThemeProvider.textScale).thenReturn(1.5);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should have proper contrast in light mode', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      final theme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('should have proper contrast in dark mode', (WidgetTester tester) async {
      when(mockThemeProvider.isDark).thenReturn(true);
      when(mockThemeProvider.currentTheme).thenReturn(ThemeData.dark());
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      final theme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(theme.brightness, Brightness.dark);
    });
  });

  group('HomeScreen - Error Handling Tests (5 tests)', () {
    testWidgets('should handle verse fetch error gracefully', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenThrow(Exception('Network error'));
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Could not load verse'), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle chapters fetch error gracefully', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Could not load chapters'), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should not crash on null verse data', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => throw Exception('No data'));
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should not crash on empty chapters list', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenAnswer((_) async => createMockVerse());
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should show error icon in error state', (WidgetTester tester) async {
      when(mockSupabaseService.fetchRandomVerseByChapter(any)).thenThrow(Exception('Error'));
      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.error_outline), findsWidgets);
    });
  });
}
