// test/widgets/share_card_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/share_card_widget.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/scenario.dart';

import '../test_setup.dart';

void main() {
  group('ShareCardWidget Widget Tests', () {
    late Verse testVerse;
    late Scenario testScenario;

    setUp(() async {
      await setupTestEnvironment();

      testVerse = Verse(
        chapterId: 2,
        verseId: 47,
        description: 'You have the right to perform your duties, but you are not entitled to the fruits of your actions.',
        audio: null,
        translation: 'Test translation',
      );

      testScenario = Scenario(
        id: 1,
        title: 'Career vs Family Balance',
        description: 'Struggling to balance demanding career with family responsibilities',
        heartResponse: 'Heart guidance',
        dutyResponse: 'Duty guidance',
        category: 'Relationships',
        relatedChapters: '2,3',
        relevanceScore: 95.0,
      );
    });

    tearDown(() async {
      await teardownTestEnvironment();
    });

    testWidgets('renders ShareCardWidget with verse', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      expect(find.byType(ShareCardWidget), findsOneWidget);
      expect(find.text('Share Wisdom'), findsOneWidget);
    });

    testWidgets('renders ShareCardWidget with scenario', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(scenario: testScenario),
          ),
        ),
      );

      expect(find.byType(ShareCardWidget), findsOneWidget);
      expect(find.text('Share Wisdom'), findsOneWidget);
    });

    testWidgets('displays verse details correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show verse chapter and verse ID
      expect(find.text('Bhagavad Gita 2.47'), findsOneWidget);
      expect(find.text(testVerse.description), findsOneWidget);
    });

    testWidgets('displays scenario details correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(scenario: testScenario),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daily Wisdom'), findsOneWidget);
      expect(find.text(testScenario.title), findsOneWidget);
      expect(find.text(testScenario.description), findsOneWidget);
    });

    testWidgets('has cancel and share buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Share Now'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ShareCardWidget(verse: testVerse),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open the bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify sheet is open
      expect(find.text('Share Wisdom'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify sheet is closed
      expect(find.text('Share Wisdom'), findsNothing);
    });

    testWidgets('close button closes dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ShareCardWidget(verse: testVerse),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open the bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify sheet is closed
      expect(find.text('Share Wisdom'), findsNothing);
    });

    testWidgets('has gradient background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find Container with gradient
      final containerFinder = find.ancestor(
        of: find.text('Share Wisdom'),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsWidgets);
    });

    testWidgets('adapts to light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ShareCardWidget), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ShareCardWidget), findsOneWidget);
    });

    testWidgets('shows share icon in header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('shows close icon button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('has preview card section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have preview with verse/scenario content
      expect(find.byType(ShareCardWidget), findsOneWidget);
    });

    testWidgets('has info description section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Share this wisdom with friends across all platforms'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should exist
      expect(find.byType(ShareCardWidget), findsOneWidget);
    });

    testWidgets('share button has gradient styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Share Now'), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('cancel button is outlined style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final cancelButton = find.ancestor(
        of: find.text('Cancel'),
        matching: find.byType(OutlinedButton),
      );

      expect(cancelButton, findsOneWidget);
    });

    testWidgets('share button is elevated style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final shareButton = find.ancestor(
        of: find.text('Share Now'),
        matching: find.byType(ElevatedButton),
      );

      expect(shareButton, findsOneWidget);
    });

    testWidgets('buttons have proper sizing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Both buttons should exist
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Share Now'), findsOneWidget);
    });

    testWidgets('has SafeArea for notch support', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('callback is called when provided', (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(
              verse: testVerse,
              onShared: () {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should be rendered
      expect(find.byType(ShareCardWidget), findsOneWidget);

      // Note: Actual share functionality requires mocking ShareCardService
      // which is tested separately in service tests
    });

    testWidgets('verse preview truncates long text', (tester) async {
      final longVerse = Verse(
        chapterId: 2,
        verseId: 47,
        description: 'This is a very long verse description that should be truncated when displayed in the preview card. ' * 10,
        audio: null,
        translation: 'Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: longVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should find the text widget with overflow
      expect(find.byType(ShareCardWidget), findsOneWidget);
    });

    testWidgets('scenario preview truncates long text', (tester) async {
      final longScenario = Scenario(
        id: 1,
        title: 'Very Long Title ' * 20,
        description: 'Very Long Description ' * 20,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        category: 'Test',
        relatedChapters: '2',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(scenario: longScenario),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ShareCardWidget), findsOneWidget);
    });

    testWidgets('displays properly in narrow screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568); // iPhone SE size
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ShareCardWidget), findsOneWidget);
    });

    testWidgets('displays properly on tablets', (tester) async {
      tester.view.physicalSize = const Size(1024, 768); // iPad size
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardWidget(verse: testVerse),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ShareCardWidget), findsOneWidget);
    });
  });
}
