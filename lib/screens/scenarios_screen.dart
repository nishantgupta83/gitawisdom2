// lib/screens/scenarios_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scenario.dart';
import '../services/service_locator.dart';
import '../services/scenario_service.dart';
// import '../services/favorites_service.dart'; // COMMENTED OUT: User-specific features disabled
import 'scenario_detail_view.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
// import 'sub_category_mapper.dart'; // TODO: Implement sub-category filtering UI

/// Utility function to format counts in human-readable format
String formatCount(int count) {
  if (count >= 1000) {
    double value = count / 1000.0;
    return '${value.toStringAsFixed(1)}k+';
  }
  return count.toString();
}

/// Sub-tag model with visual elements
class SubTag {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> keywords; // Keywords to match this sub-tag

  const SubTag({
    required this.name,
    required this.icon,
    required this.color,
    required this.keywords,
  });
}

/// Enhanced category filter with visual elements and dynamic counts
class CategoryFilter {
  final String id;
  final String nameKey; // Localization key
  final IconData icon;
  final Color color;
  final bool isDynamic; // Whether to calculate count dynamically

  const CategoryFilter({
    required this.id,
    required this.nameKey,
    required this.icon,
    required this.color,
    this.isDynamic = false,
  });

  /// Get localized name for this category
  String getLocalizedName(BuildContext context) {
    // final localizations = AppLocalizations.of(context)!; // TODO: Use when adding localization keys
    switch (nameKey) {
      case 'all':
        return 'All';
      case 'work_career':
        return 'Work & Career';
      case 'relationships':
        return 'Relationships';
      case 'parenting_family':
        return 'Parenting & Family';
      case 'personal_growth':
        return 'Personal Growth';
      case 'life_transitions':
        return 'Life Transitions';
      case 'social_community':
        return 'Social & Community';
      case 'health_wellness':
        return 'Health & Wellness';
      case 'financial':
        return 'Financial';
      case 'education_learning':
        return 'Education & Learning';
      case 'modern_living':
        return 'Modern Living';
      default:
        return nameKey.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  /// Calculate scenario count for this category
  int getScenarioCount(List<Scenario> scenarios, _ScenariosScreenState? state) {
    if (id == 'All') {
      return scenarios.length;
    }
    
    // Use direct category matching for backend categories
    return scenarios.where((s) => s.category == id).length;
  }
}

class ScenariosScreen extends StatefulWidget {
  final String? filterTag;
  final int? filterChapter; // Add chapter filtering
  const ScenariosScreen({Key? key, this.filterTag, this.filterChapter}) : super(key: key);

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  late final _service = ServiceLocator.instance.enhancedSupabaseService;
  final ScenarioService _scenarioService = ScenarioService.instance;
  // final FavoritesService _favoritesService = FavoritesService.instance; // COMMENTED OUT: User-specific features disabled
  List<Scenario> _scenarios = [];
  List<Scenario> _allScenarios = []; // Cache all scenarios for instant filtering
  String _search = '';
  String _selectedFilter = 'All'; // Top-level filter: All, Favorite, Teenager, Parents
  String? _selectedSubCategory; // Sub-category filter for enhanced filtering
  int? _selectedChapter; // Add chapter filter state
  bool _isLoading = true;
  bool _hasNewContent = false;
  int _totalScenarioCount = 0;
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
      
      // For tag-based filtering, set to 'All' and let search handle it
      _selectedFilter = 'All';
      _search = widget.filterTag!; // Use search to filter by tag
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
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      // If a specific chapter is requested, fetch scenarios directly from Supabase for that chapter
      if (_selectedChapter != null) {
        final chapterScenarios = await _service.fetchScenariosByChapter(_selectedChapter!);
        
        if (mounted) {
          setState(() {
            _allScenarios = chapterScenarios;
            _scenarios = chapterScenarios; // No additional filtering needed for chapter-specific load
          });
        }
      } else {
        // Load all scenarios from cache (instant after first load)
        final allScenarios = await _scenarioService.getAllScenarios();
        
        if (mounted) {
          setState(() {
            _allScenarios = allScenarios;
            _scenarios = _filterScenarios(allScenarios);
            _totalScenarioCount = allScenarios.length;
          });
        }
        
        // Start background sync if needed (non-blocking) - monthly check only
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
        case 'Work & Career':
        case 'Relationships':
        case 'Parenting & Family':
        case 'Personal Growth':
        case 'Life Transitions':
        case 'Social & Community':
        case 'Health & Wellness':
        case 'Financial':
        case 'Education & Learning':
        case 'Modern Living':
          filtered = filtered.where((s) => s.category == _selectedFilter).toList();
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
          // STEP 5: Handle any other unknown filter types
          else if (_selectedFilter != 'All') {
            filtered = filtered.where((s) => 
              s.tags?.any((tag) => tag.toLowerCase().contains(_selectedFilter.toLowerCase())) ?? false ||
              s.category.toLowerCase().contains(_selectedFilter.toLowerCase())
            ).toList();
          }
          break;
      }
    }
    
    // Sub-tag filtering removed - sub-categories are now informational only
    
    return filtered;
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    
    setState(() {
      _search = query;
      // Update filtered scenarios instantly - no debouncing needed for local search!
      _scenarios = _filterScenarios(_allScenarios);
    });
  }

