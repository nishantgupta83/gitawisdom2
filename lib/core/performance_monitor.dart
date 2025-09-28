// lib/core/performance_monitor.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utility to detect and prevent UI hangs
/// Monitors frame rendering, memory usage, and operation timing
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  static PerformanceMonitor get instance => _instance;

  bool _isInitialized = false;
  Timer? _monitoringTimer;
  List<Duration> _frameRenderTimes = [];
  int _skippedFrameCount = 0;
  
  // Performance thresholds
  static const Duration _frameTimeWarning = Duration(milliseconds: 32); // 2 frames at 60fps
  static const Duration _frameTimeCritical = Duration(milliseconds: 100); // 6 frames
  static const int _maxFrameHistory = 100;

  /// Initialize performance monitoring
  void initialize() {
    if (_isInitialized || !kDebugMode) return;

    _isInitialized = true;
    
    // Monitor frame rendering performance
    SchedulerBinding.instance.addTimingsCallback(_onFrameRendered);
    
    // Start periodic performance monitoring
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _analyzePerformance();
    });

    if (kDebugMode) {
      debugPrint('🚀 Performance monitor initialized');
    }
  }

  /// Dispose performance monitoring
  void dispose() {
    if (!_isInitialized) return;

    SchedulerBinding.instance.removeTimingsCallback(_onFrameRendered);
    _monitoringTimer?.cancel();
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('🚀 Performance monitor disposed');
    }
  }

  /// Monitor frame rendering times
  void _onFrameRendered(List<FrameTiming> timings) {
    if (!_isInitialized) return;

    for (final timing in timings) {
      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;
      final totalFrameTime = buildDuration + rasterDuration;

      _frameRenderTimes.add(totalFrameTime);
      
      // Keep only recent frame history
      if (_frameRenderTimes.length > _maxFrameHistory) {
        _frameRenderTimes.removeAt(0);
      }

      // Check for problematic frames
      if (totalFrameTime > _frameTimeCritical) {
        _skippedFrameCount++;
        if (kDebugMode) {
          debugPrint('⚠️ CRITICAL: Frame took ${totalFrameTime.inMilliseconds}ms to render');
        }
      } else if (totalFrameTime > _frameTimeWarning) {
        if (kDebugMode) {
          debugPrint('⚠️ WARNING: Slow frame ${totalFrameTime.inMilliseconds}ms');
        }
      }
    }
  }

  /// Analyze overall performance metrics
  void _analyzePerformance() {
    if (_frameRenderTimes.isEmpty) return;

    final totalFrames = _frameRenderTimes.length;
    final averageFrameTime = _frameRenderTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b) / totalFrames;
    
    final maxFrameTime = _frameRenderTimes
        .reduce((a, b) => a > b ? a : b);

    final averageMs = averageFrameTime / 1000;
    final maxMs = maxFrameTime.inMilliseconds;

    if (kDebugMode) {
      debugPrint('🚀 Performance Summary:');
      debugPrint('   Average frame time: ${averageMs.toStringAsFixed(1)}ms');
      debugPrint('   Max frame time: ${maxMs}ms');
      debugPrint('   Critical frames: $_skippedFrameCount/$totalFrames');
      
      if (_skippedFrameCount > totalFrames * 0.1) {
        debugPrint('⚠️ HIGH FRAME DROP RATE: ${(_skippedFrameCount/totalFrames*100).toStringAsFixed(1)}%');
      }
    }

    // Reset counters for next period
    _skippedFrameCount = 0;
    _frameRenderTimes.clear();
  }

  /// Time an operation and warn if it takes too long
  static Future<T> timeOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration warningThreshold = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      if (stopwatch.elapsed > warningThreshold) {
        if (kDebugMode) {
          debugPrint('⏱️ SLOW OPERATION: $operationName took ${stopwatch.elapsedMilliseconds}ms');
        }
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('❌ FAILED OPERATION: $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    }
  }


  /// Get current performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    if (_frameRenderTimes.isEmpty) {
      return {'status': 'No data available'};
    }

    final totalFrames = _frameRenderTimes.length;
    final averageFrameTime = _frameRenderTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b) / totalFrames;
    
    return {
      'average_frame_time_ms': (averageFrameTime / 1000).round(),
      'total_frames_monitored': totalFrames,
      'critical_frames': _skippedFrameCount,
      'frame_drop_percentage': ((_skippedFrameCount / totalFrames) * 100).round(),
      'performance_status': _getPerformanceStatus(averageFrameTime / 1000),
    };
  }

  String _getPerformanceStatus(double averageMs) {
    if (averageMs < 16) return 'Excellent (60+ FPS)';
    if (averageMs < 33) return 'Good (30+ FPS)';
    if (averageMs < 50) return 'Fair (20+ FPS)';
    return 'Poor (<20 FPS)';
  }
}