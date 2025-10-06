// lib/screens/scenarios_screen.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scenario.dart';
import '../services/service_locator.dart';
import '../services/progressive_scenario_service.dart';
import '../services/intelligent_scenario_search.dart';
// import '../services/favorites_service.dart'; // COMMENTED OUT: User-specific features disabled
import 'scenario_detail_view.dart';
import '../core/navigation/navigation_service.dart';
import '../screens/root_scaffold.dart';
import '../l10n/app_localizations.dart';
import '../widgets/share_card_widget.dart';
import '../widgets/app_background.dart';
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
  final ScenarioServiceAdapter _scenarioService = ScenarioServiceAdapter.instance;
  final IntelligentScenarioSearch _aiSearchService = IntelligentScenarioSearch.instance;
  // final FavoritesService _favoritesService = FavoritesService.instance; // COMMENTED OUT: User-specific features disabled
  List<Scenario> _scenarios = [];
  List<Scenario> _allScenarios = []; // Cache all scenarios for instant filtering
  List<Scenario> _displayedScenarios = []; // Scenarios currently displayed with lazy loading
  String _search = '';
  String _selectedFilter = 'All'; // Top-level filter: All, Favorite, Teenager, Parents
  String? _selectedSubCategory; // Sub-category filter for enhanced filtering
  int? _selectedChapter; // Add chapter filter state
  bool _isLoading = true;
  bool _isLoadingMore = false; // Loading more scenarios for pagination
  bool _hasNewContent = false;
  int _totalScenarioCount = 0;
  Timer? _debounceTimer;

  // AI Search state
  bool _aiSearchEnabled = true; // Default to AI search enabled
  bool _aiSearchInitialized = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Track search bar focus for glow effect

  // Lazy loading configuration - Load 20 scenarios at a time for smooth UI performance
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMorePages = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedChapter = widget.filterChapter;

    // Initialize pagination scroll listener
    _scrollController.addListener(_onScroll);

    // Add listener to search focus node to trigger UI updates for glow effect
    _searchFocusNode.addListener(() {
      setState(() {}); // Rebuild to show/hide glow effect
    });

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

    // Periodically check for newly loaded scenarios and update count
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentScenarios = await _scenarioService.getAllScenarios();
      if (mounted && currentScenarios.length != _allScenarios.length) {
        setState(() {
          _allScenarios = currentScenarios;
          _scenarios = _filterScenarios(currentScenarios);
          _totalScenarioCount = currentScenarios.length;
        });
        debugPrint('📊 Updated scenario count: ${currentScenarios.length}');

        // Stop checking once we have all scenarios
        if (currentScenarios.length >= 1200) {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Handle scroll events for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMorePages &&
        _search.isEmpty) {
      // Load more scenarios when scrolling near bottom
      if (_displayedScenarios.length < _scenarios.length) {
        _loadMoreScenarios();
      }
    }
  }

  Future<void> _loadScenarios() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _displayedScenarios.clear();
    });

    try {
      // If a specific chapter is requested, fetch scenarios directly from Supabase for that chapter
      if (_selectedChapter != null) {
        final chapterScenarios = await _service.fetchScenariosByChapter(_selectedChapter!);

        if (mounted) {
          setState(() {
            _allScenarios = chapterScenarios;
            _scenarios = chapterScenarios;
            _loadInitialPage();
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
            _loadInitialPage();
          });
        }

        // Start background sync if needed (non-blocking) - monthly check only
        // Pass callback to update UI when sync completes
        _scenarioService.backgroundSync(onComplete: () async {
          if (mounted) {
            debugPrint('🔄 Background sync completed - reloading all scenarios');
            // Reload all scenarios to get the full dataset
            final fullScenarios = await _scenarioService.getAllScenarios();
            if (mounted) {
              setState(() {
                _allScenarios = fullScenarios;
                _scenarios = _filterScenarios(fullScenarios);
                _totalScenarioCount = fullScenarios.length;
                // Reset pagination to show updated count
                _displayedScenarios.clear();
                _currentPage = 0;
                _loadInitialPage();
              });
              debugPrint('✅ Updated UI with ${fullScenarios.length} scenarios');
            }
          }
        });
      }

    } catch (e) {
      debugPrint('Error loading scenarios: $e');
      if (mounted) {
        setState(() {
          // Show error message to user if no scenarios are loaded
          if (_allScenarios.isEmpty) {
            _scenarios = [];
            _displayedScenarios = [];
          }
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load scenarios. Please check your connection.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadScenarios(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Load the first page of scenarios for display
  void _loadInitialPage() {
    final endIndex = (_pageSize).clamp(0, _scenarios.length);
    _displayedScenarios = _scenarios.take(endIndex).toList();
    _currentPage = 1;
    _hasMorePages = endIndex < _scenarios.length;
  }

  /// Load more scenarios for pagination
  Future<void> _loadMoreScenarios() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() => _isLoadingMore = true);

    try {
      // Simulate network delay for smooth UX
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        final startIndex = _currentPage * _pageSize;
        final endIndex = (startIndex + _pageSize).clamp(0, _scenarios.length);

        setState(() {
          _displayedScenarios.addAll(_scenarios.sublist(startIndex, endIndex));
          _currentPage++;
          _hasMorePages = endIndex < _scenarios.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading more scenarios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to load more scenarios'),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadScenarios(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
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

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Update search query immediately for UI feedback
    setState(() {
      _search = query;
    });

    // PERFORMANCE FIX: Add 300ms debouncing to prevent UI jank on rapid typing
    // This prevents search execution on every keystroke which was causing frame drops
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        // UI_OPTIMIZATION: Execute search asynchronously to prevent UI thread blocking
        if (_aiSearchEnabled && query.trim().isNotEmpty) {
          _performAISearch(query);
        } else {
          _performAsyncSearch();
        }
      }
    });
  }

  /// Perform AI-powered search using IntelligentScenarioSearch
  Future<void> _performAISearch(String query) async {
    if (!mounted || query.trim().isEmpty) return;

    try {
      // Initialize AI search if needed
      if (!_aiSearchInitialized) {
        await _aiSearchService.initialize();
        _aiSearchInitialized = true;
      }

      // Perform intelligent search
      final searchResults = await _aiSearchService.search(query);

      // Extract scenarios from search results
      final scenarios = searchResults.map((result) => result.scenario).toList();

      if (mounted) {
        setState(() {
          _scenarios = scenarios;
          _currentPage = 0;
          _displayedScenarios.clear();
          _loadInitialPage();
        });
      }
    } catch (e) {
      debugPrint('❌ AI search error: $e');
      // Fallback to basic search
      _performAsyncSearch();
    }
  }

  void _onFilterChanged(String filter) {
    if (!mounted) return;

    setState(() {
      _selectedFilter = filter;
      _scenarios = _filterScenarios(_allScenarios);
      _currentPage = 0;
      _displayedScenarios.clear();
      _loadInitialPage();
    });
  }

  /// Perform search asynchronously to prevent UI thread blocking
  /// UI_OPTIMIZATION: Handles large result sets without blocking the main thread
  Future<void> _performAsyncSearch() async {
    if (!mounted) return;
    
    try {
      // For small datasets, execute directly
      // Threshold lowered to 200 for Android mid-range devices to prevent 200-300ms jank
      if (_allScenarios.length <= 200) {
        setState(() {
          _scenarios = _filterScenarios(_allScenarios);
          _currentPage = 0;
          _displayedScenarios.clear();
          _loadInitialPage();
        });
        return;
      }
      
      // For larger datasets, use compute to prevent UI blocking
      final searchParams = {
        'allScenarios': _allScenarios.map((s) => s.toJson()).toList(),
        'searchQuery': _search,
        'selectedFilter': _selectedFilter,
        'selectedChapter': _selectedChapter,
      };
      
      final results = await compute(_performSearchCompute, searchParams);
      
      if (mounted) {
        setState(() {
          _scenarios = results.map((json) => Scenario.fromJson(json)).toList();
          _currentPage = 0;
          _displayedScenarios.clear();
          _loadInitialPage();
        });
      }
    } catch (e) {
      debugPrint('Error in async search: $e');
      // Fallback to synchronous search if compute fails
      if (mounted) {
        setState(() {
          _scenarios = _filterScenarios(_allScenarios);
          _currentPage = 0;
          _displayedScenarios.clear();
          _loadInitialPage();
        });
      }
    }
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
          // Unified gradient background
          AppBackground(isDark: theme.brightness == Brightness.dark),

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
                        color: theme.colorScheme.surface.withValues(alpha:0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
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
                              fontSize: theme.textTheme.headlineLarge?.fontSize,
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
                                  theme.colorScheme.primary.withValues(alpha:0.6),
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
                              fontSize: theme.textTheme.bodyMedium?.fontSize,
                              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Search Bar with AI Toggle
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: _aiSearchEnabled ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha:0.2),
                            theme.colorScheme.secondary.withValues(alpha:0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) : null,
                        border: _aiSearchEnabled ? Border.all(
                          color: theme.colorScheme.primary.withValues(alpha:0.5),
                          width: 2,
                        ) : null,
                        boxShadow: _searchFocusNode.hasFocus
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: _aiSearchEnabled
                              ? '✨ AI Search: Try "feeling stressed at work"'
                              : (localizations?.searchScenarios ?? 'Search scenarios...'),
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                          prefixIcon: Icon(
                            _aiSearchEnabled ? Icons.auto_awesome : Icons.search,
                            color: _aiSearchEnabled ? theme.colorScheme.primary : null,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // AI Toggle Button
                              IconButton(
                                icon: Icon(
                                  Icons.psychology,
                                  color: _aiSearchEnabled
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(alpha:0.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _aiSearchEnabled = !_aiSearchEnabled;
                                  });
                                  // Re-run search if there's a query
                                  if (_search.isNotEmpty) {
                                    _onSearchChanged(_search);
                                  }
                                },
                                tooltip: _aiSearchEnabled ? 'Disable AI Search' : 'Enable AI Search',
                              ),
                              // Clear Button
                              if (_search.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                ),
                            ],
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface.withValues(alpha:.85),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
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
                                fontSize: theme.textTheme.bodySmall?.fontSize,
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
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
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
                                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true, // Allow ListView to size itself to content
                                physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling (parent ListView handles it)
                                // Calculate item count: scenarios + Load More button (if not all loaded) + total count message (if all loaded)
                                itemCount: _displayedScenarios.length +
                                    (_displayedScenarios.length < _scenarios.length ? 1 : 0) +
                                    (_displayedScenarios.length >= _scenarios.length && _scenarios.isNotEmpty ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Scenario cards
                                  if (index < _displayedScenarios.length) {
                                    return _buildScenarioCard(_displayedScenarios[index], theme);
                                  }

                                  // Load More button (if not all loaded)
                                  if (_displayedScenarios.length < _scenarios.length && index == _displayedScenarios.length) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Center(
                                          child: _isLoadingMore
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: CircularProgressIndicator(),
                                                )
                                              : ElevatedButton.icon(
                                                  onPressed: _loadMoreScenarios,
                                                  icon: const Icon(Icons.expand_more),
                                                  label: Text(
                                                    'Load More (${_scenarios.length - _displayedScenarios.length} remaining)',
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: theme.colorScheme.primaryContainer,
                                                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(25),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  }

                                  // Total count message (if all loaded)
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Showing all ${_scenarios.length} scenarios',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
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
          top: 40,
          right: 84,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amberAccent.withValues(alpha:0.9),
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
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
                splashRadius: 30,
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Navigate to home tab instead of trying to pop empty stack
                    NavigationService.instance.goToTab(0);
                  }
                },
                tooltip: AppLocalizations.of(context)!.back,
              ),
            ),
          ),
        ),
        
        // Floating Home Button
        Positioned(
          top: 40,
          right: 24,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amberAccent.withValues(alpha:0.9),
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
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
                splashRadius: 30,
                onPressed: () {
                  // Use proper tab navigation to sync bottom navigation state
                  try {
                    NavigationService.instance.goToTab(0); // 0 = Home tab index
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
                          color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Action buttons row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Share button
                        IconButton(
                          onPressed: () => _showShareDialog(scenario),
                          icon: Icon(
                            Icons.share,
                            size: 20, // Increased from 18 for better visibility
                            color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                          ),
                          tooltip: 'Share',
                          padding: const EdgeInsets.all(12), // Increased from 4 for WCAG compliance
                          constraints: const BoxConstraints(
                            minWidth: 44,  // WCAG 2.1 AA minimum touch target
                            minHeight: 44, // WCAG 2.1 AA minimum touch target
                          ),
                        ),
                        // Read More button
                        TextButton(
                          onPressed: () {
                            _fadePush(ScenarioDetailView(scenario: scenario));
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: const Size(60, 30),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.readMore,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: theme.textTheme.bodySmall?.fontSize,
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
              shadowColor: category.color.withValues(alpha:0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isSelected 
                    ? LinearGradient(
                        colors: [
                          category.color.withValues(alpha:0.8),
                          category.color.withValues(alpha:0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                  color: isSelected ? null : theme.colorScheme.surface.withValues(alpha:0.8),
                  border: Border.all(
                    color: category.color.withValues(alpha:isSelected ? 0.8 : 0.3),
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
                                fontSize: theme.textTheme.bodySmall?.fontSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatCount(count),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected 
                                  ? Colors.white.withValues(alpha:0.9) 
                                  : category.color.withValues(alpha:0.8),
                                fontSize: theme.textTheme.labelSmall?.fontSize,
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
          // Enhanced background opacity for WCAG AA compliance (4.5:1 contrast ratio)
          color: theme.brightness == Brightness.light
              ? mainCategory.color.withValues(alpha:0.35) // Increased to 0.35 for sufficient contrast
              : mainCategory.color.withValues(alpha:0.25), // Increased to 0.25 for sufficient contrast
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: mainCategory.color.withValues(alpha:0.4), // Increased from 0.3 for better visibility
            width: 1.5,
          ),
          // Enhanced shadow for better contrast
          boxShadow: [
            BoxShadow(
              color: mainCategory.color.withValues(alpha:0.15), // Increased shadow opacity
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
                        ? theme.colorScheme.onSurface.withValues(alpha:0.95)
                        : theme.colorScheme.onSurface.withValues(alpha:0.9),
                    fontSize: theme.textTheme.bodySmall?.fontSize, // Increased from 12 for better readability
                    fontWeight: FontWeight.w600, // Increased from w500 for better visibility
                    height: 1.4, // Added line height for better text spacing
                  ),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.includes,
                      style: TextStyle(
                        fontWeight: FontWeight.w700, // Bold for "Includes:" label
                        // Theme-aware color for WCAG compliance
                        color: theme.brightness == Brightness.light
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600, // Increased weight for description
                        // Theme-aware color for WCAG compliance
                        color: theme.brightness == Brightness.light
                            ? theme.colorScheme.onSurface.withValues(alpha:0.95)
                            : Colors.white.withValues(alpha:0.95),
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

  /// Build category and tag information pills for the header
  Widget _buildInfoPills(ThemeData theme) {
    final List<Widget> pills = [];
    
    // Show current filter category
    if (_selectedFilter != 'All' && _selectedFilter.isNotEmpty && !_selectedFilter.startsWith('Tag:')) {
      pills.add(_buildInfoPill(
        text: '📂 ${_selectedFilter}',
        backgroundColor: theme.colorScheme.primaryContainer,
        textColor: theme.colorScheme.onPrimaryContainer,
      ));
    }
    
    // Show sample tags from current scenarios (up to 3 most common)
    if (_filtered.isNotEmpty) {
      final Map<String, int> tagCounts = {};
      
      // Count tags in filtered scenarios
      for (final scenario in _filtered.take(20)) { // Analyze first 20 for performance
        if (scenario.tags != null) {
          for (final tag in scenario.tags!) {
            if (tag.trim().isNotEmpty) {
              tagCounts[tag.trim()] = (tagCounts[tag.trim()] ?? 0) + 1;
            }
          }
        }
      }
      
      // Get top 3 most common tags
      final sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topTags = sortedTags.take(3);
      for (final tagEntry in topTags) {
        pills.add(_buildInfoPill(
          text: '🏷️ ${tagEntry.key} (${tagEntry.value})',
          backgroundColor: theme.colorScheme.secondaryContainer,
          textColor: theme.colorScheme.onSecondaryContainer,
        ));
      }
    }
    
    // Show total scenario count
    if (_filtered.isNotEmpty) {
      pills.add(_buildInfoPill(
        text: '📊 ${_filtered.length} scenarios',
        backgroundColor: theme.colorScheme.tertiaryContainer,
        textColor: theme.colorScheme.onTertiaryContainer,
      ));
    }
    
    if (pills.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: pills,
    );
  }
  
  /// Build individual info pill widget
  Widget _buildInfoPill({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Show share dialog for a scenario
  void _showShareDialog(Scenario scenario) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareCardWidget(
        scenario: scenario,
        onShared: () {
          // Track sharing action
          _trackScenarioShared(scenario);
        },
      ),
    );
  }

  /// Track scenario shared for analytics
  Future<void> _trackScenarioShared(Scenario scenario) async {
    try {
      // You can add analytics tracking here if needed
      debugPrint('📤 Scenario "${scenario.title}" shared by user');
    } catch (e) {
      debugPrint('Failed to track scenario share: $e');
    }
  }

}

/// Compute function for background search processing
/// UI_OPTIMIZATION: Runs search filtering in separate isolate to prevent main thread blocking
List<Map<String, dynamic>> _performSearchCompute(Map<String, dynamic> params) {
  try {
    final allScenariosJson = params['allScenarios'] as List<dynamic>;
    final searchQuery = params['searchQuery'] as String;
    final selectedFilter = params['selectedFilter'] as String;
    final selectedChapter = params['selectedChapter'] as int?;
    
    // Convert back to Scenario objects
    final allScenarios = allScenariosJson
        .map((json) => Scenario.fromJson(json as Map<String, dynamic>))
        .toList();
    
    List<Scenario> filtered = List.from(allScenarios);
    
    // Apply chapter filter first
    if (selectedChapter != null) {
      filtered = filtered.where((s) => s.chapter == selectedChapter).toList();
      
      // Apply search within chapter scenarios
      if (searchQuery.trim().isNotEmpty) {
        filtered = filtered.where((s) => 
          s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.gitaWisdom.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (s.tags?.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase())) ?? false)
        ).toList();
      }
    } else {
      // Apply search filter first (if exists) - using basic search for compute
      if (searchQuery.trim().isNotEmpty) {
        filtered = filtered.where((s) => 
          s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.gitaWisdom.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.heartResponse.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.dutyResponse.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (s.tags?.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase())) ?? false)
        ).toList();
      }
      
      // Apply category/tag filters ONLY when search query is empty
      // When user types in search bar, search ALL scenarios regardless of selected category
      if (searchQuery.trim().isEmpty && selectedFilter != 'All') {
        switch (selectedFilter) {
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
            filtered = filtered.where((s) => s.category == selectedFilter).toList();
            break;
          default:
            // Handle custom tag filters
            if (selectedFilter.startsWith('Tag:')) {
              final tagName = selectedFilter.substring(4);
              filtered = filtered.where((s) => 
                s.tags?.any((tag) => tag.toLowerCase().contains(tagName.toLowerCase())) ?? false
              ).toList();
            } else {
              filtered = filtered.where((s) => 
                s.tags?.any((tag) => tag.toLowerCase().contains(selectedFilter.toLowerCase())) ?? false ||
                s.category.toLowerCase().contains(selectedFilter.toLowerCase())
              ).toList();
            }
            break;
        }
      }
    }
    
    // Convert back to JSON for return
    return filtered.map((s) => s.toJson()).toList();
    
  } catch (e) {
    debugPrint('Error in compute search: $e');
    return [];
  }
}


