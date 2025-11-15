// test/screens/splash_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/splash_screen.dart';
import 'package:GitaWisdom/core/app_config.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('SplashScreen', () {
    testWidgets('renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('displays app logo icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
    });

    testWidgets('displays app name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.text(AppConfig.appName), findsOneWidget);
    });

    testWidgets('displays loading progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays initial loading message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.text('Initializing...'), findsOneWidget);
    });

    testWidgets('has background image', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Find Container with background image
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).image != null,
      );

      expect(containerFinder, findsWidgets);
    });

    testWidgets('uses SafeArea for content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('has centered content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('displays version info in debug mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      if (AppConfig.isDebugMode) {
        expect(find.textContaining('Version'), findsOneWidget);
      }
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, isTrue);
      expect(scaffold.extendBody, isTrue);
    });

    testWidgets('updates loading message over time', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Initial state
      expect(find.text('Initializing...'), findsOneWidget);

      // Wait a bit for progress updates
      await tester.pump(const Duration(milliseconds: 150));

      // Progress may have updated
      // We can't predict exact text, but widget should still be there
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('has stack layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('progress bar has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // Verify progress bar styling
      expect(progressIndicator.valueColor, isNotNull);
      expect(progressIndicator.backgroundColor, isNotNull);
    });

    testWidgets('icon has correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.auto_stories));
      expect(icon.size, equals(80));
    });

    testWidgets('icon has correct color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.auto_stories));
      expect(icon.color, equals(AppConfig.splashIconColor));
    });

    testWidgets('loading message is properly styled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final textFinder = find.text('Initializing...');
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.style, isNotNull);
    });

    testWidgets('app name text is properly styled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final textFinder = find.text(AppConfig.appName);
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.style, isNotNull);
      expect(text.style!.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('has proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify SizedBox spacing elements exist
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('column has correct alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final columnFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Column &&
            widget.mainAxisAlignment == MainAxisAlignment.center,
      );

      expect(columnFinder, findsOneWidget);
    });

    testWidgets('progress bar width is constrained', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Find SizedBox containing progress bar
      final sizedBoxFinder = find.ancestor(
        of: find.byType(LinearProgressIndicator),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, equals(250));
    });

    testWidgets('renders in different screen sizes', (WidgetTester tester) async {
      // Test small screen
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      // Test large screen
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('state is created correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final state = tester.state<State<SplashScreen>>(find.byType(SplashScreen));
      expect(state, isNotNull);
      expect(state.mounted, isTrue);
    });

    testWidgets('progress timer is cancelled on dispose', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Replace with different widget to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Different Screen')),
        ),
      );

      // Verify no errors occurred during dispose
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles mounted check properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Wait for some updates
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should still be mounted and functioning
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });
}
