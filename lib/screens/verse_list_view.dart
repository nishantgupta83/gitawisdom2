// lib/screens/verse_list_view.dart
// Updated with consistent UI patterns and branding header

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../models/chapter.dart';
import '../models/verse.dart';
import '../services/service_locator.dart';
// Bookmark functionality removed
// import '../services/bookmark_service.dart';
// import '../models/bookmark.dart';
import '../widgets/app_background.dart';
import '../core/navigation/navigation_service.dart';
import '../widgets/share_card_widget.dart';
// Audio player removed for Apple App Store compliance
// import '../widgets/verse_audio_player.dart';

class VerseListView extends StatefulWidget {
  /// The ID of the chapter whose verses we're displaying.
  final int chapterId;

  const VerseListView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _VerseListViewState createState() => _VerseListViewState();
}

class _VerseListViewState extends State<VerseListView> {
  late final _service = ServiceLocator.instance.enhancedSupabaseService;

  Chapter? _chapter;
  List<Verse> _verses = [];
  bool _isLoading = true;
  String? _errorMessage;
  late DateTime _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _loadVersesAndChapter();
  }
  
  @override
  void dispose() {
    // Track session time before leaving
    _trackSessionTime();
    super.dispose();
  }

  Future<void> _loadVersesAndChapter() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Track chapter started - defer to prevent setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _trackChapterStarted();
      }
    });
    try {
      // Permanent caching for verses since they never change
      final versesBoxName = 'verses_chapter_${widget.chapterId}';
      final chapterBoxName = 'chapter_${widget.chapterId}';

      // Open cache boxes for permanent storage
      if (!Hive.isBoxOpen(versesBoxName)) {
        await Hive.openBox<Verse>(versesBoxName);
      }
      if (!Hive.isBoxOpen(chapterBoxName)) {
        await Hive.openBox<Chapter>(chapterBoxName);
      }

      final versesCache = Hive.box<Verse>(versesBoxName);
      final chapterCache = Hive.box<Chapter>(chapterBoxName);

      // Check permanent cache first
      List<Verse> verses;
      Chapter? chapter;

      if (versesCache.isNotEmpty && chapterCache.isNotEmpty) {
        verses = versesCache.values.toList();
        chapter = chapterCache.values.first;
        debugPrint('📖 Using permanently cached verses for chapter ${widget.chapterId} (${verses.length} verses)');
      } else {
        debugPrint('🎯 Fetching fresh verses for chapter ${widget.chapterId} for permanent cache');

        // Fetch fresh data
        verses = await _service.fetchVersesByChapter(widget.chapterId);
        chapter = await _service.fetchChapterById(widget.chapterId);

        // If fetch succeeded, cache the results
        if (verses.isNotEmpty) {
          await versesCache.clear();
          for (int i = 0; i < verses.length; i++) {
            await versesCache.put(i, verses[i]);
          }

          if (chapter != null) {
            await chapterCache.clear();
            await chapterCache.put(0, chapter);
          }

          debugPrint('✅ Permanently cached ${verses.length} verses for chapter ${widget.chapterId}');
        } else {
          // Fetch failed (likely no internet) - show friendly message
          debugPrint('⚠️ Could not fetch verses for chapter ${widget.chapterId} (no internet?)');
          if (mounted) {
            setState(() {
              _errorMessage = 'Verses require internet connection to load for the first time.\nPlease try again when connected.';
              _isLoading = false;
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _verses = verses;
          _chapter = chapter;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load verses. Please check your internet connection and try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Unified gradient background
          AppBackground(isDark: isDark),

          // Scrollable content area that goes under the header
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  // Floating header card
                  if (_chapter != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha:0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _chapter!.title ?? 'CHAPTER VERSES',
                            style: GoogleFonts.poiretOne(
                              fontSize: MediaQuery.of(context).textScaler.scale(26),
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 1.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 80,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha:0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chapter ${widget.chapterId} verses from Bhagavad Gita',
                            style: GoogleFonts.poppins(
                              fontSize: MediaQuery.of(context).textScaler.scale(14),
                              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  // Verse list or status
                  if (_isLoading) ...[
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else if (_errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.error,
                                fontSize: MediaQuery.of(context).textScaler.scale(16),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadVersesAndChapter,
                              icon: const Icon(Icons.refresh),
                              label: Text('Retry', style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_verses.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No verses available.',
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                            fontSize: MediaQuery.of(context).textScaler.scale(16),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ] else ...[
                    for (var verse in _verses)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: theme.brightness == Brightness.dark 
                                ? [
                                    theme.colorScheme.surface,
                                    theme.colorScheme.primaryContainer.withValues(alpha:0.4),
                                  ]
                                : [
                                    theme.colorScheme.surface,
                                    theme.colorScheme.primaryContainer,
                                  ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.brightness == Brightness.dark
                                  ? Colors.black.withValues(alpha:0.4)
                                  : Colors.deepPurple.withValues(alpha:0.15),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.primary.withValues(alpha:0.15)
                                  : Colors.indigo.withValues(alpha:0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => _trackVerseRead(verse),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                color: Colors.transparent,
                                child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Top row with verse number badge and share button
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Verse number badge
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.primary.withValues(alpha:0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.withValues(alpha:0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${verse.verseId}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).textScaler.scale(18),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    // Share Button moved to top right
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => _showShareDialog(verse),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 13,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.share,
                                                size: 22,
                                                color: theme.colorScheme.onSurface.withValues(alpha:0.87),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Share',
                                                style: GoogleFonts.poppins(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(13),
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.colorScheme.onSurface.withValues(alpha:0.87),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Verse text
                                Text(
                                  verse.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: MediaQuery.of(context).textScaler.scale(15),
                                    color: theme.colorScheme.onSurface.withValues(alpha:0.9),
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                            ),
                          ),
                    ),
                  ],

                const SizedBox(height: 16),
              ],
            ),
          ),
          ),

          // Floating Back Button
          Positioned(
            top: 50,
            right: 84,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: theme.colorScheme.surface,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
                splashRadius: 30,
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
            ),
          ),

          // Floating Home Button
          Positioned(
            top: 50,
            right: 24,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: theme.colorScheme.surface,
              child: IconButton(
                icon: Icon(
                  Icons.home_filled,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
                splashRadius: 30,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  NavigationService.instance.goToTab(0);
                },
                tooltip: 'Home',
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Track verse read - logging only (progress tracking removed for Apple compliance)
  Future<void> _trackVerseRead(Verse verse) async {
    // Progress tracking removed for Apple compliance
    // Only logs verse interaction for debugging
    debugPrint('Verse read: ${verse.verseId} in chapter ${widget.chapterId}');
  }
  
  /// Track chapter started
  Future<void> _trackChapterStarted() async {
    try {
      // Progress tracking removed for Apple compliance
      debugPrint('Chapter ${widget.chapterId} started');
    } catch (e) {
      debugPrint('Failed to track chapter started: $e');
    }
  }
  
  /// Track session time spent reading
  Future<void> _trackSessionTime() async {
    try {
      final sessionDuration = DateTime.now().difference(_sessionStartTime);
      final sessionMinutes = sessionDuration.inMinutes;
      
      if (sessionMinutes > 0) { // Only track if user spent at least a minute
        // Progress tracking removed for Apple compliance
        debugPrint('Session time: $sessionMinutes minutes for chapter ${widget.chapterId}');
      }
    } catch (e) {
      debugPrint('Failed to track session time: $e');
    }
  }

  // Bookmark functionality removed - not implemented
  // Future<void> _toggleVerseBookmark(Verse verse, bool isCurrentlyBookmarked) async { ... }

  /// Show share dialog for a verse
  void _showShareDialog(Verse verse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareCardWidget(
        verse: verse,
        onShared: () {
          // Track sharing action
          _trackVerseShared(verse);
        },
      ),
    );
  }

  /// Track verse shared for analytics
  Future<void> _trackVerseShared(Verse verse) async {
    try {
      // You can add analytics tracking here if needed
      debugPrint('📤 Verse ${verse.verseId} shared by user');
    } catch (e) {
      debugPrint('Failed to track verse share: $e');
    }
  }
}

