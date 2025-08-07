import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

typedef EntryCallback = Future<void> Function(JournalEntry e);

class NewJournalEntryDialog extends StatefulWidget {
  final EntryCallback onSave;
  const NewJournalEntryDialog({Key? key, required this.onSave})
      : super(key: key);

  @override
  _NewJournalEntryDialogState createState() => _NewJournalEntryDialogState();
}

class _NewJournalEntryDialogState extends State<NewJournalEntryDialog> {
  final _ctrl = TextEditingController();
  int _rating = 0;
  bool _saving = false;

  Future<void> _doSave() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reflection: text,
      rating: _rating,
    );

    await widget.onSave(entry);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    return AlertDialog(
      title: const Text('New Journal Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(labelText: 'Your Reflection'),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return IconButton(
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: theme.colorScheme.secondary,
                ),
                onPressed: _saving ? null : () => setState(() => _rating = i + 1),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(c),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _doSave,
          child: _saving
              ? const SizedBox(
                  height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
