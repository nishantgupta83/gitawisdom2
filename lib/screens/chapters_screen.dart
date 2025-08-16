/*
import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/chapter_summary.dart';
import '../services/supabase_service.dart';
import '../assets/images/divine_scroll_bg.png';'


class ChaptersScreen extends StatefulWidget {
  @override
  _ChaptersScreenState createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  List<ChapterSummary> chapters = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void> fetchChapters() async {
  final data = await SupabaseService().fetchChapterSummaries();
  setState(() {
    chapters = data;
    isLoading = false;
  });
}

  }
/*
  Future<void> fetchChapters() async {
    final chapters = await SupabaseService().fetchChapters();
    setState(() {
    //  _chapters = chapters.map((json) => Chapter.fromJson(json)).toList();
      _chapters = chapters; // Already typed from SupabaseService
      _isLoading = false;
    });
  }
  
  */

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/divine_scroll_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Chapters'),
          backgroundColor: Colors.brown[200]?.withOpacity(0.8),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _chapters[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.1),
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapter ${chapter.number}: ${chapter.title}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Georgia',
                              color: Colors.brown[900],
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            chapter.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Arial',
                              color: Colors.brown[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
*/

/* PRE-DB changes

import 'package:flutter/material.dart';
//import '../models/chapter.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import '../screens/chapters_detail_view.dart';
import '../models/chapter_summary.dart';


class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  //List<Chapter> chapters = [];
  List<ChapterSummary> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
      fetchChapters();
  }

  Future<void> fetchChapters() async {
  final data = await SupabaseService().fetchChapterSummaries();
  setState(() {
    chapters = data;
    isLoading = false;
  });
  }

/* DEBUG BLOCK JUST IN CASE
  Future<void> fetchChapters() async {
  try {
    print('Fetching chapter summaries...');
    final data = await SupabaseService().fetchChapterSummaries();
    print('Fetched chapters: $data');

    setState(() {
      chapters = data;
      isLoading = false;
    });
  } catch (e, stack) {
    print('❌ Error loading chapters: $e');
    print(stack);
    setState(() {
      isLoading = false; // Still hide spinner on error
    });
  }
}
*/

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapters of Wisdom'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return GestureDetector(
                ListTile(
              title: Text(chapter.title),
              subtitle: Text(chapter.subtitle ?? ''),   // use ?? to avoid nullable String
              trailing: Text('${chapter.verseCount ?? 0} verses'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                  //  builder: (_) => ChapterDetailView(chapterId: chapter.chapterId.toString()),
                    builder: (_) => ChapterDetailView(chapterId: chapter.chapterId),
                 //    builder: (_) => ChapterDetailView(chapterNumber: chapter.number),

                  ),
                ),
                ),
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            chapter.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Scenarios: ${chapter.scenarioCount}'),
                            //  Text('Verses: ${chapter.verseCount}'),
                              Text('Verses: 101'),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


*/


