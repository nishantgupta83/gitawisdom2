// test/journal_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/models/journal_entry.dart';
import 'package:GitaWisdom/services/journal_service.dart';

import 'test_helpers.dart';

void main() {
  group('Journal Feature Tests', () {
    setUpAll(() async {
      await commonTestSetup();
    });

    tearDownAll(() async {
      await commonTestCleanup();
    });

    group('JournalEntry Model Tests', () {
      test('JournalEntry.create factory creates valid entry', () {
        final entry = JournalEntry.create(
          reflection: 'Test reflection on dharma',
          rating: 4,
          category: 'Dharma Insights',
          scenarioId: 123,
        );

        expect(entry.reflection, equals('Test reflection on dharma'));
        expect(entry.rating, equals(4));
        expect(entry.category, equals('Dharma Insights'));
        expect(entry.scenarioId, equals(123));
        expect(entry.id, isNotNull);
        expect(entry.dateCreated, isNotNull);
      });

      test('JournalEntry.fromJson creates valid entry from Supabase data', () {
        final json = {
          'je_id': 'test-123',
          'je_reflection': 'Learning about detachment',
          'je_rating': 5,
          'je_date_created': '2024-01-15T10:30:00.000Z',
          'je_category': 'Detachment Practice',
          'je_scenario_id': 456,
        };

        final entry = JournalEntry.fromJson(json);

        expect(entry.id, equals('test-123'));
        expect(entry.reflection, equals('Learning about detachment'));
        expect(entry.rating, equals(5));
        expect(entry.category, equals('Detachment Practice'));
        expect(entry.scenarioId, equals(456));
      });

      test('JournalEntry.fromJson handles missing optional fields', () {
        final json = {
          'je_id': 'test-456',
          'je_reflection': 'Basic reflection',
          'je_rating': 3,
          'je_date_created': '2024-01-15T10:30:00.000Z',
        };

        final entry = JournalEntry.fromJson(json);

        expect(entry.category, equals('General')); // Default category
        expect(entry.scenarioId, isNull); // Optional field
      });

      test('JournalEntry.toJson creates valid Supabase data', () {
        final entry = JournalEntry.create(
          reflection: 'Test wisdom application',
          rating: 4,
          category: 'Scenario Wisdom',
          scenarioId: 789,
        );

        final json = entry.toJson();

        expect(json['je_reflection'], equals('Test wisdom application'));
        expect(json['je_rating'], equals(4));
        expect(json['je_category'], equals('Scenario Wisdom'));
        expect(json['je_scenario_id'], equals(789));
        expect(json['je_id'], isNotNull);
        expect(json['je_date_created'], isNotNull);
      });
    });

    group('JournalService Tests', () {
      late JournalService journalService;

      setUp(() async {
        journalService = JournalService.instance;
        await journalService.initialize();
        
        // Clear any existing entries
        final box = Hive.box<JournalEntry>('journal_entries');
        await box.clear();
      });

      test('createEntry stores journal entry locally', () async {
        final entry = createTestJournalEntry(
          id: 'test-local-123',
          reflection: 'Today I practiced detachment from results',
          rating: 4,
          category: 'Detachment Practice',
        );

        await journalService.createEntry(entry);

        final entries = await journalService.fetchEntries();
        expect(entries.length, equals(1));
        expect(entries.first.id, equals('test-local-123'));
        expect(entries.first.category, equals('Detachment Practice'));
      });

      test('fetchEntries returns sorted entries (newest first)', () async {
        final entry1 = createTestJournalEntry(
          id: 'entry-1',
          reflection: 'First reflection',
        );
        final entry2 = JournalEntry(
          id: 'entry-2',
          reflection: 'Second reflection',
          rating: 5,
          dateCreated: DateTime(2024, 1, 16, 10, 30), // Later date
          category: 'General',
        );

        await journalService.createEntry(entry1);
        await journalService.createEntry(entry2);

        final entries = await journalService.fetchEntries();
        expect(entries.length, equals(2));
        expect(entries.first.id, equals('entry-2')); // Newest first
        expect(entries.last.id, equals('entry-1'));
      });

      test('searchEntries filters by reflection content', () async {
        await journalService.createEntry(createTestJournalEntry(
          id: 'entry-1',
          reflection: 'Learning about dharma and righteousness',
        ));
        await journalService.createEntry(createTestJournalEntry(
          id: 'entry-2', 
          reflection: 'Understanding karma and action',
        ));

        final dharmaResults = journalService.searchEntries('dharma');
        expect(dharmaResults.length, equals(1));
        expect(dharmaResults.first.id, equals('entry-1'));

        final karmaResults = journalService.searchEntries('karma');
        expect(karmaResults.length, equals(1));
        expect(karmaResults.first.id, equals('entry-2'));

        final allResults = journalService.searchEntries('');
        expect(allResults.length, equals(2));
      });

      test('averageRating calculates correctly', () async {
        await journalService.createEntry(createTestJournalEntry(rating: 3));
        await journalService.createEntry(createTestJournalEntry(rating: 4));
        await journalService.createEntry(createTestJournalEntry(rating: 5));

        expect(journalService.averageRating, equals(4.0));
      });

      test('averageRating returns 0 for no entries', () async {
        expect(journalService.averageRating, equals(0.0));
      });

      test('totalEntries returns correct count', () async {
        expect(journalService.totalEntries, equals(0));

        await journalService.createEntry(createTestJournalEntry());
        await journalService.createEntry(createTestJournalEntry(id: 'entry-2'));

        expect(journalService.totalEntries, equals(2));
      });
    });

    group('Journal Integration with Scenarios', () {
      test('journal entry can be linked to scenario', () async {
        final entry = createTestJournalEntry(
          scenarioId: 123,
          category: 'Scenario Wisdom',
          reflection: 'This scenario taught me about balancing heart and duty',
        );

        expect(entry.scenarioId, equals(123));
        expect(entry.category, equals('Scenario Wisdom'));
      });

      test('multiple entries can reference same scenario', () async {
        final journalService = JournalService.instance;
        await journalService.initialize();

        final entry1 = createTestJournalEntry(
          id: 'scenario-ref-1',
          scenarioId: 456,
          reflection: 'First reflection on this scenario',
        );
        final entry2 = createTestJournalEntry(
          id: 'scenario-ref-2',
          scenarioId: 456,
          reflection: 'Follow-up thoughts on the same scenario',
        );

        await journalService.createEntry(entry1);
        await journalService.createEntry(entry2);

        final allEntries = await journalService.fetchEntries();
        final scenarioEntries = allEntries.where((e) => e.scenarioId == 456).toList();
        
        expect(scenarioEntries.length, equals(2));
      });
    });

    group('Journal Categories', () {
      final gitaCategories = [
        'Dharma Insights',
        'Karma Reflections', 
        'Meditation Experiences',
        'Detachment Practice',
        'Scenario Wisdom',
        'Chapter Insights',
      ];

      for (final category in gitaCategories) {
        test('can create journal entry with $category category', () {
          final entry = createTestJournalEntry(category: category);
          expect(entry.category, equals(category));
        });
      }

      test('journal entries can be filtered by category', () async {
        final journalService = JournalService.instance;
        await journalService.initialize();

        await journalService.createEntry(createTestJournalEntry(
          id: 'dharma-1',
          category: 'Dharma Insights',
          reflection: 'Dharma reflection',
        ));
        await journalService.createEntry(createTestJournalEntry(
          id: 'karma-1', 
          category: 'Karma Reflections',
          reflection: 'Karma reflection',
        ));

        final allEntries = await journalService.fetchEntries();
        final dharmaEntries = allEntries.where((e) => e.category == 'Dharma Insights').toList();
        final karmaEntries = allEntries.where((e) => e.category == 'Karma Reflections').toList();

        expect(dharmaEntries.length, equals(1));
        expect(karmaEntries.length, equals(1));
        expect(dharmaEntries.first.reflection, contains('Dharma'));
        expect(karmaEntries.first.reflection, contains('Karma'));
      });
    });
  });
}