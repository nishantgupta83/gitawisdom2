// lib/widgets/bookmark_card.dart

import 'package:flutter/material.dart';
import '../models/bookmark.dart';

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    this.onTap,
    this.onRemove,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 8),
                _buildContent(theme),
                if (bookmark.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildTags(theme),
                ],
                if (bookmark.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildNotes(theme),
                ],
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildTypeIcon(theme),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            bookmark.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (bookmark.isHighlighted) _buildHighlightIndicator(),
        _buildActions(theme),
      ],
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (bookmark.bookmarkType) {
      case BookmarkType.verse:
        iconData = Icons.format_quote;
        iconColor = theme.colorScheme.primary;
        break;
      case BookmarkType.chapter:
        iconData = Icons.menu_book;
        iconColor = theme.colorScheme.secondary;
        break;
      case BookmarkType.scenario:
        iconData = Icons.psychology;
        iconColor = theme.colorScheme.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        size: 20,
        color: iconColor,
      ),
    );
  }

  Widget _buildHighlightIndicator() {
    Color highlightColor;
    switch (bookmark.highlightColor) {
      case HighlightColor.yellow:
        highlightColor = Colors.yellow.shade600;
        break;
      case HighlightColor.green:
        highlightColor = Colors.green.shade600;
        break;
      case HighlightColor.blue:
        highlightColor = Colors.blue.shade600;
        break;
      case HighlightColor.pink:
        highlightColor = Colors.pink.shade600;
        break;
      case HighlightColor.purple:
        highlightColor = Colors.purple.shade600;
        break;
    }

    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: highlightColor.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'remove':
            onRemove?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Remove', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: 20,
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (bookmark.contentPreview?.isNotEmpty != true) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        bookmark.contentPreview!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: bookmark.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          tag,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildNotes(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note,
            size: 16,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bookmark.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        _buildChapterInfo(theme),
        const Spacer(),
        _buildSyncStatus(theme),
        const SizedBox(width: 8),
        _buildTimestamp(theme),
      ],
    );
  }

  Widget _buildChapterInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Chapter ${bookmark.chapterId}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSyncStatus(ThemeData theme) {
    if (bookmark.syncStatus == SyncStatus.synced) {
      return Icon(
        Icons.cloud_done,
        size: 14,
        color: Colors.green.shade600,
      );
    } else if (bookmark.syncStatus == SyncStatus.pending) {
      return Icon(
        Icons.cloud_upload,
        size: 14,
        color: Colors.orange.shade600,
      );
    } else {
      return Icon(
        Icons.cloud_off,
        size: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      );
    }
  }

  Widget _buildTimestamp(ThemeData theme) {
    final timeAgo = _getTimeAgo(bookmark.createdAt);
    return Text(
      timeAgo,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}