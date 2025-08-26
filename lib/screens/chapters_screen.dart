// lib/screens/chapters_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter_summary.dart';
import '../services/service_locator.dart';
import 'chapters_detail_view.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

/// CHAPTERS SCREEN: Modern UI, themed background, Material cards, floating buttons.
/// This screen lists all Gita chapters as cards, using current app theming with enhanced multilingual support.
class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final _service = ServiceLocator.instance.enhancedSupabaseService;
  List<ChapterSummary> _chapters = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.fetchChapterSummaries();
      if (mounted) {
        setState(() {
          _chapters = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to load chapters: $e');
      }
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
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image with dark overlay for dark mode
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: isDark ? Color.fromARGB((0.32 * 255).toInt(), 0, 0, 0) : null,
              colorBlendMode: isDark ? BlendMode.darken : null,
            ),
          ),
          
          // Scrollable content area
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(color: theme.colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadChapters,
                                child: Text(AppLocalizations.of(context)!.retry),
                              ),
                            ],
                          ),
                        )
                      : _chapters.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noChaptersAvailable,
                                style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
                              ),
                            )
                          : ListView(
                              // Preserve bottom inset + extra padding
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 20,
                                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                              ),
                              children: [
                                // Floating header card
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
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
                                        AppLocalizations.of(context)!.gitaChapters,
                                        style: GoogleFonts.poiretOne(
                                          fontSize: textScaler.scale(30),
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
                                        AppLocalizations.of(context)!.immersiveKnowledge,
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Chapters list
                                ..._chapters.map((ch) => Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      color: theme.colorScheme.surface,
                                      shadowColor: Color.fromARGB((0.12 * 255).toInt(), 
                                        theme.colorScheme.primary.red,
                                        theme.colorScheme.primary.green,
                                        theme.colorScheme.primary.blue
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(22),
                                        onTap: () {
                                          _fadePush(ChapterDetailView(chapterId: ch.chapterId));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 48,
                                                    height: 48,
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
                                                        '${ch.chapterId}',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: textScaler.scale(16),
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  
                                                  // Title and subtitle
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          ch.title,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: textScaler.scale(16),
                                                            fontWeight: FontWeight.w600,
                                                            color: theme.colorScheme.onSurface,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        if (ch.subtitle != null && ch.subtitle!.isNotEmpty) ...[
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            ch.subtitle!,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: textScaler.scale(13),
                                                              color: Color.fromARGB(
                                                                (0.7 * 255).round(),
                                                                theme.colorScheme.onSurface.red,
                                                                theme.colorScheme.onSurface.green,
                                                                theme.colorScheme.onSurface.blue
                                                              ),
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  
                                                  // Chevron icon
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                              
                                              const SizedBox(height: 16),
                                              
                                              // Bottom row with verse and scenario counts
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  _buildCountChip(
                                                    '${ch.verseCount} ${AppLocalizations.of(context)!.versesCount}',
                                                    Icons.book_outlined,
                                                    theme,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildCountChip(
                                                    '${ch.scenarioCount} ${AppLocalizations.of(context)!.scenariosCount}',
                                                    Icons.lightbulb_outline,
                                                    theme,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                              ],
                            ),
            ),
          ),
          
          // Floating Back Button
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
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 32,
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // Navigate to home tab instead of trying to pop empty stack
                      NavigationHelper.goToTab(0);
                    }
                  },
                  tooltip: AppLocalizations.of(context)!.back,
                ),
              ),
            ),
          ),
          
          // Floating Home Button
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
                  tooltip: AppLocalizations.of(context)!.home,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build count chips (verses/scenarios)
  Widget _buildCountChip(String text, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).textScaler.scale(12), // Using MediaQuery directly since textScaler isn't in scope here
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}