import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/settings_service.dart';
import '../services/background_music_service.dart';
import '../services/app_sharing_service.dart';
import '../services/supabase_auth_service.dart';
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

  void _sendFeedback() {
  //  final uri = Uri(
  //    scheme: 'mailto',
  //    path: 'hub4app@gmail.com',
  //    queryParameters: { 'subject': 'OldWisdom || App Feedback' },
 //   );
 //   _launchUrl(uri.toString());

  final now = DateTime.now();
  final formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);

  final subject = Uri.encodeComponent('Gitawisdom || Feedback $formattedDate');
  final body = Uri.encodeComponent(
    'Hi Team,\n\nWould like to give feedback!\nn[Please add your feedback here...]\n\n\n' );

/*  final uri = Uri(
    scheme: 'mailto',
    path: 'hub4app@gmail.com',
    queryParameters: {
      'subject': subject,
      'body': body,
    },*/

   final url = 'mailto:support@hub4apps.com?subject=$subject&body=$body';

 //);

  launchUrl(Uri.parse(url));

 // _launchUrl(uri.toString());
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
          // Account section - only shown for authenticated users
          Consumer<SupabaseAuthService>(
            builder: (context, authService, child) {
              if (authService.isAuthenticated) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text('Account', style: theme.textTheme.titleMedium),
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: Text(authService.displayName ?? 'User'),
                      subtitle: Text(authService.userEmail ?? ''),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign Out'),
                      subtitle: const Text('Sign out of your account'),
                      onTap: () => _handleSignOut(context, authService),
                    ),
                    ListTile(
                      leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                      title: Text('Delete Account', style: TextStyle(color: theme.colorScheme.error)),
                      subtitle: const Text('Permanently delete your account and all data'),
                      onTap: () => _showDeleteAccountDialog(context, authService),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Appearance', style: theme.textTheme.titleMedium),
          ),
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
          // Background Music
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
          // Font Size
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

          // Content section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Content', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            subtitle: const Text('Find life situations and wisdom'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),

          // Extras section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Extras', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share This App'),
            onTap: () async => await AppSharingService().shareApp(),
          ),
    //      ListTile(
    //        leading: const Icon(Icons.star_rate),
    //        title: const Text('Rate & Review'),
    //        onTap: () => _launchUrl('https://your.app.store.link'),
    //      ),
    //      ListTile(
    //        leading: const Icon(Icons.clear_all),
    //        title: const Text('Clear Cache'),
    //        onTap: _clearCache,
    //      ),
          ListTile(
            title: const Text('App Version'),
            trailing: Text(_version, style: theme.textTheme.bodySmall),
          ),

          // Language section
     /*     Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Language', style: theme.textTheme.titleMedium),
          ),
         ListTile(
            title: const Text('App Language'),
            trailing: DropdownButton<String>(
              value: _settings.language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
              ],
              onChanged: (newLang) {
                if (newLang != null) {
                  setState(() {
                    _settings.language = newLang;
                    // trigger localization reload if implemented
                  });
                }
              },
            ),
          ), */

          // Resources
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Resources', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),

          // Support & Legal
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Support & Legal', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            onTap: _sendFeedback,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => _openWebView('https://hub4apps.com/privacy.html', 'Privacy Policy'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service'),
            onTap: () => _openWebView('https://hub4apps.com/terms.html', 'Terms of Service'),
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
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigation is handled automatically by auth state listener
      // in main.dart - user will be redirected to home/auth screen
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      // Show loading indicator
      if (!mounted) return;
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
                  Text('Deleting account...'),
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

      for (final boxName in boxesToDelete) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
          debugPrint('🗑️ Deleted Hive box: $boxName');
        } catch (e) {
          debugPrint('⚠️ Could not delete box $boxName: $e');
        }
      }

      debugPrint('✅ Local Hive data cleared');

      // Delete account from Supabase
      final success = await authService.deleteAccount();

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

}
