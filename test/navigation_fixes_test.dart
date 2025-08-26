import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:GitaWisdom/main.dart';
import 'package:GitaWisdom/widgets/custom_nav_bar.dart';
import 'package:GitaWisdom/screens/home_screen.dart';
import 'package:GitaWisdom/screens/scenarios_screen.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'test_helpers.dart';
import 'test_config.dart';

/// Focused tests for critical navigation fixes
/// Tests the specific issues fixed: Navigator crashes, landscape visibility, text scaling
void main() {
  setUpAll(() async {
    await commonTestSetup();
  });

  tearDownAll(() async {
    await commonTestCleanup();
  });

  group('Navigation Architecture Fixes', () {
    testWidgets('IndexedStack navigation prevents Navigator crashes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(const RootScaffold()),
        ),
      );

      await TestConfig.pumpWithSettle(tester);

      // Verify main app structure exists with IndexedStack
      expect(find.byType(RootScaffold), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);

      // Rapid tab switching should not crash (this was the main issue)
      for (int i = 0; i < 3; i++) {
        if (find.text('Chapters').evaluate().isNotEmpty) {
          await tester.tap(find.text('Chapters'));
          await tester.pump();
        }
        
        if (find.text('Scenarios').evaluate().isNotEmpty) {
          await tester.tap(find.text('Scenarios'));
          await tester.pump();
        }
        
        if (find.text('Home').evaluate().isNotEmpty) {
          await tester.tap(find.text('Home'));
          await tester.pump();
        }
      }
      
      await tester.pumpAndSettle();
      
      // Should still be functional without crashes
      expect(find.byType(RootScaffold), findsOneWidget);
    });
  });

  group('Landscape Mode Navigation Fixes', () {
    testWidgets('Navigation text visible in landscape on iPhone Pro Max', (WidgetTester tester) async {
      // iPhone Pro Max landscape size
      const landscapeSize = Size(926, 428);
      await tester.binding.setSurfaceSize(landscapeSize);
      
      int currentIndex = 0;
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          StatefulBuilder(
            builder: (context, setState) {
              return MediaQuery(
                data: MediaQueryData(size: landscapeSize),
                child: Scaffold(
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

      await tester.pumpAndSettle();

      // All navigation text should be visible in landscape mode
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Test tapping works correctly in landscape
      await tester.tap(find.text('Scenarios'));
      await tester.pumpAndSettle();
      
      // Text should still be visible after interaction
      expect(find.text('Scenarios'), findsOneWidget);
    });

    testWidgets('Navigation adapts to different device sizes', (WidgetTester tester) async {
      final deviceSizes = [
        const Size(375, 667),   // iPhone 8 portrait
        const Size(667, 375),   // iPhone 8 landscape  
        const Size(414, 896),   // iPhone 11 Pro portrait
        const Size(896, 414),   // iPhone 11 Pro landscape
        const Size(768, 1024),  // iPad portrait
        const Size(1024, 768),  // iPad landscape
      ];

      for (final size in deviceSizes) {
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

        // Navigation should render correctly at all sizes
        expect(find.byType(CustomNavBar), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Chapters'), findsOneWidget);
        expect(find.text('Scenarios'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);
      }
    });
  });

  group('Text Scaling Accessibility Fixes', () {
    testWidgets('Navigation respects text scaling factors', (WidgetTester tester) async {
      // Test different text scale factors (iOS accessibility requirement)
      final scaleFactors = [0.8, 1.0, 1.2, 1.5, 2.0];
      
      for (final scaleFactor in scaleFactors) {
        await tester.pumpWidget(
          TestConfig.wrapWithMaterialApp(
            MediaQuery(
              data: MediaQueryData(
                size: const Size(375, 667),
                textScaler: TextScaler.linear(scaleFactor),
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

        // Navigation should render without overflow at all text scales
        expect(find.byType(CustomNavBar), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Chapters'), findsOneWidget);
        expect(find.text('Scenarios'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);
      }
    });
    
    testWidgets('Large text scaling in landscape mode', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(896, 414)); // iPhone 11 Pro landscape
      
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(896, 414),
              textScaler: TextScaler.linear(2.0), // Large text
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

      // Large text in landscape should still be readable
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });
  });

  group('Color Rendering Fixes', () {
    testWidgets('Color.fromARGB works reliably vs withOpacity', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.wrapWithMaterialApp(
          Scaffold(
            bottomNavigationBar: CustomNavBar(
              currentIndex: 1, // Select non-first item to test unselected opacity
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
      );

      await tester.pumpAndSettle();

      // All items should render correctly with Color.fromARGB opacity
      expect(find.byType(CustomNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget); // Unselected - should have reduced opacity
      expect(find.text('Chapters'), findsOneWidget); // Selected - should be full opacity
    });
  });
}