  void _onFilterChanged(String filter) {
    if (!mounted) return;
    
    setState(() {
      _selectedFilter = filter;
      _scenarios = _filterScenarios(_allScenarios);
    });
  }


  List<Scenario> get _filtered => _scenarios; // Already filtered by _filterScenarios
  
  /// Check for new content availability
  Future<void> _checkForNewContent() async {
    try {
      final hasNew = await _scenarioService.hasNewScenariosAvailable();
      if (mounted && hasNew) {
        setState(() => _hasNewContent = true);
      }
    } catch (e) {
      debugPrint('Error checking for new content: $e');
    }
  }

  /// Force refresh from server
  Future<void> _refreshFromServer() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      await _scenarioService.refreshFromServer();
      await _loadScenarios(); // Reload with fresh data
      if (mounted) {
        setState(() => _hasNewContent = false); // Reset new content indicator
      }
    } catch (e) {
      debugPrint('Error refreshing scenarios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.failedToRefresh ?? 'Failed to refresh')),
        );
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
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false, // Prevent automatic resizing for keyboard
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
          
          
          // Scrollable content area
          SafeArea(
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping outside search field
                FocusScope.of(context).unfocus();
              },
              child: RefreshIndicator(
                onRefresh: _refreshFromServer,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 24,
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
                            _selectedChapter != null 
                                ? AppLocalizations.of(context)!.chapterScenarios(_selectedChapter!)
                                : AppLocalizations.of(context)!.lifeScenarios,
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
                            _selectedChapter != null
                                ? AppLocalizations.of(context)!.chapterScenariosSubtitle(_selectedChapter!)
                                : AppLocalizations.of(context)!.applyGitaWisdom,
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
                    // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: localizations?.searchScenarios ?? 'Search scenarios...',
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
                        fillColor: theme.colorScheme.surface.withOpacity(.85),
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
                                  ? AppLocalizations.of(context)!.showingScenariosForChapter(_selectedChapter!)
                                  : _selectedFilter.startsWith('Tag:')
                                      ? AppLocalizations.of(context)!.showingScenariosTaggedWith(_selectedFilter.substring(4))
                                      : 'Showing $_selectedFilter scenarios',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _selectedChapter = null;
                                  _selectedFilter = 'All';
                                });
                              }
                              _loadScenarios(); // Reload all scenarios
                            },
                            child: Text(
                              AppLocalizations.of(context)!.clearFilter,
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Filter Buttons Row (hidden when chapter filter or custom tag filter is active)
                  if (_selectedChapter == null && !_selectedFilter.startsWith('Tag:'))
                    _buildFilterButtons(),

                  // Sub-tag Row (appears when a main category is selected)
                  if (_selectedChapter == null && !_selectedFilter.startsWith('Tag:'))
                    _buildSubTags(),

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
                                    _search.isEmpty ? (localizations?.noScenariosAvailable ?? 'No scenarios available') : (localizations?.noScenariosMatch ?? 'No scenarios match your search'),
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
        ), // GestureDetector
      ), // SafeArea
        
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
                  try {
                    NavigationHelper.goToTab(0); // 0 = Home tab index
                  } catch (e) {
                    debugPrint('Home button error: $e');
                    // Fallback navigation
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RootScaffold()),
                      (route) => false,
                    );
                  }
                },
                tooltip: AppLocalizations.of(context)!.home,
              ),
            ),
          ),
        ),
        
        ], // Stack children
      ), // Stack
    ); // Scaffold

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
                        AppLocalizations.of(context)!.chapter(scenario.chapter),
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
                        _fadePush(ScenarioDetailView(scenario: scenario));
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: const Size(60, 30), // Fixed minimum size
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.readMore,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 12, // Slightly smaller font
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
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


  /// Enhanced categories with icons, colors, and dynamic counts
  List<CategoryFilter> get _enhancedCategories => [
    CategoryFilter(
      id: 'All',
      nameKey: 'all',
      icon: Icons.apps,
      color: Colors.blue.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Modern Living',
      nameKey: 'modern_living',
      icon: Icons.phone_android,
      color: Colors.blueGrey.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Parenting & Family',
      nameKey: 'parenting_family',
      icon: Icons.family_restroom,
      color: Colors.orange.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Health & Wellness',
      nameKey: 'health_wellness',
      icon: Icons.health_and_safety,
      color: Colors.green.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Work & Career',
      nameKey: 'work_career',
      icon: Icons.work,
      color: Colors.indigo.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Relationships',
      nameKey: 'relationships',
      icon: Icons.people,
      color: Colors.pink.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Personal Growth',
      nameKey: 'personal_growth',
      icon: Icons.spa,
      color: Colors.teal.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Life Transitions',
      nameKey: 'life_transitions',
      icon: Icons.timeline,
      color: Colors.purple.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Social & Community',
      nameKey: 'social_community',
      icon: Icons.groups,
      color: Colors.cyan.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Financial',
      nameKey: 'financial',
      icon: Icons.attach_money,
      color: Colors.amber.shade600,
      isDynamic: true,
    ),
    CategoryFilter(
      id: 'Education & Learning',
      nameKey: 'education_learning',
      icon: Icons.school,
      color: Colors.deepPurple.shade600,
      isDynamic: true,
    ),
  ];

  /// Sub-category descriptions for main categories
  Map<String, String> get _categoryDescriptions => {
    'Work & Career': 'Professional growth, job security, academic pressure, business, side hustles, work-life balance',
    'Relationships': 'Dating, marriage, family dynamics, friendship, romantic partnerships, communication',
    'Parenting & Family': 'Child development, new parents, pregnancy, family planning, caregiving, elder care',
    'Personal Growth': 'Self-discovery, habits, identity, mental wellness, meditation, values, mindfulness',
    'Life Transitions': 'Major milestones, big decisions, divorce, academic changes, life planning',
    'Social & Community': 'Urban loneliness, social pressure, community building, belonging, connection',
    'Health & Wellness': 'Body confidence, digital wellness, climate anxiety, physical health, mental wellbeing',
    'Financial': 'Budget management, debt, savings, investment decisions, economic security, planning',
    'Education & Learning': 'Academic success, skill development, learning goals, educational planning',
    'Modern Living': 'Technology balance, contemporary challenges, lifestyle choices, digital life',
  };

  Widget _buildFilterButtons() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 8, 18, 8),
      child: Row(
        children: _enhancedCategories.map((category) {
          final isSelected = _selectedFilter == category.id;
          final count = category.getScenarioCount(_allScenarios, null);
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              elevation: isSelected ? 6 : 2,
              borderRadius: BorderRadius.circular(20),
              shadowColor: category.color.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isSelected 
                    ? LinearGradient(
                        colors: [
                          category.color.withOpacity(0.8),
                          category.color.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                  color: isSelected ? null : theme.colorScheme.surface.withOpacity(0.8),
                  border: Border.all(
                    color: category.color.withOpacity(isSelected ? 0.8 : 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _onFilterChanged(category.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 18,
                          color: isSelected 
                            ? Colors.white 
                            : category.color,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.getLocalizedName(context),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isSelected 
                                  ? Colors.white 
                                  : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatCount(count),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected 
                                  ? Colors.white.withOpacity(0.9) 
                                  : category.color.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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
          );
        }).toList(),
      ),
    );
  }

  /// Build sub-category information row that appears when a main category is selected
  Widget _buildSubTags() {
    if (_selectedFilter == 'All' || !_categoryDescriptions.containsKey(_selectedFilter)) {
      return const SizedBox.shrink();
    }

    final description = _categoryDescriptions[_selectedFilter]!;
    final theme = Theme.of(context);
    
    // Get main category color
    final mainCategory = _enhancedCategories.firstWhere((cat) => cat.id == _selectedFilter);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Enhanced background opacity for much better visibility and contrast
          color: theme.brightness == Brightness.light 
              ? mainCategory.color.withOpacity(0.2) // Increased from 0.15 for better contrast
              : mainCategory.color.withOpacity(0.12), // Increased from 0.08 for better contrast
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: mainCategory.color.withOpacity(0.4), // Increased from 0.3 for better visibility
            width: 1.5,
          ),
          // Enhanced shadow for better contrast
          boxShadow: [
            BoxShadow(
              color: mainCategory.color.withOpacity(0.15), // Increased shadow opacity
              blurRadius: 6, // Increased blur for better visibility
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 16,
              color: mainCategory.color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    // Improved text contrast and readability
                    color: theme.brightness == Brightness.light
                        ? theme.colorScheme.onSurface.withOpacity(0.95)
                        : theme.colorScheme.onSurface.withOpacity(0.9),
                    fontSize: 13, // Increased from 12 for better readability
                    fontWeight: FontWeight.w600, // Increased from w500 for better visibility
                    height: 1.4, // Added line height for better text spacing
                  ),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.includes,
                      style: TextStyle(
                        fontWeight: FontWeight.w700, // Bold for "Includes:" label
                        color: Colors.white, // White as requested by user
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600, // Increased weight for description
                        color: Colors.white.withOpacity(0.9), // White with slight transparency
                      ),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sub-tag selection removed - sub-categories are now informational only

}


