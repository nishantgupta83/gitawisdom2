// lib/widgets/modern_nav_bar.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/accessible_colors.dart';
import '../core/ios_performance_optimizer.dart';

/// Pulsating animation wrapper for navigation icons with color animation
class PulsatingIcon extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? glowColor;
  final ValueChanged<Color>? onColorChanged;

  const PulsatingIcon({
    required this.child,
    this.enabled = true,
    this.glowColor,
    this.onColorChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<PulsatingIcon> createState() => _PulsatingIconState();
}

class _PulsatingIconState extends State<PulsatingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Animate glow color from 60% opacity to 85% opacity for pulsating effect
    _colorAnimation = ColorTween(
      begin: const Color(0xFF9C27B0).withValues(alpha: 0.6),
      end: const Color(0xFF9C27B0).withValues(alpha: 0.85),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }

    // Notify parent of color changes
    if (widget.onColorChanged != null) {
      _controller.addListener(() {
        if (_colorAnimation.value != null) {
          widget.onColorChanged!(_colorAnimation.value!);
        }
      });
    }
  }

  @override
  void didUpdateWidget(PulsatingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Pulsating icon with animated glow effect
class _PulsatingGlowIcon extends StatefulWidget {
  final bool isSelected;
  final double iconSize;
  final Color? iconColor;
  final IconData icon;

  const _PulsatingGlowIcon({
    required this.isSelected,
    required this.iconSize,
    required this.iconColor,
    required this.icon,
  });

  @override
  State<_PulsatingGlowIcon> createState() => _PulsatingGlowIconState();
}

class _PulsatingGlowIconState extends State<_PulsatingGlowIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Animate glow color from 60% opacity to 85% opacity
    _colorAnimation = ColorTween(
      begin: const Color(0xFF9C27B0).withValues(alpha: 0.6),
      end: const Color(0xFF9C27B0).withValues(alpha: 0.85),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Animate blur radius from 17.6 to 22 for pulsating effect (10% increase from base 16 to 17.6)
    _blurAnimation = Tween<double>(begin: 17.6, end: 22.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(widget.isSelected ? 2 : 1),
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: _colorAnimation.value ?? const Color(0xFF9C27B0).withValues(alpha: 0.6),
                blurRadius: _blurAnimation.value,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.icon,
              key: ValueKey('${widget.icon}_${widget.isSelected}'),
              size: widget.iconSize,
              color: widget.iconColor,
            ),
          ),
        );
      },
    );
  }
}

/// A modern navigation bar item
class ModernNavBarItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Color? color;

  const ModernNavBarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.color,
  });
}

/// Modern bottom navigation bar with smooth animations and design
class ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ModernNavBarItem> items;
  final Color? backgroundColor;
  final double? height;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;

  const ModernNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.height,
    this.margin,
    this.borderRadius,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Responsive design
    final isTablet = media.size.width > 600;
    final effectiveHeight = height ?? (isTablet ? 80 : 72);
    final effectiveMargin = margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 12);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(24);

    // Platform-optimized blur settings
    final bool enableBlur = Platform.isIOS; // Only enable glassmorphism on iOS

    // Build nav bar content
    Widget navBarContent = Container(
      decoration: BoxDecoration(
        color: enableBlur
            ? (isDark ? const Color(0x99000000) : const Color(0xCCFFFFFF)) // iOS: 60% dark, 80% light
            : (isDark ? const Color(0xDD000000) : const Color(0xF0FFFFFF)), // Android: 87% dark, 94% light
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: List.generate(items.length, (index) {
                return Flexible(
                  flex: 1,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth / items.length,
                      minHeight: 44, // Ensure minimum touch target
                    ),
                    child: _buildNavItem(
                      context,
                      items[index],
                      index,
                      currentIndex == index,
                      isDark,
                      isTablet,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );

    // Apply blur only on iOS for glassmorphism effect
    if (enableBlur) {
      navBarContent = ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: navBarContent,
        ),
      );
    } else {
      navBarContent = ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: navBarContent,
      );
    }

    return SafeArea(
      child: Container(
        margin: effectiveMargin,
        height: effectiveHeight,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          boxShadow: enableBlur
              ? [
                  // iOS: Dual shadows for depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, -6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  // Android: Single optimized shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: navBarContent,
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    ModernNavBarItem item,
    int index,
    bool isSelected,
    bool isDark,
    bool isTablet,
  ) {
    final theme = Theme.of(context);

    // Modern color scheme
    final primaryColor = item.color ?? theme.colorScheme.primary;
    final selectedColor = isSelected ? primaryColor : null;
    final iconColor = isSelected
        ? selectedColor
        : AccessibleColors.getSecondaryTextColor(context);
    final textColor = isSelected
        ? selectedColor
        : AccessibleColors.getSecondaryTextColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 12 : 10,
            horizontal: 2,
          ),
          constraints: BoxConstraints(
            minHeight: 44, // Ensure minimum 44dp touch target
            maxHeight: isTablet ? 80 : 72, // Prevent overflow
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive sizing based on available width
              final iconSize = math.min(
                isSelected ? 30.0 : 28.0,
                constraints.maxWidth * 0.4, // Max 40% of width
              ).toDouble();
              final fontSize = math.min(
                isSelected ? 12.0 : 11.0,
                constraints.maxWidth * 0.15, // Scale with width
              ).toDouble();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animated glow for Dilemmas tab (formerly Scenarios/Situations)
                  if (item.label == 'Dilemmas' || item.label == 'Scenarios')
                    _PulsatingGlowIcon(
                      isSelected: isSelected,
                      iconSize: iconSize,
                      iconColor: iconColor,
                      icon: isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                    )
                  else
                    // Regular icon for other tabs
                    AnimatedContainer(
                      duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(isUserInteraction: true),
                      curve: IOSPerformanceOptimizer.instance.getOptimalAnimationCurve(),
                      padding: EdgeInsets.all(isSelected ? 2 : 1),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: AnimatedSwitcher(
                        duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(isUserInteraction: true),
                        child: Icon(
                          isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                          key: ValueKey('${item.icon}_$isSelected'),
                          size: iconSize,
                          color: iconColor,
                        ),
                      ),
                    ),

                  // Flexible spacing
                  SizedBox(height: isTablet ? 4 : 3),

                  // Label with animation and proper overflow handling
                  Flexible(
                    child: AnimatedDefaultTextStyle(
                      duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(isUserInteraction: true),
                      curve: IOSPerformanceOptimizer.instance.getOptimalAnimationCurve(),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                        letterSpacing: isSelected ? 0.1 : 0,
                        height: 1.0,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        softWrap: false, // Prevent wrapping
                      ),
                    ),
                  ),

                  // Selection indicator - smaller and responsive
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 1),
                      height: 1.5,
                      width: math.min(12, constraints.maxWidth * 0.3),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.all(Radius.circular(0.75)),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}