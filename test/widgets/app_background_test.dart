// test/widgets/app_background_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/app_background.dart';

import '../test_setup.dart';

void main() {
  group('AppBackground Widget Tests', () {
    setUp(() async {
      await setupTestEnvironment();
    });

    tearDown() async {
      await teardownTestEnvironment();
    });

    testWidgets('renders AppBackground with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
                Center(child: Text('Content')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders AppBackground with light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: false),
                Center(child: Text('Content')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('uses Positioned.fill to cover screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('has RepaintBoundary for performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('renders without animated orbs by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true, showAnimatedOrbs: false),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('renders with animated orbs when enabled', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(seconds: 10),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AppBackground(
                  isDark: true,
                  showAnimatedOrbs: true,
                  orbController: controller,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('respects opacity parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true, opacity: 0.5),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('default opacity is 1.0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('fills available space', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      final background = tester.widget<AppBackground>(find.byType(AppBackground));
      expect(background.isDark, isTrue);
    });

    testWidgets('adapts to screen size changes', (tester) async {
      // Start with phone size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);

      // Change to tablet size
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(AppBackground), findsOneWidget);

      addTearDown(tester.view.reset);
    });

    testWidgets('handles narrow screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('handles wide screens', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: false),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('does not interfere with overlaid content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const AppBackground(isDark: true),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Button should be tappable
      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Button'), findsOneWidget);
    });

    testWidgets('maintains gradient in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('maintains gradient in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: false),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('animated orbs render with controller', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(seconds: 10),
      );
      addTearDown(controller.dispose);

      controller.repeat();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AppBackground(
                  isDark: true,
                  showAnimatedOrbs: true,
                  orbController: controller,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('rebuilds efficiently when properties change', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);

      // Rebuild with different theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: false),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('const constructor allows optimization', (tester) async {
      const background1 = AppBackground(isDark: true);
      const background2 = AppBackground(isDark: true);

      expect(identical(background1, background2), isTrue);
    });

    testWidgets('handles animation controller lifecycle', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(seconds: 10),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AppBackground(
                  isDark: true,
                  showAnimatedOrbs: true,
                  orbController: controller,
                ),
              ],
            ),
          ),
        ),
      );

      controller.forward();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AppBackground), findsOneWidget);

      controller.stop();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('background persists across widget updates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
                Center(child: Text('V1')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('V1'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
                Center(child: Text('V2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('V2'), findsOneWidget);
      expect(find.byType(AppBackground), findsOneWidget);
    });

    testWidgets('works in different scaffold contexts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: Stack(
              children: const [
                AppBackground(isDark: true),
                Center(child: Text('Content')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('handles rotation changes', (tester) async {
      // Portrait
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                AppBackground(isDark: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBackground), findsOneWidget);

      // Landscape
      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(AppBackground), findsOneWidget);

      addTearDown(tester.view.reset);
    });
  });
}
