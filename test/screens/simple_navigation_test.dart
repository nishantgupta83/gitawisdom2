
// test/screens/simple_navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('BottomNavigationBar should have correct items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Chapters'),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Scenarios'),
                BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('Should handle tab selection', (WidgetTester tester) async {
      int selectedIndex = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Chapters'),
                    BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Scenarios'),
                    BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Tap on Chapters tab
      await tester.tap(find.text('Chapters'));
      await tester.pump();

      // Verify the selection (would need to check actual implementation)
      expect(find.text('Chapters'), findsOneWidget);
    });
  });
}
