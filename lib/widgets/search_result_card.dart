// lib/widgets/search_result_card.dart

import 'package:flutter/material.dart';
import '../models/search_result.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeIcon(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              result.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (result.relevanceScore > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(theme).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getTypeColor(theme).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${result.relevanceScore.toInt()}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getTypeColor(theme),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildHighlightedSnippet(theme),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(theme).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getTypeLabel(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getTypeColor(theme),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    final color = _getTypeColor(theme);
    final icon = _getTypeIcon();
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildHighlightedSnippet(ThemeData theme) {
    final snippet = result.snippet;
    if (snippet.isEmpty || query.isEmpty) {
      return Text(
        snippet,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Simple highlighting - in a real app, you might want more sophisticated highlighting
    final queryWords = query.toLowerCase().split(RegExp(r'\s+'));
    final text = snippet;
    final textLower = text.toLowerCase();
    
    final spans = <TextSpan>[];
    int lastIndex = 0;
    
    for (final word in queryWords) {
      if (word.length < 2) continue;
      
      final regex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      final matches = regex.allMatches(text);
      
      for (final match in matches) {
        // Add text before match
        if (match.start > lastIndex) {
          spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
        }
        
        // Add highlighted match
        spans.add(TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.3),
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ));
        
        lastIndex = match.end;
      }
    }
    
    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
    
    // If no matches found, return plain text
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          height: 1.4,
        ),
        children: spans,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getTypeColor(ThemeData theme) {
    switch (result.resultType) {
      case SearchType.verse:
        return Colors.blue;
      case SearchType.chapter:
        return Colors.green;
      case SearchType.scenario:
        return Colors.purple;
      case SearchType.query:
        return theme.colorScheme.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (result.resultType) {
      case SearchType.verse:
        return Icons.format_quote;
      case SearchType.chapter:
        return Icons.menu_book;
      case SearchType.scenario:
        return Icons.psychology;
      case SearchType.query:
        return Icons.search;
    }
  }

  String _getTypeLabel() {
    switch (result.resultType) {
      case SearchType.verse:
        return result.chapterId != null 
            ? 'Chapter ${result.chapterId} • Verse ${result.verseId ?? ''}' 
            : 'Verse';
      case SearchType.chapter:
        return result.chapterId != null 
            ? 'Chapter ${result.chapterId}' 
            : 'Chapter';
      case SearchType.scenario:
        return 'Life Scenario';
      case SearchType.query:
        return 'Search Query';
    }
  }
}