/********************** JULY 19 - 2025 BEFORE LAUNCH , HIVE IMPLEMENTATION

import 'package:flutter/material.dart';
import '../models/chapter_summary.dart';
import '../services/supabase_service.dart';
import 'chapters_detail_view.dart';

//import '../services/analytics_service.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

// ──────────────────────────────────────────────────────────────────────────────
// Expandable Text (for “Read more”)
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {Key? key}) : super(key: key);
  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c).textTheme.bodyMedium;
    return LayoutBuilder(builder: (ctx, constraints) {
      final span = TextSpan(text: widget.text, style: theme);
      final tp = TextPainter(
        text: span,
        maxLines: _expanded ? null : 2,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);
      final isOverflow = tp.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.text,
              style: theme, maxLines: _expanded ? null : 2, overflow: TextOverflow.fade),
          if (isOverflow)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Read less' : 'Read more',
                style: theme?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            )
        ],
      );
    });
  }
}
// ──────────────────────────────────────────────────────────────────────────────

class _ChapterScreenState extends State<ChapterScreen> {
  final SupabaseService _service = SupabaseService();
  List<ChapterSummary> _chapters = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final data = await _service.fetchChapterSummaries();
      setState(() {
        _chapters = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching chapters: $e');
      setState(() {
        _errorMessage = 'Unable to load chapters.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapters of Wisdom'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = _chapters[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDark ? Colors.grey[850] : Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                       
                       /* Befoew analytics
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterDetailView(
                                chapterId: chapter.chapterId,
                              ),
                            ),
                          );
                        },
                        */
                        // WITH analytics
                       onTap: () {
                          // 1️⃣ Log the open-chapter event
                       //   AnalyticsService.instance.logEvent(
                      //    name: 'chapter_opened',
                     //     parameters: {'chapter_id': chapter.chapterId},
                     //   );
                          // 2️⃣ Navigate to the detail view
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterDetailView(
                                chapterId: chapter.chapterId,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              if (chapter.subtitle != null && chapter.subtitle!.isNotEmpty)
                                Text(
                                  chapter.subtitle!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Scenarios: ${chapter.scenarioCount}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Verses: ${chapter.verseCount}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
*/

//WORKING JULKY-20_MORNING
/*
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chapter.dart';
import '../services/supabase_service.dart';
import 'chapters_detail_view.dart';

/// ExpandableText widget for truncating and expanding long text
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {Key? key}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: _expanded ? null : 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final isOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: textStyle,
              maxLines: _expanded ? null : 2,
              overflow: TextOverflow.fade,
            ),
            if (isOverflow)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _expanded ? 'Read less' : 'Read more',
                    style: textStyle?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Screen listing all chapters with Hive-backed caching
class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late Box<Chapter> _chapterBox;
  final SupabaseService _service = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chapterBox = Hive.box<Chapter>('chapters');
    if (_chapterBox.isEmpty) {
      _syncChaptersFromRemote();
    }
  }

  Future<void> _syncChaptersFromRemote() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final chapters = await _service.fetchAllChapters();
      // Map entries by chapterId
      final entries = Map.fromEntries(
        chapters.map((c) => MapEntry(c.chapterId, c)),
      );
      await _chapterBox.putAll(entries);
    } catch (e) {
      _errorMessage = 'Failed to load chapters.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapters'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ValueListenableBuilder<Box<Chapter>>(
                  valueListenable: _chapterBox.listenable(),
                  builder: (context, box, _) {
                    final chapters = box.values.toList()
                      ..sort((a, b) => a.chapterId.compareTo(b.chapterId));
                    if (chapters.isEmpty) {
                      return const Center(child: Text('No chapters available.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              chapter.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: chapter.subtitle != null && chapter.subtitle!.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ExpandableText(chapter.subtitle!),
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChapterDetailView(chapterId: chapter.chapterId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

*/

/* WORKED - 10:00 AM JULY 20-2025
// lib/screens/chapters_screen.dart

import 'package:flutter/material.dart';
import '../models/chapter_summary.dart';
import '../services/supabase_service.dart';
import 'chapters_detail_view.dart';

/// A reusable widget that truncates to 2 lines and toggles with "Read more"/"Read less"
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {Key? key}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(builder: (ctx, constraints) {
      final span = TextSpan(text: widget.text, style: style);
      final tp = TextPainter(
        text: span,
        maxLines: _expanded ? null : 2,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: style,
            maxLines: _expanded ? null : 2,
            overflow: TextOverflow.fade,
          ),
          if (tp.didExceedMaxLines)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: style?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Lists all 18 chapters (with counts) by fetching your Supabase summary view.
class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final SupabaseService _service = SupabaseService();
  List<ChapterSummary> _chapters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchChapterSummaries();
      setState(() => _chapters = list);
    } catch (e) {
      setState(() => _error = 'Failed to load chapters.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapters'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chapters.length,
                  itemBuilder: (_, i) {
                    final ch = _chapters[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.book, color: theme.colorScheme.primary),
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(ch.title, style: theme.textTheme.titleMedium),
                        subtitle: ch.subtitle != null && ch.subtitle!.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ExpandableText(ch.subtitle!),
                              )
                            : null,
                        // footer row with counts
                        trailing: Text(
                          'Chapter ${ch.chapterId} • ${ch.verseCount} verses • ${ch.scenarioCount} scenarios',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterDetailView(chapterId: ch.chapterId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
*/

/* JULY 29 - 2025 WORKING CODE. NOW CHANGING TO UPLIFTED MATH HOME SCREEN

import 'package:flutter/material.dart';
import '../models/chapter_summary.dart';
import '../services/supabase_service.dart';
import 'chapters_detail_view.dart';

/// A reusable widget that truncates to 2 lines and toggles with "Read more"/"Read less"
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {Key? key}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(builder: (ctx, constraints) {
      final span = TextSpan(text: widget.text, style: style);
      final tp = TextPainter(
        text: span,
        maxLines: _expanded ? null : 2,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: style,
            maxLines: _expanded ? null : 2,
            overflow: TextOverflow.fade,
          ),
          if (tp.didExceedMaxLines)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: style?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Lists all 18 chapters (with counts) by fetching your Supabase summary view.
class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final SupabaseService _service = SupabaseService();
  List<ChapterSummary> _chapters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchChapterSummaries();
      setState(() => _chapters = list);
    } catch (e) {
      setState(() => _error = 'Failed to load chapters.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

/*
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapters'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.colorScheme.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chapters.length,
        itemBuilder: (_, i) {
          final ch = _chapters[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChapterDetailView(chapterId: ch.chapterId),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ① Chapter label on its own line
                    Text(
                      'Chapter ${ch.chapterId}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ② Bookmark icon
                        Icon(Icons.book, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),

                        // ③ Title + optional subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ch.title, style: theme.textTheme.titleMedium),
                              if (ch.subtitle != null && ch.subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ExpandableText(ch.subtitle!),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ④ Counts at bottom-right
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${ch.verseCount} verses  •  ${ch.scenarioCount} scenarios',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  */
  
  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    // let the global background image shine through
    backgroundColor: Colors.transparent,

    body: Column(
      children: [
        // ─── Hero Banner ────────────────────────────────────────
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              // reuse your main background or swap in a chapter‐specific banner
              image: AssetImage('assets/images/ow_hb.jpeg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.darken,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Gita Chapters',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        // ─── Chapter List ───────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chapters.length,
            itemBuilder: (context, i) {
              final ch = _chapters[i];
              return Card(
                // cardTheme from main.dart controls color/elevation/shape
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterDetailView(chapterId: ch.chapterId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ① Chapter label above the title
                        Text(
                          'Chapter ${ch.chapterId}',
                          style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                        ),
                        const SizedBox(height: 4),

                        // ② Icon + title + subtitle
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.book, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      ch.title, 
                                      style: theme.textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  if (ch.subtitle != null && ch.subtitle!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Flexible(child: ExpandableText(ch.subtitle!)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ③ Counts at bottom‑right
                        Align(
                          alignment: Alignment.centerRight,
                          child: Flexible(
                            child: Text(
                              '${ch.verseCount} verses  •  ${ch.scenarioCount} scenarios',
                              style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
*/
/*
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chapters_detail_view.dart';
import '../models/chapter_summary.dart';
import '../services/supabase_service.dart';


class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {Key? key}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}
class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(builder: (ctx, constraints) {
      final span = TextSpan(text: widget.text, style: style);
      final tp = TextPainter(
        text: span,
        maxLines: _expanded ? null : 2,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.text, style: style, maxLines: _expanded ? null : 2, overflow: TextOverflow.fade),
          if (tp.didExceedMaxLines)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: style?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final SupabaseService _service = SupabaseService();
  List<ChapterSummary> _chapters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchChapterSummaries();
      setState(() => _chapters = list);
    } catch (e) {
      setState(() => _error = 'Failed to load chapters.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: isDark ? Colors.black.withAlpha((0.32 * 255).toInt()) : null,
              colorBlendMode: isDark ? BlendMode.darken : null,
            ),
          ),
          SafeArea(
            child: Column(
              children: [

                // Hero banner (matches HomeScreen)
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/ow_hb.jpeg',
                      width: double.infinity,
                      height: 146,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Container(
                        height: 146,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha((0.10 * 255).toInt()),
                              Colors.black.withAlpha((0.20 * 255).toInt()),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0, right: 0, top: 56,
                      child: Column(
                        children: [
                          Text(
                            'GITA CHAPTERS',
                        style: GoogleFonts.poiretOne(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 1.3,
                            shadows: [
                            const Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                            )
                            ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explore All 18 Chapters of Wisdom',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                            ),
                         //   textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: _chapters.length,
                    itemBuilder: (context, i) {
                      final ch = _chapters[i];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        color: theme.colorScheme.surface,
                        shadowColor: theme.colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChapterDetailView(chapterId: ch.chapterId ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Badge with chapter number
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha((0.13 * 255).toInt()),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${ch.chapterId}',
                                      style: GoogleFonts.poiretOne(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ch.title,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      if (ch.subtitle != null && ch.subtitle!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        ExpandableText(ch.subtitle!),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
             //   _floatingButtons(context),
              ],
            ),
          ),
          // Floating nav buttons (wire with callback as needed)

          Positioned(
            top: 26,
            right: 84,
            child: _glowingNavButton(
              icon: Icons.home,
              onTap: () { Navigator.pop(context); },
            ),
          ),
          Positioned(
            top: 26,
            right: 24,
            child: _glowingNavButton(
              icon: Icons.more_horiz,
              onTap: () {},
            ),
          ),


        ],
      ),
    );
  }

  Widget _glowingNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withAlpha(40),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withAlpha((0.8 * 255).toInt()),
          child: IconButton(
            splashRadius: 28,
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );



  Widget _floatingButtons(BuildContext context) => IgnorePointer(
    ignoring: false,
    child: Stack(
      children: [
        Positioned(
          top: 26,
          right: 84,
          child: _glowingNavButton(
            icon: Icons.home,
            onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ),
        Positioned(
          top: 26,
          right: 24,
          child: _glowingNavButton(
            icon: Icons.more_horiz,
            onTap: () {},
          ),
        ),
      ],
    ),
  );
}
*/

/*
// ExpandableText widget
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {Key? key}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(builder: (ctx, constraints) {
      final span = TextSpan(text: widget.text, style: style);
      final tp = TextPainter(
        text: span,
        maxLines: _expanded ? null : 2,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.text,
              style: style,
              maxLines: _expanded ? null : 2,
              overflow: TextOverflow.fade),
          if (tp.didExceedMaxLines)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: style?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);
  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final SupabaseService _service = SupabaseService();
  List<ChapterSummary> _chapters = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.fetchChapterSummaries();
      setState(() {
        _chapters = data;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load chapters.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background image with dark overlay only in dark mode
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withAlpha((0.38 * 255).toInt())
                  : null,
              colorBlendMode: Theme.of(context).brightness == Brightness.dark
                  ? BlendMode.darken
                  : null,
            ),
          ),

          SafeArea(
          child: Padding(
          padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),

            child: Column(
              children: [
                // Hero Banner

      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
        child: Column(
           //     child: Stack(
                  children: [
                    Text(
                      'GITA CHAPTERS',
                      style: GoogleFonts.poiretOne(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Explore All 18 Chapters of Wisdom',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.88),
                        fontWeight: FontWeight.w400,
                        shadows: [
                          const Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Positioned.fill(
                      child: Container(
                        height: 146,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          //    Colors.black.withOpacity(0.10),
                              Colors.black.withOpacity(0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  ),
    ),
    ),
    ),

                const SizedBox(height: 20),
                // MAIN CHAPTER LIST
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : _chapters.isEmpty
                      ? const Center(child: Text('No chapters available.'))
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemCount: _chapters.length,
                    itemBuilder: (context, i) {
                      final ch = _chapters[i];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        color: theme.colorScheme.surface,
                        shadowColor: theme.colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChapterDetailView(chapterId: ch.chapterId),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      margin: const EdgeInsets.only(right: 18),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.13),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${ch.chapterId}',
                                          style: GoogleFonts.poiretOne(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ch.title,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          if (ch.subtitle != null && ch.subtitle!.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            ExpandableText(ch.subtitle!),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              // FOR VERSES AND ROW COUNT
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${ch.verseCount} Verses',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.66)),
                                    ),
                                    Text(
                                      '${ch.scenarioCount} Scenarios',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.66)),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          ),
          // Floating nav buttons, always last in the Stack for overlay
          Positioned(
            top: 26,
            right: 84,
            child: _glowingNavButton(
              icon: Icons.home,
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ),
          Positioned(
            top: 26,
            right: 24,
            child: _glowingNavButton(
              icon: Icons.more_horiz,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowingNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.amber.withAlpha(40), blurRadius: 8, spreadRadius: 2)],
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withAlpha((0.8 * 255).toInt()),
          child: IconButton(
            splashRadius: 28,
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );
}
*/


// lib/screens/chapters_screen.dart

/*

Scaffold
└─ body: Stack
   ├─ Positioned.fill (Background Image: app_bg.png)
   ├─ if dark: Positioned.fill (Black overlay)
   ├─ SafeArea
   │   └─ Column (main vertical content)
   │       ├─ Padding (Header section)
   │       │   └─ Column
   │       │       ├─ Text("GITA CHAPTERS")
   │       │       └─ Container (underline bar)
   │       ├─ Expanded
   │       │   └─
   │           if _isLoading: Center(CircularProgressIndicator)
   │           else if _error: Center(Text(_error))
   │           else if empty: Center(Text('No chapters available'))
   │           else: ListView.builder (scrolling chapters list)
   │               └─ For each chapter:
   │                   └─ Card (rounded, elevated)
   │                       └─ InkWell (onTap goes to ChapterDetailView)
   │                           └─ Padding
   │                               └─ Column
   │                                   ├─ Row:
   │                                   │   ├─ Container (circle with chapter number)
   │                                   │   ├─ Expanded:
   │                                   │   │   └─ Column (title and subtitle)
   │                                   │   └─ Icon(Icons.chevron_right)
   │                                   └─ Row (mainAxisAlignment.end):
   │                                       ├─ Text: verse count
   │                                       └─ Text: scenario count
   └─ Positioned (top-right)
        └─ Container (Floating Home Button)
            └─ CircleAvatar + IconButton (Home icon)


┌───────────────────────────── Scaffold (background: theme) ────────────────────────────┐
│  ┌──────── Stack ────────┐                                                            │
│  │BG: app_bg.png (fill)  │                                                            │
│  │Dark overlay if needed │                                                            │
│  │ ┌──── SafeArea ──┐    │                                                            │
│  │ │  Column        │    │                                                            │
│  │ │ ┌ Header ────┐ │    │                                                            │
│  │ │ │ "GITA CHP."│ │    │                                                            │
│  │ │ │ underline  │ │    │                                                            │
│  │ │ └────────────┘ │    │                                                            │
│  │ │ ┌ Expanded ───┐│    │                                                            │
│  │ │ │ if loading  ││    │ => Center(Spinner)                                         │
│  │ │ │ else if err ││    │ => Center(Text)                                            │
│  │ │ │ else if emp ││    │ => Center(Text)                                            │
│  │ │ │ else:       ││    │ => ListView: Card-per-chapter                              │
│  │ │ └─────────────┘│    │   Each card: [badge][title][subtitle] [chevron] [counts]   │
│  │ └────────────────┘    │                                                            │
│  │ ┌───────────────┐     │                                                            │
│  │ │Floating Home  │     │                                                            │
│  │ │ (top right)   │     │                                                            │
│  │ └───────────────┘     │                                                            │
│  └───────────────────────┘                                                            │
└────────────────────────────────────────────────────────────────────────────────────────┘

 */

import 'package:flutter/material.dart';
import '../models/chapter_summary.dart';
import '../services/supabase_service.dart';
import 'chapters_detail_view.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';

/// CHAPTERS SCREEN: Modern UI, themed background, Material cards, floating home button.
/// This screen lists all Gita chapters as cards, using current app theming.

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final SupabaseService _service = SupabaseService();
  List<ChapterSummary> _chapters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchChapterSummaries();
      setState(() => _chapters = list);
    } catch (e) {
      setState(() => _error = 'Failed to load chapters.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fade-transition helper
  void _fadePush(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      // Global background handled by main.dart
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          // ② Main content as a single scrollable ListView for seamless UX
          SafeArea(
            child: ListView(
              // preserve bottom inset + extra padding
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              children: [
                // ─── Header (identical to home-screen) ─────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                  child: Card(
                    // Use theme.cardTheme styling
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 28.0, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            localizations!.gitaChapters,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localizations.immerseInKnowledge,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Chapters List or Status ────────────────────────────
                if (_isLoading) ...[
                  const SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ] else if (_error != null) ...[
                  const SizedBox(height: 200),
                  Center(child: Text(_error!)),
                ] else if (_chapters.isEmpty) ...[
                  const SizedBox(height: 200),
                  Center(child: Text(localizations.noChaptersAvailable)),
                ] else ...[
                  // map each chapter to a Card
                  for (var ch in _chapters)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: Card(
                        // Use theme.cardTheme styling
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12), // Use theme radius
                          onTap: () => _fadePush(
                            ChapterDetailView(chapterId: ch.chapterId),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Chapter number + title row
                                Row(
                                  children: [
                                    // 1) Chapter badge
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${ch.chapterId}',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.8),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // 2) Title & subtitle
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ch.title,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.8),
                                              fontWeight: FontWeight.w900,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (ch.subtitle != null &&
                                              ch.subtitle!.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              ch.subtitle!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, size: 28),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // 3) Counts row - wrapped to prevent overflow
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${localizations.versesCount} -> ${ch.verseCount}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${localizations.scenariosCount} -> ${ch.scenarioCount}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                // small bottom padding
                const SizedBox(height: 16),
              ],
            ),
          ),


          // ─── Floating Back Button ───────────────────────────────
          Positioned(
            top: 26,
            right: 84,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.background,
                child: IconButton(
                  icon: Icon(Icons.arrow_back,
                      size: 32, color: theme.colorScheme.primary),
                  splashRadius: 32,
                    onPressed: () => Navigator.pop(context)
                    )


                ),
              ),
            ),


          // ─── Floating Home Button ───────────────────────────────
          Positioned(
            top: 26,
            right: 24,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.background,
                child: IconButton(
                  icon: Icon(Icons.home_filled,
                      size: 32, color: theme.colorScheme.primary),
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
