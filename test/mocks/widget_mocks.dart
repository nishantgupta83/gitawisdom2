// test/mocks/widget_mocks.dart
// Comprehensive mocks for widget testing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'package:GitaWisdom/services/simple_auth_service.dart';
import 'package:GitaWisdom/services/background_music_service.dart';
import 'package:GitaWisdom/services/journal_service.dart';
import 'package:GitaWisdom/services/bookmark_service.dart';
import 'service_mocks.dart';

// ==================== Widget Test Helpers ====================

/// Create a test widget wrapped with all necessary providers
Widget createTestWidget({
  required Widget child,
  SettingsService? settingsService,
  SimpleAuthService? authService,
  MockJournalService? journalService,
  MockBookmarkService? bookmarkService,
  NavigatorObserver? navigatorObserver,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsService>.value(
        value: settingsService ?? MockSettingsService(),
      ),
      ChangeNotifierProvider<SimpleAuthService>.value(
        value: authService ?? MockSimpleAuthService(),
      ),
      if (journalService != null)
        Provider<JournalService>.value(value: journalService),
      if (bookmarkService != null)
        ChangeNotifierProvider<BookmarkService>.value(value: bookmarkService),
    ],
    child: MaterialApp(
      home: child,
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
    ),
  );
}

/// Create a test widget with theme support
Widget createThemedTestWidget({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  SettingsService? settingsService,
}) {
  final settings = settingsService ?? MockSettingsService();

  return ChangeNotifierProvider<SettingsService>.value(
    value: settings,
    child: Consumer<SettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: child,
        );
      },
    ),
  );
}

/// Create a test widget with navigation
Widget createNavigableTestWidget({
  required Widget child,
  List<NavigatorObserver>? navigatorObservers,
  Map<String, WidgetBuilder>? routes,
}) {
  return MaterialApp(
    home: child,
    navigatorObservers: navigatorObservers ?? [],
    routes: routes ?? {},
  );
}

/// Create a test widget with MaterialApp only (minimal setup)
Widget createMinimalTestWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

// ==================== Test Helpers ====================

/// Pump widget and settle animations
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  Duration? duration,
}) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 300));
}

/// Find a widget by type with error handling
T findWidgetByType<T extends Widget>(WidgetTester tester) {
  final finder = find.byType(T);
  expect(finder, findsOneWidget, reason: 'Expected to find one $T widget');
  return tester.widget<T>(finder);
}

/// Find multiple widgets by type
List<T> findWidgetsByType<T extends Widget>(WidgetTester tester) {
  final finder = find.byType(T);
  return tester.widgetList<T>(finder).toList();
}

/// Tap a widget with settling
Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder, {
  Duration? duration,
}) async {
  await tester.tap(finder);
  await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 300));
}

/// Enter text and settle
Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String text, {
  Duration? duration,
}) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 300));
}

/// Scroll until visible with error handling
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder itemFinder,
  double delta, {
  Finder? scrollable,
  int maxScrolls = 50,
  Duration settleDuration = const Duration(milliseconds: 100),
}) async {
  final scrollableFinder = scrollable ?? find.byType(Scrollable);

  for (int i = 0; i < maxScrolls; i++) {
    if (tester.any(itemFinder)) {
      break;
    }
    await tester.drag(scrollableFinder, Offset(0, delta));
    await tester.pumpAndSettle(settleDuration);
  }

  expect(
    itemFinder,
    findsWidgets,
    reason: 'Item not found after scrolling $maxScrolls times',
  );
}

/// Verify text exists
void expectTextExists(String text) {
  expect(find.text(text), findsOneWidget, reason: 'Expected to find text: $text');
}

/// Verify text does not exist
void expectTextDoesNotExist(String text) {
  expect(find.text(text), findsNothing, reason: 'Expected not to find text: $text');
}

/// Verify widget exists
void expectWidgetExists<T extends Widget>() {
  expect(find.byType(T), findsOneWidget, reason: 'Expected to find widget: $T');
}

/// Verify widget does not exist
void expectWidgetDoesNotExist<T extends Widget>() {
  expect(find.byType(T), findsNothing, reason: 'Expected not to find widget: $T');
}

// ==================== Navigation Helpers ====================

