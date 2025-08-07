/*
// lib/screens/journal_entry_detail_view.dart

import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

/// Displays the full contents of a single JournalEntry.
class JournalEntryDetailView extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryDetailView({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate =
        '${entry.dateCreated.year.toString().padLeft(4, '0')}-'
        '${entry.dateCreated.month.toString().padLeft(2, '0')}-'
        '${entry.dateCreated.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reflection text
            Text(
              entry.reflection,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Rating stars
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < entry.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(height: 8),

            // Date line
            Text(
              'On $formattedDate',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

*/
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

class JournalEntryDetailView extends StatelessWidget {
  final JournalEntry entry;
  const JournalEntryDetailView({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Entry Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.reflection, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Row(children: List.generate(5, (i) {
            return Icon(
              i < entry.rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            );
          })),
          const SizedBox(height: 8),
          Text(
            'On ${entry.dateCreated.toLocal().toIso8601String().split("T").first}',
            style: theme.textTheme.bodySmall,
          ),
        ]),
      ),
    );
  }
}

