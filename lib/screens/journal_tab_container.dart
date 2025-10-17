import 'package:flutter/material.dart';
import '../services/supabase_auth_service.dart';
import 'journal_screen.dart';
import 'modern_auth_screen.dart';

class JournalTabContainer extends StatelessWidget {
  const JournalTabContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SupabaseAuthService authService = SupabaseAuthService.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<bool>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(context);
          }

          final isAuthenticated = snapshot.data ?? false;

          // Check BOTH authenticated AND anonymous for access
          if (!isAuthenticated && !authService.isAnonymous) {
            return _buildAuthPrompt(context);
          }

          return const JournalScreen();
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading journal...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthPrompt(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = SupabaseAuthService.instance;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha:0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to access Journal',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your journal entries are private and synced across devices',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: (isDark ? Colors.white : Colors.black87).withValues(alpha:0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Sign in button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ModernAuthScreen(
                      isModal: true, // Mark as modal launch from within app
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Continue as guest option
            TextButton(
              onPressed: () async {
                // Use consistent method name
                final success = await authService.signInAnonymously();

                // Error handling
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Unable to continue as guest. Please try again.'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                // Note: No navigation needed - StreamBuilder will auto-update
                // When isAnonymous becomes true, it will show JournalScreen automatically
              },
              child: Text(
                'Continue as Guest',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}