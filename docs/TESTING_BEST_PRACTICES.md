# Flutter Testing Best Practices - GitaWisdom App

## Testing Strategy Overview

This document outlines the comprehensive testing approach for the GitaWisdom Flutter application, covering unit tests, widget tests, integration tests, and best practices.

---

## Table of Contents

1. [Top 10 Flutter Testing Strategies](#top-10-flutter-testing-strategies)
2. [Test Structure](#test-structure)
3. [Testing Patterns](#testing-patterns)
4. [Coverage Goals](#coverage-goals)
5. [Running Tests](#running-tests)
6. [Continuous Integration](#continuous-integration)

---

## Top 10 Flutter Testing Strategies

### 1. **Widget Testing First**
- Test UI behavior before integration tests
- Use `testWidgets()` for all UI components
- Mock external dependencies to isolate widget behavior
- Example:
```dart
testWidgets('should display chapter title', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Chapter 1'), findsOneWidget);
});
```

### 2. **Mock External Dependencies**
- Use `mockito` or `mocktail` for mocking services
- Never test real API calls in unit tests
- Create mocks for: Supabase, Hive, SharedPreferences, HTTP clients
- Example:
```dart
@GenerateMocks([SupabaseAuthService, EnhancedSupabaseService])
void main() {
  late MockSupabaseAuthService mockAuth;

  setUp(() {
    mockAuth = MockSupabaseAuthService();
    when(mockAuth.isAuthenticated).thenReturn(true);
  });
}
```

### 3. **Golden Tests for Visual Regression**
- Use golden file testing for critical screens
- Prevents unintended UI changes
- Test across different device sizes
- Example:
```dart
testWidgets('home screen matches golden file', (tester) async {
  await tester.pumpWidget(HomeScreen());
  await expectLater(
    find.byType(HomeScreen),
    matchesGoldenFile('goldens/home_screen.png'),
  );
});
```

### 4. **Test Coverage Targets**
- **Target**: >80% overall coverage
- **Critical paths**: 100% coverage (auth, payments, data deletion)
- **UI widgets**: >70% coverage
- **Services**: >85% coverage
- **Models**: 100% coverage
- Run: `flutter test --coverage`

### 5. **Pump and Settle for Async Operations**
- Always use `pumpAndSettle()` after async actions
- Use `pump()` for controlled frame-by-frame testing
- Handle timeouts with `pumpAndSettle(duration: Duration(seconds: 10))`
- Example:
```dart
await tester.tap(find.text('Submit'));
await tester.pumpAndSettle(); // Wait for all animations and async ops
expect(find.text('Success'), findsOneWidget);
```

### 6. **Find by Key for Reliable Element Location**
- Use `Key()` widgets for test identification
- Avoid relying on text alone (localization changes)
- Use semantic labels for accessibility testing
- Example:
```dart
// In widget:
IconButton(key: const Key('refresh_button'), ...)

// In test:
await tester.tap(find.byKey(const Key('refresh_button')));
```

### 7. **Test User Interactions**
- Test all interactive elements: taps, drags, long-press, swipes
- Verify state changes after interactions
- Test gesture recognizers
- Example:
```dart
// Tap
await tester.tap(find.byType(IconButton));

// Long press
await tester.longPress(find.text('Delete'));

// Drag (for RefreshIndicator)
await tester.drag(find.byType(ListView), const Offset(0, 300));

// Scroll
await tester.scrollUntilVisible(find.text('Chapter 18'), 500);
```

### 8. **Error State Testing**
- Explicitly test failure scenarios
- Mock network errors, timeouts, authentication failures
- Verify error messages are user-friendly
- Example:
```dart
test('should handle network error gracefully', () async {
  when(mockService.fetchData()).thenThrow(Exception('Network error'));

  final result = await service.getData();

  expect(result, isNull);
  expect(service.error, contains('Network error'));
});
```

### 9. **Accessibility Testing**
- Use `debugCheckIsAccessible()` (currently experimental)
- Test semantic labels with screen reader simulation
- Verify minimum touch target sizes (44x44dp)
- Test color contrast ratios (WCAG 2.1 AA: 4.5:1)
- Example:
```dart
testWidgets('should meet accessibility guidelines', (tester) async {
  await tester.pumpWidget(MyApp());

  // Verify touch target sizes
  final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
  expect(button.minimumSize?.height, greaterThanOrEqualTo(44));

  // Verify semantic labels
  expect(find.bySemanticsLabel('Sign In Button'), findsOneWidget);
});
```

### 10. **CI/CD Integration**
- Automated testing on every commit
- Fail builds on test failures
- Generate and track coverage reports
- Run tests in parallel for speed
- Example GitHub Actions:
```yaml
- name: Run tests
  run: flutter test --coverage
- name: Upload coverage
  uses: codecov/codecov-action@v3
```

---

## Test Structure

### Directory Organization

```
test/
├── core/
│   └── app_initializer_test.dart
├── models/
│   ├── chapter_test.dart
│   ├── verse_test.dart
│   └── scenario_test.dart
├── screens/
│   ├── home_screen_test.dart
│   ├── chapters_screen_test.dart
│   ├── scenarios_screen_test.dart
│   ├── journal_screen_test.dart
│   └── more_screen_test.dart
├── widgets/
│   ├── modern_nav_bar_test.dart
│   ├── chapter_card_test.dart
│   └── expandable_text_test.dart
├── services/
│   ├── supabase_auth_service_test.dart
│   ├── journal_service_test.dart
│   ├── bookmark_service_test.dart
│   ├── progressive_cache_service_test.dart
│   └── ...
├── integration_test/
│   ├── auth_flow_test.dart
│   ├── journal_flow_test.dart
│   └── navigation_flow_test.dart
└── test_setup.dart
```

### Test File Naming Convention

- Unit tests: `{service_name}_test.dart`
- Widget tests: `{screen_name}_test.dart`
- Integration tests: `{flow_name}_test.dart`
- All test files must end with `_test.dart`

---

## Testing Patterns

### Unit Test Pattern (Services)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ExternalDependency])
void main() {
  late ServiceUnderTest service;
  late MockExternalDependency mockDependency;

  setUp(() {
    mockDependency = MockExternalDependency();
    service = ServiceUnderTest(dependency: mockDependency);
  });

  tearDown(() {
    // Clean up resources
  });

  group('ServiceUnderTest', () {
    test('should perform expected operation', () async {
      // Arrange
      when(mockDependency.doSomething()).thenAnswer((_) async => 'result');

      // Act
      final result = await service.performOperation();

      // Assert
      expect(result, equals('result'));
      verify(mockDependency.doSomething()).called(1);
    });

    test('should handle errors gracefully', () async {
      // Arrange
      when(mockDependency.doSomething()).thenThrow(Exception('Error'));

      // Act & Assert
      expect(() => service.performOperation(), throwsException);
    });
  });
}
```

### Widget Test Pattern (Screens)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockService mockService;

  setUp(() {
    mockService = MockService();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: mockService),
      ],
      child: const MaterialApp(
        home: ScreenUnderTest(),
      ),
    );
  }

  testWidgets('should display expected UI', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createTestWidget());

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Expected Text'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('should handle user interaction', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.text('Button'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Success'), findsOneWidget);
  });
}
```

### Integration Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GitaWisdom/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flow', () {
    testWidgets('user can sign in and access content', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password');

      // Submit
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify signed in
      expect(find.text('Welcome'), findsOneWidget);

      // Access content
      await tester.tap(find.text('Chapter 1'));
      await tester.pumpAndSettle();

      expect(find.byType(ChapterDetailScreen), findsOneWidget);
    });
  });
}
```

---

## Coverage Goals

### Coverage by Component

| Component | Target Coverage | Critical Path Coverage |
|-----------|----------------|------------------------|
| **Models** | 100% | 100% |
| **Services** | 85% | 100% |
| **Screens** | 70% | 90% |
| **Widgets** | 70% | 80% |
| **Utils** | 80% | 90% |
| **Overall** | **80%** | **95%** |

### Critical Paths (Must be 100% covered)

1. **Authentication Flow**
   - Sign in (Google, Apple, Email)
   - Sign out
   - Account deletion with data cleanup

2. **Data Persistence**
   - Journal entry creation with encryption
   - Bookmark management
   - Settings persistence

3. **Offline Functionality**
   - Cache access when offline
   - Data sync when reconnected

4. **Payment/Subscription** (if applicable)
   - Payment processing
   - Subscription validation

---

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/services/journal_service_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### View Coverage Report

```bash
# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### Run Integration Tests

```bash
# On Android emulator
flutter test integration_test/auth_flow_test.dart -d emulator-5554

# On iOS simulator
flutter test integration_test/auth_flow_test.dart -d <simulator-id>
```

### Run Tests in Watch Mode

```bash
# Install flutter_tdd
flutter pub global activate flutter_tdd

# Run in watch mode
flutter_tdd
```

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Flutter Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.2.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          fail_ci_if_error: true

      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage is below 80%: $COVERAGE%"
            exit 1
          fi
```

---

## Best Practices Checklist

### Before Writing Tests

- [ ] Understand the code you're testing
- [ ] Identify critical paths and edge cases
- [ ] Plan mock data and test scenarios
- [ ] Review existing tests for patterns

### While Writing Tests

- [ ] Use descriptive test names (should/when/then pattern)
- [ ] Test one thing per test case
- [ ] Mock external dependencies
- [ ] Use `setUp()` and `tearDown()` for common setup
- [ ] Group related tests with `group()`
- [ ] Add comments for complex test logic

### After Writing Tests

- [ ] Verify tests pass consistently
- [ ] Check test execution time (tests should be fast)
- [ ] Review code coverage
- [ ] Refactor duplicate test code
- [ ] Document any test-specific configuration

---

## Common Testing Pitfalls to Avoid

### 1. **Flaky Tests**
- ❌ Don't rely on hardcoded delays (`await Future.delayed()`)
- ✅ Use `pumpAndSettle()` or `pump()` with proper waits

### 2. **Over-Mocking**
- ❌ Don't mock everything, including simple models
- ✅ Only mock external dependencies and services

### 3. **Testing Implementation Details**
- ❌ Don't test private methods or internal state
- ✅ Test public API and observable behavior

### 4. **Ignoring Edge Cases**
- ❌ Don't just test happy paths
- ✅ Test error cases, empty states, boundary conditions

### 5. **Slow Tests**
- ❌ Don't make real API calls or database queries
- ✅ Mock all external dependencies for speed

### 6. **No Test Organization**
- ❌ Don't put all tests in one giant file
- ✅ Organize by feature/component, use `group()` liberally

---

## Testing Tools & Libraries

### Required Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

### Generate Mocks

```bash
flutter pub run build_runner build
```

---

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Test Coverage](https://docs.flutter.dev/testing/code-coverage)

---

## Conclusion

Following these testing best practices ensures:
- ✅ High-quality, maintainable code
- ✅ Confidence in deployments
- ✅ Early bug detection
- ✅ Better code documentation through tests
- ✅ Faster development cycles

**Remember**: Tests are code too. Keep them clean, maintainable, and well-documented.
