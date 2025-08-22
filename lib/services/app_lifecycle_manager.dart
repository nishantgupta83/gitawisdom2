import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'audio_service.dart';

/// Manages app lifecycle events to control background music playback.
/// Pauses music when app goes to background and resumes when returning to foreground.
class AppLifecycleManager with WidgetsBindingObserver {
  AppLifecycleManager._();
  static final AppLifecycleManager instance = AppLifecycleManager._();

  bool _isInitialized = false;
  bool _wasMusicPlayingBeforeBackground = false;
  bool _shouldResumeMusic = false;
  Timer? _resumeTimer;

  /// Initialize the lifecycle manager
  void initialize() {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    debugPrint('🎵 AppLifecycleManager initialized');
  }

  /// Dispose the lifecycle manager
  void dispose() {
    if (!_isInitialized) return;
    
    _resumeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    debugPrint('🎵 AppLifecycleManager disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('🎵 App lifecycle state changed: $state (Platform: ${Platform.operatingSystem})');
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        // App is transitioning - don't take action yet
        debugPrint('🎵 App inactive - no action taken');
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        debugPrint('🎵 App hidden - treating as paused');
        _onAppPaused();
        break;
    }
  }

  /// Handle app resuming to foreground
  void _onAppResumed() {
    debugPrint('🎵 App resumed - checking music state');
    debugPrint('🎵 Should resume: $_shouldResumeMusic, Audio enabled: ${AudioService.instance.isEnabled}');
    
    // Cancel any pending resume timer
    _resumeTimer?.cancel();
    
    // Only resume music if it should be resumed and the user still has music enabled
    if (_shouldResumeMusic && AudioService.instance.isEnabled) {
      debugPrint('🎵 Attempting to resume music playback');
      
      // iOS may need a small delay to properly resume audio
      final delay = Platform.isIOS ? 500 : 100;
      
      _resumeTimer = Timer(Duration(milliseconds: delay), () async {
        try {
          await AudioService.instance.start();
          debugPrint('🎵 Music resumed successfully');
          // Clear the should resume flag only after successful resume
          _shouldResumeMusic = false;
        } catch (e) {
          debugPrint('❌ Error resuming audio: $e');
          // Keep the flag set so we can try again if user manually toggles
        }
      });
    } else {
      debugPrint('🎵 Music resume not needed or disabled');
      // Clear flags even if not resuming
      _shouldResumeMusic = false;
      _wasMusicPlayingBeforeBackground = false;
    }
  }

  /// Handle app going to background or being minimized
  void _onAppPaused() {
    debugPrint('🎵 App paused - checking music state');
    
    // Cancel any pending resume timer
    _resumeTimer?.cancel();
    
    // Remember if music was playing before pausing
    _wasMusicPlayingBeforeBackground = AudioService.instance.isPlaying;
    debugPrint('🎵 Music was playing before background: $_wasMusicPlayingBeforeBackground');
    
    // Set resume flag if music was playing AND music is enabled
    _shouldResumeMusic = _wasMusicPlayingBeforeBackground && AudioService.instance.isEnabled;
    debugPrint('🎵 Should resume music when returning: $_shouldResumeMusic');
    
    // Pause music to be respectful of system resources and user experience
    if (_wasMusicPlayingBeforeBackground) {
      debugPrint('🎵 Pausing music due to app backgrounding');
      AudioService.instance.pause();
    }
  }

  /// Handle app being terminated
  void _onAppDetached() {
    debugPrint('🎵 App detached - stopping music');
    _resumeTimer?.cancel();
    _shouldResumeMusic = false;
    _wasMusicPlayingBeforeBackground = false;
    AudioService.instance.stop();
  }

  /// Manually clear the resume state (useful when user manually changes music settings)
  void clearResumeState() {
    debugPrint('🎵 Manually clearing resume state');
    _resumeTimer?.cancel();
    _shouldResumeMusic = false;
    _wasMusicPlayingBeforeBackground = false;
  }

  /// Get the current state for debugging/UI synchronization
  bool get shouldResumeMusic => _shouldResumeMusic;
  bool get wasMusicPlayingBeforeBackground => _wasMusicPlayingBeforeBackground;
}