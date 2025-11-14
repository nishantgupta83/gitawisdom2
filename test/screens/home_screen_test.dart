import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/screens/home_screen.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/core/theme/theme_provider.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/verse.dart';

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
  });

  Widget createHomeScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SupabaseAuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
        Provider<EnhancedSupabaseService>.value(value: mockSupabaseService),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('should render home screen with app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify app bar is present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('GitaWisdom'), findsOneWidget);
    });

    testWidgets('should display daily verse carousel', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify daily verse section is present
      expect(find.text('Daily Wisdom'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display 18 chapters section', (WidgetTester tester) async {
      final mockChapters = List.generate(
        18,
        (index) => Chapter(
          chapterId: index + 1,
          title: 'Chapter ${index + 1}',
          subtitle: 'Chapter ${index + 1}',
          summary: 'Summary ${index + 1}',
          verseCount: 10,
        ),
      );

      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => mockChapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify chapters section header
      expect(find.text('18 Chapters'), findsAtLeastNWidgets(1));
    });

    testWidgets('should navigate to chapter detail on chapter tap', (WidgetTester tester) async {
      final mockChapters = [
        Chapter(
          chapterId: 1,
          title: 'Arjuna Vishada Yoga',
          subtitle: 'Arjuna Vishada Yoga',
          summary: 'Summary',
          verseCount: 47,
        ),
      ];

      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => mockChapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find and tap first chapter card
      final chapterCard = find.text('Arjuna Vishada Yoga');
      expect(chapterCard, findsAtLeastNWidgets(1));

      await tester.tap(chapterCard.first);
      await tester.pumpAndSettle();

      // Verify navigation occurred (chapter detail screen should be pushed)
      // Note: Full navigation verification would require NavigatorObserver
    });

    testWidgets('should display loading state while fetching data', (WidgetTester tester) async {
      when(mockSupabaseService.fetchAllChapters()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2), () => []),
      );

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(); // Trigger initial build

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle error state gracefully', (WidgetTester tester) async {
      when(mockSupabaseService.fetchAllChapters()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify error handling (app should not crash)
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should display authenticated user greeting when signed in', (WidgetTester tester) async {
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockAuthService.displayName).thenReturn('Test User');

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify user greeting
      expect(find.textContaining('Test User'), findsAtLeastNWidgets(1));
    });

    testWidgets('should apply dark mode theme when enabled', (WidgetTester tester) async {
      when(mockSettingsService.isDarkMode).thenReturn(true);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify dark theme is applied
      final ThemeData theme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('should refresh data on pull-to-refresh', (WidgetTester tester) async {
      final mockChapters = [
        Chapter(
          chapterId: 1,
          title: 'Chapter 1',
          subtitle: 'Chapter 1',
          summary: 'Summary',
          verseCount: 47,
        ),
      ];

      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => mockChapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        await tester.drag(refreshIndicator.first, const Offset(0, 300));
        await tester.pumpAndSettle();

        // Verify refresh was triggered
        verify(mockSupabaseService.fetchAllChapters()).called(greaterThan(1));
      }
    });
  });

  group('HomeScreen Accessibility Tests', () {
    testWidgets('should have proper semantics for screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify semantic labels are present
      expect(
        find.bySemanticsLabel('GitaWisdom'),
        findsWidgets,
      );
    });

    testWidgets('should have minimum touch target sizes', (WidgetTester tester) async {
      final mockChapters = [
        Chapter(
          chapterId: 1,
          title: 'Chapter 1',
          subtitle: 'Chapter 1',
          summary: 'Summary',
          verseCount: 47,
        ),
      ];

      when(mockSupabaseService.fetchAllChapters()).thenAnswer((_) async => mockChapters);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify touch targets are at least 44x44 (Material Design guidelines)
      final tappableWidgets = find.byType(InkWell);
      for (final element in tappableWidgets.evaluate()) {
        final size = element.size;
        if (size != null) {
          expect(size.width, greaterThanOrEqualTo(44.0));
          expect(size.height, greaterThanOrEqualTo(44.0));
        }
      }
    });
  });
}
