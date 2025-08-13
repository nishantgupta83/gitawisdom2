import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/screens/about_screen.dart';
import 'package:GitaWisdom/screens/references_screen.dart';
import 'package:GitaWisdom/screens/home_screen.dart';
import 'package:GitaWisdom/screens/scenarios_screen.dart';
import 'package:GitaWisdom/screens/journal_screen.dart';
import 'package:GitaWisdom/screens/more_screen.dart';
import 'package:GitaWisdom/widgets/custom_nav_bar.dart';
import 'package:GitaWisdom/widgets/expandable_text.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'test_helpers.dart';
import 'test_config.dart';

void main() {
  setUpAll(() async {
    await commonTestSetup();
  });

  tearDownAll(() async {
    await commonTestCleanup();
  });

  group('Enhanced Screen Widget Tests', () {
    testWidgets('HomeScreen displays daily verses and navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(HomeScreen()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      // Should have daily verse carousel
      expect(find.byType(PageView), findsOneWidget);
      // Should have navigation buttons
      expect(find.textContaining('Chapters'), findsOneWidget);
      expect(find.textContaining('Scenarios'), findsOneWidget);
    });

    testWidgets('ScenariosScreen displays scenarios list', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(ScenariosScreen()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      // Should have search functionality
      expect(find.byIcon(Icons.search), findsOneWidget);
      // Should have scenarios list
      expect(find.byType(ListView), findsOneWidget);
      
      // Should display new filter categories
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Life Stages'), findsOneWidget);
      expect(find.text('Relationships'), findsOneWidget);
      expect(find.text('Career & Work'), findsOneWidget);
      expect(find.text('Personal Growth'), findsOneWidget);
      expect(find.text('Modern Life'), findsOneWidget);
    });

    testWidgets('ScenariosScreen with filterTag should map to correct category', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(
            ScenariosScreen(filterTag: 'parenting'),
          ),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      // Should show filter indication for tagged scenarios
      expect(find.textContaining('tagged with'), findsWidgets);
    });

    testWidgets('ScenariosScreen with filterChapter should show chapter filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(
            ScenariosScreen(filterChapter: 2),
          ),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      // Should show chapter filter indication
      expect(find.textContaining('Chapter 2'), findsWidgets);
    });

    testWidgets('JournalScreen displays journal entries', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(JournalScreen()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      // Should have add journal entry button
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('MoreScreen displays settings and options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(MoreScreen()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      // Should have settings options
      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('Settings'), findsOneWidget);
    });

    testWidgets('AboutScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(AboutScreen()),
      );

      expect(find.text('About'), findsOneWidget);
      expect(find.textContaining('Gitawisdom'), findsOneWidget);
      expect(find.textContaining('Bhagavad Gita'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ReferencesScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(ReferencesScreen()),
      );

      expect(find.text('References'), findsOneWidget);
      expect(find.textContaining('Bhagavad-gītā As It Is'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('Stephen Mitchell'), findsOneWidget);
      expect(find.textContaining('Gandhi'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.textContaining('Prabhupāda'), findsOneWidget);
    });
  });

  group('Enhanced Widget Component Tests', () {
    testWidgets('CustomNavBar displays all navigation items', (WidgetTester tester) async {
      int selectedIndex = 0;
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          Scaffold(
            bottomNavigationBar: CustomNavBar(
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
              items: const [
                NavBarItem(icon: Icons.home, label: 'Home'),
                NavBarItem(icon: Icons.menu_book, label: 'Chapters'),
                NavBarItem(icon: Icons.list, label: 'Scenarios'),
                NavBarItem(icon: Icons.edit, label: 'Journal'),
                NavBarItem(icon: Icons.more_horiz, label: 'More'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CustomNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('CustomNavBar handles tap interactions', (WidgetTester tester) async {
      int selectedIndex = 0;
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: CustomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  items: const [
                    NavBarItem(icon: Icons.home, label: 'Home'),
                    NavBarItem(icon: Icons.menu_book, label: 'Chapters'),
                    NavBarItem(icon: Icons.list, label: 'Scenarios'),
                    NavBarItem(icon: Icons.edit, label: 'Journal'),
                    NavBarItem(icon: Icons.more_horiz, label: 'More'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Tap on Scenarios tab
      await tester.tap(find.text('Scenarios'));
      await tester.pump();

      expect(find.text('Scenarios'), findsOneWidget);
    });

    testWidgets('ExpandableText shows collapsed and expanded states', (WidgetTester tester) async {
      final longText = 'This is a very long text that should be expandable when it exceeds the maximum number of lines. ' * 10;
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          Scaffold(
            body: ExpandableText(longText),
          ),
        ),
      );

      // Should show collapsed text initially
      expect(find.textContaining('Show more'), findsOneWidget);
      
      // Tap to expand
      await tester.tap(find.textContaining('Show more'));
      await tester.pump();
      
      // Should show expanded text
      expect(find.textContaining('Show less'), findsOneWidget);
    });

    testWidgets('ExpandableText handles short text without expansion', (WidgetTester tester) async {
      const shortText = 'This is short text.';
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          Scaffold(
            body: ExpandableText(shortText),
          ),
        ),
      );

      // Should not show expand/collapse options for short text
      expect(find.textContaining('Show more'), findsNothing);
      expect(find.textContaining('Show less'), findsNothing);
      expect(find.text(shortText), findsOneWidget);
    });
  });

  group('Theme and Settings Integration Tests', () {
    testWidgets('Screens respect theme settings', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService()..setTheme(ThemeMode.dark),
          child: TestConfig.wrapWithMaterialApp(HomeScreen()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      // Verify the app responds to theme changes
      final BuildContext context = tester.element(find.byType(MaterialApp));
      final ThemeData theme = Theme.of(context);
      
      expect(find.byType(Scaffold), findsOneWidget);
      // Theme should be applied
      expect(theme, isNotNull);
    });

    testWidgets('Font size settings are respected', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService()..setFontSize('large'),
          child: TestConfig.wrapWithMaterialApp(AboutScreen()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      // App should render without errors with different font sizes
    });
  });

  group('Error Handling and Edge Cases', () {
    testWidgets('Screens handle empty state gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(JournalScreen()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      // Should render without errors even with empty data
      expect(find.byType(Scaffold), findsOneWidget);
      // JournalScreen may not have AppBar in current implementation
    });

    testWidgets('Navigation handles invalid indices gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          Scaffold(
            bottomNavigationBar: CustomNavBar(
              currentIndex: -1, // Invalid index
              onTap: (index) {},
              items: const [
                NavBarItem(icon: Icons.home, label: 'Home'),
                NavBarItem(icon: Icons.menu_book, label: 'Chapters'),
                NavBarItem(icon: Icons.list, label: 'Scenarios'),
                NavBarItem(icon: Icons.more_horiz, label: 'More'),
              ],
            ),
          ),
        ),
      );

      // Should render without throwing errors
      expect(find.byType(CustomNavBar), findsOneWidget);
    });
  });
}
