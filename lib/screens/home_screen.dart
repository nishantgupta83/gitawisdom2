/****** JULY - 20 HOMESCREEN WORKING

// lib/screens/home_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../services/service_locator.dart';
import '../services/daily_verse_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _service = ServiceLocator.instance.enhancedSupabaseService;
  late final int _chapterId;
  late final Future<Verse> _verseFuture;

  @override
  void initState() {
    super.initState();
    // pick a random chapter 1–18 once
    _chapterId = Random().nextInt(18) + 1;
    _verseFuture = _service.fetchRandomVerseByChapter(_chapterId);
  }

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surface   = theme.colorScheme.surface;
    final primary   = theme.colorScheme.primary;

    return Scaffold(
      // keep bottom tabs visible
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with dark overlay for dark mode
          Image.asset(
            'assets/images/app_bg.png',
            fit: BoxFit.cover,
            color: theme.brightness == Brightness.dark ? Colors.black.withAlpha((0.32 * 255).toInt()) : null,
            colorBlendMode: theme.brightness == Brightness.dark ? BlendMode.darken : null,
          ),

          // centered card
          Center(
            child: FutureBuilder<Verse>(
              future: _verseFuture,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snap.hasError || !snap.hasData) {
                  return Text(
                    '⚠️ Could not load verse.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: onSurface),
                  );
                }

                final verse = snap.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Verse of the Day',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        verse.description,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: onSurface),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Chapter $_chapterId, Verse ${verse.verseId}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: onSurface.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

    /*
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home tab
        onTap: (i) {
          // Use your root-scaffold navigation logic here
          // e.g. context.read<NavigationController>().goTo(i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
           BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Scenarios'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Chapters'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
      */
    );
  }
}
*/


// NEW HOMEPAGE BASED ON FEEDBACK JUY-20-2025

// lib/screens/home_screen.dart
/*
Key highlights

We generate 10 random chapter IDs and corresponding futures in initState.

A PageView.builder lays them out horizontally, each wrapped in an AnimatedContainer that adds a golden glow when it’s the active page.

The “Why Old Wisdom?” card is gone.

Hero banner text is bottom‑left, and now shows a second line.
*/


// JULY-20 AFTERNOON WITH NEW FONT, HERO BANNER AND BACKGROUND
// lib/screens/home_screen.dart
/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';             // ← 4) Neumorphic cards
import 'package:smooth_page_indicator/smooth_page_indicator.dart';       // ← 3) Dots indicator

