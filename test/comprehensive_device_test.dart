import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/main.dart';
import 'package:GitaWisdom/widgets/custom_nav_bar.dart';
import 'package:GitaWisdom/screens/home_screen.dart';
import 'package:GitaWisdom/screens/chapters_screen.dart';
import 'package:GitaWisdom/screens/scenarios_screen.dart';
import 'package:GitaWisdom/screens/more_screen.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'test_helpers.dart';
import 'test_config.dart';

/// Comprehensive device and orientation testing for GitaWisdom app
/// Tests across phone, tablet, iPad, and desktop sizes in both orientations
// Device size configurations - moved to global scope
const phonePortrait = Size(375, 667);   // iPhone 8
const phoneLandscape = Size(667, 375);  // iPhone 8 landscape
const tabletPortrait = Size(768, 1024); // iPad portrait
const tabletLandscape = Size(1024, 768); // iPad landscape
const desktopSize = Size(1440, 900);    // MacBook Air
const ultraWideSize = Size(1920, 1080); // Desktop ultrawide

void main() {
  setUpAll(() async {
    await commonTestSetup();
  });

  tearDownAll(() async {
    await commonTestCleanup();
  });

  group('Device Size and Orientation Tests', () {

    void testDeviceSize(String deviceName, Size size, {bool isTablet = false, bool isDesktop = false}) {
      testWidgets('$deviceName (${size.width}x${size.height}) - Navigation works correctly', 
        (WidgetTester tester) async {
        
        // Set device size
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => SettingsService(),
            child: TestConfig.wrapWithMaterialApp(
              MediaQuery(
                data: MediaQueryData(
                  size: size,
                  devicePixelRatio: isDesktop ? 2.0 : (isTablet ? 2.0 : 3.0),
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: const RootScaffold(),
              ),
            ),
          ),
        );

        await TestConfig.pumpWithSettle(tester);

        // Verify main app structure exists
        expect(find.byType(RootScaffold), findsOneWidget);
        expect(find.byType(IndexedStack), findsOneWidget);
        expect(find.byType(CustomNavBar), findsOneWidget);

        // Test navigation tapping
        await tester.tap(find.text('Chapters'));
        await tester.pumpAndSettle();
        expect(find.byType(ChapterScreen), findsOneWidget);

        await tester.tap(find.text('Scenarios'));
        await tester.pumpAndSettle();
        expect(find.byType(ScenariosScreen), findsOneWidget);

        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();
        expect(find.byType(MoreScreen), findsOneWidget);

        // Return to home
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('$deviceName - Text scaling works correctly', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(size);
        
        // Test different text scale factors
        for (double scaleFactor in [0.8, 1.0, 1.2, 1.5, 2.0]) {
          await tester.pumpWidget(
            ChangeNotifierProvider(
              create: (_) => SettingsService(),
              child: TestConfig.wrapWithMaterialApp(
                MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scaleFactor),
                  ),
                  child: const ChapterScreen(),
                ),
              ),
            ),
          );

          await TestConfig.pumpWithSettle(tester);

          // Verify text still renders correctly at different scales
          expect(find.byType(ChapterScreen), findsOneWidget);
          expect(find.text('Gita Chapters'), findsOneWidget);
          
          // Navigation text should be visible
          expect(find.byType(CustomNavBar), findsOneWidget);
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Chapters'), findsOneWidget);
        }
      });

      testWidgets('$deviceName - Navigation text visibility in custom nav bar', 
        (WidgetTester tester) async {
        
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(
          TestConfig.wrapWithMaterialApp(
            MediaQuery(
              data: MediaQueryData(size: size),
              child: Scaffold(
                bottomNavigationBar: CustomNavBar(
                  currentIndex: 0,
                  onTap: (index) {},
                  items: const [
                    NavBarItem(icon: Icons.home, label: 'Home'),
                    NavBarItem(icon: Icons.menu_book, label: 'Chapters'),
                    NavBarItem(icon: Icons.list, label: 'Scenarios'),
                    NavBarItem(icon: Icons.more_horiz, label: 'More'),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify all navigation text is visible
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Chapters'), findsOneWidget);
        expect(find.text('Scenarios'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);

        // Test tapping works correctly
        await tester.tap(find.text('Chapters'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Scenarios'));
        await tester.pumpAndSettle();
      });
    }

    // Test all device configurations
    testDeviceSize('iPhone Portrait', phonePortrait);
    testDeviceSize('iPhone Landscape', phoneLandscape);
    testDeviceSize('iPad Portrait', tabletPortrait, isTablet: true);
    testDeviceSize('iPad Landscape', tabletLandscape, isTablet: true);
    testDeviceSize('macOS Desktop', desktopSize, isDesktop: true);
    testDeviceSize('Ultra-wide Desktop', ultraWideSize, isDesktop: true);

    // Test orientation changes don't break navigation
    testWidgets('Orientation change preserves navigation state', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(phonePortrait);
      
      int currentIndex = 0;
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          StatefulBuilder(
            builder: (context, setState) {
              return MediaQuery(
                data: MediaQueryData(size: tester.binding.window.physicalSize / tester.binding.window.devicePixelRatio),
                child: Scaffold(
                  body: IndexedStack(
                    index: currentIndex,
                    children: const [
                      Center(child: Text('Home')),
                      Center(child: Text('Chapters')),
                      Center(child: Text('Scenarios')),
                      Center(child: Text('More')),
                    ],
                  ),
                  bottomNavigationBar: CustomNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    items: const [
                      NavBarItem(icon: Icons.home, label: 'Home'),
                      NavBarItem(icon: Icons.menu_book, label: 'Chapters'),
                      NavBarItem(icon: Icons.list, label: 'Scenarios'),
                      NavBarItem(icon: Icons.more_horiz, label: 'More'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Navigate to Scenarios
      await tester.tap(find.text('Scenarios'));
      await tester.pumpAndSettle();
      expect(find.text('Scenarios'), findsNWidgets(2)); // One in nav, one in body

      // Change to landscape
      await tester.binding.setSurfaceSize(phoneLandscape);
      await tester.pumpAndSettle();

      // Navigation should still work and state preserved
      expect(find.text('Scenarios'), findsNWidgets(2));
      
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('More'), findsNWidgets(2));
    });
  });

  group('Navigation Architecture Stability Tests', () {
    testWidgets('Tab switching does not throw Navigator errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(const RootScaffold()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      // Rapidly switch between tabs - should not crash
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Chapters'));
        await tester.pump();
        
        await tester.tap(find.text('Scenarios'));
        await tester.pump();
        
        await tester.tap(find.text('More'));
        await tester.pump();
        
        await tester.tap(find.text('Home'));
        await tester.pump();
      }
      
      await tester.pumpAndSettle();
      
      // Should still be functional
      expect(find.byType(RootScaffold), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Scenario filtering works without Navigator crashes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(const RootScaffold()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      // Test scenario filtering functionality without Navigator errors
      await tester.tap(find.text('Scenarios'));
      await tester.pumpAndSettle();

      expect(find.byType(ScenariosScreen), findsOneWidget);

      // Switch back to home and then to scenarios again
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Scenarios'));
      await tester.pumpAndSettle();
      
      // Should work without crashes
      expect(find.byType(ScenariosScreen), findsOneWidget);
    });
  });

  group('Theme and Color Rendering Tests', () {
    testWidgets('Light and dark themes render correctly on all devices', (WidgetTester tester) async {
      final devices = [
        phonePortrait,
        phoneLandscape,
        tabletPortrait,
        tabletLandscape,
        desktopSize,
      ];

      for (final deviceSize in devices) {
        await tester.binding.setSurfaceSize(deviceSize);
        
        for (final brightness in [Brightness.light, Brightness.dark]) {
          await tester.pumpWidget(
            ChangeNotifierProvider(
              create: (_) => SettingsService()..setTheme(
                brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light
              ),
              child: MaterialApp(
                theme: ThemeData(brightness: brightness),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: deviceSize,
                    platformBrightness: brightness,
                  ),
                  child: const RootScaffold(),
                ),
              ),
            ),
          );

          await TestConfig.pumpWithSettle(tester);

          // Verify app renders without errors in both themes
          expect(find.byType(RootScaffold), findsOneWidget);
          expect(find.byType(CustomNavBar), findsOneWidget);
          
          // Navigation text should be visible in both themes
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Chapters'), findsOneWidget);
          expect(find.text('Scenarios'), findsOneWidget);
          expect(find.text('More'), findsOneWidget);
        }
      }
    });
  });

  group('Accessibility and Text Scaling Tests', () {
    testWidgets('App handles extreme text scaling gracefully', (WidgetTester tester) async {
      // Test with extreme text scaling values (accessibility requirements)
      final scaleFactors = [0.5, 0.8, 1.0, 1.5, 2.0, 3.0];
      
      for (final scale in scaleFactors) {
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => SettingsService(),
            child: MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: tabletPortrait,
                  textScaler: TextScaler.linear(scale),
                ),
                child: const RootScaffold(),
              ),
            ),
          ),
        );

        await TestConfig.pumpWithSettle(tester);

        // App should render without overflow or layout errors
        expect(find.byType(RootScaffold), findsOneWidget);
        expect(find.byType(CustomNavBar), findsOneWidget);

        // Navigation should still work
        await tester.tap(find.text('Chapters'));
        await tester.pump();
        expect(find.byType(ChapterScreen), findsOneWidget);
        
        await tester.tap(find.text('Home'));
        await tester.pump();
        expect(find.byType(HomeScreen), findsOneWidget);
      }
    });

    testWidgets('Navigation bar adapts to different text scales in landscape', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(phoneLandscape);
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          MediaQuery(
            data: const MediaQueryData(
              size: phoneLandscape,
              textScaler: TextScaler.linear(1.5), // Large text
            ),
            child: Scaffold(
              bottomNavigationBar: CustomNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: const [
                  NavBarItem(icon: Icons.home, label: 'Home'),
                  NavBarItem(icon: Icons.menu_book, label: 'Chapters'),
                  NavBarItem(icon: Icons.list, label: 'Scenarios'),
                  NavBarItem(icon: Icons.more_horiz, label: 'More'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All navigation text should be visible even with large text in landscape
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });
  });

  group('Performance and Stability Tests', () {
    testWidgets('Rapid navigation changes do not cause memory leaks or crashes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(const RootScaffold()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      // Simulate rapid user interaction
      for (int cycle = 0; cycle < 10; cycle++) {
        for (String tab in ['Home', 'Chapters', 'Scenarios', 'More']) {
          await tester.tap(find.text(tab));
          await tester.pump(const Duration(milliseconds: 50));
        }
      }
      
      await tester.pumpAndSettle();

      // App should still be responsive and functional
      expect(find.byType(RootScaffold), findsOneWidget);
      expect(find.byType(MoreScreen), findsOneWidget); // Last tapped tab
    });

    testWidgets('Device size changes are handled gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(const RootScaffold()),
        ),
      );

      // Simulate device rotations and size changes
      final sizes = [phonePortrait, phoneLandscape, tabletPortrait, tabletLandscape];
      
      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpAndSettle();
        
        // App should adapt without errors
        expect(find.byType(RootScaffold), findsOneWidget);
        expect(find.byType(CustomNavBar), findsOneWidget);
        
        // Test navigation works at each size
        await tester.tap(find.text('Scenarios'));
        await tester.pump();
        expect(find.byType(ScenariosScreen), findsOneWidget);
      }
    });
  });

  // Clean up after each test - tester is not available in tearDown
  // Surface size will be reset automatically by Flutter test framework
}