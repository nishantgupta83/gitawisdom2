import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A data class representing one bottom-nav entry.
class NavBarItem {
  final IconData icon;
  final String label;
  const NavBarItem({
    required this.icon,
    required this.label,
  });
}


enum NavBarStyle { pill, devTo, floating }

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;
  final NavBarStyle style;

  const CustomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.style = NavBarStyle.pill,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case NavBarStyle.pill:
        return _PillNavBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
        );
      case NavBarStyle.devTo:
        return _DevToNavBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
        );
      case NavBarStyle.floating:
        return _FloatingNavBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
        );
    }
  }
}

class _PillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  const _PillNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isTablet = media.size.width > 600;
    final isLandscape = media.orientation == Orientation.landscape;
    
    // Get text scale factor for accessibility support
    final textScaler = media.textScaler;

    // Responsive sizing - increased height for better visibility
    final double barHeight = isLandscape
        ? (media.size.height < 400 ? 56 : 64) // Increased landscape heights
        : (isTablet ? 70 : 66); // Increased portrait heights
    final double horizontalPad = isLandscape ? 60 : (isTablet ? 40 : 20);

    final Color backgroundColor = Color.fromARGB(
      (0.85 * 255).round(),
      theme.colorScheme.surface.red,
      theme.colorScheme.surface.green,
      theme.colorScheme.surface.blue
    );
    final Color selectedColor = theme.colorScheme.surface;
    final Color iconColor = theme.colorScheme.onSurface;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          right: horizontalPad,
          bottom: 8, // Fixed minimal padding - eliminates excessive safe area spacing
          top: 4, // Reduced from 8 to 4
        ),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB((0.12 * 255).round(), 0, 0, 0),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final bool selected = i == currentIndex;
              return Flexible(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    constraints: BoxConstraints(
                      minWidth: selected ? (isTablet ? 100 : 80) : (isTablet ? 80 : 64),
                      minHeight: 44,
                      maxHeight: barHeight - (isLandscape ? 4 : 8), // Less height reduction in landscape
                    ),
                    margin: EdgeInsets.symmetric(
                      vertical: selected ? (isLandscape ? 2 : 4) : (isLandscape ? 4 : 8), // Reduced in landscape
                      horizontal: selected ? 8 : 4,
                    ),
                    decoration: selected
                        ? BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB((0.14 * 255).round(), 0, 0, 0),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].icon,
                          size: isTablet ? 30 : 28,
                          color: selected
                              ? Color.fromARGB((0.98 * 255).round(), iconColor.red, iconColor.green, iconColor.blue)
                              : Color.fromARGB((0.62 * 255).round(), iconColor.red, iconColor.green, iconColor.blue),
                        ),
                        SizedBox(height: isTablet ? 3 : (isLandscape ? 0 : 1)), // No spacing in landscape on phones
                        Flexible(
                          child: Text(
                            items[i].label,
                            style: TextStyle(
                              color: selected
                                  ? Color.fromARGB((0.98 * 255).round(), iconColor.red, iconColor.green, iconColor.blue)
                                  : Color.fromARGB((0.95 * 255).round(), iconColor.red, iconColor.green, iconColor.blue), // Increased opacity for better visibility
                              fontWeight: selected
                                  ? FontWeight.w700  // Bolder for selected
                                  : FontWeight.w600, // Bolder for unselected for better visibility
                              fontSize: textScaler.scale(isTablet ? 14 : (isLandscape ? 12 : 13)), // Scale with accessibility settings
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// … existing imports and enum above …

class _DevToNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  const _DevToNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media      = MediaQuery.of(context);
    final theme      = Theme.of(context);
    final isTablet   = media.size.width > 600;
    final isLandscape = media.orientation == Orientation.landscape;
    
    // Get text scale factor for accessibility support
    final textScaler = media.textScaler;

    // Match Pill's responsive sizing - optimized for minimal height
    final double barHeight = isLandscape
        ? (media.size.height < 400 ? 48 : 54)
        : (isTablet ? 62 : 56);
    final double horizontalPad = isLandscape ? 60 : (isTablet ? 40 : 20);

    final Color backgroundColor   = Color.fromARGB(
      (0.85 * 255).round(),
      theme.colorScheme.surface.red,
      theme.colorScheme.surface.green,
      theme.colorScheme.surface.blue
    );
    final Color selectedColor     = theme.colorScheme.primary;
    final Color unselectedColor   = Color.fromARGB(
      (0.6 * 255).round(),
      theme.colorScheme.onSurface.red,
      theme.colorScheme.onSurface.green,
      theme.colorScheme.onSurface.blue
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          right: horizontalPad,
          bottom: 8, // Fixed minimal padding - eliminates excessive safe area spacing
          top: 4, // Reduced from 8 to 4
        ),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(top: BorderSide(
              color: Color.fromARGB(
                (0.2 * 255).round(),
                theme.colorScheme.outline.red,
                theme.colorScheme.outline.green,
                theme.colorScheme.outline.blue
              ),
              width: 0.5,
            )),
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final bool selected = i == currentIndex;
              return Flexible(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    constraints: BoxConstraints(
                      // selected‐item width expansion
                      minWidth: selected ? (isTablet ? 100 : 80) : (isTablet ? 80 : 64),
                      minHeight: barHeight,
                    ),
                    padding: EdgeInsets.symmetric(vertical: isLandscape ? 4 : 8), // Less vertical padding in landscape
                    margin: EdgeInsets.symmetric(horizontal: selected ? 8 : 4),
                    decoration: BoxDecoration(
                      color: selected ? Color.fromARGB(
                        (0.1 * 255).round(),
                        selectedColor.red,
                        selectedColor.green,
                        selectedColor.blue
                      ) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].icon,
                          color: selected ? selectedColor : unselectedColor,
                          size: isTablet ? 26 : 24,
                        ),
                        SizedBox(height: isLandscape ? 2 : 4), // Less spacing in landscape
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: selected 
                                ? selectedColor 
                                : Color.fromARGB(
                                    (0.9 * 255).round(), 
                                    unselectedColor.red, 
                                    unselectedColor.green, 
                                    unselectedColor.blue
                                  ), // Using Color.fromARGB instead of withOpacity
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500, // Slightly bolder for unselected
                            fontSize: textScaler.scale(isTablet ? 13 : (isLandscape ? 11 : 12)), // Scale with accessibility settings
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: selected ? 20 : 0,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media      = MediaQuery.of(context);
    final theme      = Theme.of(context);
    final isTablet   = media.size.width > 600;
    final isLandscape = media.orientation == Orientation.landscape;

    final double barHeight = isLandscape
        ? (media.size.height < 400 ? 48 : 54)
        : (isTablet ? 62 : 56);
    final double horizontalPad = isLandscape ? 60 : (isTablet ? 40 : 20);

    final Color backgroundColor = Color.fromARGB(
      (0.85 * 255).round(), 
      theme.colorScheme.surface.red, 
      theme.colorScheme.surface.green, 
      theme.colorScheme.surface.blue
    );
    final Color selectedColor   = theme.colorScheme.primary;
    final Color shadowColor     = Color.fromARGB((0.15 * 255).round(), 0, 0, 0);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          right: horizontalPad,
          bottom: 8, // Fixed minimal padding - eliminates excessive safe area spacing
          top: 4, // Reduced from 8 to 4
        ),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final bool selected = i == currentIndex;
              final double itemSize = selected
                  ? (isTablet ? 70 : 62)
                  : (isTablet ? 60 : 52);

              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: itemSize,
                  height: itemSize,
                  decoration: BoxDecoration(
                    color: selected ? selectedColor : backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: selected ? 20 : 10,
                        offset: Offset(0, selected ? 8 : 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      items[i].icon,
                      color: selected
                          ? Colors.white
                          : Color.fromARGB(
                              (0.7 * 255).round(),
                              theme.colorScheme.onSurface.red,
                              theme.colorScheme.onSurface.green,
                              theme.colorScheme.onSurface.blue
                            ),
                      size: isTablet ? 26 : 24,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
