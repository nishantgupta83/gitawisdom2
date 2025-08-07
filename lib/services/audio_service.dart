import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService._() {
    _player = AudioPlayer()..setLoopMode(LoopMode.all);
  }
  static final AudioService instance = AudioService._();

  late final AudioPlayer _player;
  bool _enabled = true;

  /// Loads the saved “enabled” flag (for now we just return true,
  /// but you could read from Hive or SharedPreferences here).
  Future<bool> loadEnabled() async {
    // TODO: read a persisted value
    return _enabled;
  }

  /// Turn the music on/off and persist if you like
  void setEnabled(bool on) {
    _enabled = on;
    if (!on) {
      _player.pause();
    } else {
      _player.play();
    }
    // TODO: persist _enabled
  }

  /// Kick off playback (you passed `start()` from main)
  Future<void> start() async {
    if (!_enabled) return;
    // point this at an asset in your pubspec (e.g. “assets/audio/Riverside_Morning_Calm.mp3”)
    await _player.setAsset('assets/audio/Riverside_Morning_Calm.mp3');
    _player.play();
  }

  void pause() => _player.pause();
  void stop() => _player.stop();
}
