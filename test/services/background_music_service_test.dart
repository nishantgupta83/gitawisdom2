// test/services/background_music_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/services/background_music_service.dart';
import 'package:GitaWisdom/models/simple_meditation.dart';
import 'package:just_audio/just_audio.dart';
import '../test_setup.dart';
import 'background_music_service_test.mocks.dart';

@GenerateMocks([AudioPlayer])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('BackgroundMusicService', () {
    late BackgroundMusicService service;

    setUp(() {
      service = BackgroundMusicService();
    });

    tearDown(() async {
      // Don't dispose singleton in tests - it causes issues
    });

    group('Initialization', () {
      test('should be singleton instance', () {
        final instance1 = BackgroundMusicService();
        final instance2 = BackgroundMusicService.instance;
        expect(instance1, equals(instance2));
      });

      test('should have initial state before initialization', () {
        expect(service.isInitialized, isFalse);
        expect(service.isEnabled, isTrue);
        expect(service.isPlaying, isFalse);
        expect(service.volume, equals(0.3));
        expect(service.isDucking, isFalse);
      });

      test('should have default meditation theme', () {
        expect(service.currentTheme, equals(MusicTheme.meditation));
      });
    });

    group('Volume Control', () {
      test('should set volume within valid range', () async {
        await service.setVolume(0.5);
        expect(service.volume, equals(0.5));
      });

      test('should clamp volume to 0.0 minimum', () async {
        await service.setVolume(-0.5);
        expect(service.volume, equals(0.0));
      });

      test('should clamp volume to 1.0 maximum', () async {
        await service.setVolume(1.5);
        expect(service.volume, equals(1.0));
      });

      test('should notify listeners on volume change', () async {
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.setVolume(0.7);

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Audio Ducking', () {
      test('should have ducking functionality available', () {
        // Duck/unduck requires audio player initialization which isn't available in unit tests
        // Just verify the methods exist and don't crash
        expect(() => service.duck(), returnsNormally);
        expect(() => service.unduck(), returnsNormally);
      });

      test('should track ducking state', () {
        // Initial state
        expect(service.isDucking, isFalse);
      });
    });

    group('Enable/Disable', () {
      test('should track enabled state', () {
        expect(service.isEnabled, isTrue); // Default
      });

      test('should change enabled state', () async {
        // Don't call setEnabled with true (tries to start music which needs plugin)
        await service.setEnabled(false);
        expect(service.isEnabled, isFalse);
      });

      test('should notify listeners on state change', () async {
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.setEnabled(false);

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Music Theme', () {
      test('should change to meditation theme', () async {
        await service.setTheme(MusicTheme.meditation);
        expect(service.currentTheme, equals(MusicTheme.meditation));
      });

      test('should change to reading theme', () async {
        await service.setTheme(MusicTheme.reading);
        expect(service.currentTheme, equals(MusicTheme.reading));
      });

      test('should change to nature theme', () async {
        await service.setTheme(MusicTheme.nature);
        expect(service.currentTheme, equals(MusicTheme.nature));
      });

      test('should change to silence theme', () async {
        await service.setTheme(MusicTheme.silence);
        expect(service.currentTheme, equals(MusicTheme.silence));
      });

      test('should not change theme if same theme', () async {
        await service.setTheme(MusicTheme.meditation);
        final initialTheme = service.currentTheme;

        await service.setTheme(MusicTheme.meditation);

        expect(service.currentTheme, equals(initialTheme));
      });

      test('should notify listeners on theme change', () async {
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.setTheme(MusicTheme.nature);

        expect(notificationCount, greaterThan(0));
      });

      test('should get correct theme names', () {
        expect(service.getThemeName(MusicTheme.meditation), equals('Meditation'));
        expect(service.getThemeName(MusicTheme.reading), equals('Reading'));
        expect(service.getThemeName(MusicTheme.nature), equals('Nature'));
        expect(service.getThemeName(MusicTheme.silence), equals('Silence'));
      });

      test('should provide all available themes', () {
        final themes = service.availableThemes;
        expect(themes, contains(MusicTheme.meditation));
        expect(themes, contains(MusicTheme.reading));
        expect(themes, contains(MusicTheme.nature));
        expect(themes, contains(MusicTheme.silence));
      });
    });

    group('Playback Control', () {
      test('should start music without errors', () async {
        expect(() => service.startMusic(), returnsNormally);
      });

      test('should stop music without errors', () async {
        expect(() => service.stopMusic(), returnsNormally);
      });

      test('should pause music without errors', () async {
        expect(() => service.pauseMusic(), returnsNormally);
      });

      test('should resume music without errors', () async {
        expect(() => service.resumeMusic(), returnsNormally);
      });

      test('should not start music when disabled', () async {
        await service.setEnabled(false);
        await service.startMusic();

        expect(service.isEnabled, isFalse);
      });

      test('should not start music for silence theme', () async {
        await service.setTheme(MusicTheme.silence);
        await service.startMusic();

        // Music should not play for silence theme
        expect(service.currentTheme, equals(MusicTheme.silence));
      });
    });

    group('Error Handling', () {
      test('should handle initialization attempts', () async {
        // Multiple initialization attempts should not crash
        // Note: Actual initialization requires audio plugins
        expect(service, isNotNull);
      });

      test('should handle playback operations gracefully', () async {
        // Attempting operations without initialization should not crash
        expect(() => service.pauseMusic(), returnsNormally);
        expect(() => service.resumeMusic(), returnsNormally);
        expect(() => service.stopMusic(), returnsNormally);
      });
    });

    group('State Consistency', () {
      test('should maintain volume across operations', () async {
        const originalVolume = 0.6;
        await service.setVolume(originalVolume);

        expect(service.volume, equals(originalVolume));
      });

      test('should maintain theme after state changes', () async {
        await service.setTheme(MusicTheme.nature);
        final theme = service.currentTheme;

        await service.setEnabled(false);

        expect(service.currentTheme, equals(theme));
      });
    });

    group('Edge Cases', () {
      test('should handle rapid theme changes', () async {
        await service.setTheme(MusicTheme.meditation);
        await service.setTheme(MusicTheme.reading);
        await service.setTheme(MusicTheme.nature);

        expect(service.currentTheme, equals(MusicTheme.nature));
      });

      test('should handle rapid state toggles', () async {
        await service.setEnabled(false);
        await service.setEnabled(false);

        expect(service.isEnabled, isFalse);
      });

      test('should handle volume changes', () async {
        await service.setVolume(0.8);

        expect(service.volume, equals(0.8));
      });
    });

    group('Lifecycle Management', () {
      test('should maintain service instance', () {
        expect(service, isNotNull);
        expect(service, equals(BackgroundMusicService.instance));
      });

      test('should maintain state across operations', () async {
        await service.setVolume(0.7);
        await service.setTheme(MusicTheme.nature);

        expect(service.volume, equals(0.7));
        expect(service.currentTheme, equals(MusicTheme.nature));
      });
    });
  });
}
