

/* WORKING CHAPTER_DETAIL_VIEW - 29-JUKY BEFORE SAME AS HOME SCREEN

import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import '../screens/scenario_detail_view.dart';
import '../screens/verse_list_view.dart';

class ChapterDetailView extends StatefulWidget {
  final int chapterId;

  const ChapterDetailView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _ChapterDetailViewState createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<ChapterDetailView> {
  final SupabaseService _service = SupabaseService();
  Chapter? _chapter;
  List<Scenario> _scenarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final chapter = await _service.fetchChapterById(widget.chapterId);
      final scenarios = await _service.fetchScenariosByChapter(widget.chapterId);
      setState(() {
        _chapter = chapter;
        _scenarios = scenarios;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chapter details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_chapter == null) {
      return Scaffold(
        body: Center(
          child: Text('Unable to load chapter.', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        iconTheme: IconThemeData(color: onSurface),
        title: Text(
          _chapter!.title,
          style: theme.textTheme.titleLarge?.copyWith(color: onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview
            Card(
              color: surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_chapter!.subtitle != null)
                      Text(
                        _chapter!.subtitle!,
                        style: theme.textTheme.titleMedium?.copyWith(color: onSurface),
                      ),
                    if (_chapter!.summary != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _chapter!.summary!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: onSurface),
                      ),
                    ],
                    const SizedBox(height: 12),
                // FIXING START - OVERLAP FOF 12-18 PIXELS with horizontal scroll view
/*                    Row(
                      children: [
                        if (_chapter!.verseCount != null)
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VersesListView(
                                    chapterId: widget.chapterId,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.primary),
                            ),
                            child: Text(
                              'Verses: ${_chapter!.verseCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                        if (_chapter!.theme != null)
                          Chip(
                            label: Text(
                              _chapter!.theme!,
                              style: theme.textTheme.bodySmall?.copyWith(color: onSurface),
                            ),
                          ),
                      ],
                    ),  */
                // FIX FOR HORIZONTAL SCROLL VIEW
                SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          OutlinedButton(
                            onPressed: ()  {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VersesListView(
                                    chapterId: widget.chapterId,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Verses: ${_chapter!.verseCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: ()  {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VersesListView(
                                    chapterId: widget.chapterId,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              _chapter!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    
                  ],
                ),
              ),
            ),

            // Key Teachings
            if (_chapter!.keyTeachings?.isNotEmpty ?? false)
              Card(
                color: surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Teachings',
                        style: theme.textTheme.titleMedium?.copyWith(color: onSurface),
                      ),
                      const SizedBox(height: 8),
                      ..._chapter!.keyTeachings!.map(
                        (t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.book, size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Related Scenarios
            Card(
              color: surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // extra bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Related Scenarios',
                      style: theme.textTheme.titleMedium?.copyWith(color: onSurface),
                    ),
                    const SizedBox(height: 12),
                    // one card per scenario
                    ..._scenarios.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.spa, color: theme.colorScheme.primary),
                            title: Text(
                              s.title,
                              style: theme.textTheme.bodyMedium?.copyWith(color: onSurface),
                            ),
                            subtitle: s.description.isNotEmpty
                                ? Text(
                                    s.description,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(color: onSurface),
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScenarioDetailView(scenario: s),
                                ),
                              );
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import '../screens/scenario_detail_view.dart';
import '../screens/verse_list_view.dart';

class ChapterDetailView extends StatefulWidget {
  final int chapterId;

  const ChapterDetailView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _ChapterDetailViewState createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<ChapterDetailView> {
  final SupabaseService _service = SupabaseService();
  Chapter? _chapter;
  List<Scenario> _scenarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final chapter = await _service.fetchChapterById(widget.chapterId);
      final scenarios = await _service.fetchScenariosByChapter(widget.chapterId);
      setState(() {
        _chapter = chapter;
        _scenarios = scenarios;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chapter details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          // Floating navigation buttons
          Positioned(
            top: 26,
            right: 84,
            child: _glowingNavButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 26,
            right: 24,
            child: _glowingNavButton(
              icon: Icons.home,
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _chapter == null
                  ? Center(
                child: Text(
                  'Unable to load chapter details.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    // Text-only header (no hero banner image)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
                      child: Column(
                        children: [
                          Text(
                         _chapter!.title,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 1.3,
                            ),
                            textAlign: TextAlign.center,
                         ),
                          const SizedBox(height: 8),
                          Text(
                           'CHAPTER ${widget.chapterId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Chapter Overview Card
                    if (_chapter!.summary != null && _chapter!.summary!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overview',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Chapter subtitle if available
                                if (_chapter!.subtitle != null && _chapter!.subtitle!.isNotEmpty) ...[
                                  Text(
                                    _chapter!.subtitle!,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Chapter summary
                                Text(
                                  _chapter!.summary!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.48,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Stats row
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_chapter!.verseCount ?? 0} Verses',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_scenarios.length} Scenarios',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Key Teachings Card (if available)
                    if (_chapter!.keyTeachings != null && _chapter!.keyTeachings!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Key Teachings',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ..._chapter!.keyTeachings!.map(
                                      (teaching) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            teaching,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Action Buttons Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore This Chapter',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Verses button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VerseListView(
                                          chapterId: widget.chapterId,
                                        ),
                                      ),
                                    );
                                  },


                            /*      onPressed: () {
                                    // Navigate to verses list
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Navigate to verses for Chapter ${widget.chapterId}'),
                                      ),
                                    );
                                  },*/
                                  icon: const Icon(Icons.book),
                                  label: Text('Read All Verses (${_chapter!.verseCount ?? 0})'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),


                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Scenarios button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                    onPressed: () {
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                    builder: (_) => VerseListView(
                                    chapterId: widget.chapterId,
                                    ),
                                    ),
                                    );
                                    },

                              /*    onPressed: () {
                                    // Navigate to scenarios
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Navigate to scenarios for Chapter ${widget.chapterId}'),
                                      ),
                                    );
                                  },

                                  */

                                  icon: const Icon(Icons.lightbulb_outline),
                                  label: Text('View Scenarios (${_scenarios.length})'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Related Scenarios Card (if scenarios exist)
                    if (_scenarios.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Related Scenarios',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ..._scenarios.take(5).map((scenario) =>
                                    InkWell(
                               onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ScenarioDetailView(scenario:scenario )),
                                      ),
                                 //     onTap: () {
                                        // Navigate to scenario detail
                                   //     ScaffoldMessenger.of(context).showSnackBar(
                                   //       SnackBar(
                                   //         content: Text('Navigate to scenario: ${scenario.title}'),
                                   //       ),
                                   //     );
                                  //    },

                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.spa,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    scenario.title,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      color: theme.colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  if (scenario.description.isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      scenario.description.length > 80
                                                          ? '${scenario.description.substring(0, 80)}...'
                                                          : scenario.description,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ),
                                if (_scenarios.length > 5) ...[
                                  const SizedBox(height: 12),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('View all ${_scenarios.length} scenarios'),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'View ${_scenarios.length - 5} more scenarios',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // ON-TOP NAV BUTTONS
          _floatingButtons(context),
        ],
      ),
    );
  }

  // Same glowing nav button as home screen
  Widget _glowingNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: IconButton(
            splashRadius: 32,
            icon: Icon(icon, size:32, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );

  // floating buttons helper WITHOUT FADE EFFECT : WORKING AUG-2-2025

  Widget _floatingButtons(BuildContext c) => IgnorePointer(
    ignoring: false,
    child: Stack(
      children: [
        Positioned(top: 26,
                  right: 84,
                  child: _glowingNavButton(icon: Icons.arrow_back,
                                          onTap: () => Navigator.pop(c)
                                           )
        ),
        Positioned(top: 26,
                  right: 24,
                  child: _glowingNavButton(icon: Icons.home,
                                          onTap: () => Navigator.popUntil(c, (r) => r.isFirst)
                                          )
        ),
      ],
    ),
  );


/*

// Floating buttons helper: Back remains instant pop, Home fades into HomeScreen
Widget _floatingButtons(BuildContext c) => IgnorePointer(
  ignoring: false,
  child: Stack(
    children: [
      // Back button: immediate pop
      Positioned(
        top: 26,
        right: 84,
        child: _glowingNavButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(c),
        ),
      ),
      // Home button: fade into HomeScreen and clear stack
      Positioned(
        top: 26,
        right: 24,
        child: _glowingNavButton(
          icon: Icons.home,
          onTap: () {
            Navigator.of(c).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomeScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                opaque: true, // HomeScreen will cover everything
              ),
              (route) => false,
            );
          },
        ),
      ),
    ],
  ),
);

 */


}



/* NOT WORKING - NO IDEAD HIVE IMPLEMENTAITON JULY-20-2025
import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import 'scenario_detail_view.dart';
import 'verse_list_view.dart';

//
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

class ChapterDetailView extends StatefulWidget {
  final int chapterId;
  const ChapterDetailView({Key? key, required this.chapterId}) : super(key: key);

  @override
  State<ChapterDetailView> createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<ChapterDetailView> {
  final SupabaseService _service = SupabaseService();
  Chapter? _chapter;
  List<Scenario> _scenarios = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final chap = await _service.fetchChapterById(widget.chapterId);
      final scen = await _service.fetchScenariosByChapter(widget.chapterId);
      setState(() {
        _chapter = chap;
        _scenarios = scen;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chapter details: $e');
      setState(() {
        _errorMessage = 'Could not load details.';
        _isLoading = false;
      });
    }
  }

  void _showAllScenarios() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: _scenarios.map((s) {
          return ListTile(
            leading: Icon(Icons.spa, color: Theme.of(context).colorScheme.primary),
            title: Text(s.title, style: Theme.of(context).textTheme.bodyMedium),
            subtitle: s.description.isNotEmpty ? ExpandableText(s.description) : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ScenarioDetailView(scenario: s)),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.background;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_chapter == null) {
      return Scaffold(body: Center(child: Text(_errorMessage ?? 'Error', style: theme.textTheme.bodyMedium)));
    }

    // prepare related‐scenario slice
    final visible = _scenarios.take(3).toList();
    final extraCount = _scenarios.length - visible.length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        iconTheme: IconThemeData(color: onSurface),
        title: Text(_chapter!.ch_title, style: theme.textTheme.titleLarge?.copyWith(color: onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // counts row
          Card(
            color: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_chapter!.ch_subtitle.isNotEmpty)
                  Text(_chapter!.ch_subtitle,
                      style: theme.textTheme.titleMedium?.copyWith(color: onSurface)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Verses: ${_chapter!.ch_verseCount}', style: theme.textTheme.bodyMedium),
                  Text('Teachings: ${_chapter!.ch_keyTeachings.length}',
                      style: theme.textTheme.bodyMedium),
                ]),
                const SizedBox(height: 16),
                Text('Overview', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ExpandableText(_chapter!.ch_summary),
              ]),
            ),
          ),

          // related scenarios
          Card(
            color: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Related Scenarios', style: theme.textTheme.titleMedium?.copyWith(color: onSurface)),
                  const SizedBox(height: 12),
                  ...visible.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.spa, color: primary),
                          title: Text(s.title,
                              style: theme.textTheme.bodyMedium?.copyWith(color: onSurface)),
                          subtitle: s.description.isNotEmpty ? ExpandableText(s.description) : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ScenarioDetailView(scenario: s)),
                            );
                          },
                        ),
                      )),
                  if (extraCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: _showAllScenarios,
                        child: Text(
                          '+$extraCount more',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

*/


/* TRYING NEW VERSION STILL FULL OF ERRORS. JULY-20-2025

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chapter.dart';
import '../services/supabase_service.dart';
import 'scenario_detail_view.dart';

/// Detailed view for a single chapter (no Hive caching)
class ChapterDetailView extends StatefulWidget {
  final int chapterId;
  const ChapterDetailView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _ChapterDetailViewState createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<ChapterDetailView> {
  Chapter? _chapter;
  List<Scenario> _relatedScenarios = [];
  bool _isLoading = false;
  bool _isLoadingRelated = false;
  String? _error;

  final SupabaseService _service = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadChapter();
    _loadRelatedScenarios();
  }

  Future<void> _loadChapter() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetched = await _service.fetchChapterById(widget.chapterId);
      setState(() => _chapter = fetched);
    } catch (e) {
      setState(() => _error = 'Failed to load chapter details.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRelatedScenarios() async {
    setState(() => _isLoadingRelated = true);
    try {
      final scenarios = await _service.fetchScenariosByChapter(widget.chapterId);
      setState(() => _relatedScenarios = scenarios);
    } catch (_) {
      // ignore errors for related scenarios
    } finally {
      if (mounted) setState(() => _isLoadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: Text(_chapter?.title ?? 'Loading...'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: onSurface),
      ),
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _chapter == null
                  ? const Center(child: Text('No data available.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_chapter!.subtitle?.isNotEmpty ?? false)
                            Text(
                              _chapter!.subtitle!,
                              style: theme.textTheme.titleMedium,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Verses: ${_chapter!.verseCount}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Teachings: ${_chapter!.keyTeachings?.length ?? 0}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          if (_chapter!.summary?.isNotEmpty ?? false)
                            ExpandableText(_chapter!.summary!),

                          // Related Scenarios
                          const SizedBox(height: 24),
                          Text(
                            'Related Scenarios',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingRelated)
                            const Center(child: CircularProgressIndicator()),
                          if (!_isLoadingRelated && _relatedScenarios.isEmpty)
                            Text(
                              'No related scenarios.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          if (!_isLoadingRelated && _relatedScenarios.isNotEmpty)
                            ..._relatedScenarios.map((s) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.spa, color: theme.colorScheme.primary),
                                    title: Text(s.title, style: theme.textTheme.bodyMedium?.copyWith(color: onSurface)),
                                    subtitle: s.description.isNotEmpty
                                        ? ExpandableText(s.description)
                                        : null,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ScenarioDetailView(scenario: s),
                                        ),
                                      );
                                    },
                                  ),
                                )),
                        ],
                      ),
                    ),
    );
  }
}

/// Reusable expandable text widget
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
                  padding: const EdgeInsets.only(top: 4.0),
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
} {
  final int chapterId;
  const ChapterDetailView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _ChapterDetailViewState createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<ChapterDetailView> {
  Chapter? _chapter;
  final SupabaseService _service = SupabaseService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetched = await _service.fetchChapterById(widget.chapterId);
      setState(() => _chapter = fetched);
    } catch (e) {
      setState(() => _error = 'Failed to load chapter details.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: Text(_chapter?.title ?? 'Loading...'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: onSurface),
      ),
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _chapter == null
                  ? const Center(child: Text('No data available.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_chapter!.subtitle?.isNotEmpty ?? false)
                            Text(
                              _chapter!.subtitle!,
                              style: theme.textTheme.titleMedium,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Verses: ${_chapter!.verseCount}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Teachings: ${_chapter!.keyTeachings?.length ?? 0}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          if (_chapter!.summary?.isNotEmpty ?? false)
                            ExpandableText(_chapter!.summary!),
                        ],
                      ),
                    ),
    );
  }
}

/// Reusable expandable text widget
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
                  padding: const EdgeInsets.only(top: 4.0),
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

*/
