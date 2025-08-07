import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oldwisdom/screens/about_screen.dart';
import 'package:oldwisdom/screens/references_screen.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('AboutScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AboutScreen()),
      );

      expect(find.text('About'), findsOneWidget);
      expect(find.textContaining('Gitawisdom'), findsOneWidget);
      expect(find.textContaining('Bhagavad Gita'), findsOneWidget);
    });

    testWidgets('ReferencesScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ReferencesScreen()),
      );

      expect(find.text('References'), findsOneWidget);
      expect(find.textContaining('Bhagavad-gītā As It Is'), findsOneWidget);
    });

    testWidgets('AboutScreen has proper AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AboutScreen()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ReferencesScreen shows multiple references', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ReferencesScreen()),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('Stephen Mitchell'), findsOneWidget);
      expect(find.textContaining('Gandhi'), findsOneWidget);
    });

    testWidgets('AboutScreen shows app description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AboutScreen()),
      );

      expect(find.textContaining('bite-size guide'), findsOneWidget);
      expect(find.textContaining('chapters, scenarios'), findsOneWidget);
    });

    testWidgets('ReferencesScreen has proper structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ReferencesScreen()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.textContaining('Prabhupāda'), findsOneWidget);
    });
  });
}