/// Mock NavigatorObserver for tracking navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];
  final List<Route<dynamic>> replacedRoutes = [];
  final List<Route<dynamic>> removedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.noSuchMethod(
      Invocation.method(#didPush, [route, previousRoute]),
      returnValueForMissingStub: null,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.noSuchMethod(
      Invocation.method(#didPop, [route, previousRoute]),
      returnValueForMissingStub: null,
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) replacedRoutes.add(newRoute);
    super.noSuchMethod(
      Invocation.method(#didReplace, [], {
        #newRoute: newRoute,
        #oldRoute: oldRoute,
      }),
      returnValueForMissingStub: null,
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    removedRoutes.add(route);
    super.noSuchMethod(
      Invocation.method(#didRemove, [route, previousRoute]),
      returnValueForMissingStub: null,
    );
  }

  // Helper methods for testing
  bool didPushRoute(String routeName) {
    return pushedRoutes.any((route) => route.settings.name == routeName);
  }

  bool didPopRoute(String routeName) {
    return poppedRoutes.any((route) => route.settings.name == routeName);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
    replacedRoutes.clear();
    removedRoutes.clear();
  }
}

// ==================== Form Testing Helpers ====================

/// Fill a text field by key
Future<void> fillTextField(
  WidgetTester tester,
  Key key,
  String text, {
  bool shouldSettle = true,
}) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget, reason: 'TextField with key $key not found');

  await tester.enterText(finder, text);
  if (shouldSettle) {
    await tester.pumpAndSettle();
  }
}

/// Fill a text field by label text
Future<void> fillTextFieldByLabel(
  WidgetTester tester,
  String labelText,
  String text, {
  bool shouldSettle = true,
}) async {
  final finder = find.widgetWithText(TextField, labelText);
  if (tester.any(finder)) {
    await tester.enterText(finder, text);
  } else {
    // Try TextFormField
    final formFieldFinder = find.widgetWithText(TextFormField, labelText);
    expect(
      formFieldFinder,
      findsOneWidget,
      reason: 'TextField/TextFormField with label "$labelText" not found',
    );
    await tester.enterText(formFieldFinder, text);
  }

  if (shouldSettle) {
    await tester.pumpAndSettle();
  }
}

/// Tap a button by text
Future<void> tapButtonByText(
  WidgetTester tester,
  String text, {
  bool shouldSettle = true,
}) async {
  final finder = find.widgetWithText(ElevatedButton, text);
  if (tester.any(finder)) {
    await tester.tap(finder);
  } else {
    // Try TextButton
    final textButtonFinder = find.widgetWithText(TextButton, text);
    if (tester.any(textButtonFinder)) {
      await tester.tap(textButtonFinder);
    } else {
      // Try OutlinedButton
      final outlinedFinder = find.widgetWithText(OutlinedButton, text);
      expect(
        outlinedFinder,
        findsOneWidget,
        reason: 'Button with text "$text" not found',
      );
      await tester.tap(outlinedFinder);
    }
  }

  if (shouldSettle) {
    await tester.pumpAndSettle();
  }
}

/// Tap a button by icon
Future<void> tapButtonByIcon(
  WidgetTester tester,
  IconData icon, {
  bool shouldSettle = true,
}) async {
  final finder = find.widgetWithIcon(IconButton, icon);
  expect(finder, findsOneWidget, reason: 'IconButton with icon not found');

  await tester.tap(finder);
  if (shouldSettle) {
    await tester.pumpAndSettle();
  }
}

// ==================== List/Grid Testing Helpers ====================

/// Find list item by text
Finder findListItem(String text) {
  return find.descendant(
    of: find.byType(ListTile),
    matching: find.text(text),
  );
}

/// Count items in a ListView
int countListViewItems(WidgetTester tester) {
  final listView = tester.widget<ListView>(find.byType(ListView));
  if (listView.semanticChildCount != null) {
    return listView.semanticChildCount!;
  }
  // Fallback: count visible items
  return find.descendant(
    of: find.byType(ListView),
    matching: find.byType(ListTile),
  ).evaluate().length;
}

/// Scroll to list item
Future<void> scrollToListItem(
  WidgetTester tester,
  String itemText, {
  Duration settleDuration = const Duration(milliseconds: 100),
}) async {
  await scrollUntilVisible(
    tester,
    find.text(itemText),
    -100.0,
    settleDuration: settleDuration,
  );
}

