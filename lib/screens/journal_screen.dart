import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../screens/new_journal_entry_dialog.dart';
import '../screens/journal_entry_detail_view.dart';
import '../screens/home_screen.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _service = JournalService.instance;
  List<JournalEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      _entries = await _service.fetchEntries();
      
      // Start background sync if needed (non-blocking)
      _service.backgroundSync();
      
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
      // Keep existing entries on error
    } finally {
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
          // Background image with dark overlay for dark mode
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: isDark ? Colors.black.withAlpha((0.32 * 255).toInt()) : null,
              colorBlendMode: isDark ? BlendMode.darken : null,
            ),
          ),
          
          // Main content
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
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
        ],
      ),
      
      // Floating Action Button for adding new entries
      floatingActionButton: FloatingActionButton(
        onPressed: _loading
            ? null
            : () => showDialog(
                  context: context,
                  builder: (_) => NewJournalEntryDialog(
                    onSave: (entry) async {
                      try {
                        await _service.createEntry(entry);
                        await _reload();
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
    
    if (index == 0) {
      // Header card
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Card(
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
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.noJournalEntries,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.tapPlusButton,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else {
        // First entry
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: _buildJournalCard(_entries[0], theme, localizations),
        );
      }
    } else {
      // Subsequent entries
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
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date, Category and Rating - Responsive Layout
                _buildResponsiveDateCategoryRating(entry, theme, context),
                const SizedBox(height: 12),
                
                // Reflection Text
                Text(
                  entry.reflection,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Read More Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JournalEntryDetailView(entry: entry),
                        ),
                      );
                    },
                    child: Text(localizations.readMore),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  /// Build responsive date/category/rating layout to prevent overflow
  Widget _buildResponsiveDateCategoryRating(JournalEntry entry, ThemeData theme, BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use Column layout for large text or narrow screens to prevent overflow
    final useColumnLayout = textScaleFactor > 1.1 || screenWidth < 360;
    
    if (useColumnLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and category
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.dateCreated.toLocal().toIso8601String().split('T').first,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        entry.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Rating stars in separate row
          Row(
            children: [
              Text(
                'Rating: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              ...List.generate(5, (j) {
                return Icon(
                  j < entry.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ],
          ),
        ],
      );
    } else {
      // Original Row layout for normal text sizes
      return Row(
        children: [
          Expanded(
            flex: 4, // Give more space to left side
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.dateCreated.toLocal().toIso8601String().split('T').first,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Fixed-width stars container
          SizedBox(
            width: 100, // Fixed width to prevent overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (j) {
                return Icon(
                  j < entry.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 14, // Slightly smaller in row layout
                );
              }),
            ),
          ),
        ],
      );
    }
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
