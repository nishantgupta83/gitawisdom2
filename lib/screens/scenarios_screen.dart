// lib/screens/scenarios_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import '../services/scenario_service.dart';
import 'scenario_detail_view.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

class ScenariosScreen extends StatefulWidget {
  final String? filterTag;
  const ScenariosScreen({Key? key, this.filterTag}) : super(key: key);

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  final SupabaseService _service = SupabaseService();
  final ScenarioService _scenarioService = ScenarioService.instance;
  List<Scenario> _scenarios = [];
  List<Scenario> _allScenarios = []; // Cache all scenarios for instant filtering
  String _search = '';
  String? _selectedTag;
  bool _isLoading = true;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.filterTag;
    _loadScenarios();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScenarios() async {
    setState(() => _isLoading = true);
    try {
      // Load all scenarios from cache (instant after first load)
      final allScenarios = await _scenarioService.getAllScenarios();
      
      setState(() {
        _allScenarios = allScenarios;
        _scenarios = _filterScenarios(allScenarios);
      });
      
      // Start background sync if needed (non-blocking)
      _scenarioService.backgroundSync();
      
    } catch (e) {
      debugPrint('Error loading scenarios: $e');
      // Keep existing scenarios on error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  /// Filter scenarios based on search and selected tag
  List<Scenario> _filterScenarios(List<Scenario> scenarios) {
    List<Scenario> filtered = scenarios;
    
    // Apply search filter
    if (_search.trim().isNotEmpty) {
      filtered = _scenarioService.searchScenarios(_search.trim());
    }
    
    // Apply tag filter
    if (_selectedTag != null) {
      filtered = filtered.where((s) => s.tags?.contains(_selectedTag) ?? false).toList();
    }
    
    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _search = query;
      // Update filtered scenarios instantly - no debouncing needed for local search!
      _scenarios = _filterScenarios(_allScenarios);
    });
  }

  List<String> get _tags {
    // Use cached service method for all available tags
    return _scenarioService.getAllTags();
  }


  List<Scenario> get _filtered => _scenarios; // Already filtered by _filterScenarios
  
  /// Force refresh from server
  Future<void> _refreshFromServer() async {
    setState(() => _isLoading = true);
    try {
      await _scenarioService.refreshFromServer();
      await _loadScenarios(); // Reload with fresh data
    } catch (e) {
      debugPrint('Error refreshing scenarios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToRefresh)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          // Main scrollable content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshFromServer,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Branding Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                    child: Card(
                      // Use theme.cardTheme styling
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              localizations!.scenarios,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              localizations.realWorldSituations,
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

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: localizations.searchScenarios,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: theme.colorScheme.surface.withOpacity(.95),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),

                  // Tag Pills Row
                  _tagPillsRow(
                    _tags,
                    _selectedTag,
                    (tag) => setState(() => _selectedTag = tag),
                  ),

                  // Scenario List
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Text(
                                    _search.isEmpty ? localizations.noScenariosAvailable : localizations.noScenariosMatch,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Column(
                                children: _filtered.map((scenario) => _buildScenarioCard(scenario, theme)).toList(),
                              ),
                  ),
                ],
              ),
            ),
            ), // RefreshIndicator
          ), // SafeArea
          
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

  Widget _buildScenarioCard(Scenario scenario, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scenario.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (scenario.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  scenario.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chapter ${scenario.chapter}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint('🔍 Navigating to scenario detail: ${scenario.title}');
                      // Navigate normally to preserve bottom navigation
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScenarioDetailView(scenario: scenario),
                        ),
                      );
                    },
                    child: const Text('Read More'),
                  ),
                ],
              ),
            ],
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

  Widget _tagPillsRow(List<String> tags, String? selectedTag, ValueChanged<String?> onTapTag) {
    final theme = Theme.of(context);
    const int showCount = 3;
    final totalCount = tags.length;

    // Always start with ALL
    final pills = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text('All', style: theme.textTheme.labelMedium),
          selected: selectedTag == null,
          onSelected: (_) => onTapTag(null),
        ),
      ),
    ];

    // Then up to 3 tags
    for (var i = 0; i < totalCount && i < showCount; ++i) {
      final tag = tags[i];
      pills.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('#$tag', style: theme.textTheme.labelMedium),
            selected: selectedTag == tag,
            onSelected: (_) => onTapTag(tag),
          ),
        ),
      );
    }
    // "+N" chip for more tags
    if (totalCount > showCount) {
      final moreCount = totalCount - showCount;
      pills.add(
        ActionChip(
          label: Text('+$moreCount', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimary)),
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: theme.colorScheme.surface,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
              builder: (_) => ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
                children: tags.map((tag) => ListTile(
                  title: Text('#$tag', style: theme.textTheme.bodyMedium),
                  selected: selectedTag == tag,
                  onTap: () {
                    Navigator.pop(context);
                    onTapTag(tag);
                  },
                )).toList(),
              ),
            );
          },
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(children: pills),
    );
  }

}


