// test/widgets/search_suggestions_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/search_suggestions.dart';
import 'package:GitaWisdom/models/search_result.dart';

void main() {
  group('SearchSuggestions Widget Tests', () {
    final mockSuggestions = [
      'Karma Yoga',
      'Bhakti Yoga',
      'Dharma',
      'Meditation',
      'Krishna',
      'Arjuna',
      'Wisdom',
      'Knowledge',
      'Peace',
      'Soul',
      'Devotion',
      'Action',
    ];

    final mockRecentSearches = <SearchResult>[
      SearchResult(
        id: '1',
        searchQuery: 'karma',
        title: 'Karma Yoga',
        content: 'Path of selfless action',
        snippet: 'Path of selfless action',
        resultType: SearchType.query,
        relevanceScore: 95,
        searchDate: DateTime.now(),
      ),
      SearchResult(
        id: '2',
        searchQuery: 'dharma',
        title: 'Dharma',
        content: 'Righteous duty',
        snippet: 'Righteous duty',
        resultType: SearchType.query,
        relevanceScore: 90,
        searchDate: DateTime.now(),
      ),
    ];

    testWidgets('should render suggestions grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: [],
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Popular Topics'), findsOneWidget);
      expect(find.text('Karma Yoga'), findsOneWidget);
      expect(find.text('Meditation'), findsOneWidget);
    });

    testWidgets('should render recent searches when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: mockRecentSearches,
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('karma'), findsOneWidget);
      expect(find.text('dharma'), findsOneWidget);
    });

    testWidgets('should not render recent searches section when empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: [],
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Recent Searches'), findsNothing);
    });

    testWidgets('should call onSuggestionTap when suggestion is tapped', (tester) async {
      String? tappedSuggestion;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: [],
                onSuggestionTap: (query) {
                  tappedSuggestion = query;
                },
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Karma Yoga'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(tappedSuggestion, 'Karma Yoga');
    });

    testWidgets('should call onRecentSearchTap when recent search is tapped', (tester) async {
      String? tappedSearch;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: mockRecentSearches,
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {
                  tappedSearch = query;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('karma'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(tappedSearch, 'karma');
    });

    testWidgets('should show Clear button when recent searches exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: mockRecentSearches,
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
                onClearRecentSearches: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Clear'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should call onClearRecentSearches when Clear is tapped', (tester) async {
      bool cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: mockRecentSearches,
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
                onClearRecentSearches: () {
                  cleared = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(cleared, isTrue);
    });

    testWidgets('should display maximum 5 recent searches', (tester) async {
      final manyRecentSearches = List<SearchResult>.generate(
        10,
        (index) => SearchResult(
          id: index.toString(),
          searchQuery: 'search $index',
          title: 'Search $index',
          content: 'Content $index',
          snippet: 'Snippet $index',
          resultType: SearchType.query,
          relevanceScore: 90,
          searchDate: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: manyRecentSearches,
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      // Should only show first 5
      expect(find.text('search 0'), findsOneWidget);
      expect(find.text('search 4'), findsOneWidget);
      expect(find.text('search 5'), findsNothing);
      expect(find.text('search 9'), findsNothing);
    });

    testWidgets('should display maximum 12 suggestions in grid', (tester) async {
      final manySuggestions = List.generate(20, (index) => 'Suggestion $index');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: manySuggestions,
                recentSearches: [],
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      // Should only show first 12
      expect(find.text('Suggestion 0'), findsOneWidget);
      expect(find.text('Suggestion 11'), findsOneWidget);
      expect(find.text('Suggestion 12'), findsNothing);
      expect(find.text('Suggestion 19'), findsNothing);
    });

    testWidgets('should render suggestion cards with icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: ['Karma', 'Meditation', 'Krishna'],
                recentSearches: [],
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      // Verify icons are rendered (at least some)
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should render recent search chips with history icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions,
                recentSearches: mockRecentSearches,
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      // Find history icons
      final historyIcons = find.byIcon(Icons.history);
      expect(historyIcons, findsWidgets);
    });

    testWidgets('should render suggestions in 2-column grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: mockSuggestions.take(4).toList(),
                recentSearches: [],
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      // Verify GridView exists
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should handle empty suggestions list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: [],
                recentSearches: [],
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Popular Topics'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should render suggestion cards with gradient backgrounds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SearchSuggestions(
                suggestions: ['Dharma', 'Karma'],
                recentSearches: [],
                onSuggestionTap: (query) {},
                onRecentSearchTap: (query) {},
              ),
            ),
          ),
        ),
      );

      // Verify InkWell widgets exist for tappable cards
      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
