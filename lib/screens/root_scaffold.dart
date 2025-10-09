// lib/screens/root_scaffold.dart

import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/navigation/navigation_service.dart';
import '../l10n/app_localizations.dart';
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

class _RootScaffoldState extends State<RootScaffold> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true; // Preserve state across rebuilds (rotation, low memory)
  int _currentIndex = 0;
  int? _pendingChapterFilter;

  // Lazy loading: Only build pages when accessed (saves memory and initialization time)
  final Map<int, Widget> _builtPages = {};

  // Performance optimization: Cache page keys to prevent unnecessary rebuilds
  final Map<int, GlobalKey<NavigatorState>> _pageKeys = {};

  // Track page state preservation
  final Map<int, bool> _pageStates = {};

  @override
  void initState() {
    super.initState();
    _initializePageKeys(); // Only initialize keys, not pages (lazy loading)
    _initializeNavigationService();
    _startPostLoginBackgroundLoading();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Initialize page keys for state management (lightweight operation)
  void _initializePageKeys() {
    for (int i = 0; i < 5; i++) {
      _pageKeys[i] = GlobalKey<NavigatorState>();
      _pageStates[i] = false;
    }
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

  /// Get page by index with lazy loading (only build when first accessed)
  Widget _getPage(int index) {
    // Return cached page if already built
    if (_builtPages.containsKey(index)) {
      return _builtPages[index]!;
    }

    // Build page on first access and cache it
    Widget page;
    switch (index) {
      case 0:
        page = _buildHomePage();
        break;
      case 1:
        page = _buildChaptersPage();
        break;
      case 2:
        page = _buildScenariosPage();
        break;
      case 3:
        page = _buildJournalPage();
        break;
      case 4:
        page = _buildMorePage();
        break;
      default:
        page = const SizedBox.shrink();
    }

    _builtPages[index] = page;
    debugPrint('📱 Lazy loaded tab $index (${_getTabName(index)})');
    return page;
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
    const totalTabs = 5; // Total number of tabs in bottom navigation
    if (index >= 0 && index < totalTabs && index != _currentIndex) {
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
      case 2: return 'Situations';
      case 3: return 'Journal';
      case 4: return 'More';
      default: return 'Unknown';
    }
  }

  /// Navigate to scenarios with chapter filter - optimized for lazy loading
  void _goToScenariosWithChapter(int chapterId) {
    debugPrint('🔧 Navigating to scenarios with chapter filter: $chapterId');

    // Only update if filter actually changed
    if (_pendingChapterFilter != chapterId) {
      _pendingChapterFilter = chapterId;

      // Rebuild scenarios page with new filter and update cache
      _builtPages[2] = _buildScenariosPage();

      setState(() {
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin to preserve state

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
          // Lazy loading: Build pages on demand using _getPage()
          children: List.generate(5, (index) => _getPage(index)),
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