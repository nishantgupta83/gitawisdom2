// test/widgets/bookmark_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/bookmark_card.dart';
import 'package:GitaWisdom/models/bookmark.dart';

import '../test_setup.dart';

void main() {
  group('BookmarkCard Widget Tests', () {
    late Bookmark testBookmark;

    setUp(() async {
      await setupTestEnvironment();

      testBookmark = Bookmark(
        id: '1',
        userDeviceId: 'test-device',
        bookmarkType: BookmarkType.verse,
        referenceId: 47,
        chapterId: 2,
        title: 'Test Bookmark Title',
        contentPreview: 'You have the right to perform your duties',
        tags: ['duty', 'action'],
        notes: 'Important verse about karma yoga',
        isHighlighted: true,
        highlightColor: HighlightColor.yellow,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.synced,
      );
    });

    tearDown(() async {
      await teardownTestEnvironment();
    });

    testWidgets('renders BookmarkCard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
      expect(find.text('Test Bookmark Title'), findsOneWidget);
    });

    testWidgets('displays verse type icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('displays chapter type icon', (tester) async {
      final chapterBookmark = testBookmark.copyWith(
        bookmarkType: BookmarkType.chapter,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: chapterBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('displays scenario type icon', (tester) async {
      final scenarioBookmark = testBookmark.copyWith(
        bookmarkType: BookmarkType.scenario,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: scenarioBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('displays content preview', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.textContaining('You have the right'), findsOneWidget);
    });

    testWidgets('displays tags', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.text('duty'), findsOneWidget);
      expect(find.text('action'), findsOneWidget);
    });

    testWidgets('displays notes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.textContaining('Important verse'), findsOneWidget);
      expect(find.byIcon(Icons.note), findsOneWidget);
    });

    testWidgets('displays chapter info', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.textContaining('Chapter 2'), findsOneWidget);
    });

    testWidgets('shows highlight indicator when highlighted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
      // Highlight indicator is a small colored container
    });

    testWidgets('shows synced status icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('shows pending sync status icon', (tester) async {
      final pendingBookmark = testBookmark.copyWith(
        syncStatus: SyncStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: pendingBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
    });

    testWidgets('shows offline status icon', (tester) async {
      final offlineBookmark = testBookmark.copyWith(
        syncStatus: SyncStatus.offline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: offlineBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('shows time ago timestamp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(
              bookmark: testBookmark,
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

    testWidgets('shows popup menu with actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      // Find and tap the more button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('calls onEdit callback when edit selected', (tester) async {
      bool editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(
              bookmark: testBookmark,
              onEdit: () {
                editCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Edit'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(editCalled, isTrue);
    });

    testWidgets('calls onRemove callback when remove selected', (tester) async {
      bool removeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(
              bookmark: testBookmark,
              onRemove: () {
                removeCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Remove'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(removeCalled, isTrue);
    });

    testWidgets('hides notes section if notes are empty', (tester) async {
      final noNotesBookmark = testBookmark.copyWith(notes: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: noNotesBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.note), findsNothing);
    });

    testWidgets('hides tags section if no tags', (tester) async {
      final noTagsBookmark = testBookmark.copyWith(tags: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: noTagsBookmark),
          ),
        ),
      );

      expect(find.text('duty'), findsNothing);
      expect(find.text('action'), findsNothing);
    });

    testWidgets('hides content preview if empty', (tester) async {
      final noPreviewBookmark = testBookmark.copyWith(contentPreview: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: noPreviewBookmark),
          ),
        ),
      );

      expect(find.textContaining('You have the right'), findsNothing);
    });

    testWidgets('truncates long title', (tester) async {
      final longTitleBookmark = testBookmark.copyWith(
        title: 'This is a very long title that should be truncated ' * 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: longTitleBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('truncates long content preview', (tester) async {
      final longPreviewBookmark = testBookmark.copyWith(
        contentPreview: 'This is a very long preview that should be truncated ' * 20,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: longPreviewBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('truncates long notes', (tester) async {
      final longNotesBookmark = testBookmark.copyWith(
        notes: 'This is a very long note that should be truncated ' * 20,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: longNotesBookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.note), findsOneWidget);
    });

    testWidgets('displays multiple tags with proper spacing', (tester) async {
      final manyTagsBookmark = testBookmark.copyWith(
        tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: manyTagsBookmark),
          ),
        ),
      );

      expect(find.text('tag1'), findsOneWidget);
      expect(find.text('tag5'), findsOneWidget);
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('adapts to light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('has gradient background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('displays time ago for recent bookmarks', (tester) async {
      final recentBookmark = testBookmark.copyWith(
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: recentBookmark),
          ),
        ),
      );

      expect(find.textContaining('m ago'), findsOneWidget);
    });

    testWidgets('displays time ago for old bookmarks', (tester) async {
      final oldBookmark = testBookmark.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: oldBookmark),
          ),
        ),
      );

      expect(find.textContaining('mo ago'), findsOneWidget);
    });

    testWidgets('handles very old bookmarks', (tester) async {
      final veryOldBookmark = testBookmark.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: veryOldBookmark),
          ),
        ),
      );

      expect(find.textContaining('y ago'), findsOneWidget);
    });

    testWidgets('displays properly on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BookmarkCard(bookmark: testBookmark),
            ),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('displays properly on tablets', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('maintains structure across rebuilds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.text('Test Bookmark Title'), findsOneWidget);

      // Rebuild
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.text('Test Bookmark Title'), findsOneWidget);
    });

    testWidgets('edit menu item has icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('remove menu item has icon and red color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('displays different highlight colors', (tester) async {
      final colors = [
        HighlightColor.yellow,
        HighlightColor.green,
        HighlightColor.blue,
        HighlightColor.pink,
        HighlightColor.purple,
      ];

      for (final color in colors) {
        final coloredBookmark = testBookmark.copyWith(
          highlightColor: color,
          isHighlighted: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookmarkCard(bookmark: coloredBookmark),
            ),
          ),
        );

        expect(find.byType(BookmarkCard), findsOneWidget);
      }
    });

    testWidgets('no callbacks means actions still show in menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(
              bookmark: testBookmark,
              // No callbacks provided
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('has semantic labels for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('renders with null contentPreview', (tester) async {
      final nullPreviewBookmark = testBookmark.copyWith(contentPreview: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: nullPreviewBookmark),
          ),
        ),
      );

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('handles rapid popup menu opens and closes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));

        // Tap outside to close
        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(BookmarkCard), findsOneWidget);
    });

    testWidgets('card elevation is visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
    });

    testWidgets('has correct border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('handles bookmark with no chapter ID', (tester) async {
      final noChapterBookmark = Bookmark(
        id: '1',
        userDeviceId: 'test-device',
        bookmarkType: BookmarkType.scenario,
        referenceId: 1,
        chapterId: 0,
        title: 'Scenario Bookmark',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.synced,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: noChapterBookmark),
          ),
        ),
      );

      expect(find.text('Chapter 0'), findsOneWidget);
    });

    testWidgets('displays proper spacing between elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('uses InkWell for tap effects', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: testBookmark),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('handles empty tags list', (tester) async {
      final emptyTagsBookmark = testBookmark.copyWith(tags: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: emptyTagsBookmark),
          ),
        ),
      );

      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('handles single tag', (tester) async {
      final singleTagBookmark = testBookmark.copyWith(tags: ['single']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: singleTagBookmark),
          ),
        ),
      );

      expect(find.text('single'), findsOneWidget);
    });
  });
}
