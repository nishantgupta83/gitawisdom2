// lib/screens/home_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/verse.dart';
import '../models/chapter.dart';
import '../models/scenario.dart';
import '../services/service_locator.dart';
import '../services/daily_verse_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/progressive_scenario_service.dart';
import '../core/theme/theme_provider.dart';
import 'chapters_detail_view.dart';

/// Serializable scenario data for compute() isolate
class ScenarioData {
  final String title;
  final String description;
  final String category;
  final int chapter;

  ScenarioData({
    required this.title,
    required this.description,
    required this.category,
    required this.chapter,
  });
}

/// Top-level function for background scenario filtering
/// Uses serializable data to avoid Hive object issues in isolates
List<ScenarioData> _filterParentingAndRelationshipScenarios(List<ScenarioData> scenarioDataList) {
  // First try specific filtering for life dilemmas
  final filtered = scenarioDataList.where((scenarioData) {
    final title = scenarioData.title.toLowerCase();
    final description = scenarioData.description.toLowerCase();
    final category = scenarioData.category.toLowerCase();

    // Expanded filtering criteria for better coverage
    const keywords = [
      'parent', 'child', 'family', 'marriage', 'relationship',
      'friend', 'spouse', 'partner', 'sibling', 'love', 'trust',
      'conflict', 'decision', 'choice', 'dilemma', 'difficult',
      'struggle', 'challenge', 'problem', 'issue', 'worry',
      'concern', 'stress', 'anxiety', 'doubt', 'fear'
    ];

    return keywords.any((keyword) =>
      title.contains(keyword) ||
      description.contains(keyword) ||
      category.contains(keyword)
    );
  }).toList();

  // If filtering results in too few scenarios, return a random selection
  if (filtered.length < 3) {
    // Fallback: return random scenarios if filtering is too restrictive
    final shuffled = List<ScenarioData>.from(scenarioDataList)..shuffle();
    return shuffled.take(8).toList(); // Return more as fallback
  }

  return filtered;
}

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const HomeScreen({Key? key, this.onTabChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final _service = ServiceLocator.instance.enhancedSupabaseService;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final PageController _pageController = PageController();
  final PageController _dilemmasPageController = PageController();
  late final int _chapterId;
  Future<Verse>? _verseFuture;
  Future<List<Chapter>>? _chaptersFuture;
  Future<List<Scenario>>? _dilemmasFuture;
  
  int _currentPage = 0;
  int _currentDilemmaPage = 0;
  bool _showGreeting = true;

  @override
  void initState() {
    super.initState();

    // Initialize animations first (lightweight)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations immediately
    _fadeController.forward();
    _slideController.forward();

    // Pick a random chapter (lightweight)
    _chapterId = math.Random().nextInt(18) + 1;

    // Defer heavy data loading until after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDataAfterFirstFrame();
    });

    // Auto-hide greeting after 3 seconds (independent of data loading)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showGreeting = false);
      }
    });
  }

  /// Initialize heavy data operations after the first frame
  /// This prevents blocking the initial UI render
  Future<void> _initializeDataAfterFirstFrame() async {
    if (!mounted) return;

    // Load data with staggered timing to prevent overwhelming the device
    setState(() {
      // Start with the most critical data first
      _verseFuture = _service.fetchRandomVerseByChapter(_chapterId);
    });

    // Small delay before loading chapters (less critical)
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      _chaptersFuture = _service.fetchAllChapters();
    });

    // Longer delay before loading scenarios (most expensive)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _dilemmasFuture = _getParentingAndRelationshipDilemmas();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _dilemmasPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Enhanced background with better dark mode support
          _buildEnhancedBackground(isDark, size),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  slivers: [
                    // Dynamic header
                    _buildDynamicHeader(theme, isDark),
                    
                    // Main content
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: math.max(MediaQuery.of(context).padding.bottom + 80, 100), // Ensure minimum padding
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Dilemmas carousel
                          _buildDilemmasCarousel(theme, isDark),
                          const SizedBox(height: 24),

                          // Quick actions grid
                          _buildQuickActionsGrid(theme, isDark),
                          const SizedBox(height: 24),

                          // Featured chapters
                          _buildFeaturedChaptersSection(theme, isDark),
                          const SizedBox(height: 24),

                          // Daily inspiration
                          _buildDailyInspirationCard(theme, isDark),
                          const SizedBox(height: 24),

                          // Verse of the day card (moved to bottom)
                          _buildVerseOfTheDayCard(theme, isDark),
                          // Removed extra SizedBox as padding is now responsive
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Greeting overlay
          if (_showGreeting) _buildGreetingOverlay(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildEnhancedBackground(bool isDark, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0D1B2A),
                  const Color(0xFF1B263B),
                  const Color(0xFF415A77),
                ]
              : [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFE2E8F0),
                  const Color(0xFFCBD5E1),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background orbs
          ...List.generate(5, (index) {
            return Positioned(
              top: (index * 150.0) % size.height,
              left: (index * 200.0) % size.width,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      math.sin(_fadeController.value * 2 * math.pi + index) * 20,
                      math.cos(_fadeController.value * 2 * math.pi + index) * 30,
                    ),
                    child: Container(
                      width: 80 + (index * 20.0),
                      height: 80 + (index * 20.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            (isDark ? Colors.orange : Colors.blue).withOpacity(0.1),
                            (isDark ? Colors.deepOrange : Colors.indigo).withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDynamicHeader(ThemeData theme, bool isDark) {
    // Fixed overflow issue by reducing padding and font sizes
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: isDark 
          ? SystemUiOverlayStyle.light 
          : SystemUiOverlayStyle.dark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                (isDark ? Colors.black : Colors.white).withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<SupabaseAuthService>(
                  builder: (context, auth, child) {
                    final hour = DateTime.now().hour;
                    String greeting = 'Good morning';
                    if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
                    if (hour >= 17) greeting = 'Good evening';
                    
                    final name = auth.isAuthenticated
                        ? (auth.displayName ?? 'User')
                        : 'Seeker';
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting,',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w300,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Let ancient wisdom guide your day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white.withOpacity(0.7) : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerseOfTheDayCard(ThemeData theme, bool isDark) {
    return FutureBuilder<Verse>(
      future: _verseFuture,
      builder: (context, snapshot) {
        // Show loading if future is null or waiting
        if (_verseFuture == null || snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(theme, isDark, 'Loading verse of the day...');
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard(theme, isDark, 'Could not load verse');
        }

        final verse = snapshot.data!;
        return Hero(
          tag: 'verse_card',
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1E293B),
                        const Color(0xFF334155),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                if (isDark)
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 0),
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verse of the Day',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isDark 
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Chapter $_chapterId, Verse ${verse.verseId}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.7)
                                    : theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withOpacity(0.05)
                          : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Text(
                      verse.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : theme.colorScheme.onSurface,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(ThemeData theme, bool isDark) {
    final actions = [
      {
        'title': 'Scenarios',
        'subtitle': 'Real-life guidance',
        'icon': Icons.psychology,
        'color': Colors.purple,
        'onTap': () => widget.onTabChange?.call(2),
      },
      {
        'title': 'Chapters',
        'subtitle': 'Explore teachings',
        'icon': Icons.menu_book,
        'color': Colors.indigo,
        'onTap': () => widget.onTabChange?.call(1),
      },
      {
        'title': 'Practice',
        'subtitle': 'Daily spiritual growth',
        'icon': Icons.self_improvement,
        'color': Colors.green,
        'onTap': () => widget.onTabChange?.call(3),
      },
      {
        'title': 'More',
        'subtitle': 'Settings & features',
        'icon': Icons.explore,
        'color': Colors.orange,
        'onTap': () => widget.onTabChange?.call(4),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(theme, isDark, action);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(ThemeData theme, bool isDark, Map<String, dynamic> action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action['onTap'],
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF334155),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (action['color'] as Color).withOpacity(0.8),
                        (action['color'] as Color),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (action['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    action['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  action['title'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    action['subtitle'],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedChaptersSection(ThemeData theme, bool isDark) {
    return FutureBuilder<List<Chapter>>(
      future: _chaptersFuture,
      builder: (context, snapshot) {
        // Show loading if future is null or waiting
        if (_chaptersFuture == null || snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(theme, isDark, 'Loading featured chapters...');
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard(theme, isDark, 'Could not load chapters');
        }

        final chapters = snapshot.data!.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Chapters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onTabChange?.call(1),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  return _buildChapterCard(theme, isDark, chapters[index], index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChapterCard(ThemeData theme, bool isDark, Chapter chapter, int index) {
    final colors = [
      [Colors.purple, Colors.deepPurple],
      [Colors.blue, Colors.indigo],
      [Colors.green, Colors.teal],
    ];
    
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[index % colors.length],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[index % colors.length][0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to specific chapter detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChapterDetailView(chapterId: chapter.chapterId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Chapter ${chapter.chapterId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chapter.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          chapter.summary ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyInspirationCard(ThemeData theme, bool isDark) {
    final inspirations = [
      "The mind is everything. What you think you become.",
      "In the depths of winter, I finally learned that within me there lay an invincible summer.",
      "The only way to make sense out of change is to plunge into it, move with it, and join the dance.",
      "What we plant in the soil of contemplation, we shall reap in the harvest of action.",
    ];
    
    final inspiration = inspirations[math.Random().nextInt(inspirations.length)];
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.amber.shade800,
                  Colors.orange.shade700,
                ]
              : [
                  Colors.amber.shade300,
                  Colors.orange.shade400,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Daily Inspiration',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '"$inspiration"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ancient Wisdom',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme, bool isDark, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark 
                  ? Colors.white.withOpacity(0.7)
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, bool isDark, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark 
                  ? Colors.white.withOpacity(0.7)
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingOverlay(ThemeData theme, bool isDark) {
    return AnimatedOpacity(
      opacity: _showGreeting ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to GitaWisdom',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your journey of ancient wisdom begins now',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark 
                        ? Colors.white.withOpacity(0.7)
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get 5 random parenting and relationship scenarios (optimized for performance)
  Future<List<Scenario>> _getParentingAndRelationshipDilemmas() async {
    try {
      debugPrint('🔄 Loading dilemmas for home screen...');

      // Quick check: if service already has cached scenarios, use them with background filtering
      if (ScenarioServiceAdapter.instance.hasScenarios) {
        // Service is already initialized and has cached data - much faster!
        debugPrint('✅ Using cached scenarios for dilemmas');

        // We need to access scenarios somehow - let's try searchScenarios with empty query
        // which should return all scenarios
        final allScenarios = ScenarioServiceAdapter.instance.searchScenarios('');
        debugPrint('📊 Found ${allScenarios.length} total scenarios for filtering');

        if (allScenarios.isNotEmpty) {
          // Convert Scenario objects to ScenarioData for isolate communication
          final scenarioDataList = allScenarios.map((scenario) => ScenarioData(
            title: scenario.title,
            description: scenario.description,
            category: scenario.category,
            chapter: scenario.chapter,
          )).toList();

          // Use compute() for background filtering to prevent UI blocking
          final filteredData = await compute(_filterParentingAndRelationshipScenarios, scenarioDataList);
          debugPrint('🎯 Filtered to ${filteredData.length} relevant scenarios');

          if (filteredData.isNotEmpty) {
            // Convert filtered data back to Scenario objects
            final filtered = <Scenario>[];
            for (final data in filteredData) {
              final scenario = allScenarios.firstWhere(
                (s) => s.title == data.title,
                orElse: () => allScenarios.first, // Fallback to avoid null
              );
              filtered.add(scenario);
            }

            filtered.shuffle();
            final result = filtered.take(5).toList();
            debugPrint('✅ Returning ${result.length} dilemmas for display');
            return result;
          } else {
            debugPrint('⚠️ No scenarios matched filter criteria, using fallback');
          }
        }
      }

      // Only initialize and load if we have no choice
      debugPrint('⚠️ No cached scenarios - initializing service (may cause performance impact)');
      await ScenarioServiceAdapter.instance.initialize();

      // Try searchScenarios again after initialization
      final allScenarios = ScenarioServiceAdapter.instance.searchScenarios('');
      debugPrint('📊 After initialization: ${allScenarios.length} scenarios available');

      if (allScenarios.isNotEmpty) {
        // Convert to ScenarioData for isolate processing
        final scenarioDataList = allScenarios.map((scenario) => ScenarioData(
          title: scenario.title,
          description: scenario.description,
          category: scenario.category,
          chapter: scenario.chapter,
        )).toList();

        final filteredData = await compute(_filterParentingAndRelationshipScenarios, scenarioDataList);
        debugPrint('🎯 Post-init filtered to ${filteredData.length} relevant scenarios');

        if (filteredData.isNotEmpty) {
          // Convert back to Scenario objects
          final filtered = <Scenario>[];
          for (final data in filteredData) {
            final scenario = allScenarios.firstWhere(
              (s) => s.title == data.title,
              orElse: () => allScenarios.first,
            );
            filtered.add(scenario);
          }

          filtered.shuffle();
          return filtered.take(5).toList();
        } else {
          // Fallback: return some random scenarios if filtering fails
          debugPrint('⚠️ Filtering failed, returning random scenarios as fallback');
          allScenarios.shuffle();
          return allScenarios.take(5).toList();
        }
      }

      // This should not happen, but return empty list if it does
      debugPrint('❌ No scenarios available after initialization');
      return [];

    } catch (e) {
      debugPrint('❌ Failed to load dilemmas: $e');
      // Return empty list to show error state in UI
      return [];
    }
  }

  Widget _buildDilemmasCarousel(ThemeData theme, bool isDark) {
    return FutureBuilder<List<Scenario>>(
      future: _dilemmasFuture,
      builder: (context, snapshot) {
        // Show loading if future is null or waiting
        if (_dilemmasFuture == null || snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(theme, isDark, 'Loading life dilemmas...');
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildErrorCard(theme, isDark, 'Could not load dilemmas');
        }

        final dilemmas = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Life Dilemmas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_currentDilemmaPage + 1} / ${dilemmas.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? Colors.white.withOpacity(0.6)
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _dilemmasPageController,
                itemCount: dilemmas.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentDilemmaPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildDilemmaCard(theme, isDark, dilemmas[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                dilemmas.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentDilemmaPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentDilemmaPage == index
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDilemmaCard(ThemeData theme, bool isDark, Scenario scenario) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade600,
            Colors.purple.shade500,
            Colors.indigo.shade500,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate directly to the specific scenario detail
          Navigator.of(context).pushNamed('/scenario-detail', arguments: scenario);
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Life Dilemma',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              scenario.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                scenario.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Heart vs Duty guidance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
