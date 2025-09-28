// ios_optimization_template.dart
// Copy this template to any Flutter project for instant iOS optimizations

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Complete iOS Optimization Suite
/// Drop-in solution for Flutter apps targeting iOS devices
class IOSOptimizationSuite {
  static IOSOptimizationSuite? _instance;
  static IOSOptimizationSuite get instance => _instance ??= IOSOptimizationSuite._();
  IOSOptimizationSuite._();

  bool _isInitialized = false;
  bool _isProMotionDevice = false;
  bool _isMetalSupported = false;

  /// Initialize all iOS optimizations
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isIOS) return;

    await _detectDeviceCapabilities();
    _isInitialized = true;

    if (kDebugMode) {
      print('🍎 iOS Optimization Suite initialized');
      print('📱 ProMotion: $_isProMotionDevice');
      print('🎨 Metal: $_isMetalSupported');
    }
  }

  Future<void> _detectDeviceCapabilities() async {
    try {
      final display = WidgetsBinding.instance.platformDispatcher.displays.first;
      _isProMotionDevice = display.refreshRate >= 120;
      _isMetalSupported = Platform.isIOS; // iOS 8+ supports Metal
    } catch (e) {
      if (kDebugMode) print('Device detection error: $e');
    }
  }

  /// Get optimal animation duration based on device
  Duration getOptimalAnimationDuration({bool isUserInteraction = false}) {
    if (!Platform.isIOS) return const Duration(milliseconds: 300);

    if (_isProMotionDevice && isUserInteraction) {
      return const Duration(milliseconds: 250); // Faster for 120Hz
    }
    return const Duration(milliseconds: 300);
  }

  /// Get optimal animation curve for iOS
  Curve getOptimalAnimationCurve() {
    if (!Platform.isIOS) return Curves.easeInOut;
    return _isProMotionDevice ? Curves.easeInOutCubicEmphasized : Curves.easeInOut;
  }

  /// Create optimized ListView for iOS
  Widget createOptimizedListView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    ScrollController? controller,
    EdgeInsets? padding,
    ScrollPhysics? physics,
  }) {
    if (!Platform.isIOS) {
      return ListView.builder(
        controller: controller,
        padding: padding,
        physics: physics,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      cacheExtent: _isProMotionDevice ? 600.0 : 300.0,
    );
  }

  /// Create optimized Container for iOS
  Widget createOptimizedContainer({
    required Widget child,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    Border? border,
    double? width,
    double? height,
  }) {
    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        border: border,
      ),
      child: child,
    );

    return Platform.isIOS ? RepaintBoundary(child: container) : container;
  }

  /// Create optimized shadows for iOS
  List<BoxShadow> createOptimizedShadows({
    required Color color,
    double blurRadius = 4.0,
    Offset offset = const Offset(0, 2),
    double spreadRadius = 0.0,
    bool isElevated = false,
  }) {
    if (!_isMetalSupported) {
      return [
        BoxShadow(
          color: color,
          blurRadius: blurRadius,
          offset: offset,
          spreadRadius: spreadRadius,
        ),
      ];
    }

    // Metal-optimized shadows
    if (isElevated) {
      return [
        BoxShadow(
          color: Color.fromARGB((0.25 * 255).round(), color.red, color.green, color.blue),
          blurRadius: blurRadius * 2,
          offset: Offset(offset.dx, offset.dy * 2),
          spreadRadius: 0,
          blurStyle: BlurStyle.normal,
        ),
        BoxShadow(
          color: Color.fromARGB((0.12 * 255).round(), color.red, color.green, color.blue),
          blurRadius: blurRadius,
          offset: offset,
          spreadRadius: spreadRadius,
          blurStyle: BlurStyle.normal,
        ),
      ];
    }

    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
        blurStyle: BlurStyle.normal,
      ),
    ];
  }

  /// Optimize widget for iOS rendering
  Widget optimizeForIOS(Widget child) {
    if (!Platform.isIOS) return child;

    return RepaintBoundary(
      child: ClipRect(child: child),
    );
  }

  /// Check device capabilities
  bool get isProMotionDevice => _isProMotionDevice;
  bool get isMetalSupported => _isMetalSupported;
  bool get isInitialized => _isInitialized;
}

/// Easy-to-use extension for any Widget
extension IOSOptimized on Widget {
  Widget optimizeForIOS() {
    return IOSOptimizationSuite.instance.optimizeForIOS(this);
  }
}

/// Usage Example:
///
/// 1. Initialize in main():
/// await IOSOptimizationSuite.instance.initialize();
///
/// 2. Use optimized widgets:
/// IOSOptimizationSuite.instance.createOptimizedListView(...)
///
/// 3. Use extension:
/// MyWidget().optimizeForIOS()