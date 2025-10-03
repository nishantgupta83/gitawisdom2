// lib/screens/root_scaffold.dart

import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/navigation/navigation_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/modern_nav_bar.dart';
import '../services/post_login_data_loader.dart';
import 'home_screen.dart';
import 'chapters_screen.dart';
import 'scenarios_screen.dart';
import 'journal_tab_container.dart';
import 'more_screen.dart';

/// Root scaffold with bottom navigation
/// Moved from main.dart and cleaned up with proper service integration
class RootScaffold extends StatefulWidget {
  const RootScaffold({Key? key}) : super(key: key);
  
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int? _pendingChapterFilter;
  late List<Widget> _pages;
  
  // Performance optimization: Cache page keys to prevent unnecessary rebuilds
  final Map<int, GlobalKey<NavigatorState>> _pageKeys = {};
  
  // Track page state preservation
  final Map<int, bool> _pageStates = {};

  @override
  void initState() {
    super.initState();
    _initializePages();
    _initializeNavigationService();
    _startPostLoginBackgroundLoading();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Start loading all 1200+ scenarios in background after login
  /// This ensures full dataset is available for AI search without blocking UI
  void _startPostLoginBackgroundLoading() {
    debugPrint('🚀 User logged in - starting background data loading...');

    // Start loading immediately but non-blocking
    PostLoginDataLoader.instance.startBackgroundLoading();

    // Optional: Show user that background loading is happening
    PostLoginDataLoader.instance.progressStream.listen((progress) {
      if (progress.isCompleted) {
        debugPrint('🎉 Background loading completed: ${progress.loadedScenarios} scenarios ready for AI search');

        // Optionally show a subtle notification that full search is now available
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ All ${progress.loadedScenarios} scenarios loaded! Full AI search available.'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  /// Initialize navigation service with callbacks
  void _initializeNavigationService() {
    NavigationService.instance.initialize(
      onTabChanged: _selectTab,
      onGoToScenariosWithChapter: _goToScenariosWithChapter,
    );
  }

  /// Initialize pages for bottom navigation with optimized state management
  void _initializePages() {
    // Initialize page keys for better state management
    for (int i = 0; i < 5; i++) {
      _pageKeys[i] = GlobalKey<NavigatorState>();
      _pageStates[i] = false;
    }
    
    _pages = [
      _buildHomePage(),
      _buildChaptersPage(),
      _buildScenariosPage(),
      _buildJournalPage(),
      _buildMorePage(),
    ];
  }
  
  /// Build home page with optimized state preservation
  Widget _buildHomePage() {
    return HomeScreen(
      key: _pageKeys[0],
      onTabChange: _selectTab,
    );
  }
  
  /// Build chapters page with state preservation
  Widget _buildChaptersPage() {
    return ChapterScreen(
      key: _pageKeys[1],
    );
  }
  
  /// Build scenarios page with optimized filtering
  Widget _buildScenariosPage() {
    return ScenariosScreen(
      key: _pageKeys[2],
      filterChapter: _pendingChapterFilter,
    );
  }
  
  /// Build journal page with tabs for practice and journal
  Widget _buildJournalPage() {
    return JournalTabContainer(
      key: _pageKeys[3],
    );
  }
  
  /// Build more page with state preservation
  Widget _buildMorePage() {
    return MoreScreen(
      key: _pageKeys[4],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Reset to home screen when app resumes for better UX
    if (state == AppLifecycleState.resumed && _currentIndex != 0) {
      debugPrint('🏠 App resumed - resetting to home screen');
      _selectTab(0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NavigationService.instance.dispose();
    super.dispose();
  }

  /// Select a tab by index with performance optimizations
  void _selectTab(int index) {
    if (index >= 0 && index < _pages.length && index != _currentIndex) {
      // Mark previous page state as preserved
      _pageStates[_currentIndex] = true;
      
      setState(() {
        _currentIndex = index;
      });
      
      debugPrint('📋 Tab switched to $index (${_getTabName(index)})');
    }
  }
  
  /// Get tab name for debugging
  String _getTabName(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Chapters';
      case 2: return 'Scenarios';
      case 3: return 'Journal';
      case 4: return 'More';
      default: return 'Unknown';
    }
  }

  /// Navigate to scenarios with chapter filter - optimized to avoid rebuilds
  void _goToScenariosWithChapter(int chapterId) {
    debugPrint('🔧 Navigating to scenarios with chapter filter: $chapterId');
    
    // Only update if filter actually changed
    if (_pendingChapterFilter != chapterId) {
      _pendingChapterFilter = chapterId;
      
      // Update scenarios screen efficiently without full rebuild
      setState(() {
        _pages[2] = _buildScenariosPage();
        _currentIndex = 2; // Switch to scenarios tab
      });
      
      debugPrint('🔧 Updated scenarios filter to chapter $chapterId and switched tab');
    } else {
      // Just switch tab if filter is same
      setState(() {
        _currentIndex = 2;
      });
      debugPrint('🔧 Switched to scenarios tab (filter unchanged)');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (bool didPop) {
        if (!didPop && _currentIndex != 0) {
          _selectTab(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          sizing: StackFit.expand,
          children: _pages,
        ),
        
        // Modern bottom navigation bar
        bottomNavigationBar: ModernNavBar(
          currentIndex: _currentIndex,
          onTap: _selectTab,
          items: [
            ModernNavBarItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: AppLocalizations.of(context)!.homeTab,
              color: Colors.blue,
            ),
            ModernNavBarItem(
              icon: Icons.menu_book_outlined,
              selectedIcon: Icons.menu_book,
              label: AppLocalizations.of(context)!.chaptersTab,
              color: Colors.indigo,
            ),
            ModernNavBarItem(
              icon: Icons.psychology_outlined,
              selectedIcon: Icons.psychology,
              label: AppLocalizations.of(context)!.scenariosTab,
              color: Colors.purple,
            ),
            ModernNavBarItem(
              icon: Icons.book_outlined,
              selectedIcon: Icons.book,
              label: AppLocalizations.of(context)!.journalTab,
              color: Colors.green,
            ),
            ModernNavBarItem(
              icon: Icons.more_horiz_outlined,
              selectedIcon: Icons.more_horiz,
              label: AppLocalizations.of(context)!.moreTab,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}