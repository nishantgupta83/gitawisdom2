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
  bool _textShadow = true;
  double _backgroundOpacity = 0.3;


  @override
  void initState() {
    super.initState();
    final box = Hive.box(SettingsService.boxName);
    _darkMode = box.get(SettingsService.darkKey, defaultValue: false);
    _musicOn = box.get(SettingsService.musicKey, defaultValue: true);
    _fontSize = box.get(SettingsService.fontKey, defaultValue: 'small');
    _textShadow = box.get(SettingsService.shadowKey, defaultValue: true);
    _backgroundOpacity = box.get(SettingsService.opacityKey, defaultValue: 0.3);
  }

  void _toggleSetting(String key, dynamic value) {
    Hive.box(SettingsService.boxName).put(key, value);
    setState(() {
      if (key == SettingsService.darkKey) _darkMode = value;
      if (key == SettingsService.musicKey) _musicOn = value;
      if (key == SettingsService.fontKey) _fontSize = value;
      if (key == SettingsService.shadowKey) _textShadow = value;
      if (key == SettingsService.opacityKey) _backgroundOpacity = value;
    });
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
                  onChanged: (val) => _toggleSetting(SettingsService.musicKey, val),
                ),
              ),
              _settingTile(
                title: 'Font Size',
                trailing: DropdownButton<String>(
                  value: _fontSize,
                  items: const [
                    DropdownMenuItem(value: 'small', child: Text('Small')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'large', child: Text('Large')),
                  ],
                  onChanged: (val) => _toggleSetting(SettingsService.fontKey, val!),
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
