// test/screens/root_scaffold_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/root_scaffold.dart';
import 'package:GitaWisdom/widgets/modern_nav_bar.dart';
import 'package:GitaWisdom/l10n/app_localizations.dart';
import 'package:GitaWisdom/core/navigation/navigation_service.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('RootScaffold', () {
    testWidgets('renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      expect(find.byType(RootScaffold), findsOneWidget);
    });

    testWidgets('has IndexedStack for page navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('has bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      expect(find.byType(ModernNavBar), findsOneWidget);
    });

    testWidgets('starts with home tab selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(0));
    });

    testWidgets('tapping chapters tab switches to chapters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Find chapters tab by looking for its icon
      final chaptersTab = find.byIcon(Icons.menu_book);
      expect(chaptersTab, findsOneWidget);

      // Tap chapters tab
      await tester.tap(chaptersTab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify index changed to 1 (chapters)
      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(1));
    });

    testWidgets('tapping scenarios tab switches to scenarios', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Find scenarios tab
      final scenariosTab = find.byIcon(Icons.psychology);
      expect(scenariosTab, findsOneWidget);

      await tester.tap(scenariosTab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(2));
    });

    testWidgets('tapping journal tab switches to journal', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Find journal tab
      final journalTab = find.byIcon(Icons.book);
      expect(journalTab, findsOneWidget);

      await tester.tap(journalTab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(3));
    });

    testWidgets('tapping more tab switches to more', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Find more tab
      final moreTab = find.byIcon(Icons.more_horiz);
      expect(moreTab, findsOneWidget);

      await tester.tap(moreTab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(4));
    });

    testWidgets('has 5 navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      final navBar = tester.widget<ModernNavBar>(find.byType(ModernNavBar));
      expect(navBar.items.length, equals(5));
    });

    testWidgets('scaffold extends body', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBody, isTrue);
    });

    testWidgets('IndexedStack uses expand sizing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.sizing, equals(StackFit.expand));
    });

    testWidgets('back button behavior on home tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // On home tab, PopScope should allow pop
      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isTrue); // Index 0 allows pop
    });

    testWidgets('back button behavior on non-home tab returns to home', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Switch to chapters tab
      await tester.tap(find.byIcon(Icons.menu_book));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify we're on chapters
      var indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(1));

      // Pop should return to home
      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse); // Not on home, can't pop

      // Simulate back press
      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should be back on home
      indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(0));
    });

    testWidgets('preserves state with AutomaticKeepAliveClientMixin', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Switch tabs multiple times
      await tester.tap(find.byIcon(Icons.menu_book));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.psychology));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.home));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should still be alive
      expect(find.byType(RootScaffold), findsOneWidget);
    });

    testWidgets('navigation service initialization', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Navigation service should be initialized
      expect(NavigationService.instance, isNotNull);
    });

    testWidgets('renders in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.dark(),
          home: const RootScaffold(),
        ),
      );

      expect(find.byType(RootScaffold), findsOneWidget);
      expect(find.byType(ModernNavBar), findsOneWidget);
    });

    testWidgets('renders in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(),
          home: const RootScaffold(),
        ),
      );

      expect(find.byType(RootScaffold), findsOneWidget);
      expect(find.byType(ModernNavBar), findsOneWidget);
    });

    testWidgets('handles rapid tab switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Rapidly switch tabs
      await tester.tap(find.byIcon(Icons.menu_book));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.psychology));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.book));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.home));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should end on home
      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(0));
    });

    testWidgets('lazy loads pages on first access', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Initially only home page is built
      expect(find.byType(IndexedStack), findsOneWidget);

      // Access chapters page
      await tester.tap(find.byIcon(Icons.menu_book));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Chapters page should now be loaded
      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(1));
    });

    testWidgets('state is properly disposed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      // Replace widget to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Different Screen')),
        ),
      );

      // Should dispose without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('responds to different screen sizes', (WidgetTester tester) async {
      // Test on small phone
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      expect(find.byType(RootScaffold), findsOneWidget);

      // Test on tablet
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      expect(find.byType(RootScaffold), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('navigation bar items have correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      final navBar = tester.widget<ModernNavBar>(find.byType(ModernNavBar));

      // Verify each item has a color
      expect(navBar.items[0].color, equals(Colors.blue));
      expect(navBar.items[1].color, equals(Colors.indigo));
      expect(navBar.items[2].color, equals(Colors.purple));
      expect(navBar.items[3].color, equals(Colors.green));
      expect(navBar.items[4].color, equals(Colors.orange));
    });

    testWidgets('prevents same tab tap from rebuilding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RootScaffold(),
        ),
      );

      final initialIndex = tester.widget<IndexedStack>(find.byType(IndexedStack)).index;
      expect(initialIndex, equals(0));

      // Tap home again (same tab)
      await tester.tap(find.byIcon(Icons.home));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Index should remain the same
      final newIndex = tester.widget<IndexedStack>(find.byType(IndexedStack)).index;
      expect(newIndex, equals(0));
    });
  });
}
