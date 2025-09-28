// lib/core/navigation/navigation_service.dart

import 'package:flutter/material.dart';

/// Centralized navigation service for the app
/// Replaces static NavigationHelper from main.dart with better architecture
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static NavigationService get instance => _instance;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState? get _navigator => _navigatorKey.currentState;

  /// Navigation key for MaterialApp
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// Current build context
  BuildContext? get context => _navigator?.context;

  // Navigation callbacks - set by RootScaffold
  void Function(int)? _onTabChanged;
  void Function(int)? _onGoToScenariosWithChapter;

  /// Initialize navigation service with callbacks
  void initialize({
    required void Function(int) onTabChanged,
    required void Function(int) onGoToScenariosWithChapter,
  }) {
    _onTabChanged = onTabChanged;
    _onGoToScenariosWithChapter = onGoToScenariosWithChapter;
    debugPrint('✅ NavigationService initialized');
  }

  /// Navigate to a specific tab by index
  /// Replaces NavigationHelper.goToTab
  void goToTab(int tabIndex) {
    try {
      _onTabChanged?.call(tabIndex);
      debugPrint('🧭 Navigated to tab: $tabIndex');
    } catch (e) {
      debugPrint('❌ Failed to navigate to tab $tabIndex: $e');
    }
  }

  /// Navigate to scenarios screen with chapter filter
  /// Replaces NavigationHelper.goToScenariosWithChapter
  void goToScenariosWithChapter(int chapterId) {
    try {
      _onGoToScenariosWithChapter?.call(chapterId);
      debugPrint('🧭 Navigated to scenarios with chapter filter: $chapterId');
    } catch (e) {
      debugPrint('❌ Failed to navigate to scenarios with chapter $chapterId: $e');
    }
  }

  /// Navigate to home tab (convenience method)
  void goToHome() => goToTab(0);

  /// Navigate to chapters tab (convenience method)
  void goToChapters() => goToTab(1);

  /// Navigate to scenarios tab (convenience method)
  void goToScenarios() => goToTab(2);

  /// Navigate to more tab (convenience method)
  void goToMore() => goToTab(3);

  /// Push a new route
  Future<T?> push<T>(Route<T> route) async {
    if (_navigator != null) {
      return await _navigator!.push(route);
    }
    debugPrint('❌ Navigator not available for push');
    return null;
  }

  /// Push a named route
  Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
  }) async {
    if (_navigator != null) {
      return await _navigator!.pushNamed(routeName, arguments: arguments);
    }
    debugPrint('❌ Navigator not available for pushNamed');
    return null;
  }

  /// Push and replace current route
  Future<T?> pushReplacement<T, TO>(Route<T> newRoute, {TO? result}) async {
    if (_navigator != null) {
      return await _navigator!.pushReplacement(newRoute, result: result);
    }
    debugPrint('❌ Navigator not available for pushReplacement');
    return null;
  }

  /// Push and replace named route
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    if (_navigator != null) {
      return await _navigator!.pushReplacementNamed(
        routeName,
        result: result,
        arguments: arguments,
      );
    }
    debugPrint('❌ Navigator not available for pushReplacementNamed');
    return null;
  }

  /// Pop current route
  void pop<T>([T? result]) {
    if (_navigator != null && _navigator!.canPop()) {
      _navigator!.pop(result);
    } else {
      debugPrint('❌ Cannot pop - navigator not available or no routes to pop');
    }
  }

  /// Pop until specific route
  void popUntil(RoutePredicate predicate) {
    if (_navigator != null) {
      _navigator!.popUntil(predicate);
    } else {
      debugPrint('❌ Navigator not available for popUntil');
    }
  }

  /// Check if can pop
  bool canPop() {
    return _navigator?.canPop() ?? false;
  }

  /// Show snackbar
  void showSnackBar(String message, {Duration? duration}) {
    final context = this.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration ?? const Duration(seconds: 3),
        ),
      );
    } else {
      debugPrint('❌ Cannot show snackbar - context not available');
    }
  }

  /// Show dialog
  Future<T?> showAppDialog<T>(Widget dialog) async {
    final context = this.context;
    if (context != null) {
      return await showDialog<T>(
        context: context,
        builder: (context) => dialog,
      );
    }
    debugPrint('❌ Cannot show dialog - context not available');
    return null;
  }

  /// Dispose navigation service
  void dispose() {
    _onTabChanged = null;
    _onGoToScenariosWithChapter = null;
    debugPrint('🧭 NavigationService disposed');
  }
}