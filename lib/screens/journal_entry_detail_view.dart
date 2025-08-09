import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../main.dart';

class JournalEntryDetailView extends StatelessWidget {
  final JournalEntry entry;
  const JournalEntryDetailView({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = entry.dateCreated.toLocal().toIso8601String().split('T').first;
    
    return Scaffold(
      // Global background handled by main.dart
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main scrollable content
          SafeArea(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              'JOURNAL ENTRY',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Reflection from $formattedDate',
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

                  // Journal Entry Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating stars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < entry.rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 28,
                                );
                              }),
                            ),
                            const SizedBox(height: 24),
                            
                            // Reflection text
                            Text(
                              entry.reflection,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Date and metadata
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Written on $formattedDate',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating navigation buttons
          Positioned(
            top: 26,
            right: 84,
            child: _glowingNavButton(
              context: context,
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
              context: context,
              icon: Icons.home,
              onTap: () {
                // Navigate back to root by popping until we reach the root
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowingNavButton({
    required BuildContext context,
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

