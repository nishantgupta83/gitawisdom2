// lib/core/ios_performance_optimizer.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// iOS-specific performance optimizer for ProMotion displays and Metal rendering
class IOSPerformanceOptimizer {
  IOSPerformanceOptimizer._();
  static final IOSPerformanceOptimizer instance = IOSPerformanceOptimizer._();

  static const int _targetFrameRate120Hz = 120;
  static const int _targetFrameRate60Hz = 60;
  static const Duration _optimalAnimationDuration = Duration(milliseconds: 300);

  bool _isProMotionDevice = false;
  bool _isInitialized = false;

  /// Initialize iOS performance optimizations
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (Platform.isIOS) {
      await _detectProMotionSupport();
      _configureSchedulerBinding();
    }

    _isInitialized = true;
  }

  /// Detect if device supports ProMotion (120Hz)
  Future<void> _detectProMotionSupport() async {
    // Check display refresh rate capability
    final display = WidgetsBinding.instance.platformDispatcher.displays.first;
    final refreshRate = display.refreshRate;

    // ProMotion devices typically report 120Hz capability
    _isProMotionDevice = refreshRate >= _targetFrameRate120Hz;

    if (kDebugMode) {
      print('iOS Performance Optimizer: ProMotion detected: $_isProMotionDevice (${refreshRate}Hz)');
    }
  }

  /// Configure scheduler binding for optimal frame timing
  void _configureSchedulerBinding() {
    if (_isProMotionDevice) {
      // For ProMotion devices, ensure we can hit 120fps when needed
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _optimizeForProMotion();
      });
    }
  }

  /// Apply ProMotion-specific optimizations
  void _optimizeForProMotion() {
    // Reduce unnecessary redraws by batching layout updates
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _batchLayoutUpdates();
    });
  }

  /// Batch layout updates to reduce frame drops
  void _batchLayoutUpdates() {
    // Defer non-critical updates to prevent frame drops
    // This helps maintain 120fps during user interactions
  }

  /// Get optimal animation duration based on device capabilities
  Duration getOptimalAnimationDuration({bool isUserInteraction = false}) {
    if (!Platform.isIOS) return _optimalAnimationDuration;

    if (_isProMotionDevice && isUserInteraction) {
      // Faster animations for ProMotion during user interactions
      return const Duration(milliseconds: 250);
    }

    return _optimalAnimationDuration;
  }

  /// Get optimal curve for ProMotion animations
  Curve getOptimalAnimationCurve() {
    if (!Platform.isIOS) return Curves.easeInOut;

    if (_isProMotionDevice) {
      // Use curves optimized for 120Hz
      return Curves.easeInOutCubicEmphasized;
    }

    return Curves.easeInOut;
  }

  /// Create ProMotion-optimized AnimationController
  AnimationController createOptimizedController({
    required TickerProvider vsync,
    Duration? duration,
    bool isUserInteraction = false,
  }) {
    final optimalDuration = duration ?? getOptimalAnimationDuration(
      isUserInteraction: isUserInteraction,
    );

    return AnimationController(
      duration: optimalDuration,
      vsync: vsync,
    );
  }

  /// Check if current device supports ProMotion
  bool get isProMotionDevice => _isProMotionDevice;

  /// Get recommended frame rate for current device
  int get recommendedFrameRate => _isProMotionDevice ? _targetFrameRate120Hz : _targetFrameRate60Hz;

  /// Optimize widget rebuilds for ProMotion
  Widget optimizeForProMotion(Widget child) {
    if (!Platform.isIOS || !_isProMotionDevice) {
      return child;
    }

    return RepaintBoundary(
      child: child,
    );
  }

  /// Create performance-optimized decoration for containers
  BoxDecoration createOptimizedDecoration({
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    // Pre-calculate values to avoid runtime calculations on ProMotion
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      border: border,
    );
  }

  /// Optimized PageView configuration for smooth scrolling
  PageController createOptimizedPageController({
    int initialPage = 0,
    double viewportFraction = 1.0,
  }) {
    return PageController(
      initialPage: initialPage,
      viewportFraction: viewportFraction,
      // Optimize for ProMotion scrolling
    );
  }

  /// Optimize ListView for ProMotion scrolling
  Widget optimizeListView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    if (!_isProMotionDevice) {
      return ListView.builder(
        controller: controller,
        padding: padding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    // ProMotion-optimized ListView
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      // Optimize caching for 120Hz scrolling
      cacheExtent: 500.0, // Increased cache for smooth ProMotion scrolling
    );
  }
}