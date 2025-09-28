import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'background_music_service.dart';

class AppLifecycleManager with WidgetsBindingObserver {
  AppLifecycleManager._();
  static final AppLifecycleManager instance = AppLifecycleManager._();

  bool _isInitialized = false;
  bool _wasMusicPlayingBeforeBackground = false;
  bool _shouldResumeMusic = false;
  Timer? _resumeTimer;

  Timer? _lifecycleDebounceTimer;
  AppLifecycleState? _lastProcessedState;
  static const Duration _lifecycleDebounceDelay = Duration(milliseconds: 1000);

  void initialize() {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    debugPrint('🎵 AppLifecycleManager initialized');
  }

  void dispose() {
    if (!_isInitialized) return;

    _resumeTimer?.cancel();
    _lifecycleDebounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    debugPrint('🎵 AppLifecycleManager disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lastProcessedState == state) {
      return;
    }

    _lifecycleDebounceTimer?.cancel();
    _lifecycleDebounceTimer = Timer(_lifecycleDebounceDelay, () {
      _lastProcessedState = state;
      debugPrint('🎵 App lifecycle changed to: $state');

      switch (state) {
        case AppLifecycleState.resumed:
          _onAppResumed();
          break;
        case AppLifecycleState.paused:
          _onAppPaused();
          break;
        case AppLifecycleState.detached:
          _onAppDetached();
          break;
        default:
          break;
      }
    });
  }

  void _onAppResumed() {
    debugPrint('🎵 App resumed - checking resume state');
    debugPrint('🎵 Should resume: $_shouldResumeMusic');

    _resumeTimer?.cancel();

    if (_shouldResumeMusic) {
      _resumeTimer = Timer(const Duration(milliseconds: 500), () async {
        try {
          debugPrint('🎵 Attempting to resume music...');
          await BackgroundMusicService.instance.resumeMusic();
          debugPrint('✅ Music resumed successfully');
        } catch (e) {
          debugPrint('❌ Failed to resume music: $e');
        }
      });
    } else {
      debugPrint('🎵 Not resuming music');
    }
  }

  void _onAppPaused() {
    debugPrint('🎵 App paused - checking music state');

    _resumeTimer?.cancel();

    _wasMusicPlayingBeforeBackground = BackgroundMusicService.instance.isPlaying;
    debugPrint('🎵 Music was playing before background: $_wasMusicPlayingBeforeBackground');

    _shouldResumeMusic = _wasMusicPlayingBeforeBackground && BackgroundMusicService.instance.isEnabled;
    debugPrint('🎵 Should resume music when returning: $_shouldResumeMusic');

    if (_wasMusicPlayingBeforeBackground) {
      debugPrint('🎵 Pausing music due to app backgrounding');
      BackgroundMusicService.instance.pauseMusic();
    }
  }

  void _onAppDetached() {
    debugPrint('🎵 App detached - stopping music');
    _resumeTimer?.cancel();
    _shouldResumeMusic = false;
    _wasMusicPlayingBeforeBackground = false;
    BackgroundMusicService.instance.stopMusic();
  }

  void clearResumeState() {
    debugPrint('🎵 Manually clearing resume state');
    _resumeTimer?.cancel();
    _shouldResumeMusic = false;
    _wasMusicPlayingBeforeBackground = false;
  }

  bool get shouldResumeMusic => _shouldResumeMusic;
  bool get wasMusicPlayingBeforeBackground => _wasMusicPlayingBeforeBackground;
}