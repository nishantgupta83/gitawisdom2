// lib/services/background_music_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/simple_meditation.dart' show MusicTheme;

/// Service for handling background ambient music during reading and meditation
/// Separate from narration for independent control and audio ducking
class BackgroundMusicService extends ChangeNotifier {
  static final BackgroundMusicService _instance = BackgroundMusicService._internal();
  factory BackgroundMusicService() => _instance;
  BackgroundMusicService._internal();

  static BackgroundMusicService get instance => _instance;

  AudioPlayer? _player;
  bool _isInitialized = false;
  bool _isInitializing = false; // Lock to prevent concurrent initialization
  bool _isEnabled = true;
  bool _isPlaying = false;
  double _volume = 0.3; // Lower volume for background music
  double _duckingVolume = 0.1; // Volume when narration is playing
  bool _isDucking = false;

  MusicTheme _currentTheme = MusicTheme.meditation;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get isDucking => _isDucking;
  MusicTheme get currentTheme => _currentTheme;

  /// Initialize the background music service
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_isInitializing) {
      final startTime = DateTime.now().millisecondsSinceEpoch;
      const timeoutMs = 5000;

      while (_isInitializing && !_isInitialized) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
        if (elapsed >= timeoutMs) {
          debugPrint('❌ Background music initialization timed out after ${timeoutMs}ms');
          _isInitializing = false;
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;
    try {
      if (Platform.isIOS) {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ));
      }

      _player = AudioPlayer();

      // Set up audio session for background music
      await _player!.setLoopMode(LoopMode.all);
      await _player!.setVolume(_volume);
      
      // Set up state listeners
      _player!.playingStream.listen((playing) {
        if (_isPlaying != playing) {
          _isPlaying = playing;
          notifyListeners();
        }
      });

      _player!.playerStateStream.listen((playerState) {
        // Monitor state changes without logging
      });

      // Handle audio interruptions (phone calls, Siri, alarms) - iOS requirement
      if (Platform.isIOS) {
        final session = await AudioSession.instance;

        session.interruptionEventStream.listen((event) {
          if (event.begin) {
            pauseMusic();
          } else {
            if (_isEnabled && !_isPlaying) {
              resumeMusic();
            }
          }
        });

        session.becomingNoisyEventStream.listen((_) {
          pauseMusic();
        });
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to initialize BackgroundMusicService: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// Start playing background music for the current theme
  Future<void> startMusic() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isEnabled || _currentTheme == MusicTheme.silence) {
      return;
    }

    try {
      await _playThemeMusic(_currentTheme);
    } catch (e) {
      debugPrint('❌ Failed to start background music: $e');
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    if (_player != null) {
      await _player!.stop();
    }
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    if (_player != null && _isPlaying) {
      await _player!.pause();
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (_player != null && !_isPlaying && _isEnabled) {
      await _player!.play();
    }
  }

  /// Enable or disable background music
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (enabled) {
      await startMusic();
    } else {
      await stopMusic();
    }
    notifyListeners();
  }

  /// Set background music volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_player != null) {
      final actualVolume = _isDucking ? _duckingVolume : _volume;
      await _player!.setVolume(actualVolume);
    }
    notifyListeners();
  }

  /// Duck audio (lower volume) when narration is playing
  Future<void> duck() async {
    if (_player != null && !_isDucking) {
      _isDucking = true;
      await _player!.setVolume(_duckingVolume);
      notifyListeners();
    }
  }

  /// Unduck audio (restore volume) when narration stops
  Future<void> unduck() async {
    if (_player != null && _isDucking) {
      _isDucking = false;
      await _player!.setVolume(_volume);
      notifyListeners();
    }
  }

  /// Change music theme
  Future<void> setTheme(MusicTheme theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    if (_isEnabled && _isPlaying) {
      await stopMusic();
      await startMusic();
    }
    notifyListeners();
  }

  /// Get theme display name
  String getThemeName(MusicTheme theme) {
    switch (theme) {
      case MusicTheme.meditation:
        return 'Meditation';
      case MusicTheme.reading:
        return 'Reading';
      case MusicTheme.nature:
        return 'Nature';
      case MusicTheme.silence:
        return 'Silence';
    }
  }

  /// Get all available themes
  List<MusicTheme> get availableThemes => MusicTheme.values;

  /// Play music for specific theme
  Future<void> _playThemeMusic(MusicTheme theme) async {
    if (_player == null) return;

    try {
      String? assetPath;
      
      // Map themes to audio files
      switch (theme) {
        case MusicTheme.meditation:
          assetPath = 'assets/audio/Riverside_Morning_Calm.mp3';
          break;
        case MusicTheme.reading:
          assetPath = 'assets/audio/Riverside_Morning_Calm.mp3'; // Same file for now
          break;
        case MusicTheme.nature:
          assetPath = 'assets/audio/Riverside_Morning_Calm.mp3'; // Same file for now
          break;
        case MusicTheme.silence:
          await _player!.stop();
          return;
      }
      
      if (assetPath != null) {
        await _player!.setAsset(assetPath);
        await _player!.play();
      }
    } catch (e) {
      debugPrint('❌ Failed to play theme music: $e');
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    // Stop and dispose player first
    if (_player != null) {
      await _player!.stop();
      await _player!.dispose();
    }

    if (Platform.isIOS && _isInitialized) {
      try {
        final session = await AudioSession.instance;
        await session.setActive(false);
      } catch (e) {
        debugPrint('⚠️ AVAudioSession deactivation error: $e');
      }
    }

    _isInitialized = false;
    super.dispose();
  }
}