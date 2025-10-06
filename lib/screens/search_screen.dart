// lib/screens/search_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/intelligent_scenario_search.dart';
import '../models/scenario.dart';
import '../screens/scenario_detail_view.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final IntelligentScenarioSearch _searchService = IntelligentScenarioSearch.instance;

  List<Scenario> _results = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isInitializing = true;
  String _lastQuery = '';
  int _currentMaxResults = 20;
  bool _hasMoreResults = true;

  late AnimationController _glowAnimationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize glow animation
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_glowAnimationController);
    _glowAnimationController.repeat();

    _initializeSearch();

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
  }

  Future<void> _initializeSearch() async {
    setState(() => _isInitializing = true);

    try {
      await _searchService.initialize();
    } catch (e) {
      debugPrint('⚠️ Search initialization error: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Search Wisdom'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          if (_isInitializing) ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing intelligent search...'),
                  ],
                ),
              ),
            ),
          ] else if (_isLoading) ...[
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (_results.isNotEmpty) ...[
            Expanded(child: _buildResultsList(theme)),
          ] else if (_lastQuery.isNotEmpty) ...[
            _buildEmptyState(theme),
          ] else ...[
            _buildWelcomeState(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              // Calculate rotation angle for snake effect
              final angle = _glowAnimation.value * 2 * math.pi;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.8),
                      blurRadius: 20,
                      spreadRadius: math.sin(angle) * 2 + 1,
                      offset: Offset(
                        math.cos(angle) * 2,
                        math.sin(angle) * 2,
                      ),
                    ),
                    BoxShadow(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.6),
                      blurRadius: 15,
                      spreadRadius: math.cos(angle + math.pi / 2) * 2 + 1,
                      offset: Offset(
                        math.cos(angle + math.pi) * 2,
                        math.sin(angle + math.pi) * 2,
                      ),
                    ),
                  ],
                ),
                child: child!,
              );
            },
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Ask about any life situation...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _lastQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withValues(alpha:0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _performSearch();
                }
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: theme.colorScheme.primary.withValues(alpha:0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Powered by AI',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary.withValues(alpha:0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length + 2, // +1 for header, +1 for load more button
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Showing ${_results.length} scenarios for "$_lastQuery"',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        // Load more button at the end
        if (index == _results.length + 1) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (_hasMoreResults) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton.icon(
                onPressed: _loadMoreResults,
                icon: const Icon(Icons.expand_more),
                label: const Text('Load More Results'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'All matching scenarios shown',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }

        final scenario = _results[index - 1];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _onScenarioTap(scenario),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scenario.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // _buildSearchTypeBadge(result.searchType, theme), // Disabled for auth testing
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scenario.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scenario.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.book_outlined,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Chapter ${scenario.chapter}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchTypeBadge(String searchType, ThemeData theme) {
    IconData icon;
    String label;
    Color color;

    switch (searchType) {
      case 'keyword':
        icon = Icons.sort_by_alpha;
        label = 'Keyword';
        color = Colors.blue;
        break;
      case 'semantic':
        icon = Icons.psychology;
        label = 'AI';
        color = Colors.purple;
        break;
      case 'hybrid':
        icon = Icons.auto_awesome;
        label = 'Hybrid';
        color = Colors.green;
        break;
      default:
        icon = Icons.search;
        label = 'Match';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha:0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No scenarios found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or rephrase your query',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState(ThemeData theme) {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha:0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'AI-Powered Wisdom Search',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Search across 1280 life scenarios using intelligent keyword and semantic AI search.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildExampleChip('Career decisions', theme),
                  _buildExampleChip('Family conflicts', theme),
                  _buildExampleChip('Work-life balance', theme),
                  _buildExampleChip('Personal growth', theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleChip(String label, ThemeData theme) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _performSearch();
      },
      backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha:0.5),
    );
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _lastQuery = query;
      _currentMaxResults = 20; // Reset to initial count
    });

    try {
      final searchResults = await _searchService.search(query, maxResults: _currentMaxResults);
      final scenarios = searchResults.map((result) => result.scenario).toList();

      if (mounted) {
        setState(() {
          _results = scenarios;
          _isLoading = false;
          _hasMoreResults = scenarios.length >= _currentMaxResults;
        });

        debugPrint('🔍 Search completed: Found ${scenarios.length} results for "$query"');
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _loadMoreResults() async {
    if (_isLoadingMore || !_hasMoreResults) return;

    setState(() {
      _isLoadingMore = true;
      _currentMaxResults += 20; // Load 20 more
    });

    try {
      final searchResults = await _searchService.search(_lastQuery, maxResults: _currentMaxResults);
      final scenarios = searchResults.map((result) => result.scenario).toList();

      if (mounted) {
        setState(() {
          _results = scenarios;
          _isLoadingMore = false;
          _hasMoreResults = scenarios.length >= _currentMaxResults;
        });

        debugPrint('📊 Loaded more: Now showing ${scenarios.length} results for "$_lastQuery"');
      }
    } catch (e) {
      debugPrint('❌ Load more error: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScenarioTap(Scenario scenario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScenarioDetailView(scenario: scenario),
      ),
    );
  }
}