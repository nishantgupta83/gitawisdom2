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
  final int? filterChapter; // Add chapter filtering
  const ScenariosScreen({Key? key, this.filterTag, this.filterChapter}) : super(key: key);

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
  int? _selectedChapter; // Add chapter filter state
  bool _isLoading = true;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.filterTag;
    _selectedChapter = widget.filterChapter;
    // Clear other filters when chapter filter is active
    if (_selectedChapter != null) {
      _selectedTag = null; // Clear tag filter when filtering by chapter
    }
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
  
  /// Filter scenarios based on search, selected tag, and chapter
  List<Scenario> _filterScenarios(List<Scenario> scenarios) {
    List<Scenario> filtered = scenarios;
    
    // Apply search filter
    if (_search.trim().isNotEmpty) {
      filtered = _scenarioService.searchScenarios(_search.trim());
    }
    
    // Apply chapter filter (takes priority)
    if (_selectedChapter != null) {
      filtered = filtered.where((s) => s.chapter == _selectedChapter).toList();
    }
    // Apply tag filter only if no chapter filter
    else if (_selectedTag != null) {
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
      body: SafeArea(
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                    child: Card(
                      // Use theme.cardTheme styling
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              _selectedChapter != null 
                                  ? 'Chapter $_selectedChapter ${localizations!.scenarios}'
                                  : localizations!.scenarios,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedChapter != null
                                  ? 'Scenarios from Bhagavad Gita Chapter $_selectedChapter'
                                  : localizations.realWorldSituations,
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

                  // Chapter Filter Clear Button
                  if (_selectedChapter != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt, 
                               color: theme.colorScheme.primary,
                               size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing scenarios for Chapter $_selectedChapter',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedChapter = null;
                                _scenarios = _filterScenarios(_allScenarios);
                              });
                            },
                            child: Text(
                              'Show All',
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Tag Pills Row (hidden when chapter filter is active)
                  if (_selectedChapter == null)
                    _tagPillsRow(
                    _tags,
                    _selectedTag,
                    (tag) => setState(() => _selectedTag = tag),
                  ),

                  // Scenario List
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
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
    );

  }

  Widget _buildScenarioCard(Scenario scenario, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        child: IntrinsicHeight( // Ensures consistent card height
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with proper overflow handling
                Text(
                  scenario.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 2, // Prevent title from taking too much space
                  overflow: TextOverflow.ellipsis,
                ),
                if (scenario.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      scenario.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                // Spacer to push bottom content down
                const SizedBox(height: 12), // Increased spacing to prevent overflow
                
                // Bottom row with flexible layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        'Chapter ${scenario.chapter}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Compact button to prevent overflow
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
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: const Size(60, 30), // Fixed minimum size
                      ),
                      child: Text(
                        'Read More',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 12, // Slightly smaller font
                        ),
                        maxLines: 1,
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
    );
  }


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


