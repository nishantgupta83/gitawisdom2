// lib/widgets/app_background.dart

import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/ios_performance_optimizer.dart';

/// App background widget - provides unified gradient backgrounds across all screens
/// Replaces image-based backgrounds for better performance and smaller bundle size
class AppBackground extends StatelessWidget {
  final bool isDark;
  final double opacity;
  final bool showAnimatedOrbs;
  final AnimationController? orbController;

  // Pre-cached gradient colors for performance (avoid runtime calculations)
  static const _darkGradientColors = [
    Color(0xFF0D1B2A),
    Color(0xFF1B263B),
    Color(0xFF415A77),
  ];

  static const _lightGradientColors = [
    Color(0xFFF8FAFC),
    Color(0xFFE2E8F0),
    Color(0xFFCBD5E1),
  ];

  // Pre-calculated orb colors with alpha (avoid runtime withValues calls)
  static const _orbColorDarkPrimary = Color(0x1AFF9800); // Orange with alpha ~0.1
  static const _orbColorDarkSecondary = Color(0x0DFF5722); // Deep Orange with alpha ~0.05
  static const _orbColorLightPrimary = Color(0x1A2196F3); // Blue with alpha ~0.1
  static const _orbColorLightSecondary = Color(0x0D3F51B5); // Indigo with alpha ~0.05

  const AppBackground({
    Key? key,
    required this.isDark,
    this.opacity = 1.0,
    this.showAnimatedOrbs = false,
    this.orbController,
  }) : assert(
         !showAnimatedOrbs || orbController != null,
         'orbController must be provided when showAnimatedOrbs is true',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned.fill(
      child: RepaintBoundary( // Isolate gradient repaints from parent widget tree
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? _darkGradientColors : _lightGradientColors,
            ),
          ),
          child: showAnimatedOrbs && orbController != null
              ? RepaintBoundary(child: _buildAnimatedOrbs(size)) // Isolate orb animations
              : null,
        ),
      ),
    );
  }

  /// Build animated background orbs (only for home screen)
  /// Reduced from 5 to 3 orbs for 30-40% less animation overhead
  Widget _buildAnimatedOrbs(Size size) {
    return Stack(
      children: List.generate(3, (index) { // Reduced from 5 to 3 orbs
        return Positioned(
          top: (index * 150.0) % size.height,
          left: (index * 200.0) % size.width,
          child: (Platform.isIOS && IOSPerformanceOptimizer.instance.isProMotionDevice)
              ? _ThrottledAnimatedBuilder(
                  animation: orbController!,
                  targetFps: 60, // Cap at 60fps for battery savings on ProMotion (120Hz displays only)
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        math.sin(orbController!.value * 2 * math.pi + index) * 20,
                        math.cos(orbController!.value * 2 * math.pi + index) * 30,
                      ),
                      child: Container(
                        width: 80 + (index * 20.0),
                        height: 80 + (index * 20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isDark
                                ? [_orbColorDarkPrimary, _orbColorDarkSecondary]
                                : [_orbColorLightPrimary, _orbColorLightSecondary],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : AnimatedBuilder(
                  animation: orbController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        math.sin(orbController!.value * 2 * math.pi + index) * 20,
                        math.cos(orbController!.value * 2 * math.pi + index) * 30,
                      ),
                      child: Container(
                        width: 80 + (index * 20.0),
                        height: 80 + (index * 20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isDark
                                ? [_orbColorDarkPrimary, _orbColorDarkSecondary]
                                : [_orbColorLightPrimary, _orbColorLightSecondary],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      }),
    );
  }
}

/// Throttled AnimatedBuilder that limits rebuild frequency for battery savings
/// Especially important on iOS ProMotion (120Hz) displays
class _ThrottledAnimatedBuilder extends StatefulWidget {
  final Animation<double> animation;
  final int targetFps;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const _ThrottledAnimatedBuilder({
    required this.animation,
    required this.targetFps,
    required this.builder,
    this.child,
  });

  @override
  State<_ThrottledAnimatedBuilder> createState() => _ThrottledAnimatedBuilderState();
}

class _ThrottledAnimatedBuilderState extends State<_ThrottledAnimatedBuilder> {
  int _lastRebuildMs = 0;
  late int _minFrameIntervalMs;

  @override
  void initState() {
    super.initState();
    // Calculate minimum interval between frames (e.g., 60fps = 16.6ms)
    _minFrameIntervalMs = (1000 / widget.targetFps).floor();
    widget.animation.addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationTick);
    super.dispose();
  }

  void _onAnimationTick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - _lastRebuildMs;

    // Only rebuild if enough time has passed since last rebuild
    if (elapsed >= _minFrameIntervalMs) {
      _lastRebuildMs = now;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}