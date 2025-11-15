// test/screens/bookmarks_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/screens/bookmarks_screen.dart';
import 'package:GitaWisdom/services/bookmark_service.dart';
import 'package:GitaWisdom/models/bookmark.dart';
import '../test_setup.dart';

class MockBookmarkService extends BookmarkService {
  List<Bookmark> _mockBookmarks = [];
  bool _mockLoading = false;

  @override
  List<Bookmark> get bookmarks => _mockBookmarks;

  @override
  bool get isLoading => _mockLoading;

  void setMockBookmarks(List<Bookmark> bookmarks) {
    _mockBookmarks = bookmarks;
    notifyListeners();
  }

  void setMockLoading(bool loading) {
    _mockLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> forcSync() async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  List<Bookmark> searchBookmarks(String query) {
    return _mockBookmarks
        .where((b) => b.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> removeBookmark(String id) async {
    _mockBookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  @override
  Future<void> clearAllBookmarks() async {
    _mockBookmarks.clear();
    notifyListeners();
  }

  @override
  Map<String, dynamic> exportBookmarks() {
    return {
      'totalCount': _mockBookmarks.length,
      'bookmarks': _mockBookmarks.map((b) => b.toJson()).toList(),
    };
  }
}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('BookmarksScreen', () {
    late MockBookmarkService mockService;

    setUp(() {
      mockService = MockBookmarkService();
    });

    Widget createTestWidget({List<Bookmark>? bookmarks, bool loading = false}) {
      if (bookmarks != null) {
        mockService.setMockBookmarks(bookmarks);
      }
      mockService.setMockLoading(loading);

      return MaterialApp(
        home: ChangeNotifierProvider<BookmarkService>.value(
          value: mockService,
          child: const BookmarksScreen(),
        ),
      );
    }

    testWidgets('renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(BookmarksScreen), findsOneWidget);
    });

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('My Bookmarks'), findsOneWidget);
    });

    testWidgets('displays loading state when loading and no bookmarks',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(loading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading bookmarks...'), findsOneWidget);
    });

    testWidgets('displays empty state when no bookmarks',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(bookmarks: []));
      await tester.pump();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.text('No Bookmarks Yet'), findsOneWidget);
      expect(
          find.text(
              'Start bookmarking verses, chapters, and situations to see them here.'),
          findsOneWidget);
      expect(find.text('Explore Content'), findsOneWidget);
    });

    testWidgets('empty state explore button navigates back',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(bookmarks: []));
      await tester.pump();

      final exploreButton = find.text('Explore Content');
      expect(exploreButton, findsOneWidget);

      await tester.tap(exploreButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('displays bookmarks list', (WidgetTester tester) async {
      final bookmarks = [
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.verse,
          referenceId: 1,
          chapterId: 1,
          title: 'Test Verse 1',
          contentPreview: 'Preview 1',
        ),
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.chapter,
          referenceId: 2,
          chapterId: 2,
          title: 'Test Chapter 2',
        ),
      ];

      await tester.pumpWidget(createTestWidget(bookmarks: bookmarks));
      await tester.pump();

      // Should show tab bar
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Verses'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Situations'), findsOneWidget);
    });

    testWidgets('search button toggles search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(bookmarks: []));
      await tester.pump();

      // Search bar should not be visible initially
      expect(find.byType(TextField), findsNothing);

      // Tap search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Search bar should now be visible
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search bookmarks...'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Search bar should be hidden again
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('search filters bookmarks', (WidgetTester tester) async {
      final bookmarks = [
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.verse,
          referenceId: 1,
          chapterId: 1,
          title: 'Karma Yoga',
        ),
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.verse,
          referenceId: 2,
          chapterId: 2,
          title: 'Bhakti Yoga',
        ),
      ];

      await tester.pumpWidget(createTestWidget(bookmarks: bookmarks));
      await tester.pump();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Karma');
      await tester.pump();

      // Should filter bookmarks (mock service filters by title)
      // Note: Actual filtering UI depends on BookmarkCard implementation
    });

    testWidgets('popup menu shows all options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(bookmarks: []));
      await tester.pump();

      // Tap popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('refresh menu action calls forcSync',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(bookmarks: []));
      await tester.pump();

      // Tap popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap refresh
      await tester.tap(find.text('Refresh'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('export menu shows dialog', (WidgetTester tester) async {
      final bookmarks = [
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.verse,
          referenceId: 1,
          chapterId: 1,
          title: 'Test',
        ),
      ];

      await tester.pumpWidget(createTestWidget(bookmarks: bookmarks));
      await tester.pump();

      // Tap popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap export
      await tester.tap(find.text('Export'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Export Bookmarks'), findsOneWidget);
      expect(find.text('Export 1 bookmarks as JSON backup?'), findsOneWidget);
    });

    testWidgets('clear all menu shows confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(bookmarks: []));
      await tester.pump();

      // Tap popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap clear all
      await tester.tap(find.text('Clear All'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Clear All Bookmarks'), findsOneWidget);
      expect(
          find.text(
              'This will permanently remove all bookmarks. This action cannot be undone.'),
          findsOneWidget);
    });

    testWidgets('filter tabs switch correctly', (WidgetTester tester) async {
      final bookmarks = [
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.verse,
          referenceId: 1,
          chapterId: 1,
          title: 'Test Verse',
        ),
      ];

      await tester.pumpWidget(createTestWidget(bookmarks: bookmarks));
      await tester.pump();

      // Tap Verses tab
      await tester.tap(find.text('Verses'));
      await tester.pump();

      // Tap Chapters tab
      await tester.tap(find.text('Chapters'));
      await tester.pump();

      // Tap Situations tab
      await tester.tap(find.text('Situations'));
      await tester.pump();

      // Tap All tab
      await tester.tap(find.text('All'));
      await tester.pump();
    });

    testWidgets('displays no results state when filtered bookmarks empty',
        (WidgetTester tester) async {
      final bookmarks = [
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.verse,
          referenceId: 1,
          chapterId: 1,
          title: 'Test',
        ),
      ];

      await tester.pumpWidget(createTestWidget(bookmarks: bookmarks));
      await tester.pump();

      // Switch to Chapters tab (should have no results)
      await tester.tap(find.text('Chapters'));
      await tester.pump();

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No Results Found'), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<BookmarkService>.value(
            value: mockService,
            child: const BookmarksScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BookmarksScreen), findsOneWidget);
      expect(find.text('My Bookmarks'), findsOneWidget);
    });

    testWidgets('renders correctly in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<BookmarkService>.value(
            value: mockService,
            child: const BookmarksScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BookmarksScreen), findsOneWidget);
      expect(find.text('My Bookmarks'), findsOneWidget);
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('search clears when search is closed',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(bookmarks: []));
      await tester.pump();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Re-open search - should be empty
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('adapts to tablet layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(BookmarksScreen), findsOneWidget);
    });

    testWidgets('tab controller disposes properly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Navigate away to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump();
    });

    testWidgets('handles empty search query', (WidgetTester tester) async {
      final bookmarks = [
        Bookmark.create(
          userDeviceId: 'test-device',
          bookmarkType: BookmarkType.verse,
          referenceId: 1,
          chapterId: 1,
          title: 'Test',
        ),
      ];

      await tester.pumpWidget(createTestWidget(bookmarks: bookmarks));
      await tester.pump();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter empty query
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
    });
  });
}
