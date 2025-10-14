// lib/core/navigation/app_router.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/splash_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/chapters_screen.dart';
import '../../screens/scenarios_screen.dart';
import '../../screens/more_screen.dart';
import '../../screens/chapters_detail_view.dart';
import '../../screens/scenario_detail_view.dart';
import '../../screens/verse_list_view.dart';
import '../../screens/about_screen.dart';
import '../navigation/navigation_service.dart';
import '../../services/supabase_auth_service.dart';

/// App router configuration
/// Centralizes route definitions and navigation logic
class AppRouter {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String chapters = '/chapters';
  static const String scenarios = '/scenarios';
  static const String more = '/more';
  static const String chapterDetail = '/chapter-detail';
  static const String scenarioDetail = '/scenario-detail';
  static const String verseList = '/verse-list';
  static const String about = '/about';
  static const String loginCallback = '/login-callback';

  /// Generate routes for the app
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // 🔍 DEBUG: Log every route request
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🧭 ROUTER: Route requested');
    debugPrint('   Route name: ${settings.name}');
    debugPrint('   Arguments: ${settings.arguments}');

    // 🔍 CRITICAL: Check for OAuth callback BEFORE route matching
    // OAuth callbacks come as /?code=xxx which doesn't match any route exactly
    final routeName = settings.name ?? '/';
    debugPrint('🔍 ROUTER: Checking for OAuth parameters in route');
    debugPrint('   Full route: "$routeName"');

    final uri = Uri.tryParse(routeName);
    if (uri != null) {
      debugPrint('📊 ROUTER: Parsed URI successfully');
      debugPrint('   Scheme: ${uri.scheme}');
      debugPrint('   Host: ${uri.host}');
      debugPrint('   Path: ${uri.path}');
      debugPrint('   Query parameters: ${uri.queryParameters}');
      debugPrint('   Has code param: ${uri.queryParameters.containsKey('code')}');
      debugPrint('   Has access_token param: ${uri.queryParameters.containsKey('access_token')}');
      debugPrint('   Has refresh_token param: ${uri.queryParameters.containsKey('refresh_token')}');

      // If ANY route has OAuth query parameters, show loading screen
      if (uri.queryParameters.containsKey('code') ||
          uri.queryParameters.containsKey('access_token') ||
          uri.queryParameters.containsKey('refresh_token')) {
        debugPrint('✅ ROUTER: OAuth callback detected!');
        debugPrint('   OAuth code: ${uri.queryParameters['code']?.substring(0, 10)}...');
        debugPrint('   🎯 ACTION: Showing loading screen for Supabase to process');
        debugPrint('   ⏱️ Will auto-redirect to home after auth completes');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return MaterialPageRoute(
          builder: (_) => const OAuthLoadingScreen(),
        );
      }
    } else {
      debugPrint('⚠️ ROUTER: Failed to parse URI from route name');
    }

    // Extract clean path without query parameters for route matching
    final cleanPath = uri?.path ?? routeName;
    debugPrint('🔍 ROUTER: Matching route path: "$cleanPath"');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    switch (cleanPath) {
      case splash:
        debugPrint('ℹ️ ROUTER: Splash route - returning SplashScreen');
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onTabChange: NavigationService.instance.goToTab,
          ),
        );
      
      case chapters:
        return MaterialPageRoute(builder: (_) => ChapterScreen());
      
      case scenarios:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ScenariosScreen(
            filterChapter: args?['filterChapter'] as int?,
          ),
        );
      
      case more:
        return MaterialPageRoute(builder: (_) => MoreScreen());
      
      case chapterDetail:
        final chapterId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ChapterDetailView(chapterId: chapterId),
        );
      
      case scenarioDetail:
        final scenario = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => ScenarioDetailView(
            scenario: scenario,
          ),
        );
      
      case verseList:
        final chapterId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => VerseListView(chapterId: chapterId),
        );
      
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case loginCallback:
        // OAuth callback route - Supabase handles authentication
        // Just return to splash which will redirect based on auth state
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      default:
        return _errorRoute(settings.name);
    }
  }

  /// Error route for unknown routes
  static MaterialPageRoute _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Route not found',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                routeName ?? 'Unknown route',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => NavigationService.instance.goToHome(),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigation helper methods
  static void goToChapterDetail(int chapterId) {
    NavigationService.instance.pushNamed(chapterDetail, arguments: chapterId);
  }

  static void goToScenarioDetail(dynamic scenario) {
    NavigationService.instance.pushNamed(
      scenarioDetail,
      arguments: scenario,
    );
  }

  static void goToVerseList(int chapterId) {
    NavigationService.instance.pushNamed(verseList, arguments: chapterId);
  }

  static void goToAbout() {
    NavigationService.instance.pushNamed(about);
  }

  static void goToScenariosWithFilter(int? chapterFilter) {
    NavigationService.instance.pushNamed(
      scenarios,
      arguments: {'filterChapter': chapterFilter},
    );
  }
}

/// OAuth Loading Screen
/// Shows loading indicator while OAuth completes
/// Automatically navigates to home after auth state changes
class OAuthLoadingScreen extends StatefulWidget {
  const OAuthLoadingScreen({Key? key}) : super(key: key);

  @override
  State<OAuthLoadingScreen> createState() => _OAuthLoadingScreenState();
}

class _OAuthLoadingScreenState extends State<OAuthLoadingScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔐 OAuth Loading Screen: Initialized');
    debugPrint('   Waiting for auth state change...');

    // Give Supabase SDK time to process the callback (minimum 500ms, maximum 3s)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _hasNavigated) return;

      // Check if we're authenticated after the delay
      final authService = Provider.of<SupabaseAuthService>(context, listen: false);

      if (authService.isAuthenticated) {
        debugPrint('🔐 OAuth Loading Screen: User authenticated after 500ms');
        _navigateToHome();
      } else {
        debugPrint('🔐 OAuth Loading Screen: Still waiting for auth...');
        // Wait up to 2.5 more seconds
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (!mounted || _hasNavigated) return;
          debugPrint('🔐 OAuth Loading Screen: Timeout reached - forcing navigation');
          _navigateToHome();
        });
      }
    });
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;

    setState(() {
      _hasNavigated = true;
    });

    debugPrint('🔐 OAuth Loading Screen: Navigating to splash for proper initialization');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Navigate to splash which will handle proper app initialization and redirect to home
    // This ensures NavigationService is properly initialized before HomeScreen is created
    Navigator.of(context).pushReplacementNamed(AppRouter.splash);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    final authService = Provider.of<SupabaseAuthService>(context);

    // If user becomes authenticated, navigate immediately
    if (authService.isAuthenticated && !_hasNavigated) {
      debugPrint('🔐 OAuth Loading Screen: Auth state changed to authenticated');
      // Schedule navigation for next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Completing sign-in...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}