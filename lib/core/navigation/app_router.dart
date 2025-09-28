// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
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

  /// Generate routes for the app
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
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