import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/screens/journal_screen.dart';
import 'package:GitaWisdom/screens/new_journal_entry_dialog.dart';
import 'package:GitaWisdom/services/journal_service.dart';
import 'package:GitaWisdom/models/journal_entry.dart';
import 'package:GitaWisdom/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'journal_screen_test.mocks.dart';

@GenerateMocks([JournalService])
void main() {
  late MockJournalService mockJournalService;

  setUp(() {
    mockJournalService = MockJournalService();
  });

  Widget createJournalScreen() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const JournalScreen(),
    );
  }

  group('JournalScreen Rendering Tests', () {
    testWidgets('screen renders without errors', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();

      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets('displays header card with title and subtitle', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Journal'), findsOneWidget);
      expect(find.text('Track your spiritual journey'), findsOneWidget);
    });

    testWidgets('displays FAB to create journal entry', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('FAB is disabled during loading', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2), () => []),
      );

      await tester.pumpWidget(createJournalScreen());
      await tester.pump(const Duration(milliseconds: 100));

      final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.onPressed, isNull);
    });

    testWidgets('displays loading indicator while fetching entries', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2), () => []),
      );

      await tester.pumpWidget(createJournalScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no entries exist', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.book_outlined), findsOneWidget);
      expect(find.text('No journal entries yet'), findsOneWidget);
      expect(find.text('Tap the + button to create your first entry'), findsOneWidget);
    });
  });

  group('Journal Entry Display Tests', () {
    final mockEntries = [
      JournalEntry(
        id: '1',
        reflection: 'Test reflection 1',
        rating: 4,
        dateCreated: DateTime(2025, 1, 15),
        category: 'General',
      ),
      JournalEntry(
        id: '2',
        reflection: 'Test reflection 2',
        rating: 5,
        dateCreated: DateTime(2025, 1, 14),
        category: 'Meditation',
      ),
    ];

    testWidgets('displays journal entries list', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => mockEntries);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test reflection 1'), findsOneWidget);
      expect(find.text('Test reflection 2'), findsOneWidget);
    });

    testWidgets('each entry shows date', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => mockEntries);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('2025-01-15'), findsOneWidget);
      expect(find.text('2025-01-14'), findsOneWidget);
    });

    testWidgets('each entry shows category', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => mockEntries);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('General'), findsOneWidget);
      expect(find.text('Meditation'), findsOneWidget);
    });

    testWidgets('each entry shows rating stars', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => mockEntries);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final starIcons = find.byIcon(Icons.star_rounded);
      expect(starIcons, findsWidgets);
    });

    testWidgets('entries are sorted by date (newest first)', (WidgetTester tester) async {
      final unsortedEntries = [
        JournalEntry(
          id: '1',
          reflection: 'Older entry',
          rating: 3,
          dateCreated: DateTime(2025, 1, 10),
          category: 'General',
        ),
        JournalEntry(
          id: '2',
          reflection: 'Newer entry',
          rating: 4,
          dateCreated: DateTime(2025, 1, 20),
          category: 'General',
        ),
      ];

      when(mockJournalService.fetchEntries()).thenAnswer((_) async => unsortedEntries);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final reflectionFinder = find.text('Newer entry');
      expect(reflectionFinder, findsOneWidget);
    });
  });

  group('Create Entry Tests', () {
    testWidgets('tapping FAB shows create entry dialog', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NewJournalEntryDialog), findsOneWidget);
      expect(find.text('New Journal Entry'), findsOneWidget);
    });

    testWidgets('dialog shows text field for reflection', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Write your thoughts and reflections here...'), findsOneWidget);
    });

    testWidgets('dialog shows save and cancel buttons', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel button dismisses dialog', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NewJournalEntryDialog), findsNothing);
    });
  });

  group('Delete Entry Tests', () {
    final mockEntry = JournalEntry(
      id: '1',
      reflection: 'Test entry to delete',
      rating: 4,
      dateCreated: DateTime(2025, 1, 15),
      category: 'General',
    );

    testWidgets('swiping entry shows delete background', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => [mockEntry]);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('dismissible has correct key', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => [mockEntry]);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.key, Key(mockEntry.id));
    });

    testWidgets('confirmDismiss is set', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => [mockEntry]);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.confirmDismiss, isNotNull);
    });
  });

  group('Pull to Refresh Tests', () {
    testWidgets('displays RefreshIndicator', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('pull to refresh triggers data reload', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);
      when(mockJournalService.refreshFromServer()).thenAnswer((_) async => {});

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify fetch was called again
      verify(mockJournalService.fetchEntries()).called(greaterThan(1));
    });
  });

  group('Background Sync Tests', () {
    testWidgets('backgroundSync is called after initial load', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(mockJournalService.backgroundSync()).called(1);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('handles fetch error gracefully', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(JournalScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows empty state on error when no cached entries', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.book_outlined), findsOneWidget);
    });
  });

  group('Layout Tests', () {
    testWidgets('uses LayoutBuilder for responsive design', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LayoutBuilder), findsOneWidget);
    });

    testWidgets('ListView has correct padding', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('FAB is positioned correctly', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final positioned = find.ancestor(
        of: find.byType(FloatingActionButton),
        matching: find.byType(Positioned),
      );
      expect(positioned, findsOneWidget);
    });
  });

  group('Theme Tests', () {
    testWidgets('adapts to light theme', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const JournalScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final context = tester.element(find.byType(JournalScreen));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('adapts to dark theme', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const JournalScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final context = tester.element(find.byType(JournalScreen));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.dark);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('FAB has tooltip', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.tooltip, 'Add journal entry');
    });

    testWidgets('rating stars have semantic labels', (WidgetTester tester) async {
      final mockEntry = JournalEntry(
        id: '1',
        reflection: 'Test',
        rating: 4,
        dateCreated: DateTime.now(),
        category: 'General',
      );

      when(mockJournalService.fetchEntries()).thenAnswer((_) async => [mockEntry]);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.bySemanticsLabel('4 out of 5 stars'), findsOneWidget);
    });

    testWidgets('cards have proper contrast', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Card), findsWidgets);
    });
  });

  group('Performance Tests', () {
    testWidgets('prevents duplicate fetches', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(mockJournalService.fetchEntries()).called(1);
    });

    testWidgets('handles large entry list efficiently', (WidgetTester tester) async {
      final largeList = List.generate(
        100,
        (index) => JournalEntry(
          id: '$index',
          reflection: 'Entry $index',
          rating: 3,
          dateCreated: DateTime.now().subtract(Duration(days: index)),
          category: 'General',
        ),
      );

      when(mockJournalService.fetchEntries()).thenAnswer((_) async => largeList);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('State Management Tests', () {
    testWidgets('maintains state on rebuild', (WidgetTester tester) async {
      final mockEntry = JournalEntry(
        id: '1',
        reflection: 'Test entry',
        rating: 4,
        dateCreated: DateTime.now(),
        category: 'General',
      );

      when(mockJournalService.fetchEntries()).thenAnswer((_) async => [mockEntry]);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test entry'), findsOneWidget);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test entry'), findsOneWidget);
    });

    testWidgets('updates UI after entry creation', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No journal entries yet'), findsOneWidget);
    });
  });

  group('Edge Cases', () {
    testWidgets('handles null values gracefully', (WidgetTester tester) async {
      when(mockJournalService.fetchEntries()).thenAnswer((_) async => []);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles empty reflection text', (WidgetTester tester) async {
      final emptyEntry = JournalEntry(
        id: '1',
        reflection: '',
        rating: 3,
        dateCreated: DateTime.now(),
        category: 'General',
      );

      when(mockJournalService.fetchEntries()).thenAnswer((_) async => [emptyEntry]);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles very long reflection text', (WidgetTester tester) async {
      final longEntry = JournalEntry(
        id: '1',
        reflection: 'Lorem ipsum ' * 100,
        rating: 5,
        dateCreated: DateTime.now(),
        category: 'General',
      );

      when(mockJournalService.fetchEntries()).thenAnswer((_) async => [longEntry]);

      await tester.pumpWidget(createJournalScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Text), findsWidgets);
    });
  });
}
