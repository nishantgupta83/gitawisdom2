// lib/widgets/modern_nav_bar.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/accessible_colors.dart';
import '../core/ios_performance_optimizer.dart';

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
    final effectiveHeight = height ?? (isTablet ? 75 : 65);
    final effectiveMargin = margin ?? const EdgeInsets.fromLTRB(12, 0, 12, 20);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    return SafeArea(
      child: Container(
        margin: effectiveMargin,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xE61C1C1E)  // 90% opacity dark
              : const Color(0xE6FFFFFF), // 90% opacity white
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
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
            vertical: isTablet ? 4 : 2,
            horizontal: 2,
          ),
          constraints: BoxConstraints(
            minHeight: 44, // Ensure minimum 44dp touch target
            maxHeight: isTablet ? 70 : 60, // Prevent overflow
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive sizing based on available width
              final iconSize = math.min(
                isSelected ? 22.0 : 20.0,
                constraints.maxWidth * 0.4, // Max 40% of width
              ).toDouble();
              final fontSize = math.min(
                isSelected ? 10.0 : 9.0,
                constraints.maxWidth * 0.15, // Scale with width
              ).toDouble();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animation - completely transparent background
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
                  SizedBox(height: isTablet ? 2 : 1),

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

// Enhanced navigation bar with floating style
class FloatingModernNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ModernNavBarItem> items;
  final Color? backgroundColor;
  final double? height;

  const FloatingModernNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.height,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final isTablet = media.size.width > 600;
    
    final effectiveHeight = height ?? (isTablet ? 70 : 60);
    
    // Floating style colors
    final navBackgroundColor = backgroundColor ?? 
        (isDark 
            ? const Color(0xFF2C2C2E)
            : Colors.white);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: navBackgroundColor,
          borderRadius: BorderRadius.circular(effectiveHeight / 2),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Floating selection indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: (MediaQuery.of(context).size.width - 40) / items.length * currentIndex + 
                    (MediaQuery.of(context).size.width - 40) / items.length * 0.15,
              top: 8,
              child: Container(
                width: (MediaQuery.of(context).size.width - 40) / items.length * 0.7,
                height: effectiveHeight - 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                      theme.colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular((effectiveHeight - 16) / 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation items
            Row(
              children: List.generate(items.length, (index) {
                return Expanded(
                  child: _buildFloatingNavItem(
                    context,
                    items[index],
                    index,
                    currentIndex == index,
                    isDark,
                    effectiveHeight,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem(
    BuildContext context,
    ModernNavBarItem item,
    int index,
    bool isSelected,
    bool isDark,
    double height,
  ) {
    final iconColor = isSelected
        ? Colors.white
        : AccessibleColors.getMutedTextColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(height / 2),
        child: Container(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(isUserInteraction: true),
                child: Icon(
                  isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                  key: ValueKey('${item.icon}_$isSelected'),
                  size: isSelected ? 24 : 22,
                  color: iconColor,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12, // Increased from 10 to 12 for better readability
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2, // Improved line height
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}