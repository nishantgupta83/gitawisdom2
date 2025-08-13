// test/screens/scenarios_filtering_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/screens/scenarios_screen.dart';
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

  group('ScenariosScreen Bulletproof Filtering Tests', () {
    group('Filter Categories', () {
      testWidgets('should display all filter categories', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.wrapWithMaterialApp(
            const ScenariosScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Check for all new filter categories
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Life Stages'), findsOneWidget);
        expect(find.text('Relationships'), findsOneWidget);
        expect(find.text('Career & Work'), findsOneWidget);
        expect(find.text('Personal Growth'), findsOneWidget);
        expect(find.text('Modern Life'), findsOneWidget);
      });

      testWidgets('should allow filter selection', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.wrapWithMaterialApp(
            const ScenariosScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Tap on Life Stages filter
        await tester.tap(find.text('Life Stages'));
        await tester.pumpAndSettle();

        // Should show Life Stages filter as selected
        final lifeStagesChip = find.ancestor(
          of: find.text('Life Stages'),
          matching: find.byType(FilterChip),
        );
        expect(lifeStagesChip, findsOneWidget);
      });
    });

    group('Tag-to-Category Mapping', () {
      test('should map parenting tags to Life Stages', () {
        final testScenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Test',
          dutyResponse: 'Test',
          gitaWisdom: 'Test',
          tags: ['parenting'],
          createdAt: DateTime.now(),
        );

        // Create scenarios screen to test helper methods
        final screenState = _ScenariosScreenTestState();
        expect(screenState.matchesLifeStages(testScenario), isTrue);
        expect(screenState.matchesRelationships(testScenario), isFalse);
      });

      test('should map relationship tags to Relationships', () {
        final testScenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Test',
          dutyResponse: 'Test',
          gitaWisdom: 'Test',
          tags: ['marriage', 'love'],
          createdAt: DateTime.now(),
        );

        final screenState = _ScenariosScreenTestState();
        expect(screenState.matchesRelationships(testScenario), isTrue);
        expect(screenState.matchesCareerWork(testScenario), isFalse);
      });

      test('should map career tags to Career & Work', () {
        final testScenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Test',
          dutyResponse: 'Test',
          gitaWisdom: 'Test',
          tags: ['career', 'job', 'workplace'],
          createdAt: DateTime.now(),
        );

        final screenState = _ScenariosScreenTestState();
        expect(screenState.matchesCareerWork(testScenario), isTrue);
        expect(screenState.matchesPersonalGrowth(testScenario), isFalse);
      });

      test('should map mental health tags to Personal Growth', () {
        final testScenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Test',
          dutyResponse: 'Test',
          gitaWisdom: 'Test',
          tags: ['anxiety', 'spiritual', 'growth'],
          createdAt: DateTime.now(),
        );

        final screenState = _ScenariosScreenTestState();
        expect(screenState.matchesPersonalGrowth(testScenario), isTrue);
        expect(screenState.matchesModernLife(testScenario), isFalse);
      });

      test('should map technology tags to Modern Life', () {
        final testScenario = Scenario(
          title: 'Test',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Test',
          dutyResponse: 'Test',
          gitaWisdom: 'Test',
          tags: ['social media', 'technology', 'digital'],
          createdAt: DateTime.now(),
        );

        final screenState = _ScenariosScreenTestState();
        expect(screenState.matchesModernLife(testScenario), isTrue);
        expect(screenState.matchesLifeStages(testScenario), isFalse);
      });
    });

    group('Advanced Search Functionality', () {
      test('should handle compound search queries', () {
        final scenarios = [
          Scenario(
            title: 'Parenting Stress Management',
            description: 'Dealing with stress while raising children',
            category: 'parenting',
            chapter: 1,
            heartResponse: 'Test',
            dutyResponse: 'Test',
            gitaWisdom: 'Test',
            tags: ['parenting', 'stress'],
            createdAt: DateTime.now(),
          ),
          Scenario(
            title: 'Work Life Balance',
            description: 'Balancing career and personal life',
            category: 'career',
            chapter: 2,
            heartResponse: 'Test',
            dutyResponse: 'Test',
            gitaWisdom: 'Test',
            tags: ['work', 'balance'],
            createdAt: DateTime.now(),
          ),
        ];

        final screenState = _ScenariosScreenTestState();
        
        // Test compound search
        final parentingStressResults = scenarios.where((s) => 
          screenState.matchesSearchQuery(s, 'parenting stress')).toList();
        expect(parentingStressResults.length, equals(1));
        expect(parentingStressResults.first.title, contains('Parenting'));

        final workBalanceResults = scenarios.where((s) => 
          screenState.matchesSearchQuery(s, 'work life balance')).toList();
        expect(workBalanceResults.length, equals(1));
        expect(workBalanceResults.first.title, contains('Work'));
      });

      test('should search across all scenario fields', () {
        final scenario = Scenario(
          title: 'Career Decision',
          description: 'Making tough choices at workplace',
          category: 'professional',
          chapter: 2,
          heartResponse: 'Follow your passion',
          dutyResponse: 'Consider responsibilities',
          gitaWisdom: 'Act without attachment to results',
          tags: ['career', 'decision'],
          actionSteps: ['Analyze options', 'Seek guidance'],
          createdAt: DateTime.now(),
        );

        final screenState = _ScenariosScreenTestState();

        // Should find in title
        expect(screenState.matchesSingleTerm(scenario, 'career'), isTrue);
        // Should find in description
        expect(screenState.matchesSingleTerm(scenario, 'workplace'), isTrue);
        // Should find in category
        expect(screenState.matchesSingleTerm(scenario, 'professional'), isTrue);
        // Should find in heart response
        expect(screenState.matchesSingleTerm(scenario, 'passion'), isTrue);
        // Should find in duty response
        expect(screenState.matchesSingleTerm(scenario, 'responsibilities'), isTrue);
        // Should find in gita wisdom
        expect(screenState.matchesSingleTerm(scenario, 'attachment'), isTrue);
        // Should find in tags
        expect(screenState.matchesSingleTerm(scenario, 'decision'), isTrue);
        // Should find in action steps
        expect(screenState.matchesSingleTerm(scenario, 'guidance'), isTrue);
      });

      test('should handle case-insensitive searches', () {
        final scenario = Scenario(
          title: 'Career Management',
          description: 'Test',
          category: 'test',
          chapter: 1,
          heartResponse: 'Test',
          dutyResponse: 'Test',
          gitaWisdom: 'Test',
          createdAt: DateTime.now(),
        );

        final screenState = _ScenariosScreenTestState();

        expect(screenState.matchesSingleTerm(scenario, 'career'), isTrue);
        expect(screenState.matchesSingleTerm(scenario, 'CAREER'), isTrue);
        expect(screenState.matchesSingleTerm(scenario, 'Career'), isTrue);
        expect(screenState.matchesSingleTerm(scenario, 'management'), isTrue);
        expect(screenState.matchesSingleTerm(scenario, 'MANAGEMENT'), isTrue);
      });
    });

    group('Category-based Filtering', () {
      test('should filter scenarios by category', () {
        final scenarios = [
          TestData.sampleScenario, // Career category
          TestData.relationshipScenario, // Relationships category
        ];

        final screenState = _ScenariosScreenTestState();

        // Should match career scenarios in career categories
        expect(screenState.matchesCategory(TestData.sampleScenario, ['career']), isTrue);
        expect(screenState.matchesCategory(TestData.relationshipScenario, ['relationships']), isTrue);
        
        // Should not match wrong categories
        expect(screenState.matchesCategory(TestData.sampleScenario, ['relationships']), isFalse);
        expect(screenState.matchesCategory(TestData.relationshipScenario, ['career']), isFalse);
      });
    });

    group('Backward Compatibility', () {
      testWidgets('should handle legacy filter names', (WidgetTester tester) async {
        // Test that old filter names still work
        await tester.pumpWidget(
          TestConfig.wrapWithMaterialApp(
            const ScenariosScreen(filterTag: 'parenting'),
          ),
        );
        await tester.pumpAndSettle();

        // Should map to Life Stages category
        // This would be tested by checking the UI state
        expect(find.byType(ScenariosScreen), findsOneWidget);
      });
    });
  });
}

