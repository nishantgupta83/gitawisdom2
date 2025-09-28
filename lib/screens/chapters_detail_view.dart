import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter.dart';
import '../models/scenario.dart';
import '../models/verse.dart';
import '../services/service_locator.dart';
import '../screens/scenario_detail_view.dart';
import '../screens/verse_list_view.dart';
import '../screens/home_screen.dart';
import '../core/navigation/navigation_service.dart';
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
  List<Verse> _verses = [];
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
      final verses = await _service.fetchVersesByChapter(widget.chapterId);
      setState(() {
        _chapter = chapter;
        _scenarios = scenarios;
        _verses = verses;
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
    final textScaler = MediaQuery.of(context).textScaler;

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
              color: theme.brightness == Brightness.dark ? Color.fromARGB((0.32 * 255).toInt(), 0, 0, 0) : null,
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
                color: theme.colorScheme.surface.withOpacity(0.85),
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
                      fontSize: textScaler.scale(26),
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
                          Color.fromARGB(
                            (0.6 * 255).round(),
                            theme.colorScheme.primary.red,
                            theme.colorScheme.primary.green,
                            theme.colorScheme.primary.blue
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chapter ${widget.chapterId} of the Bhagavad Gita',
                    style: GoogleFonts.poppins(
                      fontSize: textScaler.scale(14),
                      color: Color.fromARGB(
                        (0.7 * 255).round(),
                        theme.colorScheme.onSurface.red,
                        theme.colorScheme.onSurface.green,
                        theme.colorScheme.onSurface.blue
                      ),
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
                  // Overview Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
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
                                // Quick action buttons
                                Row(
                                  children: [
                                    Expanded(
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
                                        icon: Icon(Icons.list_alt, size: 18),
                                        label: Text('View All Verses'),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),


                        // Key Teachings with beautiful purple glow
                        if (_chapter!.keyTeachings?.isNotEmpty ?? false)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade300.withOpacity(0.28),
                                  Colors.purple.shade200.withOpacity(0.24),
                                  Colors.purple.shade100.withOpacity(0.20),
                                  Colors.purple.shade50.withOpacity(0.16),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                // Outermost purple glow - strongest and largest
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.45),
                                  blurRadius: 25,
                                  spreadRadius: 6,
                                  offset: const Offset(0, 8),
                                ),
                                // Middle purple glow - medium intensity
                                BoxShadow(
                                  color: Colors.purple.shade300.withOpacity(0.32),
                                  blurRadius: 18,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 4),
                                ),
                                // Inner purple glow - subtle and close
                                BoxShadow(
                                  color: Colors.purple.shade200.withOpacity(0.24),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                                // Accent purple shimmer
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.35),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(3), // Creates enhanced border effect
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: theme.colorScheme.surface,
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.purple.shade300, Colors.purple.shade400],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.purple.withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Key Teachings',
                                            style: GoogleFonts.poppins(
                                              fontSize: theme.textTheme.titleLarge?.fontSize,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ..._chapter!.keyTeachings!.map(
                                      (t) => Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              margin: const EdgeInsets.only(top: 8, right: 12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.purple.shade400, Colors.purple.shade500],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purple.withOpacity(0.4),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                t,
                                                style: GoogleFonts.poppins(
                                                  fontSize: theme.textTheme.bodyMedium?.fontSize,
                                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                                  height: 1.5,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.relatedScenarios,
                                      style: theme.textTheme.titleMedium?.copyWith(color: onSurface),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_scenarios.length}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // numbered scenarios with gradient separators
                                ..._scenarios.asMap().entries.expand((entry) {
                                  final index = entry.key;
                                  final scenario = entry.value;
                                  final isLast = index == _scenarios.length - 1;

                                  return [
                                    // Scenario container with enhanced styling
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorScheme.outline.withOpacity(0.1),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.shadow.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ScenarioDetailView(scenario: scenario),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Enhanced circular badge
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    theme.colorScheme.primary,
                                                    theme.colorScheme.primary.withOpacity(0.8),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    scenario.title,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                      color: onSurface,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (scenario.description.isNotEmpty) ...[
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      scenario.description,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: onSurface.withOpacity(0.7),
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            // Arrow indicator
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: theme.colorScheme.primary.withOpacity(0.6),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Gradient separator (except after last scenario)
                                    if (!isLast)
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              theme.colorScheme.primary.withOpacity(0.3),
                                              theme.colorScheme.secondary.withOpacity(0.2),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.3, 0.7, 1.0],
                                          ),
                                        ),
                                      ),
                                  ];
                                }),
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

          // Floating Back Button
          Positioned(
            top: 40,
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
                radius: 25,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 32,
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
            top: 40,
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
                radius: 25,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.home_filled,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 30,
                  onPressed: () {
                    NavigationService.instance.goToTab(0); // Use navigation service for proper tab switching
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