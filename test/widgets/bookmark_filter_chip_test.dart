// test/widgets/bookmark_filter_chip_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/bookmark_filter_chip.dart';
import 'package:GitaWisdom/models/bookmark.dart';

void main() {
  group('BookmarkFilterChip Widget Tests', () {
    testWidgets('should render filter chip with label and count', (tester) async {
      int? selectedFilter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: null,
              label: 'Verses',
              count: 5,
              onSelected: (value) => selectedFilter = value as int?,
            ),
          ),
        ),
      );

      expect(find.text('Verses'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byType(FilterChip), findsOneWidget);
    });

    testWidgets('should render filter chip without count badge when count is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: null,
              label: 'Verses',
              count: 0,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Verses'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('should show selected state when filter matches', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: BookmarkType.verse,
              label: 'Verses',
              count: 5,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isTrue);
    });

    testWidgets('should not show selected state when filter does not match', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: BookmarkType.chapter,
              label: 'Verses',
              count: 5,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isFalse);
    });

    testWidgets('should call onSelected with filterType when tapped and not selected', (tester) async {
      BookmarkType? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: null,
              label: 'Verses',
              count: 5,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(selectedValue, BookmarkType.verse);
    });

    testWidgets('should call onSelected with null when tapped and already selected', (tester) async {
      BookmarkType? selectedValue = BookmarkType.verse;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: BookmarkType.verse,
              label: 'Verses',
              count: 5,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(selectedValue, isNull);
    });

    testWidgets('should handle null filterType (All filter)', (tester) async {
      BookmarkType? selectedValue = BookmarkType.verse;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: null,
              selectedFilter: null,
              label: 'All',
              count: 15,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(selectedValue, isNull);
    });

    testWidgets('should show selected state for All filter when selectedFilter is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: null,
              selectedFilter: null,
              label: 'All',
              count: 15,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isTrue);
    });

    testWidgets('should toggle selection state correctly', (tester) async {
      BookmarkType? selectedFilter;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: BookmarkFilterChip(
                  filterType: BookmarkType.verse,
                  selectedFilter: selectedFilter,
                  label: 'Verses',
                  count: 5,
                  onSelected: (value) {
                    setState(() {
                      selectedFilter = value;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Initially not selected
      FilterChip filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isFalse);

      // Tap to select
      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isTrue);

      // Tap again to deselect
      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isFalse);
    });

    testWidgets('should display count badge with correct styling when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: BookmarkType.verse,
              label: 'Verses',
              count: 10,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);

      // Find the count container
      final countContainer = find.ancestor(
        of: find.text('10'),
        matching: find.byType(Container),
      );
      expect(countContainer, findsWidgets);
    });

    testWidgets('should render with different BookmarkType filters', (tester) async {
      // Test with Chapter filter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.chapter,
              selectedFilter: null,
              label: 'Chapters',
              count: 3,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Test with Scenario filter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.scenario,
              selectedFilter: null,
              label: 'Scenarios',
              count: 7,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('should handle large count numbers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkFilterChip(
              filterType: BookmarkType.verse,
              selectedFilter: null,
              label: 'Verses',
              count: 9999,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('9999'), findsOneWidget);
    });
  });
}
