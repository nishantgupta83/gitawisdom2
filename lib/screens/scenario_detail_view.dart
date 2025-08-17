import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/scenario.dart';
import '../models/journal_entry.dart';
import '../screens/scenarios_screen.dart';
import '../screens/new_journal_entry_dialog.dart';
import '../screens/home_screen.dart';
import '../services/journal_service.dart';
import '../main.dart';
// import '../services/favorites_service.dart'; // COMMENTED OUT: User-specific features disabled
import '../l10n/app_localizations.dart';

class ScenarioDetailView extends StatefulWidget {
  final Scenario scenario;

  const ScenarioDetailView({Key? key, required this.scenario}) : super(key: key);

  @override
  _ScenarioDetailViewState createState() => _ScenarioDetailViewState();
}

class _ScenarioDetailViewState extends State<ScenarioDetailView> {
  final ScrollController _ctrl = ScrollController();
  final GlobalKey _actionsKey = GlobalKey();
  bool _showActions = false;
  // bool _isFavorited = false; // COMMENTED OUT: User-specific features disabled
  // bool _favoriteLoading = false; // COMMENTED OUT: User-specific features disabled

  @override
  void initState() {
    super.initState();
    // _loadFavoriteStatus(); // COMMENTED OUT: User-specific features disabled
  }

  // COMMENTED OUT: User-specific features disabled
  /*
  /// Load favorite status from service
  void _loadFavoriteStatus() {
    setState(() {
      _isFavorited = FavoritesService.instance.isFavorited(widget.scenario.title);
    });
  }

  /// Toggle favorite status with animation
  Future<void> _toggleFavorite() async {
    if (_favoriteLoading) return;
    
    setState(() => _favoriteLoading = true);
    
    try {
      final newStatus = await FavoritesService.instance.toggleFavorite(widget.scenario.title);
      setState(() {
        _isFavorited = newStatus;
        _favoriteLoading = false;
      });
      
      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Added to favorites!' : 'Removed from favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _favoriteLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  */

  // COMMENTED OUT: User-specific journal features disabled
  /*
  /// Open journal entry dialog with scenario context
  void _showJournalDialog() {
    showDialog(
      context: context,
      builder: (_) => NewJournalEntryDialog(
        scenarioId: widget.scenario.key is int ? widget.scenario.key as int : null,
        scenarioTitle: widget.scenario.title,
        initialCategory: 'categoryScenarioWisdom',
        onSave: (entry) async {
          try {
            await JournalService.instance.createEntry(entry);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.journalEntrySaved ?? 'Journal entry saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context)!.failedToSaveEntry}: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
  */

