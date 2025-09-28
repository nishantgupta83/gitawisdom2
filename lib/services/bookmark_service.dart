// lib/services/bookmark_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bookmark.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import '../models/scenario.dart';

/// Service for managing bookmarks with offline-first approach and cloud sync
class BookmarkService extends ChangeNotifier {
  static const String _boxName = 'bookmarks';
  static const String _tableBookmarks = 'user_bookmarks';
  
  Box<Bookmark>? _bookmarksBox;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _error;
  String _userDeviceId = 'default_device'; // Will be set from device info

  // Getters
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get bookmarksCount => _bookmarks.length;
  
  /// Initialize the bookmark service
  Future<void> initialize(String deviceId) async {
    try {
      _userDeviceId = deviceId;
      _bookmarksBox = await Hive.openBox<Bookmark>(_boxName);
      await _loadBookmarksFromLocal();
      await _syncWithCloud();
    } catch (e) {
      _error = 'Failed to initialize bookmarks: $e';
      if (kDebugMode) print('BookmarkService initialization error: $e');
      notifyListeners();
    }
  }

  /// Load bookmarks from local storage
  Future<void> _loadBookmarksFromLocal() async {
    if (_bookmarksBox == null) return;
    
    _bookmarks = _bookmarksBox!.values.toList();
    _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Latest first
    notifyListeners();
  }

  /// Sync bookmarks with cloud (bi-directional)
  Future<void> _syncWithCloud() async {
    try {
      // Upload pending local bookmarks to cloud
      await _uploadPendingBookmarks();
      
      // Download cloud bookmarks and merge with local
      await _downloadCloudBookmarks();
      
      _error = null;
    } catch (e) {
      _error = 'Sync failed: $e';
      if (kDebugMode) print('Bookmark sync error: $e');
    }
    notifyListeners();
  }

  /// Upload pending bookmarks to cloud
  Future<void> _uploadPendingBookmarks() async {
    final pendingBookmarks = _bookmarks.where((b) => b.needsSync).toList();
    
    for (final bookmark in pendingBookmarks) {
      try {
        await _supabase.from(_tableBookmarks).upsert(bookmark.toJson());
        
        // Update local bookmark as synced
        final updatedBookmark = bookmark.copyWith(syncStatus: SyncStatus.synced);
        await _updateBookmarkLocal(updatedBookmark);
      } catch (e) {
        if (kDebugMode) print('Failed to upload bookmark ${bookmark.id}: $e');
      }
    }
  }

  /// Download bookmarks from cloud
  Future<void> _downloadCloudBookmarks() async {
    try {
      final response = await _supabase
          .from(_tableBookmarks)
          .select()
          .eq('user_device_id', _userDeviceId);
      
      for (final json in response) {
        final cloudBookmark = Bookmark.fromJson(json);
        final existingBookmark = _bookmarks
            .where((b) => b.id == cloudBookmark.id)
            .firstOrNull;
        
        if (existingBookmark == null || 
            existingBookmark.updatedAt.isBefore(cloudBookmark.updatedAt)) {
          await _updateBookmarkLocal(cloudBookmark);
        }
      }
      
      await _loadBookmarksFromLocal();
    } catch (e) {
      if (kDebugMode) print('Failed to download cloud bookmarks: $e');
    }
  }

