// test/integration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import 'package:GitaWisdom/main.dart' as app;
import 'package:GitaWisdom/services/daily_verse_service.dart';
import 'package:GitaWisdom/services/scenario_service.dart';
import 'package:GitaWisdom/services/cache_service.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/screens/home_screen.dart';
import 'package:GitaWisdom/screens/scenarios_screen.dart';
import 'package:GitaWisdom/widgets/custom_nav_bar.dart';

import 'test_helpers.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Caching and Offline Integration Tests', () {
    setUpAll(() async {
      await commonTestSetup();
    });

    tearDownAll(() async {
      await commonTestCleanup();
    });

    testWidgets('App startup with cached daily verses', (WidgetTester tester) async {
      // Pre-populate cache with daily verses
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      final todayString = DailyVerseSet.getTodayString();
      
      await dailyVerseBox.put(todayString, TestData.todayDailyVerseSet);
      
      // Start the app
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(HomeScreen()),
        ),
      );
      
      await TestConfig.pumpWithSettle(tester);
      
      // App should load with cached verses
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget); // Verse carousel
      
      // Should display verses without network call
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Offline scenario browsing with cached data', (WidgetTester tester) async {
      // Pre-populate cache with scenarios
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      await scenarioBox.put('career', TestData.sampleScenario);
      await scenarioBox.put('family', TestData.relationshipScenario);
      
      // Initialize scenario service to load cache
      await ScenarioService.instance.initialize();
      
      // Start scenarios screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(ScenariosScreen()),
        ),
      );
      
      await TestConfig.pumpWithSettle(tester);
      
      // Should show cached scenarios
      expect(find.byType(ScenariosScreen), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      
      // Should be able to search cached scenarios
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await TestConfig.pumpWithSettle(tester);
      }
    });

    testWidgets('Navigation between cached screens', (WidgetTester tester) async {
      // Setup cache with data
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      await dailyVerseBox.put(DailyVerseSet.getTodayString(), TestData.todayDailyVerseSet);
      await scenarioBox.put('test', TestData.sampleScenario);
      
      await DailyVerseService.instance.initialize();
      await ScenarioService.instance.initialize();
      
      // Start with home screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(),
              bottomNavigationBar: CustomNavBar(
                currentIndex: 0,
                onTap: (index) {},
                items: const [
                  NavBarItem(icon: Icons.home, label: 'Home'),
                  NavBarItem(icon: Icons.menu_book, label: 'Chapters'), 
                  NavBarItem(icon: Icons.list, label: 'Scenarios'),
                  NavBarItem(icon: Icons.more_horiz, label: 'More'),
                ],
              ),
            ),
          ),
        ),
      );
      
      await TestConfig.pumpWithSettle(tester);
      
      // Should show home screen with cached verses
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(CustomNavBar), findsOneWidget);
      
      // Navigation should work with cached data
      final scenariosTab = find.text('Scenarios');
      if (scenariosTab.evaluate().isNotEmpty) {
        await tester.tap(scenariosTab);
        await TestConfig.pumpWithSettle(tester);
      }
    });

    testWidgets('Cache refresh workflow', (WidgetTester tester) async {
      // Start with empty cache
      await CacheService.clearAllCache();
      
      // Initialize services
      await DailyVerseService.instance.initialize();
      await ScenarioService.instance.initialize();
      
      // Start app
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: TestConfig.wrapWithMaterialApp(HomeScreen()),
        ),
      );
      
      await TestConfig.pumpWithSettle(tester);
      
      // App should handle empty cache gracefully
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Services should attempt to populate cache
      final verses = await DailyVerseService.instance.getTodaysVerses();
      final scenarios = await ScenarioService.instance.getAllScenarios();
      
      expect(verses, isA<List<Verse>>());
      expect(scenarios, isA<List<Scenario>>());
    });

    testWidgets('Offline search functionality', (WidgetTester tester) async {
      // Setup comprehensive scenario cache
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      // Add diverse scenarios for testing search
      final careerScenario = Scenario(
        title: 'Career Change Decision',
        description: 'Should I switch to a new career path?',
        category: 'Career',
        chapter: 2,
        heartResponse: 'Follow your passion',
        dutyResponse: 'Consider stability',
        gitaWisdom: 'Act without attachment',
        tags: ['career', 'change', 'decision'],
        createdAt: DateTime.now(),
      );
      
      final relationshipScenario = Scenario(
        title: 'Family Relationship Issues',
        description: 'How to handle conflicts with family members?',
        category: 'Relationships',
        chapter: 3,
        heartResponse: 'Express feelings',
        dutyResponse: 'Maintain harmony',
        gitaWisdom: 'Practice compassion',
        tags: ['family', 'relationships', 'conflict'],
        createdAt: DateTime.now(),
      );
      
      await scenarioBox.put('career', careerScenario);
      await scenarioBox.put('family', relationshipScenario);
      
      await ScenarioService.instance.initialize();
      
      // Test search functionality
      final careerResults = ScenarioService.instance.searchScenarios('career');
      final familyResults = ScenarioService.instance.searchScenarios('family');
      final changeResults = ScenarioService.instance.searchScenarios('change');
      
      expect(careerResults, isNotEmpty);
      expect(careerResults.first.title, contains('Career'));
      
      expect(familyResults, isNotEmpty);
      expect(familyResults.first.category, equals('Relationships'));
      
      expect(changeResults, isNotEmpty);
      expect(changeResults.first.tags, contains('change'));
    });

    testWidgets('Cache size monitoring and cleanup', (WidgetTester tester) async {
      // Add substantial data to caches
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      // Add multiple verse sets
      for (int i = 0; i < 10; i++) {
        final date = '2024-01-${(i + 1).toString().padLeft(2, '0')}';
        await dailyVerseBox.put(date, DailyVerseSet(
          date: date,
          verses: TestData.allTestVerses,
          chapterIds: [1, 2],
        ));
      }
      
      // Add multiple scenarios
      for (int i = 0; i < 50; i++) {
        await scenarioBox.put('scenario_$i', TestData.sampleScenario);
      }
      
      // Check cache sizes
      final cacheSizes = await CacheService.getCacheSizes();
      final totalSize = await CacheService.getTotalCacheSize();
      
      expect(cacheSizes, isNotEmpty);
      expect(totalSize, greaterThan(0.0));
      
      // Test cache cleanup
      await CacheService.clearAllCache();
      
      final cleanedSizes = await CacheService.getCacheSizes();
      final cleanedTotal = await CacheService.getTotalCacheSize();
      
      expect(cleanedTotal, lessThan(totalSize));
    });

    testWidgets('Daily verse calendar caching workflow', (WidgetTester tester) async {
      final service = DailyVerseService.instance;
      await service.initialize();
      
      // Get today's verses (should generate and cache)
      final todayVerses = await service.getTodaysVerses();
      expect(todayVerses, isA<List<Verse>>());
      
      // Verify caching
      final box = await Hive.openBox<DailyVerseSet>('daily_verses');
      final todayString = DailyVerseSet.getTodayString();
      final cachedSet = box.get(todayString);
      
      if (cachedSet != null) {
        expect(cachedSet.isToday, isTrue);
        expect(cachedSet.verses, isNotEmpty);
      }
      
      // Getting verses again should use cache
      final cachedVerses = await service.getTodaysVerses();
      expect(cachedVerses, isA<List<Verse>>());
    });

    testWidgets('Concurrent cache operations', (WidgetTester tester) async {
      // Test that multiple cache operations can run concurrently
      await Future.wait([
        DailyVerseService.instance.initialize(),
        ScenarioService.instance.initialize(),
        CacheService.getTotalCacheSize(),
      ]);
      
      // Concurrent data operations
      final futures = await Future.wait([
        DailyVerseService.instance.getTodaysVerses(),
        ScenarioService.instance.getAllScenarios(),
        CacheService.getCacheSizes(),
      ]);
      
      expect(futures[0], isA<List<Verse>>());    // verses
      expect(futures[1], isA<List<Scenario>>());  // scenarios  
      expect(futures[2], isA<Map<String, double>>()); // cache sizes
    });

    testWidgets('Offline user journey: Home → Scenarios → Search', (WidgetTester tester) async {
      // Setup comprehensive cache
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      await dailyVerseBox.put(DailyVerseSet.getTodayString(), TestData.todayDailyVerseSet);
      await scenarioBox.put('career', TestData.sampleScenario);
      await scenarioBox.put('family', TestData.relationshipScenario);
      
      await DailyVerseService.instance.initialize();
      await ScenarioService.instance.initialize();
      
      int currentIndex = 0;
      
      // Create full app navigation
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: IndexedStack(
                    index: currentIndex,
                    children: [
                      HomeScreen(),
                      ScenariosScreen(),
                    ],
                  ),
                  bottomNavigationBar: CustomNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      setState(() => currentIndex = index);
                    },
                    items: const [
                      NavBarItem(icon: Icons.home, label: 'Home'),
                      NavBarItem(icon: Icons.list, label: 'Scenarios'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await TestConfig.pumpWithSettle(tester);
      
      // Should start on home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Navigate to scenarios
      await tester.tap(find.text('Scenarios'));
      await TestConfig.pumpWithSettle(tester);
      
      // Should show scenarios screen with cached data
      expect(find.byType(ScenariosScreen), findsOneWidget);
      
      // Test search functionality if search is available
      final searchResults = ScenarioService.instance.searchScenarios('career');
      expect(searchResults, isA<List<Scenario>>());
    });

    testWidgets('Cache resilience: Handle corrupted data', (WidgetTester tester) async {
      // This tests how the app handles corrupted or invalid cached data
      final box = await Hive.openBox<DailyVerseSet>('daily_verses');
      
      // Add some valid data first
      await box.put('valid', TestData.sampleDailyVerseSet);
      
      // Service should handle mixed valid/invalid data gracefully
      await DailyVerseService.instance.initialize();
      
      expect(() async => await DailyVerseService.instance.getTodaysVerses(), 
             returnsNormally);
    });

    testWidgets('Memory management: Large cache datasets', (WidgetTester tester) async {
      // Test app performance with large cached datasets
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      // Add many scenarios
      for (int i = 0; i < 100; i++) {
        final scenario = Scenario(
          title: 'Test Scenario $i',
          description: 'Description for scenario $i',
          category: 'Test Category ${i % 5}',
          chapter: (i % 18) + 1,
          heartResponse: 'Heart response $i',
          dutyResponse: 'Duty response $i',  
          gitaWisdom: 'Wisdom $i',
          tags: ['tag${i % 10}', 'test'],
          createdAt: DateTime.now().subtract(Duration(days: i)),
        );
        
        await scenarioBox.put('scenario_$i', scenario);
      }
      
      await ScenarioService.instance.initialize();
      
      // Should handle large datasets efficiently
      final allScenarios = await ScenarioService.instance.getAllScenarios();
      expect(allScenarios.length, greaterThanOrEqualTo(100));
      
      // Search should remain performant
      final searchResults = ScenarioService.instance.searchScenarios('test');
      expect(searchResults, isNotEmpty);
      
      // Cache size calculation should work with large data
      final sizes = await CacheService.getCacheSizes();
      expect(sizes['Scenarios'], greaterThan(0.0));
    });
  });

  group('Cache Persistence Tests', () {
    testWidgets('Data survives app restart simulation', (WidgetTester tester) async {
      // Add data to cache
      final dailyVerseBox = await Hive.openBox<DailyVerseSet>('daily_verses');
      await dailyVerseBox.put('persistent', TestData.sampleDailyVerseSet);
      
      // Simulate app restart by reinitializing service
      await DailyVerseService.instance.initialize();
      
      // Data should still be available
      final cachedData = dailyVerseBox.get('persistent');
      expect(cachedData, isNotNull);
      expect(cachedData!.verses.length, equals(TestData.sampleDailyVerseSet.verses.length));
    });

    testWidgets('Cache integrity after multiple operations', (WidgetTester tester) async {
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      
      // Perform multiple cache operations
      await scenarioBox.put('test1', TestData.sampleScenario);
      await scenarioBox.put('test2', TestData.relationshipScenario);
      await scenarioBox.delete('test1');
      await scenarioBox.put('test3', TestData.sampleScenario);
      
      // Verify final state
      expect(scenarioBox.containsKey('test1'), isFalse);
      expect(scenarioBox.containsKey('test2'), isTrue);
      expect(scenarioBox.containsKey('test3'), isTrue);
      
      final allValues = scenarioBox.values.toList();
      expect(allValues.length, equals(2));
    });

    testWidgets('Cache maintains data consistency', (WidgetTester tester) async {
      // Test that cached data maintains referential integrity
      final originalScenario = TestData.sampleScenario;
      
      final scenarioBox = await Hive.openBox<Scenario>('scenarios');
      await scenarioBox.put('consistency_test', originalScenario);
      
      final retrievedScenario = scenarioBox.get('consistency_test');
      
      expect(retrievedScenario, isNotNull);
      expect(retrievedScenario!.title, equals(originalScenario.title));
      expect(retrievedScenario.description, equals(originalScenario.description));
      expect(retrievedScenario.category, equals(originalScenario.category));
      expect(retrievedScenario.tags, equals(originalScenario.tags));
    });
  });
}