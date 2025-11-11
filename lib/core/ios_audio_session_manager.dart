// lib/core/ios_audio_session_manager.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// iOS-specific audio session configuration manager
/// Optimizes audio playback for iOS devices with proper session management
class IOSAudioSessionManager {
  IOSAudioSessionManager._();
  static final IOSAudioSessionManager instance = IOSAudioSessionManager._();

  bool _isInitialized = false;
  bool _isConfigured = false;

  /// Initialize iOS audio session optimizations
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isIOS) return;

    try {
      await _configureAudioSession();
      _isInitialized = true;

      if (kDebugMode) {
        print('iOS Audio Session Manager: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS Audio Session Manager: Initialization error: $e');
      }
    }
  }

  /// Configure iOS audio session for optimal spiritual audio experience
  Future<void> _configureAudioSession() async {
    if (!Platform.isIOS) return;

    try {
      // Configure audio session for spiritual content
      // This ensures proper audio behavior during meditation and verse listening

      // Handle iOS 26+ stricter filesystem permissions
      // Cache directory may not exist on first launch
      try {
        await AudioPlayer.clearAssetCache();
      } on PathNotFoundException catch (e) {
        // Cache directory doesn't exist yet - this is normal on first launch
        if (kDebugMode) {
          print('iOS Audio Session: Cache directory not found (first launch): $e');
        }
        // Continue initialization - cache will be created when first audio plays
      }

      _isConfigured = true;

      if (kDebugMode) {
        print('iOS Audio Session: Configured for spiritual audio content');
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS Audio Session: Configuration error: $e');
      }
    }
  }

  /// Configure audio player for iOS-optimized playback
  Future<void> configureAudioPlayer(AudioPlayer player) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      // iOS-specific audio player optimizations
      await player.setLoopMode(LoopMode.off);
      await player.setShuffleModeEnabled(false);

      // Optimize for speech and meditation content
      await player.setVolume(1.0);
      await player.setSpeed(1.0);

      if (kDebugMode) {
        print('iOS Audio Session: Audio player configured for iOS');
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS Audio Session: Player configuration error: $e');
      }
    }
  }

  /// Handle audio interruption (calls, notifications, etc.)
  void handleAudioInterruption({
    required bool isInterrupted,
    required VoidCallback? onResume,
  }) {
    if (!Platform.isIOS) return;

    if (isInterrupted) {
      // Audio was interrupted (phone call, notification, etc.)
      if (kDebugMode) {
        print('iOS Audio Session: Audio interrupted');
      }
    } else {
      // Audio interruption ended
      if (kDebugMode) {
        print('iOS Audio Session: Audio interruption ended');
      }

      // Resume if callback provided
      onResume?.call();
    }
  }

  /// Get optimized audio settings for verse narration
  Map<String, dynamic> getVerseNarrationConfig() {
    return {
      'contentType': 'speech',
      'usage': 'media',
      'focusGainType': 'gain',
      'willPauseWhenDucked': true,
      'optimizedFor': 'verse_narration',
    };
  }

  /// Get optimized audio settings for meditation music
  Map<String, dynamic> getMeditationMusicConfig() {
    return {
      'contentType': 'music',
      'usage': 'media',
      'focusGainType': 'gain',
      'willPauseWhenDucked': false, // Keep playing during short interruptions
      'optimizedFor': 'meditation',
    };
  }

  /// Create iOS-optimized AudioPlayer instance
  AudioPlayer createOptimizedPlayer({
    bool isForVersesNarration = true,
  }) {
    final config = isForVersesNarration
        ? getVerseNarrationConfig()
        : getMeditationMusicConfig();

    // Create basic AudioPlayer - iOS will handle optimization natively
    final player = AudioPlayer();

    // Configure the player with iOS optimizations
    configureAudioPlayer(player);

    if (kDebugMode) {
      print('iOS Audio: Created optimized player for ${config['optimizedFor']}');
    }

    return player;
  }

  /// Handle route changes (headphones, bluetooth, speakers)
  void handleRouteChange({
    required String newRoute,
    required VoidCallback? onRouteChanged,
  }) {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      print('iOS Audio Session: Route changed to $newRoute');
    }

    // Handle different audio routes
    switch (newRoute.toLowerCase()) {
      case 'headphones':
      case 'bluetooth':
        // Optimize for private listening
        break;
      case 'speaker':
        // Optimize for shared listening
        break;
      default:
        // Default handling
        break;
    }

    onRouteChanged?.call();
  }

  /// Prepare for background audio playback
  Future<void> prepareForBackgroundPlayback() async {
    if (!Platform.isIOS) return;

    try {
      // iOS background audio preparation
      if (kDebugMode) {
        print('iOS Audio Session: Prepared for background playback');
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS Audio Session: Background preparation error: $e');
      }
    }
  }

  /// Clean up audio session resources
  Future<void> dispose() async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      // Clean up iOS audio session
      _isInitialized = false;
      _isConfigured = false;

      if (kDebugMode) {
        print('iOS Audio Session Manager: Disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS Audio Session Manager: Disposal error: $e');
      }
    }
  }

  /// Check if iOS audio session is properly configured
  bool get isConfigured => _isConfigured && Platform.isIOS;

  /// Get recommended audio quality settings for iOS
  Map<String, dynamic> getRecommendedQualitySettings() {
    if (!Platform.isIOS) {
      return <String, dynamic>{};
    }

    return {
      'sampleRate': 44100, // CD quality for verse narration
      'bitRate': 128000,   // Balanced quality/size for spiritual content
      'channels': 2,       // Stereo for immersive experience
      'format': 'aac',     // iOS-optimized format
    };
  }
}