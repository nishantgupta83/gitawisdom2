import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../screens/new_journal_entry_dialog.dart';
import '../screens/journal_entry_detail_view.dart';

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
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _loading
                ? null
                : () => showDialog(
                      context: c,
                      builder: (_) => NewJournalEntryDialog(
                        onSave: (entry) async {
                          await _service.createEntry(entry);
                          await _reload();
                        },
                      ),
                    ),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (ctx, i) {
                final e = _entries[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(e.reflection, style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      e.dateCreated.toLocal().toIso8601String().split('T').first,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (j) {
                        return Icon(
                          j < e.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalEntryDetailView(entry: e),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