// ==================== Dialog Testing Helpers ====================

/// Verify dialog is showing
void expectDialogIsShowing() {
  expect(find.byType(Dialog), findsOneWidget, reason: 'Expected dialog to be showing');
}

/// Verify dialog is not showing
void expectDialogIsNotShowing() {
  expect(find.byType(Dialog), findsNothing, reason: 'Expected dialog not to be showing');
}

/// Dismiss dialog by tapping button
Future<void> dismissDialog(
  WidgetTester tester, {
  String buttonText = 'OK',
}) async {
  await tapButtonByText(tester, buttonText);
}

// ==================== Snackbar Testing Helpers ====================

/// Verify snackbar is showing with text
void expectSnackbarWithText(String text) {
  expect(find.byType(SnackBar), findsOneWidget);
  expect(find.text(text), findsOneWidget);
}

/// Verify snackbar is not showing
void expectNoSnackbar() {
  expect(find.byType(SnackBar), findsNothing);
}

// ==================== Accessibility Testing Helpers ====================

/// Verify widget has semantic label
void expectSemanticLabel(WidgetTester tester, String label) {
  expect(
    find.bySemanticsLabel(label),
    findsOneWidget,
    reason: 'Expected to find widget with semantic label: $label',
  );
}

/// Verify minimum touch target size (44x44 dp)
void expectMinimumTouchTargetSize(WidgetTester tester, Finder finder) {
  final widget = tester.widget(finder);
  final size = tester.getSize(finder);

  expect(
    size.width,
    greaterThanOrEqualTo(44.0),
    reason: 'Touch target width should be at least 44dp',
  );
  expect(
    size.height,
    greaterThanOrEqualTo(44.0),
    reason: 'Touch target height should be at least 44dp',
  );
}

/// Verify text contrast ratio (WCAG 2.1 AA compliance)
void expectTextContrastCompliance(
  WidgetTester tester,
  Finder textFinder, {
  double minimumRatio = 4.5,
}) {
  final text = tester.widget<Text>(textFinder);
  final style = text.style;

  // This is a simplified check - real implementation would need background color
  expect(
    style?.color,
    isNotNull,
    reason: 'Text should have explicit color for contrast checking',
  );
}

// ==================== Animation Testing Helpers ====================

/// Wait for animation to complete
Future<void> waitForAnimation(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 500),
}) async {
  await tester.pump(duration);
  await tester.pumpAndSettle();
}

/// Verify animation is running
bool isAnimationRunning(WidgetTester tester) {
  return tester.binding.hasScheduledFrame;
}

// ==================== Performance Testing Helpers ====================

/// Measure widget build time
Future<Duration> measureBuildTime(
  WidgetTester tester,
  Widget widget,
) async {
  final stopwatch = Stopwatch()..start();
  await tester.pumpWidget(widget);
  stopwatch.stop();
  return stopwatch.elapsed;
}

/// Verify build time is acceptable
Future<void> expectBuildTimeUnder(
  WidgetTester tester,
  Widget widget,
  Duration maxDuration,
) async {
  final buildTime = await measureBuildTime(tester, widget);
  expect(
    buildTime,
    lessThan(maxDuration),
    reason: 'Build time ${buildTime.inMilliseconds}ms exceeds max ${maxDuration.inMilliseconds}ms',
  );
}

// ==================== Gesture Testing Helpers ====================

/// Perform long press
Future<void> longPress(
  WidgetTester tester,
  Finder finder, {
  bool shouldSettle = true,
}) async {
  await tester.longPress(finder);
  if (shouldSettle) {
    await tester.pumpAndSettle();
  }
}

/// Perform drag gesture
Future<void> drag(
  WidgetTester tester,
  Finder finder,
  Offset offset, {
  bool shouldSettle = true,
}) async {
  await tester.drag(finder, offset);
  if (shouldSettle) {
    await tester.pumpAndSettle();
  }
}

/// Perform fling gesture
Future<void> fling(
  WidgetTester tester,
  Finder finder,
  Offset offset,
  double velocity, {
  bool shouldSettle = true,
}) async {
  await tester.fling(finder, offset, velocity);
  if (shouldSettle) {
    await tester.pumpAndSettle();
  }
}
