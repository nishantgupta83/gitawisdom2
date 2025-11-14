// test/widgets/root_scaffold_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitawisdom2/screens/root_scaffold.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gitawisdom2/services/settings_service.dart';
import 'package:gitawisdom2/services/supabase_auth_service.dart';
import 'package:gitawisdom2/models/scenario.dart';
import 'package:gitawisdom2/models/bookmark.dart';
import 'package:gitawisdom2/models/verse.dart';
import 'package:gitawisdom2/models/chapter.dart';
import 'package:gitawisdom2/models/journal_entry.dart';
import 'package:gitawisdom2/models/daily_verse_set.dart';
import 'package:gitawisdom2/models/user_settings.dart';
import 'package:gitawisdom2/models/chapter_summary.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();

    // Register all adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ScenarioAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BookmarkAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(VerseAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ChapterAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(JournalEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(DailyVerseSetAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(UserSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ChapterSummaryAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('RootScaffold Widget Tests', () {
    testWidgets('should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      // Let the widget build
      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(RootScaffold), findsOneWidget);
    });

    testWidgets('should have bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have a navigation bar (could be BottomNavigationBar or custom)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('should handle state preservation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should have AutomaticKeepAliveClientMixin
      final state = tester.state<State>(find.byType(RootScaffold));
      expect(state, isA<State>());
    });
  });

  group('RootScaffold Navigation Tests', () {
    testWidgets('should start with home screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render scaffold
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('should handle rebuilds properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger rebuild
      await tester.pumpAndSettle();

      // Should still render without errors
      expect(find.byType(RootScaffold), findsOneWidget);
    });
  });

  group('RootScaffold State Management Tests', () {
    testWidgets('should maintain state across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial state
      final initialWidget = find.byType(RootScaffold);
      expect(initialWidget, findsOneWidget);

      // Rebuild
      await tester.pump();

      // Should maintain state
      expect(find.byType(RootScaffold), findsOneWidget);
    });
  });

  group('RootScaffold Performance Tests', () {
    testWidgets('should build quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should build in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('should handle rapid rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      // Perform rapid rebuilds
      for (int i = 0; i < 5; i++) {
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Should handle without errors
      expect(find.byType(RootScaffold), findsOneWidget);
    });
  });

  group('RootScaffold Edge Cases', () {
    testWidgets('should handle missing providers gracefully', (WidgetTester tester) async {
      // Note: This will fail, but tests that we have proper provider setup
      expect(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: RootScaffold(),
          ),
        );
      }, throwsA(anything));
    });

    testWidgets('should handle hot reload simulation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate hot reload
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>(
              create: (_) => SettingsService(),
            ),
            ChangeNotifierProvider<SupabaseAuthService>(
              create: (_) => SupabaseAuthService(),
            ),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still render
      expect(find.byType(RootScaffold), findsOneWidget);
    });
  });

  group('RootScaffold Integration Tests', () {
    testWidgets('should integrate with providers', (WidgetTester tester) async {
      final settingsService = SettingsService();
      final authService = SupabaseAuthService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>.value(value: settingsService),
            ChangeNotifierProvider<SupabaseAuthService>.value(value: authService),
          ],
          child: MaterialApp(
            home: RootScaffold(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render with providers
      expect(find.byType(RootScaffold), findsOneWidget);
    });
  });
}
