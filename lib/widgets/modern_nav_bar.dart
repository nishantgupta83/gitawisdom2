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
    final effectiveMargin = margin ?? const EdgeInsets.fromLTRB(12, 0, 12, 6);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    // Modern colors with high translucency for blur effect
    final navBackgroundColor = backgroundColor ??
        (isDark
            ? const Color(0xFF1C1C1E).withOpacity(0.45)
            : Colors.white.withOpacity(0.35));

    return SafeArea(
      child: Container(
        margin: effectiveMargin,
        height: effectiveHeight,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: RepaintBoundary(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              return _buildNavItem(
                context,
                items[index],
                index,
                currentIndex == index,
                isDark,
                isTablet,
              );
            }),
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

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            constraints: const BoxConstraints(minHeight: 48), // Ensure minimum 44dp touch target
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                AnimatedContainer(
                  duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(isUserInteraction: true),
                  curve: IOSPerformanceOptimizer.instance.getOptimalAnimationCurve(),
                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: AnimatedSwitcher(
                    duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(isUserInteraction: true),
                    child: Icon(
                      isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                      key: ValueKey('${item.icon}_$isSelected'),
                      size: isSelected ? 26 : 24,
                      color: iconColor,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // Label with animation
                AnimatedDefaultTextStyle(
                  duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(isUserInteraction: true),
                  curve: IOSPerformanceOptimizer.instance.getOptimalAnimationCurve(),
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                    letterSpacing: isSelected ? 0.2 : 0,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Selection indicator
                AnimatedContainer(
                  duration: IOSPerformanceOptimizer.instance.getOptimalAnimationDuration(),
                  curve: IOSPerformanceOptimizer.instance.getOptimalAnimationCurve(),
                  margin: const EdgeInsets.only(top: 1),
                  height: 2,
                  width: isSelected ? 20 : 0,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              ],
            ),
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
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.15),
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
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular((effectiveHeight - 16) / 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
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