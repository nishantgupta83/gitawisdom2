// lib/screens/verse_list_view.dart
// Updated with consistent UI patterns and branding header

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../models/chapter.dart';
import '../models/verse.dart';
import '../services/service_locator.dart';
import '../main.dart';
import '../widgets/expandable_text.dart';

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

  @override
  void initState() {
    super.initState();
    _loadVersesAndChapter();
  }

  Future<void> _loadVersesAndChapter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
      
      setState(() {
        _verses = verses;
        _chapter = chapter;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load verses.';
        _isLoading = false;
      });
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
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          color: theme.colorScheme.surface,
                          shadowColor: theme.colorScheme.primary.withAlpha((0.12 * 255).toInt()),
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
                                // Verse text
                                Expanded(
                                  child: DefaultTextStyle(
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    child: ExpandableText(verse.description),
                                  ),
                                ),
                              ],
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 32,
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.home_filled,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 32,
                  onPressed: () {
                    // Use proper tab navigation to sync bottom navigation state
                    NavigationHelper.goToTab(0); // 0 = Home tab index
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
}

