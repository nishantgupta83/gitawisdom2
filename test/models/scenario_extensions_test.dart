import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/scenario.dart';

void main() {
  group('ScenarioMultilingualExtensions', () {
    final now = DateTime.now();

    test('fromMultilingualJson should create Scenario from JSON', () {
      final json = {
        'sc_title': 'Test Scenario',
        'sc_description': 'Test description',
        'sc_category': 'work',
        'sc_chapter': 3,
        'sc_heart_response': 'Heart says...',
        'sc_duty_response': 'Duty says...',
        'sc_gita_wisdom': 'Wisdom teaches...',
        'sc_verse': 'Verse text',
        'sc_verse_number': '3.5',
        'sc_tags': ['tag1', 'tag2'],
        'sc_action_steps': ['step1', 'step2'],
        'created_at': now.toIso8601String(),
      };

      final scenario = ScenarioMultilingualExtensions.fromMultilingualJson(json);

      expect(scenario.title, equals('Test Scenario'));
      expect(scenario.description, equals('Test description'));
      expect(scenario.category, equals('work'));
      expect(scenario.chapter, equals(3));
      expect(scenario.heartResponse, equals('Heart says...'));
      expect(scenario.dutyResponse, equals('Duty says...'));
      expect(scenario.gitaWisdom, equals('Wisdom teaches...'));
      expect(scenario.verse, equals('Verse text'));
      expect(scenario.verseNumber, equals('3.5'));
      expect(scenario.tags, equals(['tag1', 'tag2']));
      expect(scenario.actionSteps, equals(['step1', 'step2']));
    });

    test('toTranslationJson should convert to translation format', () {
      final scenario = Scenario(
        title: 'Test',
        description: 'Desc',
        category: 'personal',
        chapter: 2,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        verse: 'Verse',
        verseNumber: '2.10',
        tags: ['test'],
        actionSteps: ['action1'],
        createdAt: now,
      );

      final json = scenario.toTranslationJson('es', 42);

      expect(json['scenario_id'], equals(42));
      expect(json['lang_code'], equals('es'));
      expect(json['title'], equals('Test'));
      expect(json['description'], equals('Desc'));
      expect(json['category'], equals('personal'));
      expect(json['heart_response'], equals('Heart'));
      expect(json['duty_response'], equals('Duty'));
      expect(json['gita_wisdom'], equals('Wisdom'));
      expect(json['verse'], equals('Verse'));
      expect(json['verse_number'], equals('2.10'));
      expect(json['tags'], equals(['test']));
      expect(json['action_steps'], equals(['action1']));
    });

    test('fromTranslationJson should create Scenario from translation table', () {
      final json = {
        'title': 'Translated Title',
        'description': 'Translated Desc',
        'category': 'family',
        'heart_response': 'Corazón dice',
        'duty_response': 'Deber dice',
        'gita_wisdom': 'Sabiduría',
        'verse': 'Verso',
        'verse_number': '5.10',
        'tags': ['spanish'],
        'action_steps': ['paso1'],
      };

      final scenario = ScenarioMultilingualExtensions.fromTranslationJson(
        json,
        7,
        now,
      );

      expect(scenario.title, equals('Translated Title'));
      expect(scenario.description, equals('Translated Desc'));
      expect(scenario.category, equals('family'));
      expect(scenario.chapter, equals(7));
      expect(scenario.heartResponse, equals('Corazón dice'));
      expect(scenario.dutyResponse, equals('Deber dice'));
      expect(scenario.gitaWisdom, equals('Sabiduría'));
      expect(scenario.createdAt, equals(now));
    });

    test('hasTranslationData should validate required fields', () {
      final complete = Scenario(
        title: 'Title',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        createdAt: now,
      );

      final incomplete = Scenario(
        title: '',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        createdAt: now,
      );

      expect(complete.hasTranslationData, isTrue);
      expect(incomplete.hasTranslationData, isFalse);
    });

    test('withTranslation should update specified fields', () {
      final original = Scenario(
        title: 'Original',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        createdAt: now,
      );

      final updated = original.withTranslation(
        title: 'Updated Title',
        description: 'Updated Desc',
      );

      expect(updated.title, equals('Updated Title'));
      expect(updated.description, equals('Updated Desc'));
      expect(updated.category, equals('work'));
      expect(updated.chapter, equals(1));
      expect(updated.heartResponse, equals('Heart'));
    });

    test('withTranslation should preserve unspecified fields', () {
      final original = Scenario(
        title: 'Original',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        verse: 'Verse',
        verseNumber: '1.1',
        tags: ['tag1'],
        actionSteps: ['step1'],
        createdAt: now,
      );

      final updated = original.withTranslation(title: 'New Title');

      expect(updated.description, equals('Desc'));
      expect(updated.verse, equals('Verse'));
      expect(updated.tags, equals(['tag1']));
      expect(updated.actionSteps, equals(['step1']));
    });

    test('translationCompleteness should report field status', () {
      final scenario = Scenario(
        title: 'Title',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        verse: '',
        verseNumber: '1.1',
        tags: null,
        actionSteps: ['step'],
        createdAt: now,
      );

      final completeness = scenario.translationCompleteness;

      expect(completeness['title'], isTrue);
      expect(completeness['description'], isTrue);
      expect(completeness['verse'], isFalse);
      expect(completeness['tags'], isFalse);
      expect(completeness['action_steps'], isTrue);
    });

    test('translationCompletionPercentage should calculate correctly', () {
      final fullyComplete = Scenario(
        title: 'Title',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        verse: 'Verse',
        verseNumber: '1.1',
        tags: ['tag'],
        actionSteps: ['step'],
        createdAt: now,
      );

      final halfComplete = Scenario(
        title: 'Title',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: '',
        gitaWisdom: '',
        verse: '',
        verseNumber: '',
        tags: null,
        actionSteps: null,
        createdAt: now,
      );

      expect(fullyComplete.translationCompletionPercentage, equals(100.0));
      expect(halfComplete.translationCompletionPercentage, greaterThan(0.0));
      expect(halfComplete.translationCompletionPercentage, lessThan(100.0));
    });

    test('translationCompleteness should have all required fields', () {
      final scenario = Scenario(
        title: 'Title',
        description: 'Desc',
        category: 'work',
        chapter: 1,
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        createdAt: now,
      );

      final completeness = scenario.translationCompleteness;

      expect(completeness.keys, containsAll([
        'title',
        'description',
        'category',
        'heart_response',
        'duty_response',
        'gita_wisdom',
        'verse',
        'verse_number',
        'tags',
        'action_steps',
      ]));
    });
  });
}
