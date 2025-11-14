// test/widgets/modern_nav_bar_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/modern_nav_bar.dart';

void main() {
  group('ModernNavBar Widget Tests', () {
    final testItems = [
      ModernNavBarItem(
        icon: Icons.home,
        selectedIcon: Icons.home,
        label: 'Home',
      ),
      ModernNavBarItem(
        icon: Icons.book,
        selectedIcon: Icons.book,
        label: 'Chapters',
      ),
      ModernNavBarItem(
        icon: Icons.psychology,
        selectedIcon: Icons.psychology_outlined,
        label: 'Dilemmas',
      ),
      ModernNavBarItem(
        icon: Icons.more_horiz,
        selectedIcon: Icons.more_horiz,
        label: 'More',
      ),
    ];

    testWidgets('should render all navigation items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Dilemmas'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('should highlight selected item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      // Find Home icon (should be highlighted at index 0)
      final homeIcons = find.byIcon(Icons.home);
      expect(homeIcons, findsWidgets);
    });

    testWidgets('should call onTap with correct index when item is tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {
                  tappedIndex = index;
                },
                items: testItems,
              ),
            ),
          ),
        ),
      );

      // Tap on Chapters
      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(tappedIndex, 1);
    });

    testWidgets('should render with different currentIndex', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 2,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      // Dilemmas tab should be selected (index 2)
      expect(find.text('Dilemmas'), findsOneWidget);
    });

    testWidgets('should render all icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsWidgets);
      expect(find.byIcon(Icons.home), findsWidgets);
      expect(find.byIcon(Icons.book), findsWidgets);
    });

    testWidgets('should handle navigation item taps in sequence', (tester) async {
      final tappedIndices = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {
                  tappedIndices.add(index);
                },
                items: testItems,
              ),
            ),
          ),
        ),
      );

      // Tap multiple items
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(tappedIndices, [0, 1, 3]);
    });

    testWidgets('should render with custom colors', (tester) async {
      final coloredItems = [
        ModernNavBarItem(
          icon: Icons.home,
          label: 'Home',
          color: Colors.red,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: coloredItems,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should render in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(ModernNavBar), findsOneWidget);
    });

    testWidgets('should render in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(ModernNavBar), findsOneWidget);
    });

    testWidgets('should render SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should render with Material widget for ripple effects', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: testItems,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('should update selection when currentIndex changes', (tester) async {
      int currentIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    Expanded(child: Container()),
                    ModernNavBar(
                      currentIndex: currentIndex,
                      onTap: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      items: testItems,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially Home is selected
      expect(currentIndex, 0);

      // Tap Chapters
      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(currentIndex, 1);

      // Tap More
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(currentIndex, 3);
    });

    testWidgets('should handle minimum 2 items', (tester) async {
      final minItems = [
        ModernNavBarItem(
          icon: Icons.home,
          label: 'Home',
        ),
        ModernNavBarItem(
          icon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: minItems,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should handle maximum items without overflow', (tester) async {
      final maxItems = List.generate(
        5,
        (index) => ModernNavBarItem(
          icon: Icons.star,
          label: 'Item $index',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ModernNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: maxItems,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });
  });
}
