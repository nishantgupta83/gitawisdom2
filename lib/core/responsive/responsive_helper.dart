// lib/core/responsive/responsive_helper.dart

import 'package:flutter/material.dart';

/// Responsive helper for handling different screen sizes
/// Optimized for Indian market devices (OPPO, Vivo, OnePlus, Samsung, Xiaomi)
class ResponsiveHelper {
  static const double mobileSmallBreakpoint = 360;   // Vivo Y series, older Redmi
  static const double mobileMediumBreakpoint = 380;  // OPPO A series, Samsung M series
  static const double mobileLargeBreakpoint = 414;   // OnePlus, Samsung S series
  static const double tabletBreakpoint = 600;        // Tablets
  static const double desktopBreakpoint = 900;       // Desktop/Web
  
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileSmallBreakpoint) return DeviceType.mobileSmall;
    if (width < mobileMediumBreakpoint) return DeviceType.mobileMedium;
    if (width < mobileLargeBreakpoint) return DeviceType.mobileLarge;
    if (width < tabletBreakpoint) return DeviceType.mobileXLarge;
    if (width < desktopBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  /// Get responsive font size based on device
  static double getResponsiveFontSize(BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    if (isDesktop(context)) return desktopSize ?? tabletSize ?? mobileSize * 1.5;
    if (isTablet(context)) return tabletSize ?? mobileSize * 1.2;
    
    // Fine-tune for different mobile sizes
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return mobileSize * 0.9;  // Slightly smaller for budget devices
      case DeviceType.mobileMedium:
        return mobileSize;
      case DeviceType.mobileLarge:
      case DeviceType.mobileXLarge:
        return mobileSize * 1.1;  // Slightly larger for premium devices
      default:
        return mobileSize;
    }
  }
  
  /// Get responsive padding based on device
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    mobile ??= const EdgeInsets.all(16);
    tablet ??= const EdgeInsets.all(24);
    desktop ??= const EdgeInsets.all(32);
    
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    
    // Adjust padding for different mobile sizes
    final deviceType = getDeviceType(context);
    if (deviceType == DeviceType.mobileSmall) {
      return EdgeInsets.all(mobile.left * 0.8);  // Reduce padding for small screens
    }
    
    return mobile;
  }
  
  /// Get number of grid columns based on screen size
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
  }) {
    if (isDesktop(context)) return desktopColumns;
    if (isTablet(context)) return tabletColumns;
    
    // Adjust grid for different mobile sizes
    final deviceType = getDeviceType(context);
    if (deviceType == DeviceType.mobileSmall && mobileColumns > 1) {
      return mobileColumns - 1;  // Reduce columns for very small screens
    }
    
    return mobileColumns;
  }
  
  /// Get responsive card width for scenarios/chapters
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isDesktop(context)) {
      return (screenWidth - 96) / 3;  // 3 cards per row
    }
    if (isTablet(context)) {
      return (screenWidth - 72) / 2;  // 2 cards per row
    }
    
    // Full width cards on mobile with proper margins
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return screenWidth - 32;  // Smaller margins
      case DeviceType.mobileMedium:
      case DeviceType.mobileLarge:
      case DeviceType.mobileXLarge:
        return screenWidth - 48;  // Standard margins
      default:
        return screenWidth - 40;
    }
  }
  
  /// Check if device has notch (for modern phones)
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).viewPadding;
    return padding.top > 24;  // Most notched phones have top padding > 24
  }
  
  /// Get safe area padding adjusted for device
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final padding = MediaQuery.of(context).viewPadding;
    final hasNotch = ResponsiveHelper.hasNotch(context);
    
    return EdgeInsets.only(
      top: hasNotch ? padding.top : 0,
      bottom: padding.bottom > 0 ? padding.bottom : 16,
      left: padding.left,
      right: padding.right,
    );
  }
  
  /// Get responsive image height
  static double getImageHeight(BuildContext context, {
    required double baseHeight,
  }) {
    final deviceType = getDeviceType(context);
    
    // Adjust for different screen densities
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return baseHeight * 0.8;  // Smaller for budget devices
      case DeviceType.mobileMedium:
        return baseHeight;
      case DeviceType.mobileLarge:
      case DeviceType.mobileXLarge:
        return baseHeight * 1.1;
      case DeviceType.tablet:
        return baseHeight * 1.3;
      case DeviceType.desktop:
        return baseHeight * 1.5;
    }
  }
  
  /// Check device RAM category (approximation based on screen size/density)
  static DeviceRAMCategory getApproximateRAMCategory(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final size = MediaQuery.of(context).size;
    final totalPixels = size.width * size.height * pixelRatio;
    
    // Approximate RAM based on screen resolution
    if (totalPixels < 2000000) return DeviceRAMCategory.low;      // < 3GB
    if (totalPixels < 4000000) return DeviceRAMCategory.medium;   // 4-6GB
    return DeviceRAMCategory.high;                                // 8GB+
  }
  
  /// Should use high quality images
  static bool shouldUseHighQualityImages(BuildContext context) {
    return getApproximateRAMCategory(context) != DeviceRAMCategory.low;
  }
  
  /// Get list item height based on device
  static double getListItemHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 72;  // Compact for small screens
      case DeviceType.mobileMedium:
        return 80;
      case DeviceType.mobileLarge:
      case DeviceType.mobileXLarge:
        return 88;
      case DeviceType.tablet:
        return 96;
      case DeviceType.desktop:
        return 104;
    }
  }
}

/// Device type enumeration
enum DeviceType {
  mobileSmall,   // < 360dp (Budget phones)
  mobileMedium,  // 360-380dp (Mid-range)
  mobileLarge,   // 380-414dp (Premium phones)
  mobileXLarge,  // 414-600dp (Large phones)
  tablet,        // 600-900dp
  desktop,       // > 900dp
}

/// Device RAM category (approximation)
enum DeviceRAMCategory {
  low,     // < 4GB RAM (Budget devices)
  medium,  // 4-6GB RAM (Mid-range)
  high,    // 8GB+ RAM (Premium)
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType) builder;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveHelper.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// Responsive visibility widget
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool hiddenOnMobile;
  final bool hiddenOnTablet;
  final bool hiddenOnDesktop;
  
  const ResponsiveVisibility({
    Key? key,
    required this.child,
    this.hiddenOnMobile = false,
    this.hiddenOnTablet = false,
    this.hiddenOnDesktop = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isMobile(context) && hiddenOnMobile) {
      return const SizedBox.shrink();
    }
    if (ResponsiveHelper.isTablet(context) && hiddenOnTablet) {
      return const SizedBox.shrink();
    }
    if (ResponsiveHelper.isDesktop(context) && hiddenOnDesktop) {
      return const SizedBox.shrink();
    }
    
    return child;
  }
}