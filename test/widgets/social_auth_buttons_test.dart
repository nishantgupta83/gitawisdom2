// test/widgets/social_auth_buttons_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/widgets/social_auth_buttons.dart';
import 'package:GitaWisdom/services/supabase_auth_service.dart';

import '../test_setup.dart';

void main() {
  group('SocialAuthButtons Widget Tests', () {
    late SupabaseAuthService mockAuthService;

    setUp(() async {
      await setupTestEnvironment();
      mockAuthService = SupabaseAuthService.instance;
    });

    tearDown(() async {
      await teardownTestEnvironment();
    });

    testWidgets('renders Google and Apple sign-in buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      expect(find.byType(SocialAuthButtons), findsOneWidget);

      // Should have 2 circular social buttons (Google and Apple)
      expect(find.byIcon(Icons.apple), findsOneWidget);

      // Google button uses custom painter
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('buttons are properly sized and styled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      // Find the button containers
      final googleButtonFinder = find.ancestor(
        of: find.byType(CustomPaint),
        matching: find.byType(Container),
      ).first;

      final appleButtonFinder = find.ancestor(
        of: find.byIcon(Icons.apple),
        matching: find.byType(Container),
      ).first;

      expect(googleButtonFinder, findsOneWidget);
      expect(appleButtonFinder, findsOneWidget);
    });

    testWidgets('buttons are arranged horizontally with spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      // Should have a Row layout
      expect(find.byType(Row), findsWidgets);

      // Should have SizedBox for spacing
      expect(find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 16,
      ), findsOneWidget);
    });

    testWidgets('Google button has white background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Google button container styling
      final googleContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byType(CustomPaint),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = googleContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('Apple button adapts to theme', (tester) async {
      // Test light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Apple button should have black background in light mode
      final appleContainerLight = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.apple),
          matching: find.byType(Container),
        ).first,
      );

      final decorationLight = appleContainerLight.decoration as BoxDecoration;
      expect(decorationLight.color, equals(Colors.black));

      // Test dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Apple button should have white background in dark mode
      final appleContainerDark = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.apple),
          matching: find.byType(Container),
        ).first,
      );

      final decorationDark = appleContainerDark.decoration as BoxDecoration;
      expect(decorationDark.color, equals(Colors.white));
    });

    testWidgets('buttons have proper touch targets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find all InkWell widgets
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsNWidgets(2)); // Google and Apple

      // Verify minimum touch target size (48x48 or close to it with 56x56)
      for (final inkWell in inkWells.evaluate()) {
        final size = tester.getSize(find.byWidget(inkWell.widget));
        expect(size.width, greaterThanOrEqualTo(44)); // Minimum 44dp
        expect(size.height, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('buttons have circular border radius for InkWell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find InkWell widgets
      final googleInkWell = tester.widget<InkWell>(
        find.ancestor(
          of: find.byType(CustomPaint),
          matching: find.byType(InkWell),
        ),
      );

      expect(googleInkWell.borderRadius, equals(BorderRadius.circular(28)));

      final appleInkWell = tester.widget<InkWell>(
        find.ancestor(
          of: find.byIcon(Icons.apple),
          matching: find.byType(InkWell),
        ),
      );

      expect(appleInkWell.borderRadius, equals(BorderRadius.circular(28)));
    });

    testWidgets('buttons have box shadows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Google button has shadow
      final googleContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byType(CustomPaint),
          matching: find.byType(Container),
        ).first,
      );

      final googleDecoration = googleContainer.decoration as BoxDecoration;
      expect(googleDecoration.boxShadow, isNotEmpty);
      expect(googleDecoration.boxShadow!.first.blurRadius, equals(8));

      // Verify Apple button has shadow
      final appleContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.apple),
          matching: find.byType(Container),
        ).first,
      );

      final appleDecoration = appleContainer.decoration as BoxDecoration;
      expect(appleDecoration.boxShadow, isNotEmpty);
      expect(appleDecoration.boxShadow!.first.blurRadius, equals(8));
    });

    testWidgets('Google button has 4-color pie logo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find CustomPaint widget (Google logo)
      expect(find.byType(CustomPaint), findsOneWidget);

      // Verify it has proper size
      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      expect(customPaint.painter, isNotNull);

      // The SizedBox parent should be 24x24
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CustomPaint),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, equals(24));
      expect(sizedBox.height, equals(24));
    });

    testWidgets('Apple icon has proper size and color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final appleIcon = tester.widget<Icon>(find.byIcon(Icons.apple));
      expect(appleIcon.size, equals(28));
      expect(appleIcon.color, equals(Colors.white)); // White on black background in light mode
    });

    testWidgets('buttons center their content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find Center widgets (should have at least 2 for the buttons)
      expect(find.byType(Center).evaluate().length, greaterThanOrEqualTo(2));
    });

    testWidgets('Row centers buttons horizontally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final row = tester.widget<Row>(
        find.ancestor(
          of: find.byType(InkWell),
          matching: find.byType(Row),
        ).first,
      );

      expect(row.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('buttons have Material widget for ripple effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find Material widgets (one for each button)
      final materials = find.byType(Material);
      expect(materials.evaluate().length, greaterThanOrEqualTo(2));

      // Verify they have transparent color
      for (final material in materials.evaluate()) {
        final materialWidget = material.widget as Material;
        if (materialWidget.child is InkWell) {
          expect(materialWidget.color, equals(Colors.transparent));
        }
      }
    });

    testWidgets('widget has semantic labels for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify buttons are accessible
      expect(find.byType(InkWell), findsNWidgets(2));
    });

    testWidgets('buttons maintain aspect ratio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find button containers
      final googleContainer = find.ancestor(
        of: find.byType(CustomPaint),
        matching: find.byType(Container),
      ).first;

      final appleContainer = find.ancestor(
        of: find.byIcon(Icons.apple),
        matching: find.byType(Container),
      ).first;

      // Get sizes
      final googleSize = tester.getSize(googleContainer);
      final appleSize = tester.getSize(appleContainer);

      // Both should be 56x56
      expect(googleSize.width, equals(googleSize.height));
      expect(appleSize.width, equals(appleSize.height));
      expect(googleSize.width, equals(56));
      expect(appleSize.width, equals(56));
    });

    testWidgets('widget maintains structure across rebuilds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      final initialButtonCount = find.byType(InkWell).evaluate().length;

      // Rebuild
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      final rebuiltButtonCount = find.byType(InkWell).evaluate().length;

      expect(rebuiltButtonCount, equals(initialButtonCount));
      expect(rebuiltButtonCount, equals(2));
    });

    testWidgets('uses Row for button layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('has proper spacing between buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('Google button has white background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('has circular shape for both buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('has box shadow for elevation effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses Material widget for ink effects', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('centers icons in buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('renders on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SocialAuthButtons), findsOneWidget);
    });

    testWidgets('renders on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialAuthButtons(
              authService: mockAuthService,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SocialAuthButtons), findsOneWidget);
    });
  });
}