import '../models/verse.dart';
import '../services/supabase_service.dart';
import '../screens/chapters_screen.dart';
import '../screens/scenarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _service = SupabaseService();

  late final List<Future<Verse>> _verseFutures;  // holds 10 random‑verse futures
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // ─── 3) PREPARE 10 RANDOM VERSES ───────────────────────────────
    _verseFutures = List.generate(10, (_) {
      final randomChap = Random().nextInt(18) + 1;
      return _service.fetchRandomVerseByChapter(randomChap);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ─── FULLSCREEN BACKGROUND IMAGE ───────────────────────────────
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ─── MAIN SCROLLABLE CONTENT ─────────────────────────────────
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // ─── HERO BANNER ────────────────────────────────────────
              Stack(
                children: [
                  // (a) banner image with reduced opacity
                  Image.asset(
                    'assets/images/ow_hb.jpeg',
                    width: double.infinity,
                    height: 160,
                    color: Colors.black.withOpacity(0.2),
                    colorBlendMode: BlendMode.darken,
                    fit: BoxFit.cover,
                  ),
                  // (b) darker overlay for text legibility
                  Container(
                    width: double.infinity,
                    height: 160,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  // (c) centered title + subtitle at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Column(
                      children: [
                        Text(
                          'GITA WISDOM',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bite‑size daily guidance',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // ─── 1) & 2) GLOWING NAV BUTTONS ───────────────────────
                  Positioned(
                    top: 26, // ↑ moved down by 10px
                    right: 72,
                    child: _glowingNavButton(
                      icon: Icons.menu_book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChapterScreen()),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 26, // ↑ moved down by 10px
                    right: 16,
                    child: _glowingNavButton(
                      icon: Icons.list_alt,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScenariosScreen()),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ─── 3) VERSE CAROUSEL ─────────────────────────────────
              SizedBox(
                height: 260, // ↑ made taller
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _verseFutures.length,
                  onPageChanged: (idx) {
                    if (mounted) setState(() => _currentPage = idx);
                  },
                  itemBuilder: (context, i) {
                    return FutureBuilder<Verse>(
                      future: _verseFutures[i],
                      builder: (ctx, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snap.hasError || snap.data == null) {
                          return Center(child: Text('Error loading verse',
                              style: theme.textTheme.bodyMedium));
                        }
                        final v = snap.data!;
                        final chapId = _verseFutures[i]; //NISHANT ADDING
                        // ─── 4) NEUMORPHIC CARD ───────────────────────────
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              color: theme.colorScheme.surface,
                              depth: _currentPage == i ? 8 : 4,    // glow deeper on active
                              intensity: 0.8,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Verses Refresher',
                                      style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(v.description,
                                        style: theme.textTheme.bodyMedium),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'TEMP',
                                 //    '- Chapter $chapId, Verse ${verse.verseId}', // previously working code.
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // ─── 3b) PAGE DOT INDICATOR ─────────────────────────────
              const SizedBox(height: 12),
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _verseFutures.length,
                  effect: WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    activeDotColor: Colors.amber,
                    dotColor: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // … you can add more content here, e.g. a footer
            ],
          ),
        ],
      ),
    );
  }
}

/// 48×48 circular icon with an amber glow behind it.
/// Tapping it fires [onTap].
Widget _glowingNavButton({required IconData icon, required VoidCallback onTap}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.amber.withOpacity(0.5),
          blurRadius: 16,
          spreadRadius: 4,
        ),
      ],
    ),
    child: CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      child: IconButton(
        splashRadius: 28,
        icon: Icon(icon, color: Colors.deepPurple),
        onPressed: onTap,
      ),
    ),
  );
}

*/

/*
HomeScreen (StatefulWidget)
    │
    │
    ▼
_HomeScreenState
    │
    ├── initState()
    │     └── Initializes _chapterId
    │     └── Initializes _verseFuture with random verses
    │
    ├── build(BuildContext context)
    │     └── Returns Scaffold
    │           └── Stack
    │               ├── (1) Background Image
    │               └── (2) ListView (Main Content)
    │                       ├── Stack (Hero Banner)
    │                       │     ├── Banner Image, Overlay, Title, Subtitle
    │                       │     └── _glowingNavButton() [x2]
    │                       │
    │                       ├── FutureBuilder<List<Verse>>  // Verse Carousel
    │                       │     ├── (If Loading) _loadingCard()
    │                       │     ├── (If Error)   _errorCard()
    │                       │     └── (If Data)    PageView.builder
    │                       │            └── _neumorphicCard() for each Verse
    │                       │
    │                       └── (Footer spacing)
    │
    ├── _loadingCard()           // Returns loading Widget
    ├── _errorCard(msg)          // Returns error Widget with message
    ├── _neumorphicCard(child)   // Returns styled AnimatedContainer
    └── _glowingNavButton(...)   // Returns circular navigation button
*/

// BELOW IS THE ACCENT COLOR FULL FIX


// lib/screens/home_screen.dart


