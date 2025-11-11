import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
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
import '../core/ios_performance_optimizer.dart';
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
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);

    final subject = Uri.encodeComponent('Gitawisdom || Feedback $formattedDate');
    final body = Uri.encodeComponent(
      'Hi Team,\n\nWould like to give feedback!\n[Please add your feedback here...]\n\n\n',
    );

    final url = 'mailto:support@hub4apps.com?subject=$subject&body=$body';
    launchUrl(Uri.parse(url));
  }

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
      body: SafeArea(
        left: true,
        right: true,
        top: false, // AppBar already handles top safe area
        bottom: true,
        child: _buildBody(theme),
      ),
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
        // Account section - optimized with custom stateful widget
        Consumer<SupabaseAuthService>(
          builder: (context, authService, child) {
            if (authService.isAuthenticated) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text('ACCOUNT',
                        style: theme.textTheme.titleSmall?.copyWith(
                          letterSpacing: 0.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ),
                  RepaintBoundary(
                    child: _AccountSection(
                      theme: theme,
                      authService: authService,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Cache Management section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('CACHE MANAGEMENT',
              style: theme.textTheme.titleSmall?.copyWith(
                letterSpacing: 0.5,
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ),
        _buildAccessibleListTile(
          context: context,
          leading: Icons.cached,
          title: 'Refresh All Data',
          subtitle: 'Clear and reload chapters, verses & scenarios',
          onTap: () => _handleRefreshCache(context),
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
        ListTile(
          title: const Text('App Version'),
          trailing: Text(_version, style: theme.textTheme.bodySmall),
        ),

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
          onTap: () =>
              _openWebView('https://hub4apps.com/privacy.html', 'Privacy Policy'),
        ),
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: const Text('Terms of Service'),
          onTap: () =>
              _openWebView('https://hub4apps.com/terms.html', 'Terms of Service'),
        ),
      ],
    );
  }

  /// Build accessible list tile with 48x48dp minimum touch target
  Widget _buildAccessibleListTile({
    required BuildContext context,
    required IconData leading,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (Platform.isIOS) {
            HapticFeedback.mediumImpact();
          }
          onTap?.call();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 48), // 44dp+ touch target
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(leading, color: iconColor ?? theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ]
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: iconColor ?? theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
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
  Future<void> _handleSignOut(BuildContext context,
      SupabaseAuthService authService) async {
    final theme = Theme.of(context);

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
      await authService.signOut();

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show delete account confirmation dialog
  Future<void> _showDeleteAccountDialog(BuildContext context,
      SupabaseAuthService authService) async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: theme.colorScheme.error),
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
                  color:
                      theme.colorScheme.errorContainer.withValues(alpha: 0.3),
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
  Future<void> _performAccountDeletion(BuildContext context,
      SupabaseAuthService authService) async {
    try {
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

      final boxesToDelete = [
        'journal_entries',
        'bookmarks',
        'user_progress',
        'settings',
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

      final success = await authService.deleteAccount();

      if (!mounted) return;
      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(authService.error ?? 'Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Account deletion error: $e');
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle cache refresh with progress indicator (OPTIMIZED)
  Future<void> _handleRefreshCache(BuildContext context) async {
    final theme = Theme.of(context);

    if (!mounted) return;

    // Show progress dialog ONCE
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            String _progressMessage = 'Starting cache refresh...';
            double _progress = 0.0;

            // Start the refresh operation
            _performCacheRefresh(
              context: context,
              onProgress: (message, progress) {
                _progressMessage = message;
                _progress = progress;
                // setState is called by the async operation
              },
              onSetState: setState,
              onComplete: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              onError: (error) {
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
            );

            return AlertDialog(
              title: const Text('Refreshing Cache'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _progressMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              actions: _progress >= 1.0
                  ? [
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(),
                        child: const Text('Done'),
                      ),
                    ]
                  : [],
            );
          },
        );
      },
    );
  }

  /// Internal cache refresh operation
  Future<void> _performCacheRefresh({
    required BuildContext context,
    required Function(String, double) onProgress,
    required Function(VoidCallback) onSetState,
    required VoidCallback onComplete,
    required Function(String) onError,
  }) async {
    try {
      final cacheRefreshService = CacheRefreshService(
        supabaseService: EnhancedSupabaseService(),
      );

      String currentMessage = 'Starting cache refresh...';
      double currentProgress = 0.0;

      await cacheRefreshService.refreshAllCaches(
        onProgress: (message, progress) {
          debugPrint(
              '📊 $message - Progress: ${(progress * 100).toStringAsFixed(0)}%');

          currentMessage = message;
          currentProgress = progress;

          // Update UI without rebuilding dialog
          onProgress(message, progress);
        },
      );

      onProgress('Cache refresh completed!', 1.0);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache refreshed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      onComplete();
    } catch (e) {
      debugPrint('❌ Cache refresh error: $e');
      onError('Cache refresh failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache refresh failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Optimized Account Section Widget with custom animation
class _AccountSection extends StatefulWidget {
  final ThemeData theme;
  final SupabaseAuthService authService;

  const _AccountSection({
    required this.theme,
    required this.authService,
  });

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (Platform.isIOS) {
                HapticFeedback.lightImpact();
              }

              setState(() {
                _isExpanded = !_isExpanded;
              });

              if (_isExpanded) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    color: widget.theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.authService.displayName ?? 'User',
                          style: widget.theme.textTheme.titleSmall,
                        ),
                        Text(
                          widget.authService.userEmail ?? '',
                          style: widget.theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5)
                        .animate(_animationController),
                    child: Icon(
                      Icons.chevron_down,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            RepaintBoundary(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  _buildAccountListTile(
                    context: context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: () => _handleSignOut(context, widget.authService),
                  ),
                  _buildAccountListTile(
                    context: context,
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    color: widget.theme.colorScheme.error,
                    onTap: () =>
                        _showDeleteAccountDialog(context, widget.authService),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (Platform.isIOS) {
            HapticFeedback.mediumImpact();
          }
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color ?? Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color),
                ),
              ),
              Icon(Icons.chevron_right, color: color ?? Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context,
      SupabaseAuthService authService) async {
    // Delegate to parent screen's method
    final parentState = context.findAncestorStateOfType<_MoreScreenState>();
    parentState?._handleSignOut(context, authService);
  }

  Future<void> _showDeleteAccountDialog(BuildContext context,
      SupabaseAuthService authService) async {
    // Delegate to parent screen's method
    final parentState = context.findAncestorStateOfType<_MoreScreenState>();
    parentState?._showDeleteAccountDialog(context, authService);
  }
}
