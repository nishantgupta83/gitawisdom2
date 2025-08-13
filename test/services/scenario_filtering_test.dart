// test/services/scenario_filtering_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:GitaWisdom/services/scenario_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_helpers.dart';
import '../test_config.dart';

void main() {
  setUpAll(() async {
    await commonTestSetup();
  });

  tearDownAll(() async {
    await commonTestCleanup();
  });

  group('Advanced Scenario Filtering Tests', () {
    late ScenarioService service;
    late Box<Scenario> scenarioBox;

    setUp(() async {
      service = ScenarioService.instance;
      scenarioBox = await Hive.openBox<Scenario>('scenarios');
      await scenarioBox.clear();
      await service.initialize();
    });

    group('Compound Search Queries', () {
      test('should handle compound search terms correctly', () async {
        // Add test scenarios with different topics
        final parentingScenario = Scenario(
          title: 'Managing Parenting Stress',
          description: 'Dealing with overwhelming stress while raising children',
          category: 'parenting',
          chapter: 3,
          heartResponse: 'Take a break when needed',
          dutyResponse: 'Stay committed to your parenting duties',
          gitaWisdom: 'Act with patience and detachment',
          tags: ['parenting', 'stress', 'children'],
          createdAt: DateTime.now(),
        );

        final workStressScenario = Scenario(
          title: 'Workplace Stress Management',
          description: 'Handling pressure and stress at work',
          category: 'career',
          chapter: 2,
          heartResponse: 'Consider changing jobs',
          dutyResponse: 'Fulfill work responsibilities',
          gitaWisdom: 'Perform duty without attachment',
          tags: ['work', 'stress', 'career'],
          createdAt: DateTime.now(),
        );

        final workLifeScenario = Scenario(
          title: 'Work Life Balance',
          description: 'Balancing professional life and personal time',
          category: 'lifestyle',
          chapter: 4,
          heartResponse: 'Prioritize personal happiness',
          dutyResponse: 'Balance work and personal duties',
          gitaWisdom: 'Find harmony in all aspects of life',
          tags: ['work', 'life', 'balance', 'professional'],
          createdAt: DateTime.now(),
        );

        await scenarioBox.put('parenting_stress', parentingScenario);
        await scenarioBox.put('work_stress', workStressScenario);
        await scenarioBox.put('work_life', workLifeScenario);
        await service.initialize();

        // Test compound searches
        final parentingStressResults = service.searchScenarios('parenting stress');
        expect(parentingStressResults.length, equals(1));
        expect(parentingStressResults.first.title, contains('Parenting'));

        final workLifeResults = service.searchScenarios('work life balance');
        expect(workLifeResults.length, equals(1));
        expect(workLifeResults.first.title, contains('Work Life Balance'));

        final workStressResults = service.searchScenarios('work stress');
        expect(workStressResults.length, equals(1));
        expect(workStressResults.first.title, contains('Workplace'));
      });

      test('should search across multiple fields for compound terms', () async {
        final complexScenario = Scenario(
          title: 'Career Change Decision',
          description: 'Considering leaving current job for better work environment',
          category: 'professional',
          chapter: 5,
          heartResponse: 'Follow your passion and seek happiness',
          dutyResponse: 'Consider family responsibilities before making changes',
          gitaWisdom: 'Act with wisdom and detachment from outcomes',
          tags: ['career', 'change', 'decision', 'workplace'],
          actionSteps: ['Evaluate current situation', 'Research new opportunities'],
          createdAt: DateTime.now(),
        );

        await scenarioBox.put('complex', complexScenario);
        await service.initialize();

        // Should find scenario when searching for terms across different fields
        final careerPassionResults = service.searchScenarios('career passion');
        expect(careerPassionResults.length, equals(1));

        final workEnvironmentResults = service.searchScenarios('work environment');
        expect(workEnvironmentResults.length, equals(1));

        final familyResponsibilityResults = service.searchScenarios('family responsibilities');
        expect(familyResponsibilityResults.length, equals(1));

        final wisdomDetachmentResults = service.searchScenarios('wisdom detachment');
        expect(wisdomDetachmentResults.length, equals(1));
      });
    });

    group('Category-Based Filtering', () {
      test('should filter scenarios by multiple category types', () async {
        // Create scenarios with different categories
        final scenarios = [
          Scenario(
            title: 'New Parent Challenges',
            description: 'First time parenting difficulties',
            category: 'parenting',
            chapter: 1,
            heartResponse: 'Seek help when overwhelmed',
            dutyResponse: 'Care for your child with dedication',
            gitaWisdom: 'Perform parental duties with love',
            tags: ['parenting', 'newborn', 'challenges'],
            createdAt: DateTime.now(),
          ),
          Scenario(
            title: 'Marriage Communication',
            description: 'Improving communication with spouse',
            category: 'relationships',
            chapter: 2,
            heartResponse: 'Express feelings openly',
            dutyResponse: 'Maintain harmony in marriage',
            gitaWisdom: 'Communicate with compassion',
            tags: ['marriage', 'communication', 'relationships'],
            createdAt: DateTime.now(),
          ),
          Scenario(
            title: 'Job Interview Anxiety',
            description: 'Managing nervousness during interviews',
            category: 'career',
            chapter: 3,
            heartResponse: 'Trust in your abilities',
            dutyResponse: 'Prepare thoroughly for interviews',
            gitaWisdom: 'Act without attachment to results',
            tags: ['career', 'anxiety', 'interviews'],
            createdAt: DateTime.now(),
          ),
          Scenario(
            title: 'Social Media Pressure',
            description: 'Dealing with comparison on social platforms',
            category: 'modern life',
            chapter: 4,
            heartResponse: 'Limit social media use',
            dutyResponse: 'Use technology mindfully',
            gitaWisdom: 'Find contentment within yourself',
            tags: ['social media', 'pressure', 'comparison'],
            createdAt: DateTime.now(),
          ),
        ];

        for (int i = 0; i < scenarios.length; i++) {
          await scenarioBox.put('scenario_$i', scenarios[i]);
        }
        await service.initialize();

        // Test category-specific searches
        final parentingResults = service.searchScenarios('parenting');
        expect(parentingResults.any((s) => s.category == 'parenting'), isTrue);

        final relationshipResults = service.searchScenarios('relationships');
        expect(relationshipResults.any((s) => s.category == 'relationships'), isTrue);

        final careerResults = service.searchScenarios('career');
        expect(careerResults.any((s) => s.category == 'career'), isTrue);

        final modernLifeResults = service.searchScenarios('social media');
        expect(modernLifeResults.any((s) => s.category == 'modern life'), isTrue);
      });
    });

    group('Tag-Based Advanced Filtering', () {
      test('should handle complex tag combinations', () async {
        final scenarioWithManyTags = Scenario(
          title: 'Complex Life Situation',
          description: 'Multiple challenges in various life areas',
          category: 'personal',
          chapter: 6,
          heartResponse: 'Take things one step at a time',
          dutyResponse: 'Address each responsibility systematically',
          gitaWisdom: 'Maintain equanimity in all situations',
          tags: [
            'stress', 'family', 'work', 'health', 'financial',
            'relationships', 'personal growth', 'spirituality'
          ],
          createdAt: DateTime.now(),
        );

        await scenarioBox.put('complex_life', scenarioWithManyTags);
        await service.initialize();

        // Should find scenario for any of its tags
        final stressResults = service.searchScenarios('stress');
        expect(stressResults.length, equals(1));

        final familyResults = service.searchScenarios('family');
        expect(familyResults.length, equals(1));

        final spiritualityResults = service.searchScenarios('spirituality');
        expect(spiritualityResults.length, equals(1));

        // Should find scenario for compound tag searches
        final familyWorkResults = service.searchScenarios('family work');
        expect(familyWorkResults.length, equals(1));

        final healthFinancialResults = service.searchScenarios('health financial');
        expect(healthFinancialResults.length, equals(1));
      });

      test('should handle scenarios with null or empty tags', () async {
        final scenarioNullTags = Scenario(
          title: 'Simple Scenario',
          description: 'Basic scenario without tags',
          category: 'general',
          chapter: 1,
          heartResponse: 'Follow intuition',
          dutyResponse: 'Do what is right',
          gitaWisdom: 'Act with purpose',
          tags: null,
          createdAt: DateTime.now(),
        );

        final scenarioEmptyTags = Scenario(
          title: 'Another Simple Scenario',
          description: 'Scenario with empty tag list',
          category: 'general',
          chapter: 2,
          heartResponse: 'Trust yourself',
          dutyResponse: 'Be responsible',
          gitaWisdom: 'Stay focused',
          tags: [],
          createdAt: DateTime.now(),
        );

        await scenarioBox.put('null_tags', scenarioNullTags);
        await scenarioBox.put('empty_tags', scenarioEmptyTags);
        await service.initialize();

        // Should still find scenarios by other fields
        final simpleResults = service.searchScenarios('Simple');
        expect(simpleResults.length, equals(2));

        final intuitionResults = service.searchScenarios('intuition');
        expect(intuitionResults.length, equals(1));

        final responsibleResults = service.searchScenarios('responsible');
        expect(responsibleResults.length, equals(1));
      });
    });

    group('Search Performance and Edge Cases', () {
      test('should handle empty and whitespace searches', () async {
        await scenarioBox.put('test', TestData.sampleScenario);
        await service.initialize();

        final emptyResults = service.searchScenarios('');
        final spaceResults = service.searchScenarios('   ');
        final tabResults = service.searchScenarios('\t');

        final allScenarios = await service.getAllScenarios();

        expect(emptyResults.length, equals(allScenarios.length));
        expect(spaceResults.length, equals(allScenarios.length));
        expect(tabResults.length, equals(allScenarios.length));
      });

      test('should handle special characters in search', () async {
        final scenarioWithSpecialChars = Scenario(
          title: 'Decision-Making & Problem-Solving',
          description: 'How to make difficult choices (with confidence)',
          category: 'personal',
          chapter: 7,
          heartResponse: 'Trust your gut feelings',
          dutyResponse: 'Analyze pros & cons carefully',
          gitaWisdom: 'Act with wisdom and clarity',
          tags: ['decision-making', 'problem-solving', 'choices'],
          createdAt: DateTime.now(),
        );

        await scenarioBox.put('special_chars', scenarioWithSpecialChars);
        await service.initialize();

        // Should handle searches with special characters
        final hyphenResults = service.searchScenarios('decision-making');
        expect(hyphenResults.length, equals(1));

        final ampersandResults = service.searchScenarios('pros & cons');
        expect(ampersandResults.length, equals(1));

        final parenthesesResults = service.searchScenarios('confidence');
        expect(parenthesesResults.length, equals(1));
      });

      test('should maintain search consistency with large datasets', () async {
        // Create a larger dataset for performance testing
        final scenarios = <Scenario>[];
        for (int i = 0; i < 50; i++) {
          scenarios.add(Scenario(
            title: 'Test Scenario $i',
            description: 'Description for scenario number $i',
            category: 'test',
            chapter: (i % 18) + 1,
            heartResponse: 'Heart response $i',
            dutyResponse: 'Duty response $i',
            gitaWisdom: 'Wisdom for scenario $i',
            tags: ['test', 'scenario', 'number$i'],
            createdAt: DateTime.now(),
          ));
        }

        for (int i = 0; i < scenarios.length; i++) {
          await scenarioBox.put('test_$i', scenarios[i]);
        }
        await service.initialize();

        // Test search consistency
        final testResults = service.searchScenarios('test');
        expect(testResults.length, equals(50));

        final scenarioResults = service.searchScenarios('scenario');
        expect(scenarioResults.length, equals(50));

        final numberResults = service.searchScenarios('number');
        expect(numberResults.length, equals(50));

        // Test specific number searches
        final number5Results = service.searchScenarios('number5');
        expect(number5Results.length, equals(1));
        expect(number5Results.first.title, contains('5'));
      });
    });
  });
}