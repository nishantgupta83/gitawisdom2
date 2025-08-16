import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ReferencesScreen extends StatelessWidget {
  const ReferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(AppLocalizations.of(context)?.referencesTitle ?? 'References'),
        centerTitle: true,
        elevation: 4,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Card(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.reference1 ?? 'Bhagavad-gītā As It Is by A.C. Bhaktivedanta Swami Prabhupāda',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)?.reference2 ?? 'The Bhagavad Gita translated by Eknath Easwaran',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)?.reference3 ?? 'The Bhagavad Gita translated by Barbara Stoler Miller',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
