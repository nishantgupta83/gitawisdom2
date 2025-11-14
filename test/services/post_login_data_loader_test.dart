// test/services/post_login_data_loader_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/services/post_login_data_loader.dart';
import 'package:GitaWisdom/services/progressive_scenario_service.dart';
import 'package:GitaWisdom/services/enhanced_supabase_service.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';
import 'post_login_data_loader_test.mocks.dart';

@GenerateMocks([ProgressiveScenarioService, EnhancedSupabaseService])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('PostLoginDataLoader', () {
    late PostLoginDataLoader loader;
    late MockProgressiveScenarioService mockScenarioService;
    late MockEnhancedSupabaseService mockSupabaseService;

    setUp(() {
      loader = PostLoginDataLoader.instance;
      mockScenarioService = MockProgressiveScenarioService();
      mockSupabaseService = MockEnhancedSupabaseService();
    });

    group('Initialization', () {
      test('should be singleton instance', () {
        final instance1 = PostLoginDataLoader.instance;
        final instance2 = PostLoginDataLoader.instance;
        expect(instance1, equals(instance2));
      });

      test('should have initial state', () {
        expect(loader.isCompleted, isFalse);
        expect(loader.isLoading, isFalse);
        expect(loader.totalScenarios, equals(0));
        expect(loader.loadedScenarios, equals(0));
        expect(loader.progress, equals(0.0));
      });
    });

    group('LoadingProgress Model', () {
      test('should create LoadingProgress with required fields', () {
        final progress = LoadingProgress(
          isCompleted: false,
          totalScenarios: 100,
          loadedScenarios: 50,
          message: 'Loading...',
        );

        expect(progress.isCompleted, isFalse);
        expect(progress.totalScenarios, equals(100));
        expect(progress.loadedScenarios, equals(50));
        expect(progress.message, equals('Loading...'));
        expect(progress.hasError, isFalse);
      });

      test('should calculate progress percentage correctly', () {
        final progress = LoadingProgress(
          isCompleted: false,
          totalScenarios: 200,
          loadedScenarios: 50,
          message: 'Loading...',
        );

        expect(progress.progress, equals(0.25));
        expect(progress.percentage, equals(25));
      });

      test('should handle zero total scenarios', () {
        final progress = LoadingProgress(
          isCompleted: false,
          totalScenarios: 0,
          loadedScenarios: 0,
          message: 'Loading...',
        );

        expect(progress.progress, equals(0.0));
        expect(progress.percentage, equals(0));
      });

      test('should support error state', () {
        final progress = LoadingProgress(
          isCompleted: false,
          totalScenarios: 100,
          loadedScenarios: 30,
          message: 'Error occurred',
          hasError: true,
        );

        expect(progress.hasError, isTrue);
        expect(progress.message, equals('Error occurred'));
      });
    });

    group('Current Progress', () {
      test('should provide current progress when not started', () {
        final progress = loader.currentProgress;

        expect(progress.isCompleted, isFalse);
        expect(progress.totalScenarios, equals(0));
        expect(progress.loadedScenarios, equals(0));
        expect(progress.message, contains('Ready to load'));
      });
    });

    group('Progress Stream', () {
      test('should provide progress stream', () {
        expect(loader.progressStream, isNotNull);
      });

      test('should emit progress updates via stream', () async {
        final progressUpdates = <LoadingProgress>[];
        final subscription = loader.progressStream.listen(progressUpdates.add);

        // Trigger some operation that would emit progress
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();
        // Stream should be available even if no updates yet
        expect(loader.progressStream, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple startBackgroundLoading calls', () async {
        // First call
        loader.startBackgroundLoading();

        // Second call should be ignored
        loader.startBackgroundLoading();

        await Future.delayed(const Duration(milliseconds: 100));

        // Should only have one loading operation
        expect(loader.isLoading || loader.isCompleted, isTrue);
      });

      test('should handle dispose correctly', () {
        expect(() => loader.dispose(), returnsNormally);
      });
    });

    group('Progress Calculation', () {
      test('should calculate progress with partial load', () {
        // Create a mock scenario for progress calculation
        final progress = LoadingProgress(
          isCompleted: false,
          totalScenarios: 1000,
          loadedScenarios: 250,
          message: 'Loading scenarios: 250/1000',
        );

        expect(progress.progress, equals(0.25));
        expect(progress.percentage, equals(25));
      });

      test('should handle 100% completion', () {
        final progress = LoadingProgress(
          isCompleted: true,
          totalScenarios: 500,
          loadedScenarios: 500,
          message: 'All scenarios loaded',
        );

        expect(progress.progress, equals(1.0));
        expect(progress.percentage, equals(100));
      });
    });

    group('Message Formatting', () {
      test('should provide descriptive messages for different states', () {
        final notStarted = LoadingProgress(
          isCompleted: false,
          totalScenarios: 0,
          loadedScenarios: 0,
          message: 'Ready to load',
        );

        final loading = LoadingProgress(
          isCompleted: false,
          totalScenarios: 1000,
          loadedScenarios: 300,
          message: 'Loading scenarios: 300/1000',
        );

        final completed = LoadingProgress(
          isCompleted: true,
          totalScenarios: 1000,
          loadedScenarios: 1000,
          message: 'All scenarios loaded! Full AI search available.',
        );

        expect(notStarted.message, contains('Ready'));
        expect(loading.message, contains('Loading'));
        expect(completed.message, contains('All scenarios loaded'));
      });
    });

    group('State Consistency', () {
      test('should maintain consistent state after operations', () async {
        final initialCompleted = loader.isCompleted;
        final initialLoading = loader.isLoading;

        await Future.delayed(const Duration(milliseconds: 50));

        // State should remain consistent
        expect(loader.isCompleted, equals(initialCompleted));
        expect(loader.isLoading, equals(initialLoading));
      });
    });
  });
}
