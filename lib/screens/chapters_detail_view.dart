

/* WORKING CHAPTER_DETAIL_VIEW - Updated with consistent UI patterns

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter.dart';
import '../models/scenario.dart';
import '../services/service_locator.dart';
import '../screens/scenario_detail_view.dart';
import '../screens/verse_list_view.dart';
import '../screens/home_screen.dart';
import '../l10n/app_localizations.dart';

class ChapterDetailView extends StatefulWidget {
  final int chapterId;

  const ChapterDetailView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _ChapterDetailViewState createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<ChapterDetailView> {
  late final _service = ServiceLocator.instance.enhancedSupabaseService;
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image with dark overlay for dark mode
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: theme.brightness == Brightness.dark ? Colors.black.withAlpha((0.32 * 255).toInt()) : null,
              colorBlendMode: theme.brightness == Brightness.dark ? BlendMode.darken : null,
            ),
          ),
          
          // Sticky header that stays fixed at top
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
                    _chapter!.title,
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
                    'Chapter ${widget.chapterId} of the Bhagavad Gita',
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
              margin: const EdgeInsets.only(top: 140), // Space for sticky header
              child: ListView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  // Original branding card content removed since it's now in sticky header"}, {"old_string": "                  // Overview Card\n                  Padding(\n                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),", "new_string": "                  // Overview Card\n                  Padding(\n                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),"}, {"old_string": "        ],\n      ),\n    );", "new_string": "          // Floating Back Button\n          Positioned(\n            top: 26,\n            right: 84,\n            child: Container(\n              decoration: const BoxDecoration(\n                shape: BoxShape.circle,\n                boxShadow: [\n                  BoxShadow(\n                    color: Colors.amberAccent,\n                    blurRadius: 16,\n                    spreadRadius: 4,\n                  ),\n                ],\n              ),\n              child: CircleAvatar(\n                radius: 26,\n                backgroundColor: theme.colorScheme.surface,\n                child: IconButton(\n                  icon: Icon(\n                    Icons.arrow_back,\n                    size: 32,\n                    color: theme.colorScheme.primary,\n                  ),\n                  splashRadius: 32,\n                  onPressed: () => Navigator.pop(context),\n                  tooltip: 'Back',\n                ),\n              ),\n            ),\n          ),\n          \n          // Floating Home Button\n          Positioned(\n            top: 26,\n            right: 24,\n            child: Container(\n              decoration: const BoxDecoration(\n                shape: BoxShape.circle,\n                boxShadow: [\n                  BoxShadow(\n                    color: Colors.amberAccent,\n                    blurRadius: 16,\n                    spreadRadius: 4,\n                  ),\n                ],\n              ),\n              child: CircleAvatar(\n                radius: 26,\n                backgroundColor: theme.colorScheme.surface,\n                child: IconButton(\n                  icon: Icon(\n                    Icons.home_filled,\n                    size: 32,\n                    color: theme.colorScheme.primary,\n                  ),\n                  splashRadius: 32,\n                  onPressed: () {\n                    Navigator.of(context).pushAndRemoveUntil(\n                      PageRouteBuilder(\n                        pageBuilder: (_, __, ___) => const HomeScreen(),\n                        transitionsBuilder: (_, anim, __, child) =>\n                            FadeTransition(opacity: anim, child: child),\n                      ),\n                      (route) => false,\n                    );\n                  },\n                  tooltip: 'Home',\n                ),\n              ),\n            ),\n          ),\n        ],\n      ),\n    );"}]

                  // Overview Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Column(
                      children: [
                        Card(
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
                      AppLocalizations.of(context)!.relatedScenarios,
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
import '../services/service_locator.dart';
import '../services/scenario_service.dart';
import '../screens/scenario_detail_view.dart';
import '../screens/verse_list_view.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

class ChapterDetailView extends StatefulWidget {
  final int chapterId;

  const ChapterDetailView({Key? key, required this.chapterId}) : super(key: key);

  @override
  _ChapterDetailViewState createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<ChapterDetailView> {
  late final _service = ServiceLocator.instance.enhancedSupabaseService;
  Chapter? _chapter;
  List<Scenario> _scenarios = [];
  bool _isLoading = true;
  bool _showAllScenarios = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final chapter = await _service.fetchChapterById(widget.chapterId);
      // Ensure scenarios are loaded, then filter by chapter
      await ScenarioService.instance.getAllScenarios();
      final scenarios = ScenarioService.instance.filterByChapter(widget.chapterId);
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
                    // Enhanced header with amber glow effect (matches Key Teachings style)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 40, 20, 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amberAccent.withOpacity(0.15),
                            Colors.amber.withOpacity(0.1),
                            Colors.orangeAccent.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.amberAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                             _chapter!.title,
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 1.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.amberAccent.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                             ),
                            const SizedBox(height: 12),
                            Container(
                              width: 80,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amberAccent,
                                    Colors.amber.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amberAccent.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                             'CHAPTER ${widget.chapterId}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
                                  AppLocalizations.of(context)!.overview,
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

                    // Key Teachings Card (if available) - Enhanced with glow effect
                    if (_chapter!.keyTeachings != null && _chapter!.keyTeachings!.isNotEmpty)
                      Builder(
                        builder: (context) {
                          // Get device width for responsive design
                          final deviceWidth = MediaQuery.of(context).size.width;
                          final isTablet = deviceWidth > 600;
                          final horizontalPadding = isTablet ? deviceWidth * 0.1 : 20.0;
                          
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: AnimatedContainer(
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400.withOpacity(0.25),
                                    Colors.indigo.shade500.withOpacity(0.25),
                                    Colors.lightBlue.shade400.withOpacity(0.25),
                                    Colors.blue.shade300.withOpacity(0.18),
                                  ],
                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  // Outermost glow - reduced intensity
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.35),
                                    blurRadius: 15,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 5),
                                  ),
                                  // Middle glow - medium intensity
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.25),
                                    blurRadius: 11,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 3),
                                  ),
                                  // Inner glow - subtle and close
                                  BoxShadow(
                                    color: Colors.lightBlue.withOpacity(0.18),
                                    blurRadius: 7,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                  // Accent glow - blue shimmer
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    blurRadius: 18,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(3), // Creates enhanced border effect
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: theme.colorScheme.surface,
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 0,
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue.shade300, Colors.indigo.shade400],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.lightbulb_outline,
                                                color: Colors.white,
                                                size: isTablet ? 24 : 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                AppLocalizations.of(context)!.keyTeachings,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontSize: isTablet ? 20 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ..._chapter!.keyTeachings!.asMap().entries.map((entry) => Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                margin: const EdgeInsets.only(right: 12, top: 2),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Colors.blue.shade400, Colors.indigo.shade500],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.3),
                                                      blurRadius: 6,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${entry.key + 1}',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: isTablet ? 14 : 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  entry.value,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontSize: isTablet ? 16 : 14,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                                    height: 1.5,
                                                  ),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
                                AppLocalizations.of(context)!.exploreChapter,
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
                                    debugPrint('🔧 ChapterDetailView: View Scenarios button pressed for chapter ${widget.chapterId}');
                                    // Navigate back to root and switch to scenarios tab with chapter filter
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                    debugPrint('🔧 ChapterDetailView: Calling NavigationHelper.goToScenariosWithChapter(${widget.chapterId})');
                                    NavigationHelper.goToScenariosWithChapter(widget.chapterId);
                                  },

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
                                  AppLocalizations.of(context)!.relatedScenarios,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ...(_showAllScenarios ? _scenarios : _scenarios.take(5)).map((scenario) =>
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
                                        setState(() {
                                          _showAllScenarios = !_showAllScenarios;
                                        });
                                      },
                                      child: Text(
                                        _showAllScenarios 
                                            ? 'Show fewer scenarios'
                                            : 'View ${_scenarios.length - 5} more scenarios',
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
import '../services/service_locator.dart';
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
                _expanded ? AppLocalizations.of(context)!.readLess : AppLocalizations.of(context)!.readMore,
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
  late final _service = ServiceLocator.instance.enhancedSupabaseService;
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
      // Global background handled by main.dart
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main scrollable content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Branding Card with Chapter Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              _chapter!.ch_title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'CHAPTER ${widget.chapterId}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Cards
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                Text(AppLocalizations.of(context)!.overview, style: theme.textTheme.titleMedium),
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
                  Text(AppLocalizations.of(context)!.relatedScenarios, style: theme.textTheme.titleMedium?.copyWith(color: onSurface)),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating navigation buttons
          Positioned(
            top: 26,
            right: 84,
            child: _glowingNavButton(
              icon: Icons.arrow_back,
              onTap: () {
                // Check if we can pop, otherwise go to home
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                } else {
                  // If no route to pop to, navigate back to root
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RootScaffold()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
          Positioned(
            top: 26,
            right: 24,
            child: _glowingNavButton(
              icon: Icons.home,
              onTap: () {
                // Navigate back to root by popping until we reach the root
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
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
              color: Colors.amberAccent.withOpacity(0.5),
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
            icon: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );
}

*/


/* TRYING NEW VERSION STILL FULL OF ERRORS. JULY-20-2025

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chapter.dart';
import '../services/service_locator.dart';
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

  late final _service = ServiceLocator.instance.enhancedSupabaseService;

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
      if (mounted) {
        setState(() => _chapter = fetched);
      }
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
                            AppLocalizations.of(context)!.relatedScenarios,
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
                    _expanded ? AppLocalizations.of(context)!.readLess : AppLocalizations.of(context)!.readMore,
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
  late final _service = ServiceLocator.instance.enhancedSupabaseService;
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
      if (mounted) {
        setState(() => _chapter = fetched);
      }
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
                    _expanded ? AppLocalizations.of(context)!.readLess : AppLocalizations.of(context)!.readMore,
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
