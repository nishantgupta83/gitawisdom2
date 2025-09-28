// lib/widgets/search_suggestions.dart

import 'package:flutter/material.dart';
import '../models/search_result.dart';

class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final List<SearchResult> recentSearches;
  final Function(String) onSuggestionTap;
  final Function(String) onRecentSearchTap;
  final VoidCallback? onClearRecentSearches;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.recentSearches,
    required this.onSuggestionTap,
    required this.onRecentSearchTap,
    this.onClearRecentSearches,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            _buildRecentSearchesSection(theme),
            const SizedBox(height: 24),
          ],
          _buildSuggestionsSection(theme),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onClearRecentSearches != null)
              TextButton(
                onPressed: onClearRecentSearches,
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.take(5).map((search) {
            return _buildRecentSearchChip(search, theme);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentSearchChip(SearchResult search, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onRecentSearchTap(search.searchQuery),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                search.searchQuery,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildSuggestionGrid(theme),
      ],
    );
  }

  Widget _buildSuggestionGrid(ThemeData theme) {
    final popularSuggestions = suggestions.take(12).toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: popularSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = popularSuggestions[index];
        return _buildSuggestionCard(suggestion, theme);
      },
    );
  }

  Widget _buildSuggestionCard(String suggestion, ThemeData theme) {
    final icon = _getIconForSuggestion(suggestion);
    final color = _getColorForSuggestion(suggestion, theme);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onSuggestionTap(suggestion),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSuggestion(String suggestion) {
    final lowerSuggestion = suggestion.toLowerCase();
    
    if (lowerSuggestion.contains('chapter')) {
      return Icons.menu_book;
    } else if (lowerSuggestion.contains('dharma') || 
               lowerSuggestion.contains('duty') || 
               lowerSuggestion.contains('righteousness')) {
      return Icons.balance;
    } else if (lowerSuggestion.contains('karma') || 
               lowerSuggestion.contains('action')) {
      return Icons.trending_up;
    } else if (lowerSuggestion.contains('meditation') || 
               lowerSuggestion.contains('yoga')) {
      return Icons.self_improvement;
    } else if (lowerSuggestion.contains('wisdom') || 
               lowerSuggestion.contains('knowledge')) {
      return Icons.lightbulb;
    } else if (lowerSuggestion.contains('devotion') || 
               lowerSuggestion.contains('bhakti') || 
               lowerSuggestion.contains('love')) {
      return Icons.favorite;
    } else if (lowerSuggestion.contains('peace') || 
               lowerSuggestion.contains('calm')) {
      return Icons.spa;
    } else if (lowerSuggestion.contains('soul') || 
               lowerSuggestion.contains('consciousness')) {
      return Icons.psychology;
    } else if (lowerSuggestion.contains('krishna') || 
               lowerSuggestion.contains('arjuna')) {
      return Icons.person;
    } else {
      return Icons.search;
    }
  }

  Color _getColorForSuggestion(String suggestion, ThemeData theme) {
    final lowerSuggestion = suggestion.toLowerCase();
    
    if (lowerSuggestion.contains('chapter')) {
      return Colors.blue;
    } else if (lowerSuggestion.contains('dharma') || 
               lowerSuggestion.contains('duty')) {
      return Colors.green;
    } else if (lowerSuggestion.contains('karma') || 
               lowerSuggestion.contains('action')) {
      return Colors.orange;
    } else if (lowerSuggestion.contains('meditation') || 
               lowerSuggestion.contains('yoga')) {
      return Colors.purple;
    } else if (lowerSuggestion.contains('wisdom') || 
               lowerSuggestion.contains('knowledge')) {
      return Colors.amber;
    } else if (lowerSuggestion.contains('devotion') || 
               lowerSuggestion.contains('bhakti') || 
               lowerSuggestion.contains('love')) {
      return Colors.pink;
    } else if (lowerSuggestion.contains('peace')) {
      return Colors.teal;
    } else if (lowerSuggestion.contains('soul') || 
               lowerSuggestion.contains('consciousness')) {
      return Colors.indigo;
    } else {
      return theme.colorScheme.primary;
    }
  }
}