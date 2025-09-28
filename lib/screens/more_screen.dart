import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../services/settings_service.dart';
import '../services/background_music_service.dart';
import '../services/app_sharing_service.dart';
import 'package:provider/provider.dart';
import '../screens/about_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/search_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _version = '';
  bool _isLoading = true;
  String? _errorMessage;
  bool _musicOn = true;

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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $url')),
      );
    }
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
                value: _musicOn,
                onChanged: (v) async {
                  setState(() => _musicOn = v);
                  try {
                    if (v) {
                      await musicService.startMusic();
                    } else {
                      await musicService.stopMusic();
                    }
                    debugPrint('🎵 Background music ${v ? 'enabled' : 'disabled'}');
                  } catch (e) {
                    debugPrint('⚠️ Failed to toggle background music: $e');
                    setState(() => _musicOn = !v);
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
            subtitle: const Text('Find verses, chapters, and wisdom'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('My Bookmarks'),
            subtitle: const Text('Saved verses, chapters, and scenarios'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
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
            onTap: () => _launchUrl('https://hub4apps.com/privacy.html'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service'),
            onTap: () => _launchUrl('https://hub4apps.com/terms.html'),
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

}
