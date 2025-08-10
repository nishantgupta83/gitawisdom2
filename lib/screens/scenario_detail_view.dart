import 'package:flutter/material.dart';

import '../models/scenario.dart';
import '../models/journal_entry.dart';
import '../screens/scenarios_screen.dart';
import '../screens/new_journal_entry_dialog.dart';
import '../services/journal_service.dart';
import '../main.dart';
import '../services/favorites_service.dart';
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
  bool _isFavorited = false;
  bool _favoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

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

  void _revealActions() {
    setState(() => _showActions = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(_actionsKey.currentContext!, duration: const Duration(milliseconds: 350));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Stack(
          children: [
            // Scroll content
            ListView(
              controller: _ctrl,
              padding: EdgeInsets.zero,
              children: [
                // Branding Header Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            'MODERN DAY SCENARIO',
                            style: t.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bite-sized wisdom for modern challenges',
                            textAlign: TextAlign.center,
                            style: t.textTheme.bodyMedium?.copyWith(
                              color: t.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Scenario Title Card with Heart
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.scenario.title,
                              style: t.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: t.colorScheme.primary,
                              ),
                              // Allow multiple lines for long titles but prevent overflow
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                          valueColor: AlwaysStoppedAnimation<Color>(t.colorScheme.primary),
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
                                          color: _isFavorited ? Colors.red : t.colorScheme.onSurface.withOpacity(0.6),
                                          size: 28,
                                        ),
                                      ),
                                      tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                _card('Description', widget.scenario.description, t),
                _buildHeartSection(t),
                _buildDutySection(t),
                
                // Strategy 2 SHOW WISDOM Button
                if (!_showActions) _buildShowWisdomButton(t),
                
                if (widget.scenario.tags?.isNotEmpty ?? false) _tagCard(t),
                _card('Gita Wisdom', widget.scenario.gitaWisdom, t),
                if (_showActions) _actionStepsCard(t),
                
                // Bottom padding for floating elements and bottom navigation bar
                SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
              ],
            ),
            
            // Floating navigation buttons with higher z-index
            Positioned(
              top: 26,
              right: 144,
              child: Material(
                elevation: 12,
                shape: CircleBorder(),
                color: Colors.transparent,
                child: _glowingNavButton(
                  icon: Icons.arrow_back,
                  onTap: () {
                    debugPrint('🔙 Back button tapped');
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
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
            Positioned(
              top: 26,
              right: 24,
              child: Material(
                elevation: 12,
                shape: CircleBorder(),
                color: Colors.transparent,
                child: _glowingNavButton(
                  icon: Icons.home,
                  onTap: () {
                    debugPrint('🏠 Home button tapped');
                    // Return to existing root without creating new navigation stack
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  // helper widgets (compact) ...
  Widget _titleHeader(ThemeData t) => Text(widget.scenario.title,
      style: t.textTheme.headlineMedium
  );

  Widget _card(String title, String body, ThemeData t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            style: t.textTheme.titleMedium
          ),
          const SizedBox(height: 10),
          Text(body,
            style: t.textTheme.bodyMedium
          ),
        ]),
      ),
    ),
  );

  Widget _buildHeartSection(ThemeData t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Heart Says',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(widget.scenario.heartResponse,
                      style: t.textTheme.bodyMedium,
                      // Allow flexible text length for heart response
                      overflow: TextOverflow.visible),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDutySection(ThemeData t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.balance, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duty Says',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(widget.scenario.dutyResponse,
                      style: t.textTheme.bodyMedium,
                      // Allow flexible text length for duty response
                      overflow: TextOverflow.visible),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagCard(ThemeData t) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: widget.scenario.tags!
            .map((tag) => ActionChip(
              label: Text(tag),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScenariosScreen(filterTag: tag),
                  ),
                );
              },
            ))
            .toList(),
      ),
    ),
  );

  Widget _actionStepsCard(ThemeData t) => Builder(
    builder: (context) {
      // Get device width for responsive design
      final deviceWidth = MediaQuery.of(context).size.width;
      final isTablet = deviceWidth > 600;
      final horizontalPadding = isTablet ? deviceWidth * 0.1 : 16.0;
      
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
              borderRadius: BorderRadius.circular(15),
              color: t.colorScheme.surface,
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
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: t.colorScheme.primary,
                              fontSize: isTablet ? 20 : 18,
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
                                style: TextStyle(
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
                              style: t.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                                fontSize: isTablet ? 16 : 14,
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

  // Same glowing nav button as home screen
  Widget _buildShowWisdomButton(ThemeData t) {
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
                  style: TextStyle(
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
}