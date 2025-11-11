import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../screens/new_journal_entry_dialog.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_background.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _service = JournalService.instance;
  List<JournalEntry> _entries = [];
  bool _loading = true;
  bool _isFetching = false; // Prevent duplicate fetches

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;

    // Prevent duplicate simultaneous fetches
    if (_isFetching) {
      debugPrint('⚠️ Journal fetch already in progress, skipping duplicate call');
      return;
    }

    _isFetching = true;
    setState(() => _loading = true);
    try {
      debugPrint('📔 Starting journal fetch...');
      _entries = await _service.fetchEntries();
      debugPrint('✅ Journal fetch completed: ${_entries.length} entries');

      // Start background sync if needed (non-blocking)
      _service.backgroundSync();

    } catch (e) {
      debugPrint('Error loading journal entries: $e');
      // Keep existing entries on error
    } finally {
      _isFetching = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Unified gradient background
          AppBackground(isDark: isDark),

          // Main content with bottom padding for nav bar
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await _service.refreshFromServer();
                await _reload();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Padding for nav bar only
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _getListItemCount(),
                      itemBuilder: (context, index) => _buildListItem(index, constraints),
                    ),
                  );
                },
              ),
            ),
          ),

          // Add button positioned in top-right below "My Journal" card
          Positioned(
            top: 120,
            right: 24,
            child: SafeArea(
              child: FloatingActionButton(
                onPressed: _loading
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (_) => NewJournalEntryDialog(
                            onSave: (entry) async {
                              try {
                                await _service.createEntry(entry);
                                // No need to reload - createEntry already adds to cache
                                // This prevents duplication
                                setState(() {}); // Just trigger UI refresh
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${localizations.failedToSaveEntry}: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                child: const Icon(Icons.add),
                tooltip: localizations.addJournalEntry,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get total list item count (header + entries)
  int _getListItemCount() {
    return 2 + _entries.length; // Header + empty/entries + bottom padding
  }

  /// Build list item by index
  Widget _buildListItem(int index, BoxConstraints constraints) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    if (index == 0) {
      // Header card
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Card(
          elevation: 8,
          color: theme.colorScheme.surface.withValues(alpha: 0.98), // Increased from 0.95 for better readability
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
            child: Column(
              children: [
                Text(
                  localizations.myJournal,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  localizations.trackSpiritual,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (index == 1) {
      // Content area (loading, empty, or entries start)
      if (_loading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (_entries.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.noJournalEntries,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.tapPlusButton,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else {
        // Empty placeholder - entries start at index 2
        return const SizedBox.shrink();
      }
    } else {
      // Journal entries (starting from index 2)
      final entryIndex = index - 2;
      if (entryIndex < _entries.length) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: _buildJournalCard(_entries[entryIndex], theme, localizations),
        );
      } else {
        // Bottom padding
        return const SizedBox(height: 80);
      }
    }
  }

  Widget _buildJournalCard(JournalEntry entry, ThemeData theme, AppLocalizations localizations) {
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white, size: 28),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, entry, localizations);
      },
      onDismissed: (direction) async {
        await _deleteJournalEntry(entry, localizations);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 2, // Reduced from 8 for modern, subtle depth
          color: theme.colorScheme.surface.withValues(alpha: 0.98),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Metadata header with background tint for visual grouping
              _buildMetadataHeader(entry, theme, context),

              // Reflection content - flows directly from header (no gap)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  entry.reflection,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.6, // Better line spacing
                    fontSize: 15, // Slightly larger for readability
                  ),
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build metadata header with visual grouping via background tint
  Widget _buildMetadataHeader(JournalEntry entry, ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Date (vertical stack for better hierarchy)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip - primary focus
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.category,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // Increased from 10 for accessibility
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                // Date - secondary info
                Text(
                  entry.dateCreated.toLocal().toIso8601String().split('T').first,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Rating stars with screen reader support
          Semantics(
            label: '${entry.rating} out of 5 stars',
            readOnly: true,
            child: Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < entry.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber[700],
                  size: 18, // Increased from 14-16 for better visibility
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmation(BuildContext context, JournalEntry entry, AppLocalizations localizations) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteEntry ?? 'Delete Entry'),
          content: Text(
            localizations.deleteConfirmation ?? 'Are you sure you want to delete this journal entry? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(localizations.delete ?? 'Delete'),
            ),
          ],
        );
      },
    );
  }


  /// Delete journal entry with feedback
  Future<void> _deleteJournalEntry(JournalEntry entry, AppLocalizations localizations) async {
    try {
      await _service.deleteEntry(entry.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.entryDeleted ?? 'Journal entry deleted'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: localizations.undo ?? 'Undo',
              onPressed: () async {
                // Restore the deleted entry
                try {
                  await _service.createEntry(entry);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.entryRestored ?? 'Journal entry restored'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${localizations.failedToRestoreEntry ?? 'Failed to restore entry'}: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
        await _reload(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.failedToDeleteEntry ?? 'Failed to delete entry'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
