import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/settings_service.dart';
import '../services/background_music_service.dart';
import '../services/app_sharing_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/cache_refresh_service.dart';
import '../services/enhanced_supabase_service.dart';
import 'package:provider/provider.dart';
import '../screens/about_screen.dart';
import '../screens/search_screen.dart';
import '../screens/web_view_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _version = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      // Load app version
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = '${info.version}+${info.buildNumber}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Failed to initialize More screen: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load screen';
          _isLoading = false;
        });
      }
    }
  }

  void _openWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          url: url,
          title: title,
        ),
      ),
    );
  }

  void _sendFeedback() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(now);

    final subject = 'GitaWisdom || Feedback || $formattedDate';
    final body = 'Hi Team,\n\nWould like to provide feedback on,\n1: \n2: \n\nRegards';

    final uri = Uri(
      scheme: 'mailto',
      path: 'support@hub4apps.com',
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    await launchUrl(uri);
  }

  /// Show in-app feedback dialog (kept for reference, no longer used)
  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.feedback_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Send Feedback'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Help us improve GitaWisdom! Share your thoughts, suggestions, or report issues.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final feedback = feedbackController.text.trim();
                if (feedback.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your feedback'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback! We appreciate it.'),
                    backgroundColor: Colors.green,
                  ),
                );

                feedbackController.dispose();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Removed problematic _clearCache method that manually accessed Hive boxes
  // Cache clearing should be handled through proper service methods if needed

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading settings...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeScreen();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView(
        children: [
          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('APPEARANCE', style: theme.textTheme.titleSmall?.copyWith(letterSpacing: 0.5, color: theme.colorScheme.onSurfaceVariant)),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildSafeConsumer<SettingsService>(
                  builder: (context, settingsService, child) {
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: settingsService.isDarkMode,
                      onChanged: (v) {
                        settingsService.isDarkMode = v;
                        debugPrint('🌓 Dark mode changed to: $v');
                      },
                    );
                  },
                  fallback: _buildLoadingListTile('Dark Mode', 'Loading theme settings...'),
                ),
                const Divider(height: 1),
                Consumer<BackgroundMusicService>(
                  builder: (context, musicService, child) {
                    return SwitchListTile(
                      title: const Text('Background Music'),
                      subtitle: const Text('Enable ambient meditation music'),
                      value: musicService.isEnabled,
                      onChanged: (v) async {
                        try {
                          await musicService.setEnabled(v);
                          debugPrint('🎵 Background music ${v ? 'enabled' : 'disabled'}');
                        } catch (e) {
                          debugPrint('⚠️ Failed to toggle background music: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to toggle music: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                Consumer<SettingsService>(
                  builder: (context, settingsService, child) {
                    return ListTile(
                      title: const Text('Font Size'),
                      trailing: DropdownButton<String>(
                        value: settingsService.fontSize,
                        items: const [
                          DropdownMenuItem(value: 'small', child: Text('Small')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'large', child: Text('Large')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            settingsService.fontSize = v;
                            debugPrint('📝 Font size changed to: $v');
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('CONTENT', style: theme.textTheme.titleSmall?.copyWith(
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              subtitle: const Text('Find life situations and wisdom'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
          ),

          // Resources section (About, Feedback, Privacy & Legal)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('RESOURCES', style: theme.textTheme.titleSmall?.copyWith(letterSpacing: 0.5, color: theme.colorScheme.onSurfaceVariant)),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Send Feedback'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _sendFeedback,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openWebView('https://hub4apps.com/privacy.html', 'Privacy Policy'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openWebView('https://hub4apps.com/terms.html', 'Terms of Service'),
                ),
              ],
            ),
          ),

          // Extras section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('EXTRAS', style: theme.textTheme.titleSmall?.copyWith(
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share This App'),
                  onTap: () async => await AppSharingService().shareApp(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('App Version'),
                  trailing: Text(_version, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),

          // Account section - collapsed design (iOS-style with Card)
          Selector<SupabaseAuthService, bool>(
            selector: (context, authService) => authService.isAuthenticated,
            builder: (context, isAuthenticated, child) {
              if (isAuthenticated) {
                return Consumer<SupabaseAuthService>(
                  builder: (context, authService, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text('ACCOUNT', style: theme.textTheme.titleSmall?.copyWith(
                            letterSpacing: 0.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                        ),
                        Card(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: ExpansionTile(
                            leading: Icon(Icons.account_circle, color: theme.colorScheme.primary),
                            title: Text(
                              authService.displayName ?? 'User',
                              style: theme.textTheme.titleSmall,
                            ),
                            subtitle: Text(
                              authService.userEmail ?? '',
                              style: theme.textTheme.bodySmall,
                            ),
                            collapsedBackgroundColor: theme.colorScheme.surface,
                            backgroundColor: theme.colorScheme.surface,
                            children: [
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text('Sign Out'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _handleSignOut(context, authService),
                          ),
                          ListTile(
                            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                            title: Text(
                              'Delete Account',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                              trailing: Icon(Icons.chevron_right, color: theme.colorScheme.error),
                              onTap: () => _showDeleteAccountDialog(context, authService),
                            ),
                          ],
                        ),
                      ),
                    ],
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Cache Management section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('CACHE MANAGEMENT', style: theme.textTheme.titleSmall?.copyWith(
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.cached),
              title: const Text('Refresh All Data'),
              subtitle: const Text('Clear and reload chapters, verses & scenarios (Device Specific)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _handleRefreshCache(context),
            ),
          ),
        ],
      );
    }

  /// Safe Consumer wrapper that provides fallback UI if service is not available
  Widget _buildSafeConsumer<T extends ChangeNotifier>({
    required Widget Function(BuildContext, T, Widget?) builder,
    required Widget fallback,
  }) {
    return Consumer<T>(
      builder: (context, service, child) {
        try {
          // Try to access the service
          return builder(context, service, child);
        } catch (e) {
          debugPrint('⚠️ Consumer error for ${T.toString()}: $e');
          return fallback;
        }
      },
    );
  }

  /// Loading state for list tiles
  Widget _buildLoadingListTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// Handle sign out with confirmation
  Future<void> _handleSignOut(BuildContext context, SupabaseAuthService authService) async {
    // Dismiss any active snackbars before showing dialog
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out?'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // Dismiss any snackbars again before signing out
    ScaffoldMessenger.of(context).clearSnackBars();

    // Save navigator and scaffold messenger for use after async operation
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Signing out...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Perform sign out
      await authService.signOut();

      if (!mounted) return;

      // Clear all snackbars before closing dialog
      scaffoldMessenger.clearSnackBars();

      // Use saved navigator reference instead of context
      try {
        navigator.pop(); // Close loading dialog
      } catch (e) {
        debugPrint('⚠️ Could not close dialog: $e');
      }

      // Navigation is handled automatically by auth state listener
      // in main.dart - user will be redirected to home/auth screen
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      if (!mounted) return;

      // Clear snackbars even on error
      scaffoldMessenger.clearSnackBars();

      try {
        navigator.pop(); // Close loading dialog
      } catch (popError) {
        debugPrint('⚠️ Could not close dialog: $popError');
      }

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Show delete account confirmation dialog
  Future<void> _showDeleteAccountDialog(BuildContext context, SupabaseAuthService authService) async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              const Text('Delete Account?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action is immediate and cannot be undone.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'All your data will be permanently deleted:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),
              const Text('• Journal entries and reflections'),
              const Text('• Bookmarks and saved verses'),
              const Text('• Progress tracking data'),
              const Text('• Account credentials and information'),
              const SizedBox(height: 16),
              Text(
                'Your account will be deleted from our servers immediately. If you signed in with Apple or Google, you may need to revoke access separately in your account settings.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you absolutely sure you want to delete your account?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performAccountDeletion(context, authService);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  /// Perform account deletion with Hive data clearing
  Future<void> _performAccountDeletion(BuildContext context, SupabaseAuthService authService) async {
    try {
      // Use ValueNotifier to track progress and update UI without blocking
      final messageNotifier = ValueNotifier<String>('Deleting account...');

      // Show loading indicator with dynamic progress message
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: messageNotifier,
                    builder: (context, message, _) {
                      return Text(message);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Clear all local Hive data
      // List all known Hive boxes that contain USER-SPECIFIC data only
      // DO NOT delete shared content (scenarios, chapters, verses) - these are the same for all users!
      final boxesToDelete = [
        'journal_entries',
        'bookmarks',  // FIXED: was 'user_bookmarks' (wrong name)
        'user_progress',
        'settings',
        // NOTE: Scenarios, chapters, daily_verses are SHARED content - do not delete!
        // 'scenarios',           // REMOVED: shared content
        // 'scenarios_critical',  // REMOVED: shared content
        // 'scenarios_frequent',  // REMOVED: shared content
        // 'scenarios_complete',  // REMOVED: shared content
        // 'daily_verses',        // REMOVED: shared content
        // 'chapters',            // REMOVED: shared content
        // 'chapter_summaries',   // REMOVED: shared content
        // 'search_cache',        // REMOVED: shared content (can keep for performance)
      ];

      // Delete boxes with progress updates and timeout protection
      int deletedCount = 0;
      for (int i = 0; i < boxesToDelete.length; i++) {
        final boxName = boxesToDelete[i];

        // Update progress message
        messageNotifier.value = 'Clearing $boxName... (${i + 1}/${boxesToDelete.length})';

        try {
          // Use timeout to prevent hanging on any single box deletion
          await Hive.deleteBoxFromDisk(boxName).timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint('⏰ Timeout deleting box $boxName');
            },
          );
          deletedCount++;
          debugPrint('🗑️ Deleted Hive box: $boxName');
        } catch (e) {
          debugPrint('⚠️ Could not delete box $boxName: $e');
          // Continue with next box even if this one fails
        }

        // Small delay to allow UI to update between operations
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ Local Hive data cleared ($deletedCount boxes)');

      // Update message before deleting account
      messageNotifier.value = 'Deleting account from server...';

      // Delete account from Supabase with timeout
      final success = await authService
          .deleteAccount()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏰ Account deletion timed out');
              return false;
            },
          )
          .catchError((e) {
            debugPrint('❌ Account deletion error: $e');
            return false;
          });

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to auth screen or home
        // The auth state listener will handle navigation automatically
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error ?? 'Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Account deletion error: $e');
      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle cache refresh with progress indicator
  Future<void> _handleRefreshCache(BuildContext context) async {
    if (!mounted) return;

    // Check 20-day timer before allowing refresh
    final settingsService = Provider.of<SettingsService>(context, listen: false);

    if (!settingsService.canRefreshCache) {
      final daysRemaining = settingsService.daysUntilNextRefresh;

      // Show red warning dialog
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                const Text('Cannot Refresh Yet'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cache refresh is limited to once every 20 days to preserve data integrity.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Days until next refresh: $daysRemaining',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last refreshed: ${settingsService.lastCacheRefreshDate?.toString().split(' ')[0] ?? 'Never'}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit early - don't allow refresh
    }

    // Use a ValueNotifier to track progress across dialog rebuilds
    final progressNotifier = ValueNotifier<double>(0.0);
    final messageNotifier = ValueNotifier<String>('Clearing cache...');
    final isCompleteNotifier = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (context, progress, _) {
            return ValueListenableBuilder<String>(
              valueListenable: messageNotifier,
              builder: (context, message, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isCompleteNotifier,
                  builder: (context, isComplete, _) {
                    return AlertDialog(
                      title: const Text('Refreshing Cache'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (isComplete) ...[
                            const SizedBox(height: 16),
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 48,
                            ),
                          ],
                        ],
                      ),
                      actions: isComplete
                          ? [
                              ElevatedButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Done'),
                              ),
                            ]
                          : [],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );

    try {
      final cacheRefreshService = CacheRefreshService(
        supabaseService: EnhancedSupabaseService(),
      );

      // Refresh with progress callback - updates ValueNotifiers for instant UI updates
      await cacheRefreshService.refreshAllCaches(
        onProgress: (message, progress) {
          debugPrint('📊 $message - Progress: ${(progress * 100).toStringAsFixed(0)}%');

          // Update ValueNotifiers safely
          if (mounted) {
            messageNotifier.value = message;
            progressNotifier.value = progress;
            if (progress >= 1.0) {
              isCompleteNotifier.value = true;
            }
          }
        },
      );

      if (!mounted) return;

      // Update last refresh timestamp on success
      settingsService.setLastCacheRefreshDate(DateTime.now());
      debugPrint('✅ Cache refresh timestamp updated');

      // Dialog stays open for user to tap "Done" - manual close ensures visibility
    } catch (e) {
      debugPrint('❌ Cache refresh error: $e');

      if (!mounted) return;

      // Update error state in dialog
      messageNotifier.value = 'Cache refresh failed!\n${e.toString()}';
      isCompleteNotifier.value = true;
      progressNotifier.value = 1.0;

      // Show additional snackbar for visibility
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache refresh failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

}
