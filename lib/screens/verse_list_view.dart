// lib/screens/verse_list_view.dart
// WORKING AUG-1-2025 BEFORE UX CHANGES

/*
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/chapter.dart';
import '../models/verse.dart'; // ← import your Verse model

class VersesListView extends StatefulWidget {
  final int chapterId;

  const VersesListView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _VersesListViewState createState() => _VersesListViewState();
}

class _VersesListViewState extends State<VersesListView> {
  late Future<Chapter?> _chapterFuture;
  late Future<List<Verse>> _versesFuture;
  final SupabaseService _service = SupabaseService();

  @override
  void initState() {
    super.initState();
    _chapterFuture = _service.fetchChapterById(widget.chapterId);
    _versesFuture  = _service.fetchVersesByChapter(widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verses'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: FutureBuilder<Chapter?>(
        future: _chapterFuture,
        builder: (context, chapSnap) {
          if (chapSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chapSnap.hasError || chapSnap.data == null) {
            return const Center(child: Text('Error loading chapter info'));
          }
          final chapter = chapSnap.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter header
              Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${widget.chapterId}: ${chapter.title}',
                        style: theme.textTheme.titleLarge,
                      ),
                      if (chapter.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          chapter.subtitle!,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Verses list
              Expanded(
                child: FutureBuilder<List<Verse>>(
                  future: _versesFuture,
                  builder: (context, vsSnap) {
                    if (vsSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (vsSnap.hasError) {
                      return Center(
                          child:
                              Text('Error loading verses: ${vsSnap.error}'));
                    }
                    final verses = vsSnap.data!;
                    if (verses.isEmpty) {
                      return const Center(child: Text('No verses found.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final v = verses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verse ${v.verseId}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  v.description,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
*/

// lib/screens/verse_list_view.dart
// Updated AUG-02-2025: Mirror Home screen UX with branding header and nav buttons

import 'package:flutter/material.dart';

import '../models/chapter.dart';
import '../models/verse.dart';
import '../services/supabase_service.dart';
import '../screens/home_screen.dart';
import '../widgets/expandable_text.dart';

class VerseListView extends StatefulWidget {
  /// The ID of the chapter whose verses we're displaying.
  final int chapterId;

  const VerseListView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _VerseListViewState createState() => _VerseListViewState();
}

class _VerseListViewState extends State<VerseListView> {
  final SupabaseService _service = SupabaseService();

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          // Main scrollable content
          SafeArea(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              children: [
                // Chapter header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 28.0, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            _chapter!.title ?? '',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _chapter!.summary ?? '',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Verse list or status
                if (_isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (_errorMessage != null) ...[
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ] else if (_verses.isEmpty) ...[
                  Center(
                    child: Text(
                      'No verses available.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                ] else ...[
                  for (var verse in _verses)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Verse number badge
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primaryContainer,
                                ),
                                child: Center(
                                  child: Text(
                                    '${verse.verseId}',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Verse text
                              Expanded(
                                child: DefaultTextStyle(
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ) ?? const TextStyle(),
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

          // Back button
          Positioned(
            top: 26,
            right: 84,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
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
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              ),
            ),
          ),

          // Home button
          Positioned(
            top: 26,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
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
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeScreen(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                      (route) => false,
                    );
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

