// lib/screens/verse_list_view.dart
// Updated with consistent UI patterns and branding header

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      final verses = await _service.fetchVersesByChapter(widget.chapterId);
      final chapter = await _service.fetchChapterById(widget.chapterId);
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
          
          // Sticky header that stays fixed at top
          if (_chapter != null)
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
                decoration: BoxDecoration(
                  // Semi-transparent background for glassmorphism effect
                  color: theme.colorScheme.surface.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  // Subtle border at bottom
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
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
                    // Underline bar
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
            ),
          
          // Scrollable content area that goes under the header
          SafeArea(
            child: Container(
              margin: EdgeInsets.only(top: _chapter != null ? 140 : 20), // Space for sticky header
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  // Header is now sticky, content starts here

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

