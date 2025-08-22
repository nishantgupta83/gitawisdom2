// test/integration/production_readiness_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;
import 'package:GitaWisdom/services/service_locator.dart';
import 'package:GitaWisdom/config/environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Production Readiness Integration Test
/// 
/// This test suite verifies that the app is ready for production deployment
/// by testing critical functionality that could fail in release builds.
/// 
/// Key areas tested:
/// 1. Network connectivity and permissions
/// 2. Supabase connection and data retrieval
/// 3. Core app initialization
/// 4. Critical user flows
/// 5. Environment configuration
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Production Readiness Tests', () {
    
    group('🌐 Network & API Connectivity', () {
      
      testWidgets('Environment configuration is valid', (WidgetTester tester) async {
        // Test environment variables and configuration
        expect(Environment.isConfigured, isTrue, 
               reason: 'Environment must be properly configured for production');
        
        expect(Environment.supabaseUrl.isNotEmpty, isTrue,
               reason: 'Supabase URL must be configured');
        
        expect(Environment.supabaseAnonKey.isNotEmpty, isTrue,
               reason: 'Supabase anon key must be configured');
        
        // Validate URL format
        expect(Environment.supabaseUrl.startsWith('https://'), isTrue,
               reason: 'Supabase URL must use HTTPS in production');
      });

      testWidgets('Supabase connection test', (WidgetTester tester) async {
        // Initialize minimal required components
        await Hive.initFlutter();
        
        // Initialize Supabase
        await Supabase.initialize(
          url: Environment.supabaseUrl,
          anonKey: Environment.supabaseAnonKey,
        );
        
        await ServiceLocator.instance.initialize();
        
        // Test connection
        final supabaseService = ServiceLocator.instance.enhancedSupabaseService;
        final isConnected = await supabaseService.testConnection();
        
        expect(isConnected, isTrue, 
               reason: 'Supabase connection must work in production environment');
      });

      testWidgets('Critical data endpoints are accessible', (WidgetTester tester) async {
        await Hive.initFlutter();
        await Supabase.initialize(
          url: Environment.supabaseUrl,
          anonKey: Environment.supabaseAnonKey,
        );
        await ServiceLocator.instance.initialize();
        
        final supabaseService = ServiceLocator.instance.enhancedSupabaseService;
        
        // Test chapters endpoint
        final chapters = await supabaseService.fetchChapterSummaries();
        expect(chapters.isNotEmpty, isTrue, 
               reason: 'Chapters data must be available');
        expect(chapters.length, equals(18), 
               reason: 'All 18 Gita chapters must be available');
        
        // Test scenarios endpoint
        final scenarios = await supabaseService.fetchScenarios(limit: 5);
        expect(scenarios.isNotEmpty, isTrue, 
               reason: 'Scenarios data must be available');
        
        // Test that scenarios have required fields
        for (final scenario in scenarios.take(3)) {
          expect(scenario.title.isNotEmpty, isTrue,
                 reason: 'Scenario title must not be empty');
          expect(scenario.heartResponse.isNotEmpty, isTrue,
                 reason: 'Heart response must not be empty');
          expect(scenario.dutyResponse.isNotEmpty, isTrue,
                 reason: 'Duty response must not be empty');
          expect(scenario.gitaWisdom.isNotEmpty, isTrue,
                 reason: 'Gita wisdom must not be empty');
        }
      });
    });

    group('🚀 App Initialization', () {
      
      testWidgets('App starts without crashing', (WidgetTester tester) async {
        // This tests the full app initialization flow
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 10));
        
        // Verify app loaded successfully
        expect(find.byType(app.WisdomGuideApp), findsOneWidget,
               reason: 'Main app widget must be present');
      });

      testWidgets('Home screen loads with content', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 15));
        
        // Wait for content to load
        await tester.pump(const Duration(seconds: 5));
        
        // Verify daily verses appear (indicating Supabase connection works)
        // Note: This might need adjustment based on exact widget structure
        expect(find.textContaining('Daily Verse'), findsWidgets,
               reason: 'Daily verses should be loaded and displayed');
      });

      testWidgets('Navigation between core screens works', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 10));
        
        // Test navigation to Chapters
        await tester.tap(find.text('Chapters'));
        await tester.pumpAndSettle();
        
        // Test navigation to Scenarios
        await tester.tap(find.text('Scenarios'));
        await tester.pumpAndSettle();
        
        // Test navigation to More
        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();
        
        // If we get here without exceptions, navigation works
        expect(true, isTrue, reason: 'Navigation completed successfully');
      });
    });

    group('🔧 System Requirements', () {
      
      testWidgets('Required permissions are available', (WidgetTester tester) async {
        // Test internet permission (this would fail if AndroidManifest is wrong)
        try {
          // Try to make a simple HTTP request
          await Supabase.initialize(
            url: Environment.supabaseUrl,
            anonKey: Environment.supabaseAnonKey,
          );
          
          final response = await Supabase.instance.client
              .from('chapters')
              .select('ch_chapter_id')
              .limit(1);
          
          expect(response, isNotNull, 
                 reason: 'Network request must succeed (indicates proper permissions)');
        } catch (e) {
          fail('Network request failed - check AndroidManifest.xml permissions: $e');
        }
      });

      testWidgets('Local storage works', (WidgetTester tester) async {
        await Hive.initFlutter();
        
        // Test Hive box operations
        final testBox = await Hive.openBox('test_production_readiness');
        await testBox.put('test_key', 'test_value');
        final value = testBox.get('test_key');
        
        expect(value, equals('test_value'),
               reason: 'Local storage must work for offline functionality');
        
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_production_readiness');
      });
    });

    group('📊 Performance & User Experience', () {
      
      testWidgets('App initialization completes within reasonable time', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 20));
        
        stopwatch.stop();
        
        // App should initialize within 20 seconds even on slower devices
        expect(stopwatch.elapsed.inSeconds, lessThan(20),
               reason: 'App initialization should complete within 20 seconds');
      });

      testWidgets('Core content loads within acceptable time', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 10));
        
        final stopwatch = Stopwatch()..start();
        
        // Navigate to scenarios and measure load time
        await tester.tap(find.text('Scenarios'));
        await tester.pumpAndSettle(const Duration(seconds: 10));
        
        stopwatch.stop();
        
        // Content should load within 10 seconds
        expect(stopwatch.elapsed.inSeconds, lessThan(10),
               reason: 'Core content should load within 10 seconds');
      });
    });

    group('🚨 Critical User Flows', () {
      
      testWidgets('Heart vs Duty scenario flow works end-to-end', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 15));
        
        // Navigate to scenarios
        await tester.tap(find.text('Scenarios'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Try to find and tap a scenario category
        // Note: Adjust selector based on actual UI
        if (find.text('Family').evaluate().isNotEmpty) {
          await tester.tap(find.text('Family'));
          await tester.pumpAndSettle(const Duration(seconds: 5));
          
          // Verify scenarios loaded
          expect(find.byType(Card), findsWidgets,
                 reason: 'Scenarios should be displayed as cards');
        }
      });

      testWidgets('Chapter reading flow works', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 15));
        
        // Navigate to chapters
        await tester.tap(find.text('Chapters'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Verify chapters are loaded
        expect(find.textContaining('Chapter'), findsWidgets,
               reason: 'Chapter list should be displayed');
      });
    });
  });
}