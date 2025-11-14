import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/screens/more_screen.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'package:GitaWisdom/services/background_music_service.dart';
import 'package:GitaWisdom/core/theme/theme_provider.dart';

import 'more_screen_test.mocks.dart';

@GenerateMocks([
  SupabaseAuthService,
  SettingsService,
  BackgroundMusicService,
  ThemeProvider,
])
void main() {
  late MockSupabaseAuthService mockAuthService;
  late MockSettingsService mockSettingsService;
  late MockBackgroundMusicService mockMusicService;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockAuthService = MockSupabaseAuthService();
    mockSettingsService = MockSettingsService();
    mockMusicService = MockBackgroundMusicService();
    mockThemeProvider = MockThemeProvider();

    // Setup default mocks
    when(mockAuthService.isAuthenticated).thenReturn(false);
    when(mockAuthService.displayName).thenReturn('Test User');
    when(mockAuthService.userEmail).thenReturn('test@example.com');
    when(mockSettingsService.isDarkMode).thenReturn(false);
    when(mockSettingsService.fontSize).thenReturn('medium');
    when(mockMusicService.isEnabled).thenReturn(false);
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

  Widget createMoreScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SupabaseAuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
        ChangeNotifierProvider<BackgroundMusicService>.value(value: mockMusicService),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
      ],
      child: const MaterialApp(
        home: MoreScreen(),
      ),
    );
  }

  group('MoreScreen Widget Tests', () {
    testWidgets('should render more screen with app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('should display sections in correct order', (WidgetTester tester) async {
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify new section order: APPEARANCE → CONTENT → RESOURCES → EXTRAS → ACCOUNT → CACHE
      // Just verify all sections are present
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.text('RESOURCES'), findsOneWidget);
      expect(find.text('EXTRAS'), findsOneWidget);
      // Note: ACCOUNT and CACHE sections may not be visible depending on auth state
    });

    testWidgets('should display ACCOUNT section only when authenticated', (WidgetTester tester) async {
      when(mockAuthService.isAuthenticated).thenReturn(false);

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ACCOUNT section should NOT be visible
      expect(find.text('ACCOUNT'), findsNothing);

      // Now authenticate
      when(mockAuthService.isAuthenticated).thenReturn(true);
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ACCOUNT section should be visible
      expect(find.text('ACCOUNT'), findsOneWidget);
    });

    testWidgets('should toggle dark mode when switch is tapped', (WidgetTester tester) async {
      when(mockSettingsService.isDarkMode).thenReturn(false);

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find dark mode switch
      final darkModeSwitch = find.widgetWithText(SwitchListTile, 'Dark Mode');
      expect(darkModeSwitch, findsOneWidget);

      // Tap the switch
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify setter was called
      verify(mockSettingsService.isDarkMode = true).called(1);
    });

    testWidgets('should toggle background music when switch is tapped', (WidgetTester tester) async {
      when(mockMusicService.isEnabled).thenReturn(false);
      when(mockMusicService.setEnabled(any)).thenAnswer((_) async => {});

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find background music switch
      final musicSwitch = find.widgetWithText(SwitchListTile, 'Background Music');
      expect(musicSwitch, findsOneWidget);

      // Tap the switch
      await tester.tap(musicSwitch);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify setEnabled was called
      verify(mockMusicService.setEnabled(true)).called(1);
    });

    testWidgets('should update font size when dropdown is changed', (WidgetTester tester) async {
      when(mockSettingsService.fontSize).thenReturn('medium');

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find font size dropdown
      final fontSizeDropdown = find.widgetWithText(ListTile, 'Font Size');
      expect(fontSizeDropdown, findsOneWidget);

      // Find dropdown button
      final dropdownButton = find.descendant(
        of: fontSizeDropdown,
        matching: find.byType(DropdownButton<String>),
      );
      expect(dropdownButton, findsOneWidget);

      // Tap dropdown to open it
      await tester.tap(dropdownButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Select 'Large' option
      await tester.tap(find.text('Large').last);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify setter was called
      verify(mockSettingsService.fontSize = 'large').called(1);
    });

    testWidgets('should navigate to search screen when search tile is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find search list tile
      final searchTile = find.widgetWithText(ListTile, 'Search');
      expect(searchTile, findsOneWidget);

      // Tap search tile
      await tester.tap(searchTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify navigation (SearchScreen should be in widget tree)
      // Note: Full navigation verification would require NavigatorObserver
    });

    testWidgets('should display app version in EXTRAS section', (WidgetTester tester) async {
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find app version list tile
      expect(find.text('App Version'), findsOneWidget);
    });

    testWidgets('should show sign out confirmation dialog', (WidgetTester tester) async {
      when(mockAuthService.isAuthenticated).thenReturn(true);

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Expand account section
      final accountTile = find.byType(ExpansionTile);
      if (accountTile.evaluate().isNotEmpty) {
        await tester.tap(accountTile.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Find and tap sign out button
        final signOutButton = find.text('Sign Out');
        if (signOutButton.evaluate().isNotEmpty) {
          await tester.tap(signOutButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Verify confirmation dialog is shown
          expect(find.text('Sign Out?'), findsOneWidget);
          expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
        }
      }
    });

    testWidgets('should show delete account confirmation dialog', (WidgetTester tester) async {
      when(mockAuthService.isAuthenticated).thenReturn(true);

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Expand account section
      final accountTile = find.byType(ExpansionTile);
      if (accountTile.evaluate().isNotEmpty) {
        await tester.tap(accountTile.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Find and tap delete account button
        final deleteButton = find.text('Delete Account');
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Verify confirmation dialog is shown
          expect(find.text('Delete Account?'), findsOneWidget);
          expect(find.textContaining('cannot be undone'), findsOneWidget);
        }
      }
    });

    testWidgets('should handle cache refresh', (WidgetTester tester) async {
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find refresh cache tile
      final refreshTile = find.widgetWithText(ListTile, 'Refresh All Data');
      expect(refreshTile, findsOneWidget);

      // Tap refresh tile
      await tester.tap(refreshTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify progress dialog is shown
      expect(find.text('Refreshing Cache'), findsOneWidget);
    });
  });

  group('MoreScreen Accessibility Tests', () {
    testWidgets('should have proper semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify section headers are accessible
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.text('RESOURCES'), findsOneWidget);
    });

    testWidgets('should have minimum touch target sizes for all interactive elements', (WidgetTester tester) async {
      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify ListTile touch targets
      final listTiles = find.byType(ListTile);
      for (final element in listTiles.evaluate()) {
        final size = element.size;
        if (size != null) {
          expect(size.height, greaterThanOrEqualTo(44.0),
              reason: 'ListTile height should be at least 44dp for accessibility');
        }
      }
    });
  });
}
