import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        // use your theme surface so it shows up as a light card
        backgroundColor: theme.colorScheme.surface,
        title: Text(AppLocalizations.of(context)?.about ?? 'About'),
        centerTitle: true,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
              // Made with... section at top
              Card(
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.madeWithLove ?? 'Made with ❤️ for spiritual seekers',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Main content in the middle
              Card(
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.aboutGitaWisdom ?? 'About GitaWisdom',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          AppLocalizations.of(context)?.aboutDescription ?? 'GitaWisdom brings ancient wisdom to modern life. Navigate daily challenges with timeless teachings from the Bhagavad Gita.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.gitaQuote ?? '"You have a right to perform your prescribed duty, but never to the fruits of action."',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          AppLocalizations.of(context)?.gitaQuoteReference ?? '— Bhagavad Gita 2.47',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Version at bottom
              Card(
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.appVersion ?? 'Version 1.0.0',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
