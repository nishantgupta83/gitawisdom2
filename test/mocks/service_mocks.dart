// test/mocks/service_mocks.dart
// Comprehensive mocks for all GitaWisdom services

import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:GitaWisdom/models/journal_entry.dart';
import 'package:GitaWisdom/models/bookmark.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/simple_meditation.dart';
import 'package:GitaWisdom/models/search_result.dart';

// ==================== Hive Mocks ====================

/// Mock Hive Box for testing local storage
class MockBox<T> extends Mock implements Box<T> {
  final Map<dynamic, T> _storage = {};

  @override
  T? get(dynamic key, {T? defaultValue}) {
    return _storage.containsKey(key) ? _storage[key] : defaultValue;
  }

  @override
  Future<void> put(dynamic key, T value) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  bool containsKey(dynamic key) => _storage.containsKey(key);

  @override
  Iterable<T> get values => _storage.values;

  @override
  Iterable get keys => _storage.keys;

  @override
  int get length => _storage.length;

  @override
  bool get isEmpty => _storage.isEmpty;

  @override
  bool get isNotEmpty => _storage.isNotEmpty;

  @override
  bool get isOpen => true;

  @override
  String get name => 'mock_box';

  @override
  Future<int> add(T value) async {
    final key = _storage.length;
    _storage[key] = value;
    return key;
  }

  @override
  T? getAt(int index) {
    final keys = _storage.keys.toList();
    if (index >= 0 && index < keys.length) {
      return _storage[keys[index]];
    }
    return null;
  }

  @override
  Future<void> putAt(int index, T value) async {
    final keys = _storage.keys.toList();
    if (index >= 0 && index < keys.length) {
      _storage[keys[index]] = value;
    }
  }

  @override
  Future<void> deleteAt(int index) async {
    final keys = _storage.keys.toList();
    if (index >= 0 && index < keys.length) {
      _storage.remove(keys[index]);
    }
  }

  @override
  Future<void> close() async {
    // Mock close operation
  }

  @override
  Future<void> compact() async {
    // Mock compact operation
  }

  @override
  Future<int> addAll(Iterable<T> values) async {
    int count = 0;
    for (final value in values) {
      await add(value);
      count++;
    }
    return count;
  }

  @override
  Future<void> putAll(Map<dynamic, T> entries) async {
    _storage.addAll(entries);
  }

  @override
  Future<void> deleteAll(Iterable keys) async {
    for (final key in keys) {
      _storage.remove(key);
    }
  }

  // Helper method to inspect storage for testing
  Map<dynamic, T> get mockStorage => Map.from(_storage);
}

// ==================== Audio Player Mocks ====================

/// Mock AudioPlayer for testing background music
class MockAudioPlayer extends Mock implements AudioPlayer {
  bool _isPlaying = false;
  double _volume = 1.0;
  LoopMode _loopMode = LoopMode.off;
  String? _currentAsset;

