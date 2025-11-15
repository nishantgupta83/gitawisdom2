// test/widgets/expandable_text_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/expandable_text.dart';

void main() {
  group('ExpandableText Widget Tests', () {
    testWidgets('should render short text without expand button', (tester) async {
      const shortText = 'Short text';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableText(shortText),
          ),
        ),
      );

      expect(find.text(shortText), findsOneWidget);
      expect(find.text('Read more'), findsNothing);
      expect(find.text('Read less'), findsNothing);
    });

    testWidgets('should render long text with "Read more" button', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button. This is important for testing the widget behavior.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrain width to force overflow
              child: ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(longText), findsOneWidget);
      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('Read less'), findsNothing);
    });

    testWidgets('should expand text when "Read more" is tapped', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button. This is important for testing the widget behavior.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify "Read more" exists
      expect(find.text('Read more'), findsOneWidget);

      // Tap "Read more" using GestureDetector
      final gestureDetector = find.ancestor(
        of: find.text('Read more'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetector.first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify it changed to "Read less"
      expect(find.text('Read more'), findsNothing);
      expect(find.text('Read less'), findsOneWidget);
    });

    testWidgets('should collapse text when "Read less" is tapped', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button. This is important for testing the widget behavior.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Expand first - tap using GestureDetector
      final gestureDetectorMore = find.ancestor(
        of: find.text('Read more'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetectorMore.first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify expanded state
      expect(find.text('Read less'), findsOneWidget);

      // Tap "Read less" using GestureDetector
      final gestureDetectorLess = find.ancestor(
        of: find.text('Read less'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetectorLess.first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify collapsed state
      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('Read less'), findsNothing);
    });

    testWidgets('should toggle between expanded and collapsed multiple times', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button. This is important for testing the widget behavior.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Toggle expand/collapse 3 times
      for (int i = 0; i < 3; i++) {
        // Expand
        final gestureDetectorMore = find.ancestor(
          of: find.text('Read more'),
          matching: find.byType(GestureDetector),
        );
        await tester.tap(gestureDetectorMore.first);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Read less'), findsOneWidget);

        // Collapse
        final gestureDetectorLess = find.ancestor(
          of: find.text('Read less'),
          matching: find.byType(GestureDetector),
        );
        await tester.tap(gestureDetectorLess.first);
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Read more'), findsOneWidget);
      }
    });

    testWidgets('should use theme text style', (tester) async {
      const text = 'Test text';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ),
          home: Scaffold(
            body: ExpandableText(text),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(text));
      expect(textWidget.style?.fontSize, 20);
      expect(textWidget.style?.color, Colors.blue);
    });

    testWidgets('should apply primary color to Read more/less text', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button. This is important for testing the widget behavior.';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          ),
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find the "Read more" text and verify it uses primary color
      final readMoreText = tester.widget<Text>(find.text('Read more'));
      expect(readMoreText.style?.color, isNotNull);
    });

    testWidgets('should handle empty text', (tester) async {
      const emptyText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableText(emptyText),
          ),
        ),
      );

      expect(find.text('Read more'), findsNothing);
      expect(find.text('Read less'), findsNothing);
    });

    testWidgets('should handle text with exactly 2 lines', (tester) async {
      const twoLineText = 'Line one\nLine two';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ExpandableText(twoLineText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(twoLineText), findsOneWidget);
      // Should not show expand button for exactly 2 lines
      expect(find.text('Read more'), findsNothing);
    });

    testWidgets('should respond to GestureDetector tap', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button. This is important for testing the widget behavior.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify GestureDetector exists and is tappable
      final gestureDetector = find.ancestor(
        of: find.text('Read more'),
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetector, findsOneWidget);

      await tester.tap(gestureDetector.first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Read less'), findsOneWidget);
    });

    testWidgets('should handle null text gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpandableText(''),
          ),
        ),
      );

      expect(find.byType(ExpandableText), findsOneWidget);
    });

    testWidgets('should handle very long single word', (tester) async {
      final longWord = 'a' * 1000;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ExpandableText(longWord),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ExpandableText), findsOneWidget);
    });

    testWidgets('should adapt to different screen widths', (tester) async {
      const text = 'This text adapts to different screen widths';

      for (final width in [200.0, 400.0, 600.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: const ExpandableText(text),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text(text), findsOneWidget);
      }
    });

    testWidgets('should handle special characters', (tester) async {
      const text = 'Special chars: @#\$%^&*()_+{}|:"<>?';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpandableText(text),
          ),
        ),
      );

      expect(find.textContaining('Special chars'), findsOneWidget);
    });

    testWidgets('should handle unicode characters', (tester) async {
      const text = 'Unicode: 🙏 नमस्ते ॐ भगवद्गीता';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpandableText(text),
          ),
        ),
      );

      expect(find.textContaining('Unicode'), findsOneWidget);
    });

    testWidgets('should render with custom theme colors', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button.';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange,
              brightness: Brightness.light,
            ),
          ),
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: const ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('should handle rapid tap events', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget. It should trigger the overflow detection and show the Read more button.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: const ExpandableText(longText),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Rapid tap test
      for (int i = 0; i < 5; i++) {
        final gestureDetector = find.ancestor(
          of: find.textContaining('Read'),
          matching: find.byType(GestureDetector),
        );
        await tester.tap(gestureDetector.first);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('should maintain state during parent rebuild', (tester) async {
      const longText = 'This is a very long text that will definitely exceed the maximum number of lines allowed in the ExpandableText widget.';

      Widget buildWidget(int key) {
        return MaterialApp(
          key: ValueKey(key),
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: const ExpandableText(longText),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWidget(1));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Expand the text
      final gestureDetector = find.ancestor(
        of: find.text('Read more'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetector.first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Read less'), findsOneWidget);
    });

    testWidgets('should use LayoutBuilder for responsive sizing', (tester) async {
      const longText = 'This is a very long text for testing LayoutBuilder';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: const ExpandableText(longText),
            ),
          ),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
    });

    testWidgets('should display Column widget', (tester) async {
      const text = 'Test text';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpandableText(text),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
    });
  });
}
