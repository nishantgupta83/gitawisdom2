import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive/hive.dart';
import 'settings_service.dart';

class AudioService {
  AudioService._() {
    _player = AudioPlayer()..setLoopMode(LoopMode.all);
  }
  static final AudioService instance = AudioService._();

  late final AudioPlayer _player;
  bool _enabled = true;
  bool _isInitialized = false;

  /// Loads the saved "enabled" flag from Hive settings
  Future<bool> loadEnabled() async {
    try {
      final box = Hive.box(SettingsService.boxName);
      _enabled = box.get(SettingsService.musicKey, defaultValue: true) as bool;
      return _enabled;
    } catch (e) {
      return true; // Default to enabled if there's an error
    }
  }

  /// Turn the music on/off and persist the setting
  void setEnabled(bool on) {
    _enabled = on;
    
    // Persist the setting
    try {
      final box = Hive.box(SettingsService.boxName);
      box.put(SettingsService.musicKey, on);
    } catch (e) {
      debugPrint('Error saving music setting: $e');
    }
    
    // Control playback
    if (!on) {
      _player.pause();
    } else if (_isInitialized) {
      _player.play();
    } else if (on) {
      // If music is turned on but not initialized, initialize it
      start().catchError((e) {
        debugPrint('Error starting audio from toggle: $e');
      });
    }
  }

  /// Kick off playbook (you passed `start()` from main)
  Future<void> start() async {
    try {
      // Load current setting before starting
      await loadEnabled();
      
      if (!_enabled) {
        debugPrint('🔇 Audio is disabled, not starting');
        return;
      }
      
      if (_isInitialized) {
        debugPrint('🎵 Audio already initialized, resuming playback');
        await _player.play();
        return;
      }
      
      debugPrint('🎵 Initializing audio player...');
      // point this at an asset in your pubspec (e.g. "assets/audio/Riverside_Morning_Calm.mp3")
      await _player.setAsset('assets/audio/Riverside_Morning_Calm.mp3');
      _isInitialized = true;
      debugPrint('🎵 Audio player initialized, starting playback');
      await _player.play();
      debugPrint('🎵 Audio playback started successfully');
    } catch (e) {
      debugPrint('❌ Error starting audio: $e');
      _isInitialized = false;
    }
  }

  void pause() => _player.pause();
  void stop() => _player.stop();
  
  bool get isPlaying => _player.playing;
  bool get isEnabled => _enabled;
  bool get isInitialized => _isInitialized;
}
