// lib/core/ui/app_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../../l10n/app_localizations.dart';
import '../app_config.dart';
import '../theme/theme_provider.dart';
import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';
// import '../dependency_injection.dart'; // Simplified for Apple compliance
import '../../services/supabase_auth_service.dart';
import '../../services/bookmark_service.dart';
import '../../services/background_music_service.dart';
import '../../services/settings_service.dart';
import '../../screens/root_scaffold.dart';

/// Main app widget - clean MaterialApp configuration
/// Replaces the complex 200+ line build method from main.dart
class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider for theme management
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider()..initialize(),
        ),
        // Settings service for app settings
        ChangeNotifierProvider<SettingsService>(
          create: (_) {
            final service = SettingsService();
            // Initialize Hive box if needed
            if (!Hive.isBoxOpen(SettingsService.boxName)) {
              Hive.openBox(SettingsService.boxName).then((_) {
                debugPrint('✅ Settings box opened in provider');
              }).catchError((e) {
                debugPrint('❌ Failed to open settings box: $e');
              });
            }
            return service;
          },
        ),
        // Supabase auth provider for real authentication
        ChangeNotifierProvider<SupabaseAuthService>(
          create: (_) => SupabaseAuthService.instance,
        ),
        // Background music service for meditation
        ChangeNotifierProvider<BackgroundMusicService>(
          create: (_) => BackgroundMusicService(),
        ),
        // Bookmark service for verse bookmarking
        ChangeNotifierProvider<BookmarkService>(
          create: (_) {
            final service = BookmarkService();
            service.initialize('default_device');
            return service;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
              // Basic app configuration
              title: AppConfig.appTitle,
              debugShowCheckedModeBanner: false,

              // Navigation configuration
              navigatorKey: NavigationService.instance.navigatorKey,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: AppRouter.splash,

              // Localization configuration
              locale: const Locale('en', ''),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppConfig.supportedLocales,

              // Theme configuration
              theme: themeProvider.lightTheme,
              darkTheme: themeProvider.darkTheme,
              themeMode: themeProvider.themeMode,

              // Custom builder with background and text scaling
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(themeProvider.textScale),
                  ),
                  child: Stack(
                    children: [
                      // Simplified background
                      Container(
                        color: themeProvider.isDark ? Colors.black : Colors.white,
                      ),
                      if (child != null) child,
                    ],
                  ),
                );
              },
          );
        },
      ),
    );
  }
}