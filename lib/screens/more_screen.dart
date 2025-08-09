/*
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../screens/about_screen.dart';
import '../screens/references_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final _settings = SettingsService();
  bool _musicOn = true;
  String _version = '';

  @override
  void initState() {
    super.initState();
    // Load app version
    PackageInfo.fromPlatform().then((info) {
      setState(() => _version = '${info.version}+${info.buildNumber}');
    });
    // Load music enabled state
    AudioService.instance.loadEnabled().then((v) {
      setState(() => _musicOn = v);
    });
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

   final url = 'mailto:hub4app@gmail.com?subject=$subject&body=$body';

 //);

  launchUrl(Uri.parse(url));

 // _launchUrl(uri.toString());
  }

  Future<void> _clearCache() async {
    // Clear all settings
    final box = Hive.box(SettingsService.boxName);
    await box.clear();
    // Optionally clear other boxes if needed:
    // await Hive.box<Chapter>('chapters').clear();
    // await Hive.box<JournalEntry>('journal_entries').clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
    setState(() {});
  }

void _showWebsiteQr() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {                    // ← note this new name
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Visit our website',
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Your SVG QR code
            SvgPicture.asset(
              'assets/images/hub4apps_qr.svg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(sheetContext).pop(),  // ← use sheetContext!
              child: const Text('Close'),
            ),
          ],
        ),
      );
    },
  );
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
      body: ListView(
        children: [
          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Appearance', style: theme.textTheme.titleMedium),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _settings.isDarkMode,
            onChanged: (v) {
              setState(() => _settings.isDarkMode = v);
            },
          ),
          // Background Music
          SwitchListTile(
            title: const Text('Background Music'),
            subtitle: const Text('Enable ambient music in the background'),
            value: _musicOn,
            onChanged: (v) {
              setState(() => _musicOn = v);
              AudioService.instance.setEnabled(v);
            },
          ),
          // Font Size
          ListTile(
            title: const Text('Font Size'),
            trailing: DropdownButton<String>(
              value: _settings.fontSize,
              items: const [
                DropdownMenuItem(value: 'small', child: Text('Small')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'large', child: Text('Large')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _settings.fontSize = v);
              },
            ),
          ),

          // Extras section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Extras', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share This App'),
            onTap: () => Share.share(
              'Check out Gitawisdom: Bhagavad Gita Guide on the store: https://your.app.link',
            ),
          ),
        ListTile(
          leading: const Icon(Icons.qr_code),
          title: const Text('QR Code'),
          subtitle: const Text('Scan to open our website'),
          onTap: _showWebsiteQr,
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
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('References'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReferencesScreen()),
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
            onTap: () => _launchUrl('https://hub4apps.com/privacy-policy'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service'),
            onTap: () => _launchUrl('https://hub4apps.com/terms-and-conditions'),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';

import '../services/settings_service.dart';
import '../services/cache_service.dart';
import '../screens/about_screen.dart';
import '../screens/references_screen.dart';
import '../services/audio_service.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _darkMode = false;
  bool _musicOn = false;
  String _fontSize = 'small';
  double _fontSizeValue = 1.0; // 0.0 = small, 1.0 = medium, 2.0 = large
  bool _textShadow = true;
  double _backgroundOpacity = 0.3;
  String _cacheSize = 'Calculating...';
  Map<String, double> _cacheSizes = {};

  // Helper functions for font size mapping
  String _getFontSizeString(double value) {
    if (value <= 0.5) return 'small';
    if (value <= 1.5) return 'medium';
    return 'large';
  }

  double _getFontSizeValue(String fontSize) {
    switch (fontSize) {
      case 'small': return 0.0;
      case 'medium': return 1.0;
      case 'large': return 2.0;
      default: return 1.0;
    }
  }

  String _getFontSizeLabel(double value) {
    if (value <= 0.5) return 'Small';
    if (value <= 1.5) return 'Medium';
    return 'Large';
  }

  @override
  void initState() {
    super.initState();
    final box = Hive.box(SettingsService.boxName);
    _darkMode = box.get(SettingsService.darkKey, defaultValue: false);
    _musicOn = box.get(SettingsService.musicKey, defaultValue: true);
    _fontSize = box.get(SettingsService.fontKey, defaultValue: 'small');
    _fontSizeValue = _getFontSizeValue(_fontSize);
    _textShadow = box.get(SettingsService.shadowKey, defaultValue: true);
    _backgroundOpacity = box.get(SettingsService.opacityKey, defaultValue: 0.3);
    
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    try {
      final totalSize = await CacheService.getTotalCacheSize();
      final sizes = await CacheService.getCacheSizes();
      
      setState(() {
        _cacheSize = CacheService.formatCacheSize(totalSize);
        _cacheSizes = sizes;
      });
    } catch (e) {
      setState(() {
        _cacheSize = 'Error loading';
      });
    }
  }

  void _toggleSetting(String key, dynamic value) {
    Hive.box(SettingsService.boxName).put(key, value);
    setState(() {
      if (key == SettingsService.darkKey) _darkMode = value;
      if (key == SettingsService.musicKey) _musicOn = value;
      if (key == SettingsService.fontKey) {
        _fontSize = value;
        _fontSizeValue = _getFontSizeValue(value);
      }
      if (key == SettingsService.shadowKey) _textShadow = value;
      if (key == SettingsService.opacityKey) _backgroundOpacity = value;
    });
  }

  void _updateFontSize(double value) {
    final newFontSize = _getFontSizeString(value);
    _toggleSetting(SettingsService.fontKey, newFontSize);
  }

  Future<void> _clearAllCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear All Cache',
      'This will remove all cached data (verses, chapters, journal) but keep your settings. The app will need to re-download content.',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearAllCache();
        await _loadCacheInfo();
        _showCacheSuccess('All cache cleared successfully');
      } catch (e) {
        _showCacheError('Error clearing cache: $e');
      }
    }
  }

  Future<void> _clearVerseCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear Verse Cache',
      'This will remove cached daily verses. New verses will be downloaded tomorrow or when manually refreshed.',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearVerseCache();
        await _loadCacheInfo();
        _showCacheSuccess('Verse cache cleared');
      } catch (e) {
        _showCacheError('Error clearing verse cache: $e');
      }
    }
  }

  Future<void> _clearChapterCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear Chapter Cache',
      'This will remove cached chapter data. Chapters will be re-downloaded when accessed.',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearChapterCache();
        await _loadCacheInfo();
        _showCacheSuccess('Chapter cache cleared');
      } catch (e) {
        _showCacheError('Error clearing chapter cache: $e');
      }
    }
  }

  Future<void> _clearJournalCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear Journal Cache',
      'This will permanently delete all your local journal entries. This cannot be undone!',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearJournalCache();
        await _loadCacheInfo();
        _showCacheSuccess('Journal cache cleared');
      } catch (e) {
        _showCacheError('Error clearing journal cache: $e');
      }
    }
  }

  Future<bool> _showCacheConfirmation(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showCacheSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCacheError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB (10,100,10,10),
          child: ListView(
            children: [
              _sectionTitle('Appearance'),
              _settingTile(
                title: 'Dark Mode',
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (val) => _toggleSetting(SettingsService.darkKey, val),
                ),
              ),
              _settingTile(
                title: 'Background Music',
                trailing: Switch(
                  value: _musicOn,
                  onChanged: (val) {
                    _toggleSetting(SettingsService.musicKey, val);
                    AudioService.instance.setEnabled(val);
                  },
                ),
              ),
              _settingTile(
                title: 'Font Size',
                subtitle: '${_getFontSizeLabel(_fontSizeValue)} - Adjust text size throughout the app',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: _fontSizeValue,
                    min: 0.0,
                    max: 2.0,
                    divisions: 2,
                    onChanged: (val) {
                      setState(() => _fontSizeValue = val);
                      _updateFontSize(val);
                    },
                  ),
                ),
              ),
              _settingTile(
                title: 'Text Shadow',
                subtitle: 'Add shadow effect to text',
                trailing: Switch(
                  value: _textShadow,
                  onChanged: (val) => _toggleSetting(SettingsService.shadowKey, val),
                ),
              ),
              _settingTile(
                title: 'Background Opacity',
                subtitle: '${(_backgroundOpacity * 100).round()}% - Adjust background transparency',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: _backgroundOpacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (val) => _toggleSetting(SettingsService.opacityKey, val),
                  ),
                ),
              ),

              _sectionTitle('Storage & Cache'),
              
              // Simplified Cache Management - Single Button Approach
              // User requested: Simple one-button cache clearing while preserving detailed functionality
              _settingTile(
                title: 'Cache Size',
                subtitle: _cacheSize,
                leading: const Icon(Icons.storage),
                onTap: () => _loadCacheInfo(),
              ),
              
              _settingTile(
                title: 'Clear Cache',
                subtitle: 'Remove all app cache to free up space',
                leading: const Icon(Icons.delete_sweep, color: Colors.orange),
                onTap: _clearAllCache,
              ),

              /* ============================================================================
               * DETAILED CACHE MANAGEMENT (PRESERVED FOR FUTURE RESTORATION)
               * 
               * This section contains granular cache management functionality that has been
               * commented out per user request for simplified UX. All functionality is
               * preserved and can be easily restored by uncommenting this block.
               * 
               * Features preserved:
               * - Individual cache size breakdown display
               * - Granular cache clearing (verses, chapters, journal separately)
               * - Real-time cache size monitoring
               * - Confirmation dialogs and success feedback
               * 
               * To restore: Simply uncomment the entire block below.
               * ============================================================================ */
              
              // // Individual cache sizes breakdown
              // if (_cacheSizes.isNotEmpty) ...[
              //   for (final entry in _cacheSizes.entries)
              //     if (entry.value > 0)
              //       Padding(
              //         padding: const EdgeInsets.only(left: 32, right: 16),
              //         child: _settingTile(
              //           title: entry.key,
              //           subtitle: CacheService.formatCacheSize(entry.value),
              //         ),
              //       ),
              // ],
              // 
              // // Granular cache clearing options
              // _settingTile(
              //   title: 'Clear All Cache',
              //   subtitle: 'Remove all cached data except settings',
              //   leading: const Icon(Icons.clear_all, color: Colors.red),
              //   onTap: _clearAllCache,
              // ),
              // 
              // _settingTile(
              //   title: 'Clear Verse Cache',
              //   subtitle: 'Remove daily verse cache',
              //   leading: const Icon(Icons.auto_stories, color: Colors.orange),
              //   onTap: _clearVerseCache,
              // ),
              // 
              // _settingTile(
              //   title: 'Clear Chapter Cache',
              //   subtitle: 'Remove chapter data cache',
              //   leading: const Icon(Icons.menu_book, color: Colors.blue),
              //   onTap: _clearChapterCache,
              // ),
              // 
              // _settingTile(
              //   title: 'Clear Journal Cache',
              //   subtitle: 'Permanently delete journal entries',
              //   leading: const Icon(Icons.delete_forever, color: Colors.red),
              //   onTap: _clearJournalCache,
              // ),
              
              /* ============================================================================ */

              _sectionTitle('Extras'),
              _settingTile(
                title: 'Share this App',
                onTap: () {
                  Share.share(
                    'Check out GitaWisdom on the App Store or Play Store!',
                    subject: 'GitaWisdom – Your Daily Spiritual Guide',
                  );
                },
              ),

              _sectionTitle('Resources'),
              _settingTile(
                title: 'About',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              _settingTile(
                title: 'References',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReferencesScreen()),
                ),
              ),

              _sectionTitle('Support & Legal'),
              _settingTile(
                title: 'Send Feedback',
                leading: const Icon(Icons.email_outlined),
                  onTap: () async {
                    final now = DateTime.now();
                    final formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);

                    final subject = Uri.encodeComponent('Gitawisdom || Feedback $formattedDate');
                    final body = Uri.encodeComponent(
                        'Hi Team,\n\nWould like to give feedback!\n[Please add your feedback here...]\n\n');

                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'support@gitawisdom.app',
                      query: 'subject=$subject&body=$body',
                    );

                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    } else {
                      // Optional: Show snackbar or error dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open email client.')),
                      );
                    }
                  }
              ),
              _settingTile(title: 'Privacy Policy'),
              _settingTile(title: 'Terms & Conditions'),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Made with ❤️ for spiritual seekers everywhere'
                      '\n                        App Version 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ) : null,
        trailing: trailing,
      ),
    );
  }
}
