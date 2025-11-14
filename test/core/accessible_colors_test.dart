import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/core/accessible_colors.dart';

void main() {
  group('AccessibleColors', () {
    test('should have WCAG compliant light theme colors', () {
      expect(AccessibleColors.lightSecondaryText, equals(const Color(0xFF424242)));
      expect(AccessibleColors.lightMutedText, equals(const Color(0xFF616161)));
    });

    test('should have WCAG compliant dark theme colors', () {
      expect(AccessibleColors.darkSecondaryText, equals(const Color(0xFFB3B3B3)));
      expect(AccessibleColors.darkMutedText, equals(const Color(0xFF9E9E9E)));
    });

    test('should have pre-calculated alpha colors for light theme', () {
      expect(AccessibleColors.lightSurfaceAlpha95, equals(const Color(0xF2FFFFFF)));
      expect(AccessibleColors.lightPrimaryAlpha90, equals(const Color(0xE6D84315)));
      expect(AccessibleColors.lightPrimaryAlpha10, equals(const Color(0x1AD84315)));
    });

    test('should have pre-calculated alpha colors for dark theme', () {
      expect(AccessibleColors.darkSurfaceAlpha95, equals(const Color(0xF21C1C1E)));
      expect(AccessibleColors.darkPrimaryAlpha90, equals(const Color(0xE6FF6B35)));
      expect(AccessibleColors.darkPrimaryAlpha10, equals(const Color(0x1AFF6B35)));
    });

    test('should have shadow colors', () {
      expect(AccessibleColors.shadowLight, equals(const Color(0x1A000000)));
      expect(AccessibleColors.shadowDark, equals(const Color(0x1A000000)));
    });

    testWidgets('getSecondaryTextColor should return light color in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getSecondaryTextColor(context);
              expect(color, equals(AccessibleColors.lightSecondaryText));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getSecondaryTextColor should return dark color in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getSecondaryTextColor(context);
              expect(color, equals(AccessibleColors.darkSecondaryText));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getMutedTextColor should return light color in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getMutedTextColor(context);
              expect(color, equals(AccessibleColors.lightMutedText));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getMutedTextColor should return dark color in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getMutedTextColor(context);
              expect(color, equals(AccessibleColors.darkMutedText));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getSurfaceAlpha95 should return light color in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getSurfaceAlpha95(context);
              expect(color, equals(AccessibleColors.lightSurfaceAlpha95));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getSurfaceAlpha95 should return dark color in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getSurfaceAlpha95(context);
              expect(color, equals(AccessibleColors.darkSurfaceAlpha95));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getPrimaryAlpha90 should return light color in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getPrimaryAlpha90(context);
              expect(color, equals(AccessibleColors.lightPrimaryAlpha90));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getPrimaryAlpha90 should return dark color in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getPrimaryAlpha90(context);
              expect(color, equals(AccessibleColors.darkPrimaryAlpha90));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getPrimaryAlpha10 should return light color in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getPrimaryAlpha10(context);
              expect(color, equals(AccessibleColors.lightPrimaryAlpha10));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getPrimaryAlpha10 should return dark color in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getPrimaryAlpha10(context);
              expect(color, equals(AccessibleColors.darkPrimaryAlpha10));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getShadowColor should return consistent color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getShadowColor(context);
              expect(color, equals(AccessibleColors.shadowLight));
              return Container();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final color = AccessibleColors.getShadowColor(context);
              expect(color, equals(AccessibleColors.shadowLight));
              return Container();
            },
          ),
        ),
      );
    });
  });
}