  /// Add a new bookmark
  Future<bool> addBookmark({
    required BookmarkType bookmarkType,
    required int referenceId,
    required int chapterId,
    required String title,
    String? contentPreview,
    String? notes,
    List<String> tags = const [],
    bool isHighlighted = false,
    HighlightColor highlightColor = HighlightColor.yellow,
  }) async {
    try {
      _setLoading(true);
      
      // Check if bookmark already exists
      if (isBookmarked(bookmarkType, referenceId)) {
        _error = 'Already bookmarked';
        _setLoading(false);
        return false;
      }
      
      final bookmark = Bookmark.create(
        userDeviceId: _userDeviceId,
        bookmarkType: bookmarkType,
        referenceId: referenceId,
        chapterId: chapterId,
        title: title,
        contentPreview: contentPreview,
        notes: notes,
        tags: tags,
        isHighlighted: isHighlighted,
        highlightColor: highlightColor,
      );
      
      // Save locally first
      await _bookmarksBox?.put(bookmark.id, bookmark);
      _bookmarks.add(bookmark);
      _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Try to sync to cloud
      _syncWithCloud(); // Don't await - background sync
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to add bookmark: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Remove a bookmark
  Future<bool> removeBookmark(String bookmarkId) async {
    try {
      _setLoading(true);
      
      // Remove from local storage
      await _bookmarksBox?.delete(bookmarkId);
      _bookmarks.removeWhere((b) => b.id == bookmarkId);
      
      // Remove from cloud
      try {
        await _supabase
            .from(_tableBookmarks)
            .delete()
            .eq('id', bookmarkId);
      } catch (e) {
        if (kDebugMode) print('Failed to remove bookmark from cloud: $e');
      }
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to remove bookmark: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Update bookmark notes and tags
  Future<bool> updateBookmark({
    required String bookmarkId,
    String? notes,
    List<String>? tags,
    bool? isHighlighted,
    HighlightColor? highlightColor,
  }) async {
    try {
      _setLoading(true);
      
      final existingBookmark = _bookmarks
          .where((b) => b.id == bookmarkId)
          .firstOrNull;
      
      if (existingBookmark == null) {
        _error = 'Bookmark not found';
        _setLoading(false);
        return false;
      }
      
      final updatedBookmark = existingBookmark.copyWith(
        notes: notes,
        tags: tags,
        isHighlighted: isHighlighted,
        highlightColor: highlightColor,
        syncStatus: SyncStatus.pending,
      );
      
      await _updateBookmarkLocal(updatedBookmark);
      _syncWithCloud(); // Background sync
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update bookmark: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Check if content is bookmarked
  bool isBookmarked(BookmarkType type, int referenceId) {
    return _bookmarks.any((b) => 
        b.bookmarkType == type && 
        b.referenceId == referenceId);
  }

  /// Get bookmark for specific content
  Bookmark? getBookmark(BookmarkType type, int referenceId) {
    try {
      return _bookmarks.firstWhere((b) => 
          b.bookmarkType == type && 
          b.referenceId == referenceId);
    } catch (e) {
      return null;
    }
  }

  /// Get bookmarks by type
  List<Bookmark> getBookmarksByType(BookmarkType type) {
    return _bookmarks.where((b) => b.bookmarkType == type).toList();
  }

  /// Get bookmarks by chapter
  List<Bookmark> getBookmarksByChapter(int chapterId) {
    return _bookmarks.where((b) => b.chapterId == chapterId).toList();
  }

  /// Get recent bookmarks (for widgets)
  List<Bookmark> getRecentBookmarks([int limit = 10]) {
    return _bookmarks.take(limit).toList();
  }

  /// Search bookmarks
  List<Bookmark> searchBookmarks(String query) {
    final lowerQuery = query.toLowerCase();
    return _bookmarks.where((bookmark) =>
        bookmark.title.toLowerCase().contains(lowerQuery) ||
        bookmark.contentPreview?.toLowerCase().contains(lowerQuery) == true ||
        bookmark.notes?.toLowerCase().contains(lowerQuery) == true ||
        bookmark.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  /// Get bookmarks grouped by chapter for organized display
  Map<int, List<Bookmark>> getBookmarksGroupedByChapter() {
    final grouped = <int, List<Bookmark>>{};
    for (final bookmark in _bookmarks) {
      grouped.putIfAbsent(bookmark.chapterId, () => []).add(bookmark);
    }
    return grouped;
  }

  /// Convenience methods for adding specific content types

  /// Add verse bookmark
  Future<bool> bookmarkVerse(Verse verse, int chapterId) async {
    return addBookmark(
      bookmarkType: BookmarkType.verse,
      referenceId: verse.verseId,
      chapterId: chapterId,
      title: 'Chapter $chapterId, Verse ${verse.verseId}',
      contentPreview: verse.preview,
    );
  }

  /// Add chapter bookmark
  Future<bool> bookmarkChapter(Chapter chapter) async {
    return addBookmark(
      bookmarkType: BookmarkType.chapter,
      referenceId: chapter.chapterId,
      chapterId: chapter.chapterId,
      title: chapter.title,
      contentPreview: chapter.summary?.substring(0, 100),
    );
  }

  /// Add scenario bookmark
  Future<bool> bookmarkScenario(Scenario scenario) async {
    return addBookmark(
      bookmarkType: BookmarkType.scenario,
      referenceId: scenario.hashCode, // Since scenario doesn't have an ID
      chapterId: scenario.chapter,
      title: scenario.title,
      contentPreview: scenario.description.length > 100 
          ? scenario.description.substring(0, 97) + '...'
          : scenario.description,
      tags: scenario.tags ?? [],
    );
  }

  /// Force sync with cloud (for user-initiated refresh)
  Future<void> forcSync() async {
    _setLoading(true);
    await _syncWithCloud();
    _setLoading(false);
  }

  /// Clear all bookmarks (with confirmation)
  Future<bool> clearAllBookmarks() async {
    try {
      _setLoading(true);
      
      // Clear local storage
      await _bookmarksBox?.clear();
      _bookmarks.clear();
      
      // Clear cloud storage
      try {
        await _supabase
            .from(_tableBookmarks)
            .delete()
            .eq('user_device_id', _userDeviceId);
      } catch (e) {
        if (kDebugMode) print('Failed to clear cloud bookmarks: $e');
      }
      
      _error = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to clear bookmarks: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Export bookmarks as JSON (for backup/sharing)
  Map<String, dynamic> exportBookmarks() {
    return {
      'bookmarks': _bookmarks.map((b) => b.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'totalCount': _bookmarks.length,
    };
  }

  /// Get bookmark statistics
  Map<String, int> getBookmarkStats() {
    final stats = <String, int>{
      'total': _bookmarks.length,
      'verses': 0,
      'chapters': 0,
      'scenarios': 0,
      'highlighted': 0,
    };
    
    for (final bookmark in _bookmarks) {
      stats[bookmark.bookmarkType.value] = 
          (stats[bookmark.bookmarkType.value] ?? 0) + 1;
      if (bookmark.isHighlighted) {
        stats['highlighted'] = stats['highlighted']! + 1;
      }
    }
    
    return stats;
  }

  // Private helper methods

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  Future<void> _updateBookmarkLocal(Bookmark bookmark) async {
    await _bookmarksBox?.put(bookmark.id, bookmark);
    
    final index = _bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (index >= 0) {
      _bookmarks[index] = bookmark;
    } else {
      _bookmarks.add(bookmark);
    }
    
    _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Dispose resources
  @override
  void dispose() {
    _bookmarksBox?.close();
    super.dispose();
  }
}