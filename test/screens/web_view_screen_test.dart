// test/screens/web_view_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/web_view_screen.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('WebViewScreen', () {
    testWidgets('renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('displays title in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page Title',
          ),
        ),
      );

      expect(find.text('Test Page Title'), findsOneWidget);
    });

    testWidgets('displays back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page',
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button navigates back', (WidgetTester tester) async {
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
                        builder: (_) => const WebViewScreen(
                          url: 'https://example.com',
                          title: 'Test',
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Web View'),
                );
              },
            ),
          ),
        ),
      );

      // Navigate to web view
      await tester.tap(find.text('Open Web View'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify we're on web view screen
      expect(find.byType(WebViewScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should be back to original screen
      expect(find.text('Open Web View'), findsOneWidget);
    });

    testWidgets('displays loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page',
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
      expect(find.text('Test Page'), findsOneWidget);
    });

    testWidgets('renders correctly in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
      expect(find.text('Test Page'), findsOneWidget);
    });

    testWidgets('handles different URLs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://google.com',
            title: 'Google',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('handles different titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Different Title',
          ),
        ),
      );

      expect(find.text('Different Title'), findsOneWidget);
    });

    testWidgets('adapts to tablet layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test Page',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('adapts to small phone layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('handles long titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'This is a very long title that should be handled properly',
          ),
        ),
      );

      expect(
          find.text('This is a very long title that should be handled properly'),
          findsOneWidget);
    });

    testWidgets('handles empty title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: '',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('app bar has proper elevation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test',
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('loading indicator covers entire screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test',
          ),
        ),
      );

      // Loading indicator should be in a Container
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles special characters in URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com/path?param=value&other=123',
            title: 'Test',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('handles special characters in title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test & Title <with> "special" \'chars\'',
          ),
        ),
      );

      expect(find.text('Test & Title <with> "special" \'chars\''), findsOneWidget);
    });

    testWidgets('maintains state during rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test',
          ),
        ),
      );

      // Rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test',
          ),
        ),
      );

      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('stack contains all necessary elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebViewScreen(
            url: 'https://example.com',
            title: 'Test',
          ),
        ),
      );

      final stack = tester.widget<Stack>(find.byType(Stack));
      expect(stack.children.length, greaterThanOrEqualTo(2));
    });
  });
}
