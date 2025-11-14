// test/widgets/error_widgets_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/error_widgets.dart';

import '../test_setup.dart';

void main() {
  group('ErrorWidgets Tests', () {
    setUp(() async {
      await setupTestEnvironment();
    });

    tearDown() async {
      await teardownTestEnvironment();
    });

    group('initializationError', () {
      testWidgets('displays initialization error screen', (tester) async {
        final widget = ErrorWidgets.initializationError('Test error message');

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Configuration Error'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('The app could not initialize properly. Please check your configuration.'), findsOneWidget);
      });

      testWidgets('has retry button', (tester) async {
        final widget = ErrorWidgets.initializationError('Test error');

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Retry'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('retry button is tappable', (tester) async {
        final widget = ErrorWidgets.initializationError('Test error');

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final retryButton = find.text('Retry');
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Should not crash
      });

      testWidgets('displays large error icon', (tester) async {
        final widget = ErrorWidgets.initializationError('Test error');

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.size, equals(64));
        expect(icon.color, equals(Colors.red));
      });

      testWidgets('centers content vertically', (tester) async {
        final widget = ErrorWidgets.initializationError('Test error');

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byType(Center), findsWidgets);
      });

      testWidgets('has MaterialApp wrapper', (tester) async {
        final widget = ErrorWidgets.initializationError('Test error');

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('genericError', () {
      testWidgets('displays title and message', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Test Error',
          message: 'This is a test error message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Test Error'), findsOneWidget);
        expect(find.text('This is a test error message'), findsOneWidget);
      });

      testWidgets('displays error icon', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.size, equals(64));
        expect(icon.color, equals(Colors.red));
      });

      testWidgets('has go home button by default', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Go Home'), findsOneWidget);
      });

      testWidgets('shows retry button when provided', (tester) async {
        bool retryCalled = false;

        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
          onRetry: () {
            retryCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(retryCalled, isTrue);
      });

      testWidgets('calls onGoHome callback when provided', (tester) async {
        bool goHomeCalled = false;

        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
          onGoHome: () {
            goHomeCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        await tester.tap(find.text('Go Home'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(goHomeCalled, isTrue);
      });

      testWidgets('centers content', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byType(Center), findsOneWidget);
      });

      testWidgets('has proper padding', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('shows both retry and go home when retry provided', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
          onRetry: () {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Go Home'), findsOneWidget);
      });

      testWidgets('buttons are arranged in row', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
          onRetry: () {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byType(Row), findsWidgets);
      });
    });

    group('networkError', () {
      testWidgets('displays network error message', (tester) async {
        final widget = ErrorWidgets.networkError();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Network Error'), findsOneWidget);
        expect(find.textContaining('Unable to connect'), findsOneWidget);
      });

      testWidgets('has retry button when callback provided', (tester) async {
        bool retryCalled = false;

        final widget = ErrorWidgets.networkError(
          onRetry: () {
            retryCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(retryCalled, isTrue);
      });

      testWidgets('shows error icon', (tester) async {
        final widget = ErrorWidgets.networkError();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('loadingError', () {
      testWidgets('displays loading error with custom message', (tester) async {
        final widget = ErrorWidgets.loadingError(
          message: 'Failed to load data',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Loading Error'), findsOneWidget);
        expect(find.text('Failed to load data'), findsOneWidget);
      });

      testWidgets('has retry callback', (tester) async {
        bool retryCalled = false;

        final widget = ErrorWidgets.loadingError(
          message: 'Failed to load',
          onRetry: () {
            retryCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(retryCalled, isTrue);
      });
    });

    group('notFound', () {
      testWidgets('displays not found error', (tester) async {
        final widget = ErrorWidgets.notFound(
          title: 'Chapter Not Found',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Chapter Not Found'), findsOneWidget);
        expect(find.textContaining('could not be found'), findsOneWidget);
      });

      testWidgets('displays custom message when provided', (tester) async {
        final widget = ErrorWidgets.notFound(
          title: 'Not Found',
          message: 'Custom not found message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Custom not found message'), findsOneWidget);
      });

      testWidgets('does not have retry button', (tester) async {
        final widget = ErrorWidgets.notFound(
          title: 'Not Found',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Retry'), findsNothing);
        expect(find.text('Go Home'), findsOneWidget);
      });
    });

    group('serviceUnavailable', () {
      testWidgets('displays service unavailable error', (tester) async {
        final widget = ErrorWidgets.serviceUnavailable();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Service Unavailable'), findsOneWidget);
        expect(find.textContaining('temporarily unavailable'), findsOneWidget);
      });

      testWidgets('has retry callback', (tester) async {
        bool retryCalled = false;

        final widget = ErrorWidgets.serviceUnavailable(
          onRetry: () {
            retryCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(retryCalled, isTrue);
      });
    });

    group('Accessibility', () {
      testWidgets('error widgets are accessible', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Should have buttons that are tappable
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('text is readable', (tester) async {
        final widget = ErrorWidgets.genericError(
          title: 'Error Title',
          message: 'Error message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Title should have proper styling
        final titleText = tester.widget<Text>(find.text('Error Title'));
        expect(titleText.style?.fontSize, equals(24));
        expect(titleText.style?.fontWeight, equals(FontWeight.bold));
      });
    });

    group('Responsive Design', () {
      testWidgets('adapts to narrow screens', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
          onRetry: () {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('adapts to wide screens', (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        final widget = ErrorWidgets.genericError(
          title: 'Error',
          message: 'Message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Error'), findsOneWidget);
      });
    });
  });
}
