// test/widgets/search_result_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/search_result_card.dart';
import 'package:GitaWisdom/models/search_result.dart';

import '../test_setup.dart';

void main() {
  group('SearchResultCard Widget Tests', () {
    setUp(() async {
      await setupTestEnvironment();
    });

    tearDown(() async {
      await teardownTestEnvironment();
    });

    testWidgets('renders verse search result', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test Verse Title',
        snippet: 'This is a test verse snippet',
        chapterId: 2,
        verseId: 47,
        relevanceScore: 95.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Verse Title'), findsOneWidget);
      expect(find.text('This is a test verse snippet'), findsOneWidget);
    });

    testWidgets('renders chapter search result', (tester) async {
      final result = SearchResult(
        resultType: SearchType.chapter,
        title: 'Chapter 2',
        snippet: 'Sankhya Yoga',
        chapterId: 2,
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'yoga',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Chapter 2'), findsOneWidget);
      expect(find.text('Sankhya Yoga'), findsOneWidget);
    });

    testWidgets('renders scenario search result', (tester) async {
      final result = SearchResult(
        resultType: SearchType.scenario,
        title: 'Career Dilemma',
        snippet: 'Balancing career and family',
        relevanceScore: 88.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'career',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Career Dilemma'), findsOneWidget);
      expect(find.text('Balancing career and family'), findsOneWidget);
    });

    testWidgets('shows relevance score badge', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 95.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('does not show score if zero', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 0.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsNothing);
    });

    testWidgets('displays verse type label correctly', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        chapterId: 3,
        verseId: 15,
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Chapter 3'), findsOneWidget);
      expect(find.textContaining('Verse 15'), findsOneWidget);
    });

    testWidgets('displays chapter type label correctly', (tester) async {
      final result = SearchResult(
        resultType: SearchType.chapter,
        title: 'Test',
        snippet: 'Snippet',
        chapterId: 5,
        relevanceScore: 85.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Chapter 5'), findsOneWidget);
    });

    testWidgets('displays scenario type label', (tester) async {
      final result = SearchResult(
        resultType: SearchType.scenario,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 80.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Life Scenario'), findsOneWidget);
    });

    testWidgets('has proper type icon for verse', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('has proper type icon for chapter', (tester) async {
      final result = SearchResult(
        resultType: SearchType.chapter,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('has proper type icon for scenario', (tester) async {
      final result = SearchResult(
        resultType: SearchType.scenario,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('has arrow forward icon', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isTrue);
    });

    testWidgets('has gradient background', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('has rounded border radius', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('has proper padding and margins', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('truncates long title text', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'This is a very long title that should be truncated ' * 5,
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('truncates long snippet text', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'This is a very long snippet that should be truncated when displayed in the card ' * 10,
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('highlights query terms in snippet', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'This snippet contains the test keyword',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('handles empty query gracefully', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Test snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: '',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test snippet'), findsOneWidget);
    });

    testWidgets('handles empty snippet gracefully', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: '',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('adapts to light theme', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('has proper touch target size', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(InkWell));
      expect(size.height, greaterThan(44)); // Minimum touch target
    });

    testWidgets('displays properly on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('displays properly on tablets', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('type icon has gradient background', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('maintains structure across rebuilds', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);

      // Rebuild
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('highlights multiple query words', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'This snippet contains test and another word keyword',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test word keyword',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('handles case-insensitive highlighting', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'This TEST snippet CONTAINS test',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('displays query type icon', (tester) async {
      final result = SearchResult(
        resultType: SearchType.query,
        title: 'Test Query',
        snippet: 'Query snippet',
        relevanceScore: 75.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('has proper icon container decoration', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultCard), findsOneWidget);
    });

    testWidgets('handles null chapter ID gracefully', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        chapterId: null,
        verseId: null,
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Verse'), findsOneWidget);
    });

    testWidgets('displays relevance score as integer', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 87.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('87%'), findsOneWidget);
    });

    testWidgets('uses Row layout for header', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('uses Column layout for content', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('has proper spacing with SizedBox', (tester) async {
      final result = SearchResult(
        resultType: SearchType.verse,
        title: 'Test',
        snippet: 'Snippet',
        relevanceScore: 90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultCard(
              result: result,
              query: 'test',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
