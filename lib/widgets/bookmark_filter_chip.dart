// lib/widgets/bookmark_filter_chip.dart

import 'package:flutter/material.dart';
import '../models/bookmark.dart';

class BookmarkFilterChip extends StatelessWidget {
  final BookmarkType? filterType;
  final BookmarkType? selectedFilter;
  final String label;
  final int count;
  final ValueChanged<BookmarkType?> onSelected;

  const BookmarkFilterChip({
    super.key,
    this.filterType,
    required this.selectedFilter,
    required this.label,
    required this.count,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedFilter == filterType;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(isSelected ? null : filterType),
      selectedColor: theme.colorScheme.primaryContainer,
      backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
      side: BorderSide(
        color: isSelected 
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
      showCheckmark: false,
    );
  }
}