/* WORKING AFTERNOON JULY-22-2025
// WITH HERO BANNER


import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';       // ← 3) Dots indicator
import '../models/verse.dart';
import '../services/supabase_service.dart';
import '../screens/chapters_screen.dart';
import '../screens/scenarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _service = SupabaseService();
  late final int _chapterId;
  late final Future<List<Verse>> _versesFuture;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  final int _carouselCount = 10;

  @override
  void initState() {
    super.initState();
    // 1) Pick a random chapter and preload N verses
    _chapterId = Random().nextInt(18) + 1;
    _versesFuture = Future.wait(
      List.generate(
        _carouselCount,
        (_) => _service.fetchRandomVerseByChapter(_chapterId),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Full‑screen background ───────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.contain,
            ),
          ),

          // ─── Scrollable content ───────────────────────────────
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // ─── Hero banner ──────────────────────────────────
              Stack(
                children: [
                  Image.asset(
                    'assets/images/ow_hb.jpeg',
                    width: double.infinity,
                    height: 120,
                    //color: Colors.black.withOpacity(0.3),
                  //  color: Colors.black.withAlpha((0.2 * 255).round()),
                   // fit: BoxFit.cover,
                    fit: BoxFit.fitWidth, // or BoxFit.contain or fitWidth
                  ),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(8), // fade-in at top
                          Colors.transparent           // fade to transparent at bottom
                        ],
                      ),
                    ),
                   // color: Colors.black.withOpacity(0.3),
                  ),

            // Handwritten font title, centered, moved down
                  Positioned(
                    left: 0,
                    right: 0,
                  //  bottom: 24,
                   top: 56,
                    child: Text(
                      'GITA WISDOM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.caveat (
                        textStyle: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Positioned(
                    left: 16,
                    bottom: 8,
                    child: Text(
                      'Find Wisdom for Any Life Challenge',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.caveatBrush (
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                  ),

                  // Glowing nav buttons (moved down 10px)
                  Positioned(
                    top: 36, right: 72,
                    child: _glowingNavButton(
                      icon: Icons.menu_book_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChapterScreen()),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 36, right: 16,
                    child: _glowingNavButton(
                      icon: Icons.list_alt,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScenariosScreen()),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 64),


              // ─── Verse carousel ─────────────────────────────────
              FutureBuilder<List<Verse>>(
                future: _versesFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return _loadingCard();
                  }
                  if (snap.hasError || snap.data == null) {
                    return _errorCard('Error loading verses');
                  }
                  final verses = snap.data!;
                  return SizedBox(
                    height: 220,
                   // width: 120,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: verses.length,
                      onPageChanged: (idx) {
                        if (mounted) setState(() => _currentPage = idx);
                      },
                      itemBuilder: (ctx, i) {
                        final v = verses[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _neumorphicCard(
                            glow: i == _currentPage,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Verse Refresher',
                                textAlign: TextAlign.left ,
                                style: GoogleFonts.caveatBrush (
                                    textStyle: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : theme.colorScheme.onSurface
                                    ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                   ),
                                const SizedBox(height: 8),
                              Expanded(
                                child: Text(v.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white.withAlpha((0.92 * 255).round())
                                        : theme.colorScheme.onSurface.withAlpha((0.92 * 255).round()),
                                  ),
                                ),
                              ),
                                const SizedBox(height: 8),
                                Text(
                                  '- Chapter $_chapterId, Verse ${v.verseId}',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: onSurface.withOpacity(0.6)),
                                ),
                                const SizedBox(height: 4),
                                // page indicators
                            /*    Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    verses.length,
                                    (j) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      width: i == j ? 8 : 6,
                                      height: i == j ? 8 : 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i == j
                                            ? theme.colorScheme.primary
                                            : onSurface.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                                */
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // ─── 3b) PAGE DOT INDICATOR ─────────────────────────────
              const SizedBox(height: 12),
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _carouselCount,
                  effect: WormEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    activeDotColor: Colors.amber,
                    dotColor: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),

            const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );

  Widget _errorCard(String msg) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text(msg)),
        ),
      );

  /// Manual “neumorphic” card that glows when [glow] is true.
  Widget _neumorphicCard({required Widget child, bool glow = false}) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: Colors.amber.withAlpha((0.6 * 255).round()),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                  offset: const Offset(-6, -6),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).round()),
                  offset: const Offset(6, 6),
                  blurRadius: 16,
                ),
              ],
      ),
     // child: Padding(padding: const EdgeInsets.all(16), child: child),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Padding(padding: EdgeInsets.all(20), child: child),
      ),
    ),
    );
  }

  /// 48×48 circular icon with an amber glow behind it.
  Widget _glowingNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withAlpha((0.5 * 255).round()),
              blurRadius: 16,
              spreadRadius: 6,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withAlpha((0.8 * 255).round()),
          child: IconButton(
            splashRadius: 28,
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );
}

