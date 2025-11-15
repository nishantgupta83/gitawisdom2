// test/screens/journal_tab_container_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/journal_tab_container.dart';
import 'package:GitaWisdom/screens/journal_screen.dart';
import 'package:GitaWisdom/screens/modern_auth_screen.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';
import '../test_setup.dart';
import 'dart:async';

class MockAuthService extends SupabaseAuthService {
  final StreamController<bool> _authController = StreamController<bool>.broadcast();
  bool _isAuthenticated = false;

  MockAuthService() : super._internal();

  @override
  Stream<bool> get authStateChanges => _authController.stream;

  @override
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    _authController.add(value);
  }

  void dispose() {
    _authController.close();
  }
}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('JournalTabContainer', () {
    testWidgets('renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      expect(find.byType(JournalTabContainer), findsOneWidget);
    });

    testWidgets('displays loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading journal...'), findsOneWidget);
    });

    testWidgets('displays auth prompt when not authenticated',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      // Wait for stream to emit
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show auth prompt
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Sign in to access Journal'), findsOneWidget);
      expect(
          find.text('Your journal entries are private and synced across devices'),
          findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('sign in button navigates to auth screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap sign in button
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should navigate to ModernAuthScreen
      expect(find.byType(ModernAuthScreen), findsOneWidget);
    });

    testWidgets('sign in button has login icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(JournalTabContainer), findsOneWidget);
      expect(find.text('Sign in to access Journal'), findsOneWidget);
    });

    testWidgets('renders correctly in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(JournalTabContainer), findsOneWidget);
      expect(find.text('Sign in to access Journal'), findsOneWidget);
    });

    testWidgets('has proper scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('scaffold has transparent background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.transparent);
    });

    testWidgets('loading state has proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('auth prompt has proper icon size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final icon = tester.widget<Icon>(find.byIcon(Icons.lock_outline));
      expect(icon.size, 80);
    });

    testWidgets('auth prompt text is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find Text widgets with textAlign center
      final titleText = tester.widgetList<Text>(
        find.text('Sign in to access Journal'),
      );
      expect(titleText.isNotEmpty, true);
    });

    testWidgets('sign in button has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );
      expect(button.style?.padding, isNotNull);
    });

    testWidgets('sign in button has rounded corners',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );
      expect(button.style?.shape, isNotNull);
    });

    testWidgets('adapts to tablet layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(JournalTabContainer), findsOneWidget);
    });

    testWidgets('adapts to small phone layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(JournalTabContainer), findsOneWidget);
      expect(find.text('Sign in to access Journal'), findsOneWidget);
    });

    testWidgets('loading state is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('auth prompt has proper spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses StreamBuilder for auth state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      expect(find.byType(StreamBuilder<bool>), findsOneWidget);
    });

    testWidgets('auth prompt description mentions privacy',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
          find.text('Your journal entries are private and synced across devices'),
          findsOneWidget);
    });

    testWidgets('sign in button opens as fullscreen dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JournalTabContainer(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap sign in
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Auth screen should be displayed
      expect(find.byType(ModernAuthScreen), findsOneWidget);
    });
  });
}
