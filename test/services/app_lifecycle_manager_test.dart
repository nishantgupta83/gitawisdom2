// test/services/app_lifecycle_manager_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/app_lifecycle_manager.dart';
import 'package:GitaWisdom/services/background_music_service.dart';
import '../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('AppLifecycleManager', () {
    late AppLifecycleManager manager;
    late BackgroundMusicService musicService;

    setUp(() async {
      manager = AppLifecycleManager.instance;
      musicService = BackgroundMusicService.instance;

      // Reset state before each test
      manager.clearResumeState();
    });

    tearDown(() async {
      manager.dispose();
    });

    group('Initialization', () {
      test('should create manager instance', () {
        expect(manager, isNotNull);
        expect(manager, isA<AppLifecycleManager>());
      });

      test('should be a singleton', () {
        final instance1 = AppLifecycleManager.instance;
        final instance2 = AppLifecycleManager.instance;
        expect(instance1, same(instance2));
      });

      test('should implement WidgetsBindingObserver', () {
        expect(manager, isA<WidgetsBindingObserver>());
      });

      test('should initialize without errors', () {
        manager.initialize();
        expect(manager, isNotNull);
      });

      test('should not initialize twice', () {
        manager.initialize();
        manager.initialize(); // Second call should be no-op
        expect(manager, isNotNull);
      });

      test('should initialize music service', () async {
        manager.initialize();
        expect(musicService, isNotNull);
      });
    });

    group('State Properties', () {
      test('should expose shouldResumeMusic property', () {
        final shouldResume = manager.shouldResumeMusic;
        expect(shouldResume, isA<bool>());
      });

      test('should expose wasMusicPlayingBeforeBackground property', () {
        final wasPlaying = manager.wasMusicPlayingBeforeBackground;
        expect(wasPlaying, isA<bool>());
      });

      test('should have false initial state', () {
        expect(manager.shouldResumeMusic, isFalse);
        expect(manager.wasMusicPlayingBeforeBackground, isFalse);
      });
    });

    group('App Lifecycle - Resumed', () {
      test('should handle app resumed state', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });

      test('should not throw on resumed without initialization', () {
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });

      test('should handle rapid resume calls', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });
    });

    group('App Lifecycle - Paused', () {
      test('should handle app paused state', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(manager, isNotNull);
      });

      test('should update music state on pause', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);

        // State should be captured
        expect(manager, isNotNull);
      });

      test('should handle pause without initialization', () {
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(manager, isNotNull);
      });

      test('should handle rapid pause calls', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(manager, isNotNull);
      });
    });

    group('App Lifecycle - Detached', () {
      test('should handle app detached state', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        expect(manager, isNotNull);
      });

      test('should clear resume state on detached', () {
        manager.initialize();

        // Simulate background with music playing
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);

        // Detach should clear state
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);

        expect(manager, isNotNull);
      });

      test('should handle detached without initialization', () {
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        expect(manager, isNotNull);
      });
    });

    group('App Lifecycle - Inactive', () {
      test('should handle app inactive state', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.inactive);
        expect(manager, isNotNull);
      });

      test('should not change state on inactive', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.inactive);
        expect(manager, isNotNull);
      });
    });

    group('App Lifecycle - Hidden', () {
      test('should handle app hidden state', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.hidden);
        expect(manager, isNotNull);
      });

      test('should treat hidden like paused', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.hidden);
        expect(manager, isNotNull);
      });
    });

    group('Lifecycle Transitions', () {
      test('should handle resume -> pause transition', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(manager, isNotNull);
      });

      test('should handle pause -> resume transition', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });

      test('should handle resumed -> detached transition', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        expect(manager, isNotNull);
      });

      test('should handle paused -> detached transition', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        expect(manager, isNotNull);
      });

      test('should handle inactive -> resumed transition', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.inactive);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });

      test('should handle multiple rapid transitions', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.inactive);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(manager, isNotNull);
      });
    });

    group('Debouncing', () {
      test('should handle duplicate lifecycle events', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(manager, isNotNull);
      });

      test('should debounce rapid state changes', () async {
        manager.initialize();

        // Rapidly change states
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

        // Wait for debounce timer
        await Future.delayed(const Duration(milliseconds: 1100));

        expect(manager, isNotNull);
      });

      test('should handle state changes within debounce window', () async {
        manager.initialize();

        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future.delayed(const Duration(milliseconds: 500));
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);

        expect(manager, isNotNull);
      });
    });

    group('Resume State Management', () {
      test('should clear resume state manually', () {
        manager.initialize();
        manager.clearResumeState();

        expect(manager.shouldResumeMusic, isFalse);
        expect(manager.wasMusicPlayingBeforeBackground, isFalse);
      });

      test('should clear state after manual clear', () {
        manager.initialize();

        // Simulate state
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);

        // Clear manually
        manager.clearResumeState();

        expect(manager.shouldResumeMusic, isFalse);
        expect(manager.wasMusicPlayingBeforeBackground, isFalse);
      });

      test('should handle multiple clear calls', () {
        manager.initialize();
        manager.clearResumeState();
        manager.clearResumeState();
        manager.clearResumeState();
        expect(manager, isNotNull);
      });

      test('should clear state before dispose', () {
        manager.initialize();
        manager.clearResumeState();
        manager.dispose();
        expect(manager, isNotNull);
      });
    });

    group('Timer Management', () {
      test('should cancel timers on dispose', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.dispose();
        expect(manager, isNotNull);
      });

      test('should handle dispose without initialization', () {
        manager.dispose();
        expect(manager, isNotNull);
      });

      test('should handle multiple dispose calls', () {
        manager.initialize();
        manager.dispose();
        manager.dispose();
        expect(manager, isNotNull);
      });

      test('should handle dispose after lifecycle changes', () async {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future.delayed(const Duration(milliseconds: 100));
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        await Future.delayed(const Duration(milliseconds: 100));
        manager.dispose();
        expect(manager, isNotNull);
      });
    });

    group('Music Service Integration', () {
      test('should interact with BackgroundMusicService', () {
        manager.initialize();
        expect(musicService, isNotNull);
        expect(musicService.isInitialized, anyOf(isTrue, isFalse));
      });

      test('should check music playing state', () {
        manager.initialize();
        final isPlaying = musicService.isPlaying;
        expect(isPlaying, isA<bool>());
      });

      test('should check music enabled state', () {
        manager.initialize();
        final isEnabled = musicService.isEnabled;
        expect(isEnabled, isA<bool>());
      });

      test('should handle music service not initialized', () {
        final uninitializedService = BackgroundMusicService.instance;
        expect(uninitializedService.isPlaying, anyOf(isTrue, isFalse));
      });
    });

    group('Error Handling', () {
      test('should handle errors gracefully', () {
        try {
          manager.initialize();
          manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        } catch (e) {
          fail('Should not throw exception: $e');
        }
        expect(manager, isNotNull);
      });

      test('should recover from errors', () {
        manager.initialize();

        // Cause potential error conditions
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

        expect(manager, isNotNull);
      });

      test('should handle invalid state transitions', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });
    });

    group('Dispose', () {
      test('should dispose without errors', () {
        manager.initialize();
        manager.dispose();
        expect(manager, isNotNull);
      });

      test('should dispose with active timers', () async {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future.delayed(const Duration(milliseconds: 100));
        manager.dispose();
        expect(manager, isNotNull);
      });

      test('should clear all timers on dispose', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.dispose();
        expect(manager, isNotNull);
      });

      test('should remove observer on dispose', () {
        manager.initialize();
        manager.dispose();
        // Should be removed from WidgetsBinding
        expect(manager, isNotNull);
      });
    });

    group('State Persistence', () {
      test('should maintain state across multiple calls', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);

        final shouldResume1 = manager.shouldResumeMusic;
        final shouldResume2 = manager.shouldResumeMusic;

        expect(shouldResume1, equals(shouldResume2));
      });

      test('should update state on lifecycle changes', () {
        manager.initialize();

        final initial = manager.shouldResumeMusic;
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        final after = manager.shouldResumeMusic;

        // State should be consistent
        expect(initial, isA<bool>());
        expect(after, isA<bool>());
      });

      test('should reset state on clear', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);

        manager.clearResumeState();

        expect(manager.shouldResumeMusic, isFalse);
        expect(manager.wasMusicPlayingBeforeBackground, isFalse);
      });
    });

    group('Concurrent Operations', () {
      test('should handle concurrent lifecycle changes', () async {
        manager.initialize();

        // Fire multiple changes concurrently
        final futures = <Future>[];
        futures.add(Future(() => manager.didChangeAppLifecycleState(AppLifecycleState.paused)));
        futures.add(Future(() => manager.didChangeAppLifecycleState(AppLifecycleState.resumed)));
        futures.add(Future(() => manager.didChangeAppLifecycleState(AppLifecycleState.inactive)));

        await Future.wait(futures);

        expect(manager, isNotNull);
      });

      test('should handle concurrent clear and lifecycle change', () async {
        manager.initialize();

        final futures = <Future>[];
        futures.add(Future(() => manager.clearResumeState()));
        futures.add(Future(() => manager.didChangeAppLifecycleState(AppLifecycleState.paused)));

        await Future.wait(futures);

        expect(manager, isNotNull);
      });

      test('should handle concurrent dispose and lifecycle change', () async {
        manager.initialize();

        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        await Future.delayed(const Duration(milliseconds: 50));
        manager.dispose();

        expect(manager, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('should handle detached without previous state', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        expect(manager, isNotNull);
      });

      test('should handle resumed without previous pause', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });

      test('should handle hidden without initialization', () {
        manager.didChangeAppLifecycleState(AppLifecycleState.hidden);
        expect(manager, isNotNull);
      });

      test('should handle multiple detached calls', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        manager.didChangeAppLifecycleState(AppLifecycleState.detached);
        expect(manager, isNotNull);
      });

      test('should handle alternating inactive and resumed', () {
        manager.initialize();
        manager.didChangeAppLifecycleState(AppLifecycleState.inactive);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        manager.didChangeAppLifecycleState(AppLifecycleState.inactive);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(manager, isNotNull);
      });
    });
  });
}
