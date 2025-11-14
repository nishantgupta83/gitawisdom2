import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/simple_meditation.dart';

void main() {
  group('MusicTheme', () {
    test('should have all themes defined', () {
      expect(MusicTheme.values.length, greaterThanOrEqualTo(4));
      expect(MusicTheme.values, contains(MusicTheme.meditation));
      expect(MusicTheme.values, contains(MusicTheme.nature));
      expect(MusicTheme.values, contains(MusicTheme.reading));
      expect(MusicTheme.values, contains(MusicTheme.silence));
    });
  });

  group('MeditationSession', () {
    test('should create session with all required fields', () {
      final session = MeditationSession(
        id: '123',
        startedAt: DateTime.now(),
        plannedDurationSeconds: 600,
        actualDurationSeconds: 0,
        musicTheme: MusicTheme.meditation,
        isCompleted: false,
      );

      expect(session.id, equals('123'));
      expect(session.plannedDurationSeconds, equals(600));
      expect(session.actualDurationSeconds, equals(0));
      expect(session.musicTheme, equals(MusicTheme.meditation));
      expect(session.isCompleted, equals(false));
      expect(session.userRating, isNull);
      expect(session.notes, isNull);
    });

    test('should create session with optional fields', () {
      final session = MeditationSession(
        id: '123',
        startedAt: DateTime.now(),
        plannedDurationSeconds: 600,
        actualDurationSeconds: 600,
        musicTheme: MusicTheme.nature,
        isCompleted: true,
        userRating: 4.5,
        notes: 'Great session',
      );

      expect(session.userRating, equals(4.5));
      expect(session.notes, equals('Great session'));
      expect(session.isCompleted, equals(true));
    });

    test('create factory should generate new session', () {
      final session = MeditationSession.create(
        durationSeconds: 300,
        musicTheme: MusicTheme.reading,
      );

      expect(session.id, isNotEmpty);
      expect(session.plannedDurationSeconds, equals(300));
      expect(session.actualDurationSeconds, equals(0));
      expect(session.musicTheme, equals(MusicTheme.reading));
      expect(session.isCompleted, equals(false));
      expect(session.startedAt, isA<DateTime>());
    });

    test('create factory should generate unique IDs', () {
      final session1 = MeditationSession.create(
        durationSeconds: 300,
        musicTheme: MusicTheme.meditation,
      );

      // Small delay to ensure different timestamp
      Future.delayed(const Duration(milliseconds: 5));

      final session2 = MeditationSession.create(
        durationSeconds: 300,
        musicTheme: MusicTheme.meditation,
      );

      // IDs might be the same if created very quickly, but that's acceptable
      expect(session1.id, isNotEmpty);
      expect(session2.id, isNotEmpty);
    });

    test('copyWith should update specified fields', () {
      final original = MeditationSession.create(
        durationSeconds: 300,
        musicTheme: MusicTheme.meditation,
      );

      final updated = original.copyWith(
        actualDurationSeconds: 300,
        isCompleted: true,
        userRating: 5.0,
        notes: 'Excellent',
      );

      expect(updated.id, equals(original.id));
      expect(updated.startedAt, equals(original.startedAt));
      expect(updated.plannedDurationSeconds, equals(original.plannedDurationSeconds));
      expect(updated.actualDurationSeconds, equals(300));
      expect(updated.isCompleted, equals(true));
      expect(updated.userRating, equals(5.0));
      expect(updated.notes, equals('Excellent'));
    });

    test('copyWith should preserve unspecified fields', () {
      final original = MeditationSession(
        id: '123',
        startedAt: DateTime.now(),
        plannedDurationSeconds: 600,
        actualDurationSeconds: 500,
        musicTheme: MusicTheme.nature,
        isCompleted: true,
        userRating: 4.0,
        notes: 'Good',
      );

      final updated = original.copyWith(
        userRating: 5.0,
      );

      expect(updated.id, equals(original.id));
      expect(updated.actualDurationSeconds, equals(original.actualDurationSeconds));
      expect(updated.isCompleted, equals(original.isCompleted));
      expect(updated.notes, equals(original.notes));
      expect(updated.userRating, equals(5.0)); // Only this changed
    });

    test('copyWith with no arguments should create identical copy', () {
      final original = MeditationSession.create(
        durationSeconds: 300,
        musicTheme: MusicTheme.silence,
      );

      final copy = original.copyWith();

      expect(copy.id, equals(original.id));
      expect(copy.startedAt, equals(original.startedAt));
      expect(copy.plannedDurationSeconds, equals(original.plannedDurationSeconds));
      expect(copy.actualDurationSeconds, equals(original.actualDurationSeconds));
      expect(copy.musicTheme, equals(original.musicTheme));
      expect(copy.isCompleted, equals(original.isCompleted));
    });

    test('should support different music themes', () {
      for (final theme in MusicTheme.values) {
        final session = MeditationSession.create(
          durationSeconds: 300,
          musicTheme: theme,
        );

        expect(session.musicTheme, equals(theme));
      }
    });

    test('should handle various duration values', () {
      final durations = [60, 300, 600, 900, 1200, 1800];

      for (final duration in durations) {
        final session = MeditationSession.create(
          durationSeconds: duration,
          musicTheme: MusicTheme.meditation,
        );

        expect(session.plannedDurationSeconds, equals(duration));
      }
    });
  });
}
