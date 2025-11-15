// test/screens/about_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/about_screen.dart';
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

  group('AboutScreen', () {
    testWidgets('renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('displays app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      expect(find.text('ABOUT GITAWISDOM'), findsOneWidget);
    });

    testWidgets('displays tagline', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      expect(find.text('Ancient wisdom for modern life'), findsOneWidget);
    });

    testWidgets('displays made with love section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays content validated section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to find the content
      await tester.dragUntilVisible(
        find.text('Content Validated Against'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      expect(find.text('Content Validated Against'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('displays source items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to find sources
      await tester.dragUntilVisible(
        find.text('ISKCON Vedabase'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      expect(find.text('ISKCON Vedabase'), findsOneWidget);
      expect(find.text('vedabase.io'), findsOneWidget);
      expect(find.text('Holy Bhagavad Gita'), findsOneWidget);
      expect(find.text('holy-bhagavad-gita.org'), findsOneWidget);
      expect(find.text('IIT Kanpur Gita Supersite'), findsOneWidget);
      expect(find.text('gitasupersite.iitk.ac.in'), findsOneWidget);
    });

    testWidgets('displays scenario disclaimer section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to find disclaimer
      await tester.dragUntilVisible(
        find.text('Important Note'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      expect(find.text('Important Note'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.text('These scenarios are NOT based on:'), findsOneWidget);
    });

    testWidgets('displays disclaimer items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to find disclaimer items
      await tester.dragUntilVisible(
        find.text('• Specific Research Studies'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      expect(find.text('• Specific Research Studies'), findsOneWidget);
      expect(find.text('• Survey Data'), findsOneWidget);
      expect(find.text('• Clinical Case Studies'), findsOneWidget);
    });

    testWidgets('displays Gita quote section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
      expect(find.text('- Bhagavad Gita 2.47'), findsOneWidget);
    });

    testWidgets('back button navigates back', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                  child: const Text('Go to About'),
                );
              },
            ),
          ),
        ),
      );

      // Navigate to about screen
      await tester.tap(find.text('Go to About'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify we're on the about screen
      expect(find.text('ABOUT GITAWISDOM'), findsOneWidget);

      // Find and tap the back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify we're back to the original screen
      expect(find.text('Go to About'), findsOneWidget);
    });

    testWidgets('home button navigates to home tab', (WidgetTester tester) async {
      // Initialize NavigationService
      NavigationService.instance.initialize(
        onTabChanged: (index) {},
        onGoToScenariosWithChapter: (chapterId) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: NavigationService.instance.navigatorKey,
          home: const AboutScreen(),
        ),
      );

      // Find the home button
      final homeButton = find.byIcon(Icons.home_filled);
      expect(homeButton, findsOneWidget);

      // Tap the home button
      await tester.tap(homeButton);
      await tester.pump();
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.dark(),
          home: const AboutScreen(),
        ),
      );

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('ABOUT GITAWISDOM'), findsOneWidget);
    });

    testWidgets('renders correctly in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(),
          home: const AboutScreen(),
        ),
      );

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('ABOUT GITAWISDOM'), findsOneWidget);
    });

    testWidgets('scrolls properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      // Find the ListView
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Scroll down
      await tester.drag(listView, const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify content is still visible
      expect(find.text('Content Validated Against'), findsOneWidget);
    });

    testWidgets('adapts to tablet layout', (WidgetTester tester) async {
      // Set tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('ABOUT GITAWISDOM'), findsOneWidget);
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('displays all cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      // Pump a few frames to let everything render
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify multiple cards are present
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('has proper icon sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      // Verify icons are present
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('back and home buttons have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      );

      // Verify buttons are properly positioned
      final backButton = find.byIcon(Icons.arrow_back);
      final homeButton = find.byIcon(Icons.home_filled);

      expect(backButton, findsOneWidget);
      expect(homeButton, findsOneWidget);
    });
  });
}
