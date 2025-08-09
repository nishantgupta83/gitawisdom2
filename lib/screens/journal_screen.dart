import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../screens/new_journal_entry_dialog.dart';
import '../screens/journal_entry_detail_view.dart';
import '../screens/home_screen.dart';
import '../main.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _service = JournalService();
  List<JournalEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _entries = await _service.fetchEntries();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      // Global background handled by main.dart
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main scrollable content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Branding Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                      child: Card(
                        // Use theme.cardTheme styling
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
                          child: Column(
                            children: [
                              Text(
                                'MY JOURNAL',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Track your spiritual reflections and growth',
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

                    // Journal Entries List
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      child: _loading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _entries.isEmpty
                              ? Center(
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
                                          'No journal entries yet',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap the + button to create your first reflection',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _entries.map((entry) => _buildJournalCard(entry, theme)).toList(),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Floating navigation buttons
          Positioned(
            top: 26,
            right: 84,
            child: _glowingNavButton(
              icon: Icons.arrow_back,
              onTap: () {
                // Check if we can pop, otherwise go to home
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                } else {
                  // If no route to pop to, navigate back to root
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RootScaffold()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
          Positioned(
            top: 26,
            right: 24,
            child: _glowingNavButton(
              icon: Icons.home,
              onTap: () {
                // Navigate back to root by popping until we reach the root
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
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
                      await _service.createEntry(entry);
                      await _reload();
                    },
                  ),
                ),
        child: const Icon(Icons.add),
        tooltip: 'Add Journal Entry',
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.dateCreated.toLocal().toIso8601String().split('T').first,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (j) {
                      return Icon(
                        j < entry.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                ],
              ),
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
                  child: const Text('Read More'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowingNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amberAccent.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: IconButton(
            splashRadius: 32,
            icon: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );
}
