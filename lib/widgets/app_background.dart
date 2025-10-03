// lib/widgets/app_background.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// App background widget - provides unified gradient backgrounds across all screens
/// Replaces image-based backgrounds for better performance and smaller bundle size
class AppBackground extends StatelessWidget {
  final bool isDark;
  final double opacity;
  final bool showAnimatedOrbs;
  final AnimationController? orbController;

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
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D1B2A),
                    const Color(0xFF1B263B),
                    const Color(0xFF415A77),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E1),
                  ],
          ),
        ),
        child: showAnimatedOrbs && orbController != null
            ? _buildAnimatedOrbs(size)
            : null,
      ),
    );
  }

  /// Build animated background orbs (only for home screen)
  Widget _buildAnimatedOrbs(Size size) {
    return Stack(
      children: List.generate(5, (index) {
        return Positioned(
          top: (index * 150.0) % size.height,
          left: (index * 200.0) % size.width,
          child: AnimatedBuilder(
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
                      colors: [
                        (isDark ? Colors.orange : Colors.blue).withValues(alpha: 0.1),
                        (isDark ? Colors.deepOrange : Colors.indigo).withValues(alpha: 0.05),
                      ],
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