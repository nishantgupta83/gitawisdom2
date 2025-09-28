// lib/screens/verse_list_view.dart
// Updated with consistent UI patterns and branding header

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/chapter.dart';
import '../models/verse.dart';
import '../services/service_locator.dart';
import '../services/bookmark_service.dart';
// import '../services/progress_service.dart'; // Removed for Apple compliance
import '../models/bookmark.dart';
import '../core/navigation/navigation_service.dart';
import '../widgets/expandable_text.dart';
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
        
        // Permanently cache the results
        await versesCache.clear();
        for (int i = 0; i < verses.length; i++) {
          await versesCache.put(i, verses[i]);
        }
        
        if (chapter != null) {
          await chapterCache.clear();
          await chapterCache.put(0, chapter);
        }
        
        debugPrint('✅ Permanently cached ${verses.length} verses for chapter ${widget.chapterId}');
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
          _errorMessage = 'Failed to load verses.';
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
          // Background image with dark overlay for dark mode
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: isDark ? Colors.black.withAlpha((0.32 * 255).toInt()) : null,
              colorBlendMode: isDark ? BlendMode.darken : null,
            ),
          ),
          
          
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
                        color: theme.colorScheme.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                              fontSize: 26,
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
                                  theme.colorScheme.primary.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chapter ${widget.chapterId} verses from Bhagavad Gita',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.error,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
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
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 16,
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
                                    theme.colorScheme.primaryContainer.withOpacity(0.4),
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
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.deepPurple.withOpacity(0.15),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.primary.withOpacity(0.15)
                                  : Colors.indigo.withOpacity(0.1),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        theme.colorScheme.primary.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(0.3),
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
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Verse text and bookmark
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        verse.description,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Audio player removed for Apple App Store compliance
                                      // VerseAudioPlayer(
                                      //   verse: verse,
                                      //   chapterId: widget.chapterId,
                                      // ),
                                      const SizedBox(height: 8),
                                      
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Share Button
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () => _showShareDialog(verse),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.share,
                                                      size: 16,
                                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Share',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          
                                          // Bookmark Button
                                          Consumer<BookmarkService>(
                                            builder: (context, bookmarkService, child) {
                                              final isBookmarked = bookmarkService.isBookmarked(
                                                BookmarkType.verse, 
                                                verse.verseId,
                                              );
                                              
                                              return Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(20),
                                                  onTap: () => _toggleVerseBookmark(verse, isBookmarked),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isBookmarked
                                                          ? theme.colorScheme.primary
                                                          : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          isBookmarked 
                                                              ? Icons.bookmark 
                                                              : Icons.bookmark_border,
                                                          size: 16,
                                                          color: isBookmarked
                                                              ? theme.colorScheme.onPrimary
                                                              : theme.colorScheme.onSurface.withOpacity(0.7),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          isBookmarked ? 'Saved' : 'Save',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                            color: isBookmarked
                                                                ? theme.colorScheme.onPrimary
                                                                : theme.colorScheme.onSurface.withOpacity(0.7),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
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
            top: 26,
            right: 84,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent.withOpacity(0.9),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
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
          ),
          
          // Floating Home Button
          Positioned(
            top: 26,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent.withOpacity(0.9),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
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
                    // Use proper tab navigation to sync bottom navigation state
                    NavigationService.instance.goToTab(0); // 0 = Home tab index
                  },
                  tooltip: 'Home',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Track verse read for progress analytics
  Future<void> _trackVerseRead(Verse verse) async {
    // Progress tracking removed for Apple compliance

    try {
      // Progress tracking removed for Apple compliance
      debugPrint('Verse read: ${verse.verseId} in chapter ${widget.chapterId}');
      
      // Optional: Show subtle feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text('Verse ${verse.verseId} progress tracked'),
              ],
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
      }
    } catch (e) {
      // Silent failure for progress tracking - don't disrupt user experience
      if (mounted) {
        debugPrint('Failed to track verse read: $e');
      }
    }
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

  /// Toggle bookmark for a verse
  Future<void> _toggleVerseBookmark(Verse verse, bool isCurrentlyBookmarked) async {
    final bookmarkService = context.read<BookmarkService>();
    
    if (isCurrentlyBookmarked) {
      final bookmark = bookmarkService.getBookmark(BookmarkType.verse, verse.verseId);
      if (bookmark != null) {
        final success = await bookmarkService.removeBookmark(bookmark.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verse ${verse.verseId} removed from bookmarks'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      final success = await bookmarkService.bookmarkVerse(verse, widget.chapterId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verse ${verse.verseId} saved to bookmarks'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'VIEW',
              onPressed: () => Navigator.of(context).pushNamed('/bookmarks'),
            ),
          ),
        );
      }
    }
  }

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