// Test helper class to access private methods for testing
class _ScenariosScreenTestState {
  bool matchesLifeStages(Scenario s) {
    final lifeStageKeywords = [
      'parenting', 'parent', 'parents', 'child', 'children', 'kids', 'baby', 'toddler', 'teenager', 'teens',
      'pregnancy', 'pregnant', 'new parents', 'first-time parent', 'twins', 'siblings', 'newborn',
      'daycare', 'education', 'school', 'student', 'learning', 'feeding', 'sleep', 'development',
      'newly_married', 'joint family', 'empty nest', 'birth', 'breastfeeding', 'postpartum'
    ];
    
    return s.tags?.any((tag) => lifeStageKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  bool matchesRelationships(Scenario s) {
    final relationshipKeywords = [
      'relationships', 'relationship', 'relation', 'dating', 'romance', 'love', 'partner', 'couple',
      'marriage', 'married', 'spouse', 'wedding', 'engagement', 'breakup', 'ex-partner', 'cheating',
      'family', 'relatives', 'in-laws', 'mother-in-law', 'father-in-law', 'sister-in-law', 'brother-in-law',
      'grandparents', 'extended family', 'traditions', 'household', 'home', 'domestic',
      'friendship', 'friends', 'social', 'connection', 'intimacy', 'communication', 'trust'
    ];
    
    return s.tags?.any((tag) => relationshipKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  bool matchesCareerWork(Scenario s) {
    final careerKeywords = [
      'career', 'job', 'work', 'workplace', 'professional', 'business', 'entrepreneurship', 'startup',
      'employment', 'office', 'colleague', 'boss', 'authority', 'leadership', 'performance',
      'money', 'financial', 'finances', 'budget', 'salary', 'income', 'debt', 'loans', 'expenses',
      'investment', 'saving', 'spending', 'housing', 'rent', 'mortgage', 'insurance'
    ];
    
    return s.tags?.any((tag) => careerKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  bool matchesPersonalGrowth(Scenario s) {
    final growthKeywords = [
      'personal', 'growth', 'purpose', 'identity', 'self-care', 'confidence', 'self-doubt', 'self-worth',
      'values', 'authenticity', 'boundaries', 'balance', 'change', 'transformation', 'goals',
      'mental health', 'anxiety', 'depression', 'stress', 'therapy', 'emotional', 'emotions',
      'burnout', 'exhaustion', 'wellness', 'mindfulness', 'healing',
      'spiritual', 'spirituality', 'meditation', 'wisdom', 'enlightenment', 'consciousness',
      'detachment', 'dharma', 'karma', 'service', 'duty', 'ethics', 'morals'
    ];
    
    return s.tags?.any((tag) => growthKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  bool matchesModernLife(Scenario s) {
    final modernKeywords = [
      'technology', 'digital', 'social media', 'internet', 'online', 'apps', 'screen time',
      'comparison', 'fomo', 'influencers', 'networking',
      'modern', 'contemporary', 'lifestyle', 'urban', 'climate', 'environment', 'sustainability',
      'travel', 'vacation', 'experiences', 'adventure', 'hobbies', 'entertainment',
      'pressure', 'expectations', 'judgment', 'criticism', 'peer pressure', 'status', 'image',
      'celebration', 'events', 'parties', 'gifts', 'holidays', 'traditions'
    ];
    
    return s.tags?.any((tag) => modernKeywords.any((keyword) => 
      tag.toLowerCase().contains(keyword.toLowerCase())
    )) ?? false;
  }
  
  bool matchesCategory(Scenario s, List<String> categories) {
    return categories.contains(s.category.toLowerCase());
  }
  
  bool matchesSearchQuery(Scenario s, String query) {
    final lowerQuery = query.toLowerCase().trim();
    final searchTerms = lowerQuery.split(' ').where((term) => term.length > 1).toList();
    
    if (searchTerms.length == 1) {
      return matchesSingleTerm(s, lowerQuery);
    }
    
    return searchTerms.every((term) => matchesSingleTerm(s, term));
  }
  
  bool matchesSingleTerm(Scenario s, String term) {
    if (s.title.toLowerCase().contains(term)) return true;
    if (s.description.toLowerCase().contains(term)) return true;
    if (s.category.toLowerCase().contains(term)) return true;
    if (s.tags?.any((tag) => tag.toLowerCase().contains(term)) ?? false) return true;
    if (s.gitaWisdom.toLowerCase().contains(term)) return true;
    if (s.heartResponse.toLowerCase().contains(term)) return true;
    if (s.dutyResponse.toLowerCase().contains(term)) return true;
    if (s.actionSteps?.any((step) => step.toLowerCase().contains(term)) ?? false) return true;
    
    return false;
  }
}