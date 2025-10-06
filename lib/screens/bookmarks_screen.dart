// lib/screens/bookmarks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bookmark_service.dart';
import '../models/bookmark.dart';
import '../widgets/bookmark_card.dart';
import '../widgets/bookmark_filter_chip.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with TickerProviderStateMixin {
  BookmarkType? _selectedFilter;
  String _searchQuery = '';
  bool _showSearch = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: Consumer<BookmarkService>(
        builder: (context, bookmarkService, child) {
          if (bookmarkService.isLoading && bookmarkService.bookmarks.isEmpty) {
            return _buildLoadingState(theme);
          }

          if (bookmarkService.bookmarks.isEmpty) {
            return _buildEmptyState(theme);
          }

          return Column(
            children: [
              if (_showSearch) _buildSearchBar(theme),
              _buildFilterTabs(theme),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBookmarksList(bookmarkService, theme),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      title: Text(
        'My Bookmarks',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_showSearch ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_download),
                  SizedBox(width: 8),
                  Text('Export'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Clear All', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha:0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search bookmarks...',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha:0.6),
        indicatorColor: theme.colorScheme.primary,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Verses'),
          Tab(text: 'Chapters'),
          Tab(text: 'Scenarios'),
        ],
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _selectedFilter = null;
                break;
              case 1:
                _selectedFilter = BookmarkType.verse;
                break;
              case 2:
                _selectedFilter = BookmarkType.chapter;
                break;
              case 3:
                _selectedFilter = BookmarkType.scenario;
                break;
            }
          });
        },
      ),
    );
  }

  Widget _buildBookmarksList(BookmarkService bookmarkService, ThemeData theme) {
    List<Bookmark> bookmarks = bookmarkService.bookmarks;

    // Apply filters
    if (_selectedFilter != null) {
      bookmarks = bookmarks.where((b) => b.bookmarkType == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      bookmarks = bookmarkService.searchBookmarks(_searchQuery);
    }

    if (bookmarks.isEmpty) {
      return _buildNoResultsState(theme);
    }

    // Group bookmarks by date for better organization
    final groupedBookmarks = _groupBookmarksByDate(bookmarks);

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<BookmarkService>().forcSync();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groupedBookmarks.length,
        itemBuilder: (context, index) {
          final entry = groupedBookmarks.entries.elementAt(index);
          final date = entry.key;
          final dayBookmarks = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date, theme),
              ...dayBookmarks.map((bookmark) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BookmarkCard(
                  bookmark: bookmark,
                  onTap: () => _handleBookmarkTap(bookmark),
                  onRemove: () => _handleBookmarkRemove(bookmark),
                  onEdit: () => _handleBookmarkEdit(bookmark),
                ),
              )),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(String date, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        date,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading bookmarks...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha:0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookmarks Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start bookmarking verses, chapters, and scenarios to see them here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Content'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: theme.colorScheme.onSurface.withValues(alpha:0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No bookmarks match "$_searchQuery"'
                  : 'No bookmarks in this category',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods

  Map<String, List<Bookmark>> _groupBookmarksByDate(List<Bookmark> bookmarks) {
    final grouped = <String, List<Bookmark>>{};
    final now = DateTime.now();

    for (final bookmark in bookmarks) {
      final date = bookmark.createdAt;
      String key;

      if (_isSameDay(date, now)) {
        key = 'Today';
      } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
        key = 'Yesterday';
      } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
        key = _getDayName(date.weekday);
      } else {
        key = '${date.day}/${date.month}/${date.year}';
      }

      grouped.putIfAbsent(key, () => []).add(bookmark);
    }

    return grouped;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  // Event handlers

  void _handleMenuAction(String action) async {
    final bookmarkService = context.read<BookmarkService>();

    switch (action) {
      case 'refresh':
        await bookmarkService.forcSync();
        break;
      case 'export':
        _showExportDialog();
        break;
      case 'clear':
        _showClearConfirmDialog();
        break;
    }
  }

  void _handleBookmarkTap(Bookmark bookmark) {
    // Navigate to the original content based on bookmark type
    switch (bookmark.bookmarkType) {
      case BookmarkType.verse:
        _navigateToVerse(bookmark);
        break;
      case BookmarkType.chapter:
        _navigateToChapter(bookmark);
        break;
      case BookmarkType.scenario:
        _navigateToScenario(bookmark);
        break;
    }
  }

  void _handleBookmarkRemove(Bookmark bookmark) async {
    final confirmed = await _showRemoveConfirmDialog(bookmark);
    if (confirmed == true) {
      await context.read<BookmarkService>().removeBookmark(bookmark.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${bookmark.title} removed from bookmarks'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
      }
    }
  }

  void _handleBookmarkEdit(Bookmark bookmark) {
    // TODO: Show edit dialog for notes and tags
    _showEditDialog(bookmark);
  }

  // Navigation methods

  void _navigateToVerse(Bookmark bookmark) {
    Navigator.of(context).pushNamed(
      '/verse_detail',
      arguments: {
        'chapterId': bookmark.chapterId,
        'verseId': bookmark.referenceId,
      },
    );
  }

  void _navigateToChapter(Bookmark bookmark) {
    Navigator.of(context).pushNamed(
      '/chapters_detail_view',
      arguments: bookmark.chapterId,
    );
  }

  void _navigateToScenario(Bookmark bookmark) {
    Navigator.of(context).pushNamed(
      '/scenario_detail',
      arguments: bookmark.referenceId,
    );
  }

  // Dialog methods

  Future<bool?> _showRemoveConfirmDialog(Bookmark bookmark) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bookmark'),
        content: Text('Remove "${bookmark.title}" from bookmarks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks'),
        content: const Text(
          'This will permanently remove all bookmarks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<BookmarkService>().clearAllBookmarks();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final bookmarkService = context.read<BookmarkService>();
    final exportData = bookmarkService.exportBookmarks();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Bookmarks'),
        content: Text(
          'Export ${exportData['totalCount']} bookmarks as JSON backup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement export functionality
              Navigator.of(context).pop();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Bookmark bookmark) {
    // TODO: Implement edit dialog
  }
}