*/

/*
BELOW CODE IS USING 1 CHAPTER AND MULTIPLE VERSES FROM SAME CHAPTER.
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/verse.dart';
import '../services/supabase_service.dart';
import '../screens/chapters_screen.dart';
import '../screens/scenarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _service = SupabaseService();
  late final int _chapterId;
  late final Future<List<Verse>> _versesFuture;
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  final int _carouselCount = 10;

  @override
  void initState() {
    super.initState();
    _chapterId = math.Random().nextInt(18) + 1;
    _versesFuture = Future.wait(
      List.generate(
        _carouselCount,
            (_) => _service.fetchRandomVerseByChapter(_chapterId),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/app_bg.png',
                fit: BoxFit.cover,
                color: isDark ? Colors.black.withOpacity(0.32) : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
            ),

            // Floating navigation buttons
            Positioned(
              top: 20,
              right: isTablet ? 100 : 84,
              child: _glowingNavButton(
                icon: Icons.menu_book,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChapterScreen()),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: isTablet ? 40 : 24,
              child: _glowingNavButton(
                icon: Icons.list_alt,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScenariosScreen()),
                ),
              ),
            ),

            // Main content - Responsive ScrollView
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                ),
                child: Column(
                  children: [
                    // Branding Card - Responsive
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 40 : 20,
                        screenHeight * 0.08, // 8% of screen height
                        isTablet ? 40 : 20,
                        16,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: theme.colorScheme.surface,
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 36 : 28,
                            horizontal: isTablet ? 24 : 16,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'GITA WISDOM',
                                style: GoogleFonts.poiretOne(
                                  fontSize: isTablet ? 36 : 30,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isTablet ? 10 : 6),
                              Text(
                                'Find Wisdom for Any Life Challenge',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 16 : 14.5,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Verse of the Day - Fully Responsive with Flexible Height
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 18,
                        vertical: 15,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate responsive height based on screen size
                          final cardHeight = math.min(
                            screenHeight * 0.4, // Max 40% of screen height
                            math.max(
                              240.0, // Minimum height
                              constraints.maxWidth * 0.6, // Proportional to width
                            ),
                          );

                          return SizedBox(
                            height: cardHeight,
                            child: FutureBuilder<List<Verse>>(
                              future: _versesFuture,
                              builder: (ctx, snap) {
                                if (snap.connectionState != ConnectionState.done) {
                                  return _loadingCard(context, cardHeight);
                                }
                                if (snap.hasError || snap.data == null) {
                                  return _errorCard('Error loading verses', cardHeight);
                                }
                                final verses = snap.data!;
                                return PageView.builder(
                                  controller: _pageController,
                                  itemCount: verses.length,
                                  onPageChanged: (idx) =>
                                      setState(() => _currentPage = idx),
                                  itemBuilder: (ctx, i) {
                                    final v = verses[i];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 12 : 8,
                                      ),
                                      child: Card(
                                        elevation: i == _currentPage ? 12 : 2,
                                        color: theme.colorScheme.surface,
                                        shadowColor: Colors.black.withOpacity(0.12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(isTablet ? 28 : 22),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Verse of the Day",
                                                style: GoogleFonts.poppins(
                                                  fontSize: isTablet ? 19 : 16.5,
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: isTablet ? 18 : 14),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Text(
                                                    v.description,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: isTablet ? 17 : 15,
                                                      color: theme.colorScheme.onSurface,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: isTablet ? 14 : 10),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  "- Chapter $_chapterId, Verse ${v.verseId}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: isTablet ? 14 : 13,
                                                    color: theme.colorScheme.onSurface
                                                        .withOpacity(0.56),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Page Indicator - Responsive
                    Padding(
                      padding: EdgeInsets.only(
                        top: isTablet ? 16 : 12,
                        bottom: isTablet ? 28 : 20,
                      ),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _carouselCount,
                        effect: WormEffect(
                          dotWidth: isTablet ? 16 : 14,
                          dotHeight: isTablet ? 16 : 14,
                          activeDotColor: theme.colorScheme.primary,
                          dotColor: theme.colorScheme.onSurface.withOpacity(0.32),
                        ),
                      ),
                    ),

                    // Extra bottom spacing for navigation bar
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingCard(BuildContext context, double height) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    margin: const EdgeInsets.all(0),
    color: Theme.of(context).colorScheme.surface,
    child: SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    ),
  );

  Widget _errorCard(String msg, double height) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    margin: const EdgeInsets.all(0),
    color: Theme.of(context).colorScheme.surface,
    child: SizedBox(
      height: height,
      child: Center(child: Text(msg)),
    ),
  );

  Widget _glowingNavButton({required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final buttonSize = isTablet ? 28.0 : 24.0;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.19),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: buttonSize,
        backgroundColor: Colors.white.withOpacity(0.8),
        child: IconButton(
          splashRadius: buttonSize + 4,
          icon: Icon(icon, color: theme.colorScheme.primary),
          onPressed: onTap,
        ),
      ),
    );
  }
}
*/


