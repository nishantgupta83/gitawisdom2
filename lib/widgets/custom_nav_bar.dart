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

    // Responsive sizing - reduced heights
    final double barHeight = isLandscape
        ? (media.size.height < 400 ? 54 : 60)
        : (isTablet ? 70 : 64);
    final double horizontalPad = isLandscape ? 60 : (isTablet ? 40 : 20);

    final Color backgroundColor =
    theme.colorScheme.surface.withOpacity(0.85);
    final Color selectedColor = theme.colorScheme.surface;
    final Color iconColor = theme.colorScheme.onSurface;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          right: horizontalPad,
          bottom: math.max(media.padding.bottom, 4), // Reduced padding to minimize wasted space
          top: 4, // Reduced from 8 to 4
        ),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
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
                      maxHeight: barHeight - 8,
                    ),
                    margin: EdgeInsets.symmetric(
                      vertical: selected ? 4 : 8,
                      horizontal: selected ? 8 : 4,
                    ),
                    decoration: selected
                        ? BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
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
                              ? iconColor.withAlpha((0.98 * 255).round())
                              : iconColor.withAlpha((0.62 * 255).round()),
                        ),
                        SizedBox(height: isTablet ? 3 : 1),
                        Flexible(
                          child: Text(
                            items[i].label,
                            style: TextStyle(
                              color: selected
                                  ? iconColor.withAlpha((0.98 * 255).round())
                                  : iconColor.withAlpha((0.57 * 255).round()),
                              fontWeight: selected
                                  ? FontWeight.w200
                                  : FontWeight.bold,
                              fontSize: isTablet ? 14 : 13,
                            ),
                            overflow: TextOverflow.ellipsis,
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

    // Match Pill's responsive sizing - reduced heights
    final double barHeight = isLandscape
        ? (media.size.height < 400 ? 54 : 60)
        : (isTablet ? 70 : 64);
    final double horizontalPad = isLandscape ? 60 : (isTablet ? 40 : 20);

    final Color backgroundColor   = theme.colorScheme.surface.withOpacity(0.85);
    final Color selectedColor     = theme.colorScheme.primary;
    final Color unselectedColor   = theme.colorScheme.onSurface.withOpacity(0.6);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          right: horizontalPad,
          bottom: math.max(media.padding.bottom, 4), // Reduced padding to minimize wasted space
          top: 4, // Reduced from 8 to 4
        ),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: EdgeInsets.symmetric(horizontal: selected ? 8 : 4),
                    decoration: BoxDecoration(
                      color: selected ? selectedColor.withOpacity(0.1) : Colors.transparent,
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
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: selected ? selectedColor : unselectedColor,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: isTablet ? 13 : 12,
                          ),
                          overflow: TextOverflow.ellipsis,
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
        ? (media.size.height < 400 ? 54 : 60)
        : (isTablet ? 70 : 64);
    final double horizontalPad = isLandscape ? 60 : (isTablet ? 40 : 20);

    final Color backgroundColor = theme.colorScheme.surface.withOpacity(0.85);
    final Color selectedColor   = theme.colorScheme.primary;
    final Color shadowColor     = Colors.black.withOpacity(0.15);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          right: horizontalPad,
          bottom: math.max(media.padding.bottom, 4), // Reduced padding to minimize wasted space
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
                          : theme.colorScheme.onSurface.withOpacity(0.7),
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