  @override
  Future<void> setAsset(String asset, {bool preload = true}) async {
    _currentAsset = asset;
    return super.noSuchMethod(
      Invocation.method(#setAsset, [asset], {#preload: preload}),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    return super.noSuchMethod(
      Invocation.method(#play, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    return super.noSuchMethod(
      Invocation.method(#pause, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    return super.noSuchMethod(
      Invocation.method(#stop, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    return super.noSuchMethod(
      Invocation.method(#setVolume, [volume]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    _loopMode = mode;
    return super.noSuchMethod(
      Invocation.method(#setLoopMode, [mode]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Future<void> dispose() async {
    _isPlaying = false;
    return super.noSuchMethod(
      Invocation.method(#dispose, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Stream<bool> get playingStream => Stream.value(_isPlaying);

  @override
  Stream<PlayerState> get playerStateStream => Stream.value(
    PlayerState(_isPlaying, ProcessingState.ready),
  );

  // Helper getters for testing
  bool get mockIsPlaying => _isPlaying;
  double get mockVolume => _volume;
  LoopMode get mockLoopMode => _loopMode;
  String? get mockCurrentAsset => _currentAsset;
}

/// Mock AudioSession for testing audio configuration
class MockAudioSession extends Mock implements AudioSession {
  @override
  Future<bool> setActive(
    bool active, {
    AVAudioSessionSetActiveOptions avAudioSessionSetActiveOptions =
        AVAudioSessionSetActiveOptions.none,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#setActive, [active], {
        #avAudioSessionSetActiveOptions: avAudioSessionSetActiveOptions,
      }),
      returnValue: Future.value(true),
      returnValueForMissingStub: Future.value(true),
    );
  }

  @override
  Future<void> configure(AudioSessionConfiguration configuration) async {
    return super.noSuchMethod(
      Invocation.method(#configure, [configuration]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }

  @override
  Stream<AudioInterruptionEvent> get interruptionEventStream =>
      Stream.empty();

  @override
  Stream<void> get becomingNoisyEventStream => Stream.empty();
}

// ==================== Settings Service Mock ====================

/// Mock SettingsService for testing
class MockSettingsService extends Mock implements ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'en';
  String _fontSize = 'small';
  bool _musicEnabled = true;
  bool _textShadowEnabled = false;
  double _backgroundOpacity = 1.0;
  DateTime? _lastCacheRefreshDate;

  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  String get language => _language;
  set language(String value) {
    _language = value;
    notifyListeners();
  }

  String get fontSize => _fontSize;
  set fontSize(String value) {
    _fontSize = value;
    notifyListeners();
  }

  bool get musicEnabled => _musicEnabled;
  set musicEnabled(bool value) {
    _musicEnabled = value;
    notifyListeners();
  }

  bool get textShadowEnabled => _textShadowEnabled;
  set textShadowEnabled(bool value) {
    _textShadowEnabled = value;
    notifyListeners();
  }

  double get backgroundOpacity => _backgroundOpacity;
  set backgroundOpacity(double value) {
    _backgroundOpacity = value;
    notifyListeners();
  }

  DateTime? get lastCacheRefreshDate => _lastCacheRefreshDate;
  void setLastCacheRefreshDate(DateTime date) {
    _lastCacheRefreshDate = date;
    notifyListeners();
  }

  bool get canRefreshCache {
    if (_lastCacheRefreshDate == null) return true;
    final daysSince = DateTime.now().difference(_lastCacheRefreshDate!).inDays;
    return daysSince >= 20;
  }

  int get daysUntilNextRefresh {
    if (_lastCacheRefreshDate == null) return 0;
    final daysSince = DateTime.now().difference(_lastCacheRefreshDate!).inDays;
    final remaining = 20 - daysSince;
    return remaining > 0 ? remaining : 0;
  }
}

// ==================== Journal Service Mock ====================

/// Mock JournalService for testing
class MockJournalService extends Mock {
  final List<JournalEntry> _entries = [];

  Future<List<JournalEntry>> fetchEntries() async {
    return Future.value(List.from(_entries));
  }

  Future<void> createEntry(JournalEntry entry) async {
    _entries.insert(0, entry);
  }

  Future<void> deleteEntry(String entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
  }

  List<JournalEntry> searchEntries(String query) {
    if (query.trim().isEmpty) return _entries;
    final searchLower = query.toLowerCase();
    return _entries.where((e) =>
      e.reflection.toLowerCase().contains(searchLower)
    ).toList();
  }

  int get totalEntries => _entries.length;

  double get averageRating {
    if (_entries.isEmpty) return 0.0;
    final validEntries = _entries.where((e) => e.rating > 0).toList();
    if (validEntries.isEmpty) return 0.0;
    return validEntries.map((e) => e.rating).reduce((a, b) => a + b) /
           validEntries.length;
  }

  Future<void> clearCache() async {
    _entries.clear();
  }

  // Helper method to add test entries
  void addMockEntry(JournalEntry entry) {
    _entries.add(entry);
  }
}

// ==================== Bookmark Service Mock ====================

/// Mock BookmarkService for testing
class MockBookmarkService extends Mock implements ChangeNotifier {
  final List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get bookmarksCount => _bookmarks.length;

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
    if (isBookmarked(bookmarkType, referenceId)) {
      _error = 'Already bookmarked';
      return false;
    }

    final bookmark = Bookmark.create(
      userDeviceId: 'test_device',
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

    _bookmarks.add(bookmark);
    notifyListeners();
    return true;
  }

  Future<bool> removeBookmark(String bookmarkId) async {
    _bookmarks.removeWhere((b) => b.id == bookmarkId);
    notifyListeners();
    return true;
  }

  bool isBookmarked(BookmarkType type, int referenceId) {
    return _bookmarks.any((b) =>
      b.bookmarkType == type && b.referenceId == referenceId
    );
  }

  Bookmark? getBookmark(BookmarkType type, int referenceId) {
    try {
      return _bookmarks.firstWhere((b) =>
        b.bookmarkType == type && b.referenceId == referenceId
      );
    } catch (e) {
      return null;
    }
  }

  List<Bookmark> getBookmarksByType(BookmarkType type) {
    return _bookmarks.where((b) => b.bookmarkType == type).toList();
  }

  // Helper method to add test bookmarks
  void addMockBookmark(Bookmark bookmark) {
    _bookmarks.add(bookmark);
  }
}

// ==================== Auth Service Mock ====================

/// Mock SimpleAuthService for testing
class MockSimpleAuthService extends Mock implements ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isGuest = false;
  String? _error;
  bool _isLoading = false;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated || _isGuest;
  bool get isAnonymous => _isGuest;
  String? get error => _error;
  bool get isLoading => _isLoading;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  String? get displayName {
    if (_userName != null && _userName!.isNotEmpty) return _userName;
    if (_userEmail != null && _userEmail!.isNotEmpty) {
      return _userEmail!.split('@').first;
    }
    return null;
  }

  Stream<bool> get authStateChanges => Stream.value(isAuthenticated);

  Future<bool> signInAnonymously() async {
    _isGuest = true;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isAuthenticated = true;
    _isGuest = false;
    _userEmail = email;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isAuthenticated = true;
    _isGuest = false;
    _userEmail = email;
    _userName = name.isNotEmpty ? name : null;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _isGuest = false;
    _userEmail = null;
    _userName = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods to set state for testing
  void setMockAuthState({
    bool authenticated = false,
    bool guest = false,
    String? email,
    String? name,
  }) {
    _isAuthenticated = authenticated;
    _isGuest = guest;
    _userEmail = email;
    _userName = name;
    notifyListeners();
  }
}

// ==================== Search Service Mock ====================

/// Mock SearchService for testing
class MockSearchService extends Mock {
  final List<SearchResult> _mockResults = [];

  Future<List<SearchResult>> search(String query, {
    SearchType? type,
    int? chapterId,
  }) async {
    if (query.trim().isEmpty) return [];

    final searchLower = query.toLowerCase();
    return _mockResults.where((result) {
      final matchesQuery = result.title.toLowerCase().contains(searchLower) ||
                          result.preview.toLowerCase().contains(searchLower);
      final matchesType = type == null || result.type == type;
      return matchesQuery && matchesType;
    }).toList();
  }

  Future<List<SearchResult>> getRecentSearches() async {
    return Future.value(_mockResults.take(5).toList());
  }

  Future<void> clearRecentSearches() async {
    _mockResults.clear();
  }

  // Helper method to add test results
  void addMockResult(SearchResult result) {
    _mockResults.add(result);
  }
}

// ==================== Scenario Service Mock ====================

/// Mock ScenarioService for testing
class MockScenarioService extends Mock {
  final List<Scenario> _scenarios = [];

  Future<List<Scenario>> getAllScenarios() async {
    return Future.value(List.from(_scenarios));
  }

  Future<List<Scenario>> getScenariosByChapter(int chapterId) async {
    return Future.value(
      _scenarios.where((s) => s.chapter == chapterId).toList()
    );
  }

  Future<List<Scenario>> searchScenarios(String query) async {
    if (query.trim().isEmpty) return _scenarios;

    final searchLower = query.toLowerCase();
    return _scenarios.where((s) {
      return s.title.toLowerCase().contains(searchLower) ||
             s.description.toLowerCase().contains(searchLower) ||
             (s.tags?.any((t) => t.toLowerCase().contains(searchLower)) ?? false);
    }).toList();
  }

  // Helper method to add test scenarios
  void addMockScenario(Scenario scenario) {
    _scenarios.add(scenario);
  }
}

// ==================== Helper Functions ====================

/// Create a mock JournalEntry for testing
JournalEntry createMockJournalEntry({
  String? id,
  String reflection = 'Test reflection',
  int rating = 4,
  String tag = 'Gratitude',
  DateTime? dateCreated,
}) {
  return JournalEntry(
    id: id ?? 'test-entry-${DateTime.now().millisecondsSinceEpoch}',
    reflection: reflection,
    rating: rating,
    tag: tag,
    dateCreated: dateCreated ?? DateTime.now(),
  );
}

/// Create a mock Scenario for testing
Scenario createMockScenario({
  int chapter = 1,
  String title = 'Test Scenario',
  String description = 'Test description',
  String heartResponse = 'Heart response',
  String dutyResponse = 'Duty response',
  List<String>? tags,
  List<String>? actionSteps,
}) {
  return Scenario(
    chapter: chapter,
    title: title,
    description: description,
    heartResponse: heartResponse,
    dutyResponse: dutyResponse,
    tags: tags ?? ['test'],
    actionSteps: actionSteps ?? ['Step 1', 'Step 2'],
  );
}

/// Create a mock Chapter for testing
Chapter createMockChapter({
  int chapterId = 1,
  String title = 'Test Chapter',
  String? summary,
  String? keyMessage,
  int? verseCount,
}) {
  return Chapter(
    chapterId: chapterId,
    title: title,
    summary: summary ?? 'Test summary',
    keyMessage: keyMessage ?? 'Test key message',
    verseCount: verseCount ?? 10,
  );
}

/// Create a mock Verse for testing
Verse createMockVerse({
  int verseId = 1,
  int chapterId = 1,
  String? preview,
  String? translation,
  String? explanation,
}) {
  return Verse(
    verseId: verseId,
    chapterId: chapterId,
    preview: preview ?? 'Test verse preview',
    translation: translation ?? 'Test translation',
    explanation: explanation ?? 'Test explanation',
  );
}

/// Create a mock SearchResult for testing
SearchResult createMockSearchResult({
  SearchType type = SearchType.scenario,
  String title = 'Test Result',
  String preview = 'Test preview',
  int chapterId = 1,
  int? referenceId,
}) {
  return SearchResult(
    type: type,
    title: title,
    preview: preview,
    chapterId: chapterId,
    referenceId: referenceId ?? 1,
  );
}