  void _revealActions() {
    setState(() => _showActions = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(_actionsKey.currentContext!, duration: const Duration(milliseconds: 350));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
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
                      'MODERN DAY SCENARIO',
                      style: GoogleFonts.poiretOne(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 1.3,
                      ),
                      textAlign: TextAlign.center,
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
                      'Bite-sized wisdom for modern challenges',
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
                  controller: _ctrl,
                  padding: EdgeInsets.zero,
                  children: [
                    // Scenario Title Card with Heart
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                              Expanded(
                                child: Text(
                                  widget.scenario.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                  // Allow multiple lines for long titles but prevent overflow
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // COMMENTED OUT: User-specific favorites feature disabled
                              /*
                              // Heart favorite button with fixed size to prevent layout shifts
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: _favoriteLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                            ),
                                          ),
                                        )
                                      : IconButton(
                                          key: ValueKey(_isFavorited),
                                          onPressed: _toggleFavorite,
                                          icon: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: Icon(
                                              _isFavorited ? Icons.favorite : Icons.favorite_border,
                                              key: ValueKey(_isFavorited),
                                              color: _isFavorited ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.6),
                                              size: 28,
                                            ),
                                          ),
                                          tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
                                        ),
                                ),
                              ),
                              */
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    _card('Description', widget.scenario.description, theme),
                    _buildHeartSection(theme),
                    _buildDutySection(theme),
                    
                    // Strategy 2 SHOW WISDOM Button
                    if (!_showActions) _buildShowWisdomButton(theme),
                    
                    if (widget.scenario.tags?.isNotEmpty ?? false) _tagCard(theme),
                    _card('Gita Wisdom', widget.scenario.gitaWisdom, theme),
                    if (_showActions) _actionStepsCard(theme),
                    
                    // Bottom padding for floating elements and bottom navigation bar
                    SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
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
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                  ),
                ),
              ),
            ),
            // COMMENTED OUT: User-specific journal features disabled
            /*
            // Journal This button
            Positioned(
              top: 26,
              right: 84,
              child: Material(
                elevation: 12,
                shape: CircleBorder(),
                color: Colors.transparent,
                child: _glowingJournalButton(),
              ),
            ),
            */
            
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
                    tooltip: 'Home',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helper widgets (compact) ...
  Widget _titleHeader(ThemeData t) => Text(widget.scenario.title,
      style: t.textTheme.headlineMedium
  );

  Widget _card(String title, String body, ThemeData theme) => Padding(
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(body,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ]),
      ),
    ),
  );

  Widget _buildHeartSection(ThemeData theme) {
    return Padding(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite, size: 24, color: Colors.pink),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Heart Says',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(widget.scenario.heartResponse,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                        // Allow flexible text length for heart response
                        overflow: TextOverflow.visible),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDutySection(ThemeData theme) {
    return Padding(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.balance, size: 24, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duty Says',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(widget.scenario.dutyResponse,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                        // Allow flexible text length for duty response
                        overflow: TextOverflow.visible),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagCard(ThemeData theme) => Padding(
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
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.scenario.tags!
              .map((tag) => ActionChip(
                label: Text(
                  tag,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ScenariosScreen(filterTag: tag),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                side: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ))
              .toList(),
        ),
      ),
    ),
  );

  Widget _actionStepsCard(ThemeData theme) => Builder(
    builder: (context) {
      // Get device width for responsive design
      final deviceWidth = MediaQuery.of(context).size.width;
      final isTablet = deviceWidth > 600;
      final horizontalPadding = isTablet ? deviceWidth * 0.1 : 20.0;
      
      return Container(
        key: _actionsKey,
        width: double.infinity, // Ensure full width responsiveness
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade400.withOpacity(0.4),
                Colors.orange.shade500.withOpacity(0.4),
                Colors.deepOrange.shade400.withOpacity(0.4),
                Colors.amber.shade300.withOpacity(0.3),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              // Outermost glow - strongest and largest
              BoxShadow(
                color: Colors.amber.withOpacity(0.6),
                blurRadius: 25,
                spreadRadius: 6,
                offset: const Offset(0, 8),
              ),
              // Middle glow - medium intensity
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 18,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
              // Inner glow - subtle and close
              BoxShadow(
                color: Colors.deepOrange.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
              // Accent glow - golden shimmer
              BoxShadow(
                color: Colors.amberAccent.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 8,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3), // Creates enhanced border effect
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: theme.colorScheme.surface,
              border: Border.all(
                color: Colors.amber.withOpacity(0.2),
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
                              colors: [Colors.amber.shade300, Colors.orange.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: isTablet ? 24 : 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Wisdom Steps',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...?widget.scenario.actionSteps?.asMap().entries.map((entry) => Container(
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
                                colors: [Colors.amber.shade400, Colors.orange.shade500],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: GoogleFonts.poppins(
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
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                height: 1.5,
                              ),
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
  );

  // Same glowing show wisdom button with consistent styling
  Widget _buildShowWisdomButton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade600,
            Colors.deepOrange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _revealActions,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 28, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '🔮 SHOW WISDOM',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // COMMENTED OUT: User-specific journal features disabled
  /*
  Widget _glowingJournalButton() =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.6),
              blurRadius: 18,
              spreadRadius: 4,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.green.shade50,
          child: IconButton(
            splashRadius: 32,
            icon: Icon(
              Icons.book,
              size: 32, 
              color: Colors.green.shade700,
            ),
            tooltip: 'Journal This',
            onPressed: _showJournalDialog,
          ),
        ),
      );
  */
}