// lib/screens/scenarios_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import '../services/scenario_service.dart';
// import '../services/favorites_service.dart'; // COMMENTED OUT: User-specific features disabled
import 'scenario_detail_view.dart';
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
  // final FavoritesService _favoritesService = FavoritesService.instance; // COMMENTED OUT: User-specific features disabled
  List<Scenario> _scenarios = [];
  List<Scenario> _allScenarios = []; // Cache all scenarios for instant filtering
  String _search = '';
  String _selectedFilter = 'All'; // Top-level filter: All, Favorite, Teenager, Parents
  int? _selectedChapter; // Add chapter filter state
  bool _isLoading = true;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedChapter = widget.filterChapter;
    
    
    // Set initial filter based on any existing tag
    if (widget.filterTag != null) {
      // Map tags to comprehensive filter categories with intelligent matching
      // Create a dummy scenario to test tag matching
      final testScenario = Scenario(
        title: '',
        description: '',
        category: '',
        chapter: 1,
        heartResponse: '',
        dutyResponse: '',
        gitaWisdom: '',
        tags: [widget.filterTag!],
        createdAt: DateTime.now(),
      );
      
      // Use helper methods to determine best category match
      if (_matchesLifeStages(testScenario)) {
        _selectedFilter = 'Life Stages';
      } else if (_matchesRelationships(testScenario)) {
        _selectedFilter = 'Relationships';
      } else if (_matchesCareerWork(testScenario)) {
        _selectedFilter = 'Career & Work';
      } else if (_matchesPersonalGrowth(testScenario)) {
        _selectedFilter = 'Personal Growth';
      } else if (_matchesModernLife(testScenario)) {
        _selectedFilter = 'Modern Life';
      } else {
        // For unmatched tags, use custom filter approach
        _selectedFilter = 'Tag:${widget.filterTag}'; // Custom tag filter
      }
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
      // If a specific chapter is requested, fetch scenarios directly from Supabase for that chapter
      if (_selectedChapter != null) {
        final chapterScenarios = await _service.fetchScenariosByChapter(_selectedChapter!);
        
        setState(() {
          _allScenarios = chapterScenarios;
          _scenarios = chapterScenarios; // No additional filtering needed for chapter-specific load
        });
      } else {
        // Load all scenarios from cache (instant after first load)
        final allScenarios = await _scenarioService.getAllScenarios();
        
        setState(() {
          _allScenarios = allScenarios;
          _scenarios = _filterScenarios(allScenarios);
        });
        
        // Start background sync if needed (non-blocking)
        _scenarioService.backgroundSync();
      }
      
    } catch (e) {
      // Keep existing scenarios on error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  /// Filter scenarios based on search, selected filter, and chapter
  /// Handles ALL filtering scenarios: search, chapter, tags, categories, etc.
  List<Scenario> _filterScenarios(List<Scenario> scenarios) {
    // Start with the input scenarios
    List<Scenario> filtered = List.from(scenarios);
    
    // STEP 1: Apply chapter filter first (highest priority - overrides everything except search)
    if (_selectedChapter != null) {
      filtered = filtered.where((s) => s.chapter == _selectedChapter).toList();
      
      // STEP 2: Apply search within chapter scenarios if search exists
      if (_search.trim().isNotEmpty) {
        filtered = filtered.where((s) => 
          s.title.toLowerCase().contains(_search.toLowerCase()) ||
          s.description.toLowerCase().contains(_search.toLowerCase()) ||
          s.category.toLowerCase().contains(_search.toLowerCase()) ||
          s.gitaWisdom.toLowerCase().contains(_search.toLowerCase()) ||
          (s.tags?.any((tag) => tag.toLowerCase().contains(_search.toLowerCase())) ?? false)
        ).toList();
      }
    }
    // STEP 1 ALT: No chapter filter, so apply other filters
    else {
      // STEP 2: Apply search filter first (if exists)
      if (_search.trim().isNotEmpty) {
        filtered = _scenarioService.searchScenarios(_search.trim());
      }
      
      // STEP 3: Apply category/tag filters to search results (or all scenarios if no search)
      switch (_selectedFilter) {
        case 'Life Stages':
          filtered = filtered.where((s) =>
            _matchesLifeStages(s) || _matchesCategory(s, ['new parents', 'parenting', 'pregnancy', 'education'])
          ).toList();
          break;
          
        case 'Relationships':
          filtered = filtered.where((s) => 
            _matchesRelationships(s) || _matchesCategory(s, ['relationships', 'family', 'friendships'])
          ).toList();
          break;
          
        case 'Career & Work':
          filtered = filtered.where((s) =>
            _matchesCareerWork(s) || _matchesCategory(s, ['career', 'business', 'work', 'workplace', 'finances'])
          ).toList();
          break;
          
        case 'Personal Growth':
          filtered = filtered.where((s) =>
            _matchesPersonalGrowth(s) || _matchesCategory(s, ['personal', 'spiritual', 'life direction', 'ethics', 'mental health', 'mentalHealth'])
          ).toList();
          break;
          
        case 'Modern Life':
          filtered = filtered.where((s) =>
            _matchesModernLife(s) || _matchesCategory(s, ['social', 'social pressure', 'digital', 'modern life', 'lifestyle', 'living situation'])
          ).toList();
          break;
          
        case 'All':
          // No additional filtering for 'All' - show all results from search (if any)
          break;
          
        default:
          // STEP 4: Handle custom tag filters (Tag:tagname format)
          if (_selectedFilter.startsWith('Tag:')) {
            final tagName = _selectedFilter.substring(4); // Remove 'Tag:' prefix
            filtered = filtered.where((s) => 
              s.tags?.any((tag) => tag.toLowerCase().contains(tagName.toLowerCase())) ?? false
            ).toList();
          }
          // STEP 5: Handle legacy filter names for backward compatibility
          else if (_selectedFilter == 'Parenting') {
            filtered = filtered.where((s) => _matchesLifeStages(s)).toList();
          }
          else if (_selectedFilter == 'Family') {
            filtered = filtered.where((s) => _matchesRelationships(s)).toList();
          }
          // STEP 6: Handle any other unknown filter types
          else if (_selectedFilter != 'All') {
            filtered = filtered.where((s) => 
              s.tags?.any((tag) => tag.toLowerCase().contains(_selectedFilter.toLowerCase())) ?? false ||
              s.category.toLowerCase().contains(_selectedFilter.toLowerCase())
            ).toList();
          }
          break;
      }
    }
    
    return filtered;
  }
  
  /// Helper method to check if scenario matches life stages categories
  bool _matchesLifeStages(Scenario s) {
    final lifeStageKeywords = [
      // Parenting & Children
      'parenting', 'parent', 'parents', 'child', 'children', 'kids', 'baby', 'toddler', 'teenager', 'teens',
      'pregnancy', 'pregnant', 'new parents', 'first-time parent', 'twins', 'siblings', 'newborn',
      'daycare', 'education', 'school', 'student', 'learning', 'feeding', 'sleep', 'development',
      // Life stages
      'newly_married', 'joint family', 'empty nest', 'birth', 'breastfeeding', 'postpartum'
    ];
    
    return s.tags?.any((tag) => lifeStageKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  /// Helper method to check if scenario matches relationships categories
  bool _matchesRelationships(Scenario s) {
    final relationshipKeywords = [
      // Relationships
      'relationships', 'relationship', 'relation', 'dating', 'romance', 'love', 'partner', 'couple',
      'marriage', 'married', 'spouse', 'wedding', 'engagement', 'breakup', 'ex-partner', 'cheating',
      // Family
      'family', 'relatives', 'in-laws', 'mother-in-law', 'father-in-law', 'sister-in-law', 'brother-in-law',
      'grandparents', 'extended family', 'traditions', 'household', 'home', 'domestic',
      // Friendships
      'friendship', 'friends', 'social', 'connection', 'intimacy', 'communication', 'trust'
    ];
    
    return s.tags?.any((tag) => relationshipKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  /// Helper method to check if scenario matches career & work categories
  bool _matchesCareerWork(Scenario s) {
    final careerKeywords = [
      // Career & Work
      'career', 'job', 'work', 'workplace', 'professional', 'business', 'entrepreneurship', 'startup',
      'employment', 'office', 'colleague', 'boss', 'authority', 'leadership', 'performance',
      // Finance
      'money', 'financial', 'finances', 'budget', 'salary', 'income', 'debt', 'loans', 'expenses',
      'investment', 'saving', 'spending', 'housing', 'rent', 'mortgage', 'insurance'
    ];
    
    return s.tags?.any((tag) => careerKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  /// Helper method to check if scenario matches personal growth categories
  bool _matchesPersonalGrowth(Scenario s) {
    final growthKeywords = [
      // Personal Development
      'personal', 'growth', 'purpose', 'identity', 'self-care', 'confidence', 'self-doubt', 'self-worth',
      'values', 'authenticity', 'boundaries', 'balance', 'change', 'transformation', 'goals',
      // Mental Health
      'mental health', 'anxiety', 'depression', 'stress', 'therapy', 'emotional', 'emotions',
      'burnout', 'exhaustion', 'wellness', 'mindfulness', 'healing',
      // Spiritual
      'spiritual', 'spirituality', 'meditation', 'wisdom', 'enlightenment', 'consciousness',
      'detachment', 'dharma', 'karma', 'service', 'duty', 'ethics', 'morals'
    ];
    
    return s.tags?.any((tag) => growthKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  /// Helper method to check if scenario matches modern life categories
  bool _matchesModernLife(Scenario s) {
    final modernKeywords = [
      // Technology & Digital
      'technology', 'digital', 'social media', 'internet', 'online', 'apps', 'screen time',
      'comparison', 'fomo', 'influencers', 'networking',
      // Modern Challenges
      'modern', 'contemporary', 'lifestyle', 'urban', 'climate', 'environment', 'sustainability',
      'travel', 'vacation', 'experiences', 'adventure', 'hobbies', 'entertainment',
      // Social Pressure
      'pressure', 'expectations', 'judgment', 'criticism', 'peer pressure', 'status', 'image',
      'celebration', 'events', 'parties', 'gifts', 'holidays', 'traditions'
    ];
    
    return s.tags?.any((tag) => modernKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  /// Helper method to check if scenario matches specific categories
  bool _matchesCategory(Scenario s, List<String> categories) {
    return categories.contains(s.category.toLowerCase());
  }

  void _onSearchChanged(String query) {
    setState(() {
      _search = query;
      // Update filtered scenarios instantly - no debouncing needed for local search!
      _scenarios = _filterScenarios(_allScenarios);
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _scenarios = _filterScenarios(_allScenarios);
    });
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

                  // Chapter/Tag Filter Clear Button
                  if (_selectedChapter != null || _selectedFilter.startsWith('Tag:'))
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
                              _selectedChapter != null
                                  ? 'Showing scenarios for Chapter $_selectedChapter'
                                  : _selectedFilter.startsWith('Tag:')
                                      ? 'Showing scenarios tagged with "${_selectedFilter.substring(4)}"'
                                      : 'Showing $_selectedFilter scenarios',
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
                                _selectedFilter = 'All';
                              });
                              _loadScenarios(); // Reload all scenarios
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

                  // Filter Buttons Row (hidden when chapter filter or custom tag filter is active)
                  if (_selectedChapter == null && !_selectedFilter.startsWith('Tag:'))
                    _buildFilterButtons(),

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


  Widget _buildFilterButtons() {
    final theme = Theme.of(context);
    final filters = ['All', 'Life Stages', 'Relationships', 'Career & Work', 'Personal Growth', 'Modern Life']; // Comprehensive category groupings
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          // Removed favorite-specific UI since user-specific features are disabled
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _onFilterChanged(filter),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
              checkmarkColor: theme.colorScheme.onPrimary,
              elevation: isSelected ? 4 : 1,
              shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

}


