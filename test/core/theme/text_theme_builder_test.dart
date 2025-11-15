import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/core/theme/text_theme_builder.dart';
import 'package:GitaWisdom/core/app_config.dart';

void main() {
  group('TextThemeBuilder', () {
    late TextTheme baseTheme;

    setUp(() {
      baseTheme = const TextTheme(
        displayLarge: TextStyle(fontSize: 96),
        displayMedium: TextStyle(fontSize: 60),
        displaySmall: TextStyle(fontSize: 48),
        headlineLarge: TextStyle(fontSize: 40),
        headlineMedium: TextStyle(fontSize: 34),
        headlineSmall: TextStyle(fontSize: 24),
        titleLarge: TextStyle(fontSize: 20),
        titleMedium: TextStyle(fontSize: 16),
        titleSmall: TextStyle(fontSize: 14),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
        labelLarge: TextStyle(fontSize: 14),
        labelMedium: TextStyle(fontSize: 12),
        labelSmall: TextStyle(fontSize: 11),
      );
    });

    group('buildTextThemeWithShadows', () {
      test('should return base theme when shadows disabled', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, false);

        expect(result, equals(baseTheme));
        expect(result.displayLarge?.shadows, isNull);
        expect(result.bodyLarge?.shadows, isNull);
      });

      test('should add shadows when enabled', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(result.displayLarge?.shadows, isNotNull);
        expect(result.displayLarge?.shadows, isNotEmpty);
        expect(result.bodyLarge?.shadows, isNotNull);
        expect(result.bodyLarge?.shadows, isNotEmpty);
      });

      test('should add header shadows to all display styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(result.displayLarge?.shadows, isNotEmpty);
        expect(result.displayMedium?.shadows, isNotEmpty);
        expect(result.displaySmall?.shadows, isNotEmpty);
      });

      test('should add header shadows to all headline styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(result.headlineLarge?.shadows, isNotEmpty);
        expect(result.headlineMedium?.shadows, isNotEmpty);
        expect(result.headlineSmall?.shadows, isNotEmpty);
      });

      test('should add body shadows to all title styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(result.titleLarge?.shadows, isNotEmpty);
        expect(result.titleMedium?.shadows, isNotEmpty);
        expect(result.titleSmall?.shadows, isNotEmpty);
      });

      test('should add body shadows to all body styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(result.bodyLarge?.shadows, isNotEmpty);
        expect(result.bodyMedium?.shadows, isNotEmpty);
        expect(result.bodySmall?.shadows, isNotEmpty);
      });

      test('should add label shadows to all label styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(result.labelLarge?.shadows, isNotEmpty);
        expect(result.labelMedium?.shadows, isNotEmpty);
        expect(result.labelSmall?.shadows, isNotEmpty);
      });

      test('should preserve font sizes', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(result.displayLarge?.fontSize, equals(96));
        expect(result.bodyLarge?.fontSize, equals(16));
        expect(result.labelSmall?.fontSize, equals(11));
      });
    });

    group('Header Shadows', () {
      test('should have correct number of shadows', () {
        final shadows = TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true)
            .displayLarge
            ?.shadows;

        expect(shadows?.length, equals(1));
      });

      test('should use iOS shadow configuration on iOS', () {
        // This test assumes running on iOS simulator/device
        // In practice, you'd mock Platform.isIOS
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);
        final shadow = result.displayLarge?.shadows?.first;

        expect(shadow, isNotNull);
        if (Platform.isIOS) {
          expect(shadow!.blurRadius, equals(AppConfig.iOSHeaderShadowBlur));
          expect(shadow.offset, equals(const Offset(1.5, 1.5)));
          expect(shadow.color, isNot(equals(Colors.transparent)));
        }
      });

      test('should use transparent shadow on Android', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);
        final shadow = result.displayLarge?.shadows?.first;

        expect(shadow, isNotNull);
        if (!Platform.isIOS) {
          expect(shadow!.color, equals(Colors.transparent));
          expect(shadow.offset, equals(const Offset(0.0, 0.0)));
          expect(shadow.blurRadius, equals(0.0));
        }
      });
    });

    group('Body Shadows', () {
      test('should have correct number of shadows', () {
        final shadows = TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true)
            .bodyLarge
            ?.shadows;

        expect(shadows?.length, equals(1));
      });

      test('should use iOS shadow configuration on iOS', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);
        final shadow = result.bodyLarge?.shadows?.first;

        expect(shadow, isNotNull);
        if (Platform.isIOS) {
          expect(shadow!.blurRadius, equals(AppConfig.iOSBodyShadowBlur));
          expect(shadow.offset, equals(const Offset(1.0, 1.0)));
        }
      });

      test('should use transparent shadow on Android', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);
        final shadow = result.bodyLarge?.shadows?.first;

        expect(shadow, isNotNull);
        if (!Platform.isIOS) {
          expect(shadow!.color, equals(Colors.transparent));
        }
      });
    });

    group('Label Shadows', () {
      test('should have correct number of shadows', () {
        final shadows = TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true)
            .labelLarge
            ?.shadows;

        expect(shadows?.length, equals(1));
      });

      test('should use iOS shadow configuration on iOS', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);
        final shadow = result.labelLarge?.shadows?.first;

        expect(shadow, isNotNull);
        if (Platform.isIOS) {
          expect(shadow!.blurRadius, equals(AppConfig.iOSLabelShadowBlur));
          expect(shadow.offset, equals(const Offset(0.8, 0.8)));
          expect(shadow.color, equals(Colors.black45));
        }
      });

      test('should use transparent shadow on Android', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);
        final shadow = result.labelLarge?.shadows?.first;

        expect(shadow, isNotNull);
        if (!Platform.isIOS) {
          expect(shadow!.color, equals(Colors.transparent));
        }
      });
    });

    group('createCustomShadow', () {
      test('should create shadow with specified parameters', () {
        const color = Colors.red;
        const offset = Offset(2.0, 3.0);
        const blurRadius = 5.0;

        final shadows = TextThemeBuilder.createCustomShadow(
          color: color,
          offset: offset,
          blurRadius: blurRadius,
        );

        expect(shadows.length, equals(1));
        expect(shadows.first.color, equals(color));
        expect(shadows.first.offset, equals(offset));
        expect(shadows.first.blurRadius, equals(blurRadius));
      });

      test('should create shadow with zero offset', () {
        final shadows = TextThemeBuilder.createCustomShadow(
          color: Colors.blue,
          offset: Offset.zero,
          blurRadius: 10.0,
        );

        expect(shadows.first.offset, equals(Offset.zero));
      });

      test('should create shadow with zero blur radius', () {
        final shadows = TextThemeBuilder.createCustomShadow(
          color: Colors.green,
          offset: const Offset(1.0, 1.0),
          blurRadius: 0.0,
        );

        expect(shadows.first.blurRadius, equals(0.0));
      });

      test('should create shadow with transparent color', () {
        final shadows = TextThemeBuilder.createCustomShadow(
          color: Colors.transparent,
          offset: const Offset(1.0, 1.0),
          blurRadius: 5.0,
        );

        expect(shadows.first.color, equals(Colors.transparent));
      });

      test('should create shadow with large blur radius', () {
        final shadows = TextThemeBuilder.createCustomShadow(
          color: Colors.black,
          offset: const Offset(1.0, 1.0),
          blurRadius: 100.0,
        );

        expect(shadows.first.blurRadius, equals(100.0));
      });

      test('should create shadow with negative offset', () {
        final shadows = TextThemeBuilder.createCustomShadow(
          color: Colors.black,
          offset: const Offset(-2.0, -3.0),
          blurRadius: 5.0,
        );

        expect(shadows.first.offset, equals(const Offset(-2.0, -3.0)));
      });
    });

    group('Edge Cases', () {
      test('should handle null text styles in base theme', () {
        const emptyTheme = TextTheme();
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(emptyTheme, true);

        expect(result, isA<TextTheme>());
      });

      test('should not modify original base theme', () {
        final originalTheme = baseTheme;
        TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        expect(baseTheme.displayLarge?.shadows, equals(originalTheme.displayLarge?.shadows));
      });

      test('should work with theme that already has shadows', () {
        final themeWithShadows = baseTheme.copyWith(
          displayLarge: baseTheme.displayLarge?.copyWith(
            shadows: [
              const Shadow(
                color: Colors.red,
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
              ),
            ],
          ),
        );

        final result =
            TextThemeBuilder.buildTextThemeWithShadows(themeWithShadows, true);

        expect(result.displayLarge?.shadows, isNotEmpty);
      });
    });

    group('Platform-specific Behavior', () {
      test('should apply different shadows based on platform', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        final headerShadow = result.displayLarge?.shadows?.first;
        final bodyShadow = result.bodyLarge?.shadows?.first;
        final labelShadow = result.labelLarge?.shadows?.first;

        if (Platform.isIOS) {
          expect(headerShadow?.blurRadius, greaterThan(0));
          expect(bodyShadow?.blurRadius, greaterThan(0));
          expect(labelShadow?.blurRadius, greaterThan(0));
        } else {
          expect(headerShadow?.color, equals(Colors.transparent));
          expect(bodyShadow?.color, equals(Colors.transparent));
          expect(labelShadow?.color, equals(Colors.transparent));
        }
      });

      test('should use AppConfig values for iOS shadows', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        if (Platform.isIOS) {
          expect(
            result.displayLarge?.shadows?.first.blurRadius,
            equals(AppConfig.iOSHeaderShadowBlur),
          );
          expect(
            result.bodyLarge?.shadows?.first.blurRadius,
            equals(AppConfig.iOSBodyShadowBlur),
          );
          expect(
            result.labelLarge?.shadows?.first.blurRadius,
            equals(AppConfig.iOSLabelShadowBlur),
          );
        }
      });
    });

    group('Shadow Consistency', () {
      test('should apply same header shadows to all display styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        final displayLargeShadow = result.displayLarge?.shadows?.first;
        final displayMediumShadow = result.displayMedium?.shadows?.first;
        final displaySmallShadow = result.displaySmall?.shadows?.first;

        expect(displayLargeShadow?.color, equals(displayMediumShadow?.color));
        expect(displayMediumShadow?.color, equals(displaySmallShadow?.color));
        expect(displayLargeShadow?.blurRadius, equals(displayMediumShadow?.blurRadius));
      });

      test('should apply same body shadows to all title and body styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        final titleShadow = result.titleLarge?.shadows?.first;
        final bodyShadow = result.bodyLarge?.shadows?.first;

        expect(titleShadow?.color, equals(bodyShadow?.color));
        expect(titleShadow?.blurRadius, equals(bodyShadow?.blurRadius));
        expect(titleShadow?.offset, equals(bodyShadow?.offset));
      });

      test('should apply same label shadows to all label styles', () {
        final result =
            TextThemeBuilder.buildTextThemeWithShadows(baseTheme, true);

        final labelLargeShadow = result.labelLarge?.shadows?.first;
        final labelMediumShadow = result.labelMedium?.shadows?.first;
        final labelSmallShadow = result.labelSmall?.shadows?.first;

        expect(labelLargeShadow?.color, equals(labelMediumShadow?.color));
        expect(labelMediumShadow?.color, equals(labelSmallShadow?.color));
      });
    });
  });
}