/*
Scaffold
└─ body: Stack
   ├─ Positioned.fill
   │    └─ Image.asset('app_bg.png') [background, covers screen]
   ├─ SafeArea
   │    └─ Padding (bottom: ...+24)
   │         └─ ListView
   │             ├─ Padding (top: 60, bottom: 14)
   │             │    └─ Card (Branding)
   │             │         └─ Column
   │             │              ├─ Text("GITA WISDOM")
   │             │              └─ Text("Apply Gita Teaching...")
   │             ├─ Padding (top: 15, bottom: 18)
   │             │    └─ SizedBox(height: 280)
   │             │         └─ FutureBuilder<List<Verse>>
   │             │              ├─ (loading or error: card)
   │             │              └─ PageView.builder (carousel)
   │             │                   └─ Container (margin)
   │             │                       └─ Card (Verse)
   │             │                            └─ Column
   │             │                                 ├─ Text("Verse Refresher")
   │             │                                 ├─ Expanded: Text(verse description)
   │             │                                 └─ Align: Text("- Chapter X, Verse Y")
   │             └─ Center
   │                 └─ Padding (top/bottom: 6/20)
   │                      └─ SmoothPageIndicator
   ├─ Positioned (top:26, right:84)
   │    └─ _glowingNavButton (icon: Icons.menu_book)
   └─ Positioned (top:26, right:24)
        └─ _glowingNavButton (icon: Icons.list_alt)

┌────────────────────────── Scaffold ──────────────────────────┐
│ ┌──────────────────── Stack ──────────────────────────────┐  │
│ │ BG: Positioned.fill (Image.asset: app_bg.png)           │  │
│ │ ┌──────────── SafeArea ──────────────┐                  │  │
│ │ │ ┌──── Padding (bottom 24) ──────┐ │                  │  │
│ │ │ │    ┌────── ListView ──────┐   │ │                  │  │
│ │ │ │    │  Padding             │   │ │                  │  │
│ │ │ │    │  ┌─ Card ──────────┐ │   │ │                  │  │
│ │ │ │    │  │"GITA WISDOM"    │ │   │ │                  │  │
│ │ │ │    │  │Subtitle         │ │   │ │                  │  │
│ │ │ │    │  └─────────────────┘ │   │ │                  │  │
│ │ │ │    │  Padding              │   │ │                  │  │
│ │ │ │    │  ┌─ SizedBox (280) ┐  │   │ │───┐              │  │
│ │ │ │    │  │ FutureBuilder    │  │   │    │              │  │
│ │ │ │    │  │ └─PageView      │  │   │    │              │  │
│ │ │ │    │  │   └─Card per    │  │   │    │              │  │
│ │ │ │    │  │     verse (title│  │   │    │              │  │
│ │ │ │    │  │     + exp desc  │  │   │    │              │  │
│ │ │ │    │  │     + source    │  │   │    │              │  │
│ │ │ │    │  └─────────────────┘  │   │    │              │  │
│ │ │ │    │  Center(SmoothIndicator)│ │    │              │  │
│ │ │ │    └────────────────────────┘ │    │              │  │
│ │ │ └───────────────────────────────┘    │              │  │
│ │ └──────────────────────────────────────┘              │  │
│ │ Positioned(top:26, right:84)  [Chapters btn]          │  │
│ │ Positioned(top:26, right:24)  [Scenarios btn]         │  │
│ └───────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘


 */

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/verse.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import '../services/daily_verse_service.dart';
import '../services/scenario_service.dart';
// import '../services/journal_service.dart'; // COMMENTED OUT: User-specific features disabled
import '../services/settings_service.dart';
import '../screens/scenario_detail_view.dart';
// import '../screens/new_journal_entry_dialog.dart'; // COMMENTED OUT: User-specific features disabled
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const HomeScreen({Key? key, this.onTabChange}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _service = SupabaseService();
  final DailyVerseService _dailyVerseService = DailyVerseService.instance;
  final ScenarioService _scenarioService = ScenarioService.instance;
  final SettingsService _settingsService = SettingsService();

  late final Future<List<Verse>> _versesFuture;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final PageController _scenarioPageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  int _currentScenarioPage = 0;
  
  List<Scenario> _modernDilemmaScenarios = [];
  bool _isLoadingScenarios = true;
  
  // Number of verses to display in carousel
  final int _carouselCount = 5;
  
  // Categories for Modern Dilemma carousel
  final List<String> _modernDilemmaCategories = ['new parents', 'family', 'relationships'];

  @override
  void initState() {
    super.initState();

    // 1️⃣ Use calendar-based verse refreshing (same verses all day)
    _versesFuture = _dailyVerseService.getTodaysVerses();
    
    // 2️⃣ Load Modern Dilemma scenarios
    _loadModernDilemmaScenarios();
  }

  void _loadModernDilemmaScenarios() async {
    if (!mounted) return;
    
    try {
      setState(() => _isLoadingScenarios = true);
      
      // Ensure ScenarioService is initialized
      await _scenarioService.initialize();
      
      // Get 5 random scenarios from the specified categories
      final scenarios = _scenarioService.fetchScenariosByCategories(
        _modernDilemmaCategories,
        limit: 5,
      );
      
      if (mounted) {
        setState(() {
          _modernDilemmaScenarios = scenarios;
          _isLoadingScenarios = false;
        });
      }
      
      debugPrint('🎯 Loaded ${scenarios.length} Modern Dilemma scenarios');
    } catch (e) {
      debugPrint('❌ Error loading Modern Dilemma scenarios: $e');
      if (mounted) {
        setState(() => _isLoadingScenarios = false);
      }
    }
  }

  void _refreshModernDilemmaScenarios() {
    debugPrint('🔄 Refreshing Modern Dilemma scenarios...');
    _loadModernDilemmaScenarios();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scenarioPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      // Global background handled by main.dart
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [


          // Main scrollable content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Branding Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                    child: Card(
                      // Use theme.cardTheme styling
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              (AppLocalizations.of(context)?.appTitle ?? 'Gitawisdom').toUpperCase(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context)?.applyGitaTeaching ?? 'Find Wisdom for Any Life Challenge',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Modern Dilemma Carousel (5 cards) - moved up
                  _buildModernDilemmaCarousel(theme),
                  
                  // Verse of the Day Card - Now with random chapters - moved down
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 18),
                    child: SizedBox(
                      height: 280,
                      child: FutureBuilder<List<Verse>>(
                        future: _versesFuture,
                        builder: (ctx, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return _loadingCard(context);
                          }
                          if (snap.hasError || snap.data == null) {
                            return _errorCard(AppLocalizations.of(context)?.errorLoadingData ?? 'Error loading data');
                          }
                          final verses = snap.data!;
                          return PageView.builder(
                            controller: _pageController,
                            itemCount: verses.length,
                            onPageChanged: (idx) {
                              if (mounted) setState(() => _currentPage = idx);
                            },
                            itemBuilder: (ctx, i) {
                              final v = verses[i];
                              // Use chapter ID from the verse model
                              final chapterId = v.chapterId ?? 1;

                              return Container(
                                margin: EdgeInsets.only(
                                  top: i == 0 ? 0 : 12,
                                  bottom: i == verses.length - 1 ? 0 : 8,
                                  left: 6,
                                  right: 6,
                                ),
                                child: Card(
                                  // Use theme.cardTheme with dynamic elevation
                                  elevation: i == _currentPage ? 8 : 4, // Use theme-consistent values
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)?.verseRefresher ?? 'Tap for new verse',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              v.description,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "- Chapter $chapterId, Verse ${v.verseId}",
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Page Indicator (dots)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 20),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _carouselCount,
                        effect: WormEffect(
                          dotWidth: 14,
                          dotHeight: 14,
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: Theme.of(context).colorScheme.onSurface.withAlpha((0.38 * 255).toInt()),
                        ),
                      ),
                    ),
                  ),
                  
                  // COMMENTED OUT: User-specific journal features disabled
                  // _buildJournalReflectionWidget(theme),
                ],
              ),
            ),
          ),
          // Floating navigation buttons
          Positioned(
            top: 26,
            right: 84,
            child: _glowingNavButton(
              icon: Icons.menu_book,
              onTap: () {
                if (widget.onTabChange != null) {
                  widget.onTabChange!(1); // Navigate to chapters tab (index 1)
                }
              },
            ),
          ),
          Positioned(
            top: 26,
            right: 24,
            child: _glowingNavButton(
              icon: Icons.list_alt,
              onTap: () {
                if (widget.onTabChange != null) {
                  widget.onTabChange!(2); // Navigate to scenarios tab (index 2)
                }
              },
            ),
          ),
          

        ],
      ),
    );
  }

  Widget _loadingCard(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  Widget _errorCard(String msg) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Center(child: Text(msg)),
    ),
  );


  Widget _buildModernDilemmaCarousel(ThemeData theme) {
    if (_isLoadingScenarios) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Card(
          elevation: 4,
          child: Container(
            height: 180,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (_modernDilemmaScenarios.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Card(
          elevation: 4,
          child: Container(
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 32,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No scenarios available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshModernDilemmaScenarios,
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Modern Dilemma Section Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (AppLocalizations.of(context)?.modernDilemma ?? 'Modern Dilemma').toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isLoadingScenarios ? null : _refreshModernDilemmaScenarios,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.refresh,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16), // Spacing between title and carousel
              
              // Modern Dilemma Carousel
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _scenarioPageController,
                  itemCount: _modernDilemmaScenarios.length,
                  onPageChanged: (idx) {
                    if (mounted) setState(() => _currentScenarioPage = idx);
                  },
                  itemBuilder: (ctx, i) {
                    final scenario = _modernDilemmaScenarios[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Card(
                        elevation: i == _currentScenarioPage ? 8 : 4,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  scenario.category.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Scenario Title
                              Text(
                                scenario.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              
                              const Spacer(),
                              
                              // Show Wisdom Button
                              _buildCompactShowWisdomButton(scenario, theme),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Page indicator for Modern Dilemma carousel
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SmoothPageIndicator(
                  controller: _scenarioPageController,
                  count: _modernDilemmaScenarios.length,
                  effect: WormEffect(
                    dotWidth: 12,
                    dotHeight: 12,
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactShowWisdomButton(Scenario scenario, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            debugPrint('🔍 Home: Navigating to scenario detail: ${scenario.title}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScenarioDetailView(scenario: scenario),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '🔮 ${(AppLocalizations.of(context)?.showWisdom ?? 'Show Wisdom').toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // COMMENTED OUT: User-specific journal features disabled
  /*
  Widget _buildJournalReflectionWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with journal icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'DAILY REFLECTION',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Add spacing between title and subtitle
              Padding(
                padding: const EdgeInsets.only(left: 44), // Align with title text after icon
                child: Text(
                  'Start your spiritual journal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 44), // Placeholder for alignment
                ],
              ),
              const SizedBox(height: 16),
              
              // Daily prompt or recent entry
              _buildJournalContent(theme),
              
              const SizedBox(height: 16),
              
              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: _buildJournalActionButton(
                      icon: Icons.add,
                      label: 'NEW ENTRY',
                      color: Colors.green,
                      onTap: _openNewJournalEntry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildJournalActionButton(
                      icon: Icons.list,
                      label: 'VIEW ALL',
                      color: Colors.blue,
                      onTap: () => widget.onTabChange?.call(3), // Navigate to journal tab
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  */

  // COMMENTED OUT: User-specific journal features disabled
  /*
  Widget _buildJournalContent(ThemeData theme) {
    return FutureBuilder<List<dynamic>>(
      future: _getJournalContentData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            height: 60,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data![0] != null) {
          // Show recent journal entry
          final entries = snapshot.data![0] as List;
          if (entries.isNotEmpty) {
            final recentEntry = entries.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your latest reflection:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recentEntry.reflection.length > 120 
                        ? '${recentEntry.reflection.substring(0, 120)}...'
                        : recentEntry.reflection,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            );
          }
        }
        
        // Show daily prompt for new users
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s reflection prompt:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                _getDailyPrompt(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJournalActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> _getJournalContentData() async {
    try {
      final entries = await JournalService.instance.fetchEntries();
      return [entries];
    } catch (e) {
      debugPrint('❌ Error fetching journal entries for home widget: $e');
      return [null];
    }
  }

  String _getDailyPrompt() {
    final prompts = [
      "How did I apply dharma (righteous duty) in a difficult situation today?",
      "What teaching from the Gita resonated with me this week?",
      "When did I choose between heart and duty today? What did I learn?",
      "How can I bring more peace and wisdom into tomorrow?",
      "What am I grateful for in my spiritual journey right now?",
      "How did I practice detachment from outcomes today?",
      "What challenged my understanding of karma this week?",
    ];
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return prompts[dayOfYear % prompts.length];
  }

  void _openNewJournalEntry() {
    showDialog(
      context: context,
      builder: (_) => NewJournalEntryDialog(
        onSave: (entry) async {
          try {
            await JournalService.instance.createEntry(entry);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)?.journalEntrySaved ?? 'Journal entry saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to save entry: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
  */

  Widget _glowingNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amberAccent,
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 26,
         // backgroundColor: Colors.white.withAlpha((0.8 * 255).toInt()),
          backgroundColor: Theme.of(context).colorScheme.background,
          child: IconButton(
            splashRadius: 32,
            icon: Icon(icon, size:  32, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );

}
