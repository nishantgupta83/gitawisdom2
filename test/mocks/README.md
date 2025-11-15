# GitaWisdom Test Mocks Documentation

Comprehensive mock infrastructure for testing the GitaWisdom Flutter app.

## Table of Contents

1. [Overview](#overview)
2. [Mock Files](#mock-files)
3. [Usage Patterns](#usage-patterns)
4. [Authentication Mocks](#authentication-mocks)
5. [Service Mocks](#service-mocks)
6. [Widget Test Helpers](#widget-test-helpers)
7. [Best Practices](#best-practices)
8. [Examples](#examples)

---

## Overview

The mock infrastructure provides:

- **Complete authentication mocks** - Supabase auth, Google Sign-In, user sessions
- **Service layer mocks** - All app services including settings, journal, bookmarks
- **Widget test helpers** - Utilities for widget testing with providers and navigation
- **Test setup utilities** - Hive, Supabase, and environment initialization
- **Data generators** - Create mock data for comprehensive testing

---

## Mock Files

### 1. `auth_mocks.dart`

**Purpose:** Mocks for Supabase authentication and social auth providers

**Key Classes:**
- `MockSupabaseClient` - Complete Supabase client mock
- `MockGoTrueClient` - Authentication client with auth state streams
- `MockPostgrestFilterBuilder` - Database query builder
- `MockGoogleSignIn` - Google authentication mock
- `MockUser`, `MockSession` - User and session data

**Usage:**
```dart
import 'package:test/mocks/auth_mocks.dart';

// Create authenticated user
final user = createAuthenticatedUser(
  email: 'test@example.com',
  displayName: 'Test User',
);

// Setup successful auth flow
final mockAuth = MockGoTrueClient();
setupSuccessfulAuth(mockAuth, email: 'test@example.com', password: 'pass123');
```

### 2. `service_mocks.dart`

**Purpose:** Mocks for all app services and data storage

**Key Classes:**
- `MockBox<T>` - Hive storage mock with in-memory data
- `MockAudioPlayer` - Background music player mock
- `MockSettingsService` - App settings with state management
- `MockJournalService` - Journal entry management
- `MockBookmarkService` - Bookmark operations
- `MockSimpleAuthService` - Simplified auth service
- `MockSearchService` - Content search functionality
- `MockScenarioService` - Scenario data access

**Usage:**
```dart
import 'package:test/mocks/service_mocks.dart';

// Create mock settings service
final settings = MockSettingsService();
settings.isDarkMode = true;
settings.language = 'hi';

// Create mock journal service with test data
final journal = MockJournalService();
journal.addMockEntry(createMockJournalEntry(
  reflection: 'Test reflection',
  rating: 4,
));
```

### 3. `widget_mocks.dart`

**Purpose:** Widget testing helpers and utilities

**Key Features:**
- Widget wrappers with providers
- Navigation testing helpers
- Form interaction utilities
- Accessibility testing helpers
- Gesture and animation helpers

**Usage:**
```dart
import 'package:test/mocks/widget_mocks.dart';

// Create test widget with providers
final widget = createTestWidget(
  child: MyScreen(),
  settingsService: mockSettings,
  authService: mockAuth,
);

await tester.pumpWidget(widget);

// Use helper functions
await tapButtonByText(tester, 'Submit');
await fillTextFieldByLabel(tester, 'Email', 'test@example.com');
expectTextExists('Success!');
```

---

## Usage Patterns

### Basic Test Setup

```dart
import 'package:flutter_test/flutter_test.dart';
import '../test_setup.dart';
import '../mocks/service_mocks.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('MyService Tests', () {
    late MyService service;

    setUp(() {
      service = MyService();
    });

    tearDown(() {
      // Cleanup
    });

    test('should perform operation', () async {
      // Test implementation
    });
  });
}
```

### Widget Test Setup

```dart
import 'package:flutter_test/flutter_test.dart';
import '../mocks/widget_mocks.dart';
import '../mocks/service_mocks.dart';

void main() {
  testWidgets('MyWidget displays correctly', (tester) async {
    // Setup mocks
    final settings = MockSettingsService();
    final auth = MockSimpleAuthService();

    // Create widget with providers
    final widget = createTestWidget(
      child: MyWidget(),
      settingsService: settings,
      authService: auth,
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    // Verify
    expectTextExists('Welcome');
    expectWidgetExists<MyWidget>();
  });
}
```

---

## Authentication Mocks

### Creating Authenticated User

```dart
// Basic authenticated user
final user = createAuthenticatedUser(
  email: 'user@example.com',
  displayName: 'John Doe',
);

// Anonymous user
final anonUser = createAnonymousUser(id: 'anon-123');

// Complete auth response
final authResponse = createAuthenticatedAuthResponse(
  userId: 'user-123',
  email: 'user@example.com',
  accessToken: 'token-abc',
);
```

### Testing Auth Flows

```dart
test('successful sign in', () async {
  final mockAuth = MockGoTrueClient();

  // Setup successful authentication
  setupSuccessfulAuth(
    mockAuth,
    email: 'test@example.com',
    password: 'password123',
  );

  // Test sign in
  final response = await mockAuth.signInWithPassword(
    email: 'test@example.com',
    password: 'password123',
  );

  expect(response.user, isNotNull);
  expect(response.session, isNotNull);
});

test('failed sign in', () async {
  final mockAuth = MockGoTrueClient();

  // Setup failed authentication
  setupFailedAuth(
    mockAuth,
    email: 'test@example.com',
    password: 'wrong-password',
  );

  // Test should throw
  expect(
    () => mockAuth.signInWithPassword(
      email: 'test@example.com',
      password: 'wrong-password',
    ),
    throwsA(isA<AuthException>()),
  );
});
```

### Google Sign In Testing

```dart
test('Google sign in success', () async {
  final mockGoogleSignIn = MockGoogleSignIn();
  final mockAuth = MockGoTrueClient();

  setupSuccessfulGoogleSignIn(
    mockGoogleSignIn,
    mockAuth,
    email: 'user@gmail.com',
  );

  final account = await mockGoogleSignIn.signIn();
  expect(account, isNotNull);
  expect(account!.email, equals('user@gmail.com'));
});
```

---

## Service Mocks

### Settings Service

```dart
test('settings persistence', () async {
  final settings = MockSettingsService();

  // Set values
  settings.isDarkMode = true;
  settings.language = 'hi';
  settings.fontSize = 'large';

  // Verify
  expect(settings.isDarkMode, isTrue);
  expect(settings.language, equals('hi'));
  expect(settings.fontSize, equals('large'));
});

test('cache refresh logic', () async {
  final settings = MockSettingsService();

  // Initially can refresh
  expect(settings.canRefreshCache, isTrue);

  // Set recent refresh
  settings.setLastCacheRefreshDate(DateTime.now());
  expect(settings.canRefreshCache, isFalse);

  // Check days until next refresh
  expect(settings.daysUntilNextRefresh, greaterThan(0));
});
```

### Journal Service

```dart
test('journal CRUD operations', () async {
  final journal = MockJournalService();

  // Create entry
  final entry = createMockJournalEntry(
    reflection: 'Today I learned...',
    rating: 5,
  );
  await journal.createEntry(entry);

  // Fetch entries
  final entries = await journal.fetchEntries();
  expect(entries.length, equals(1));
  expect(entries.first.reflection, contains('learned'));

  // Delete entry
  await journal.deleteEntry(entry.id);
  final afterDelete = await journal.fetchEntries();
  expect(afterDelete.length, equals(0));
});

test('journal search', () async {
  final journal = MockJournalService();

  // Add test entries
  journal.addMockEntry(createMockJournalEntry(
    reflection: 'Gratitude for family',
  ));
  journal.addMockEntry(createMockJournalEntry(
    reflection: 'Learned meditation',
  ));

  // Search
  final results = journal.searchEntries('family');
  expect(results.length, equals(1));
  expect(results.first.reflection, contains('family'));
});
```

### Bookmark Service

```dart
test('bookmark management', () async {
  final bookmarks = MockBookmarkService();

  // Add bookmark
  final success = await bookmarks.addBookmark(
    bookmarkType: BookmarkType.verse,
    referenceId: 101,
    chapterId: 1,
    title: 'Bhagavad Gita 1.1',
    contentPreview: 'Verse preview...',
  );

  expect(success, isTrue);
  expect(bookmarks.bookmarksCount, equals(1));

  // Check if bookmarked
  expect(bookmarks.isBookmarked(BookmarkType.verse, 101), isTrue);

  // Get bookmark
  final bookmark = bookmarks.getBookmark(BookmarkType.verse, 101);
  expect(bookmark, isNotNull);
  expect(bookmark!.title, equals('Bhagavad Gita 1.1'));
});
```

### Hive Box Mock

```dart
test('Hive box operations', () async {
  final box = MockBox<String>();

  // Put values
  await box.put('key1', 'value1');
  await box.put('key2', 'value2');

  // Get values
  expect(box.get('key1'), equals('value1'));
  expect(box.length, equals(2));

  // Delete
  await box.delete('key1');
  expect(box.length, equals(1));
  expect(box.get('key1'), isNull);

  // Clear
  await box.clear();
  expect(box.isEmpty, isTrue);
});
```

---

## Widget Test Helpers

### Basic Widget Testing

```dart
testWidgets('button tap test', (tester) async {
  final widget = createMinimalTestWidget(
    ElevatedButton(
      onPressed: () {},
      child: Text('Tap Me'),
    ),
  );

  await pumpTestWidget(tester, widget);

  // Find and tap button
  await tapButtonByText(tester, 'Tap Me');

  // Verify
  expectTextExists('Tap Me');
});
```

### Form Testing

```dart
testWidgets('form submission', (tester) async {
  final formKey = GlobalKey<FormState>();

  final widget = createMinimalTestWidget(
    Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Submit'),
          ),
        ],
      ),
    ),
  );

  await pumpTestWidget(tester, widget);

  // Fill form
  await fillTextFieldByLabel(tester, 'Email', 'test@example.com');
  await fillTextFieldByLabel(tester, 'Password', 'password123');

  // Submit
  await tapButtonByText(tester, 'Submit');

  // Verify form state
  expect(formKey.currentState!.validate(), isTrue);
});
```

### Navigation Testing

```dart
testWidgets('navigation test', (tester) async {
  final observer = MockNavigatorObserver();

  final widget = createNavigableTestWidget(
    child: HomeScreen(),
    navigatorObservers: [observer],
    routes: {
      '/detail': (context) => DetailScreen(),
    },
  );

  await pumpTestWidget(tester, widget);

  // Navigate
  await tapButtonByText(tester, 'View Details');

  // Verify navigation
  expect(observer.pushedRoutes.length, equals(1));
  expect(observer.didPushRoute('/detail'), isTrue);
});
```

### List/Scroll Testing

```dart
testWidgets('scroll to item', (tester) async {
  final items = List.generate(100, (i) => 'Item $i');

  final widget = createMinimalTestWidget(
    ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(items[index]),
      ),
    ),
  );

  await pumpTestWidget(tester, widget);

  // Scroll to specific item
  await scrollToListItem(tester, 'Item 50');

  // Verify item visible
  expectTextExists('Item 50');
});
```

### Accessibility Testing

```dart
testWidgets('accessibility compliance', (tester) async {
  final widget = createMinimalTestWidget(
    IconButton(
      icon: Icon(Icons.home),
      onPressed: () {},
      tooltip: 'Home',
    ),
  );

  await pumpTestWidget(tester, widget);

  // Check semantic label
  expectSemanticLabel(tester, 'Home');

  // Check touch target size
  final finder = find.byType(IconButton);
  expectMinimumTouchTargetSize(tester, finder);
});
```

---

## Best Practices

### 1. Use Appropriate Mock Level

```dart
// ✅ Good - Use specific service mock
final journal = MockJournalService();
journal.addMockEntry(testEntry);

// ❌ Avoid - Don't mock entire app
final app = MockGitaWisdomApp(); // Too broad
```

### 2. Clean Up After Tests

```dart
// ✅ Good - Proper cleanup
tearDown(() async {
  await service.dispose();
  await cleanupBox('test_box');
});

// ❌ Avoid - No cleanup leads to flaky tests
tearDown(() {
  // Nothing - boxes remain open
});
```

### 3. Use Helper Functions

```dart
// ✅ Good - Use provided helpers
final user = createAuthenticatedUser(email: 'test@example.com');
await tapButtonByText(tester, 'Submit');

// ❌ Avoid - Manual setup
final user = MockUser();
when(user.email).thenReturn('test@example.com');
when(user.id).thenReturn('123');
// ... lots more setup
```

### 4. Test Edge Cases

```dart
// ✅ Good - Test empty states
test('empty journal state', () async {
  final journal = MockJournalService();
  final entries = await journal.fetchEntries();
  expect(entries, isEmpty);
  expect(journal.totalEntries, equals(0));
});

// ✅ Good - Test error conditions
test('handles network error', () async {
  when(mockService.fetch()).thenThrow(NetworkException());
  expect(() => service.getData(), throwsA(isA<NetworkException>()));
});
```

### 5. Verify State Changes

```dart
// ✅ Good - Verify listeners notified
test('settings notify listeners', () async {
  final settings = MockSettingsService();
  bool notified = false;

  settings.addListener(() => notified = true);
  settings.isDarkMode = true;

  expect(notified, isTrue);
});
```

---

## Examples

### Complete Service Test

```dart
import 'package:flutter_test/flutter_test.dart';
import '../test_setup.dart';
import '../mocks/service_mocks.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('JournalService Integration', () {
    late MockJournalService service;

    setUp(() {
      service = MockJournalService();
    });

    test('creates and retrieves entries', () async {
      // Create entry
      final entry = createMockJournalEntry(
        reflection: 'Meditation was peaceful today',
        rating: 5,
        tag: 'Meditation',
      );

      await service.createEntry(entry);

      // Retrieve
      final entries = await service.fetchEntries();
      expect(entries.length, equals(1));
      expect(entries.first.reflection, equals(entry.reflection));
    });

    test('calculates average rating', () async {
      // Add multiple entries
      service.addMockEntry(createMockJournalEntry(rating: 4));
      service.addMockEntry(createMockJournalEntry(rating: 5));
      service.addMockEntry(createMockJournalEntry(rating: 3));

      expect(service.averageRating, equals(4.0));
    });

    test('searches entries by text', () async {
      service.addMockEntry(createMockJournalEntry(
        reflection: 'Grateful for family',
      ));
      service.addMockEntry(createMockJournalEntry(
        reflection: 'Learned about karma',
      ));

      final results = service.searchEntries('family');
      expect(results.length, equals(1));
    });
  });
}
```

### Complete Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/widget_mocks.dart';
import '../mocks/service_mocks.dart';

void main() {
  testWidgets('JournalScreen displays and creates entries', (tester) async {
    // Setup services
    final journal = MockJournalService();
    final auth = MockSimpleAuthService();
    auth.setMockAuthState(authenticated: true, email: 'test@example.com');

    // Create widget
    final widget = createTestWidget(
      child: JournalScreen(),
      journalService: journal,
      authService: auth,
    );

    await pumpTestWidget(tester, widget);

    // Verify empty state
    expectTextExists('No journal entries yet');

    // Add entry
    await tapButtonByIcon(tester, Icons.add);
    await fillTextFieldByLabel(tester, 'Reflection', 'Today I learned...');
    await tapButtonByText(tester, 'Save');

    // Verify entry created
    final entries = await journal.fetchEntries();
    expect(entries.length, equals(1));
  });
}
```

---

## Additional Resources

- **Flutter Testing Documentation**: https://docs.flutter.dev/testing
- **Mockito Package**: https://pub.dev/packages/mockito
- **Widget Testing Guide**: https://docs.flutter.dev/cookbook/testing/widget/introduction

---

## Support

For issues or questions about the mock infrastructure:

1. Check this documentation first
2. Review existing test files for examples
3. Consult the inline documentation in mock files
4. Reach out to the development team

---

**Last Updated:** November 14, 2024
**Version:** 1.0.0
