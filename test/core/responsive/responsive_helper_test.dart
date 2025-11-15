import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/core/responsive/responsive_helper.dart';

void main() {
  group('ResponsiveHelper', () {
    group('Constants', () {
      test('should have correct breakpoint values', () {
        expect(ResponsiveHelper.mobileSmallBreakpoint, equals(360));
        expect(ResponsiveHelper.mobileMediumBreakpoint, equals(380));
        expect(ResponsiveHelper.mobileLargeBreakpoint, equals(414));
        expect(ResponsiveHelper.tabletBreakpoint, equals(600));
        expect(ResponsiveHelper.desktopBreakpoint, equals(900));
      });
    });

    group('getDeviceType', () {
      testWidgets('should return mobileSmall for width < 360',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getDeviceType(context),
                    equals(DeviceType.mobileSmall));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return mobileMedium for width 360-379',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(370, 640)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getDeviceType(context),
                    equals(DeviceType.mobileMedium));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return mobileLarge for width 380-413',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getDeviceType(context),
                    equals(DeviceType.mobileLarge));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return mobileXLarge for width 414-599',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getDeviceType(context),
                    equals(DeviceType.mobileXLarge));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return tablet for width 600-899',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getDeviceType(context),
                    equals(DeviceType.tablet));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return desktop for width >= 900',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getDeviceType(context),
                    equals(DeviceType.desktop));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('isMobile', () {
      testWidgets('should return true for mobile widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isMobile(context), isTrue);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return false for tablet widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isMobile(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('isTablet', () {
      testWidgets('should return true for tablet widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isTablet(context), isTrue);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return false for mobile widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isTablet(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return false for desktop widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isTablet(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('isDesktop', () {
      testWidgets('should return true for desktop widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isDesktop(context), isTrue);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return false for mobile widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isDesktop(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getResponsiveFontSize', () {
      testWidgets('should scale font for mobileSmall',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 16,
                );
                expect(fontSize, equals(16 * 0.9));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should keep font size for mobileMedium',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(370, 640)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 16,
                );
                expect(fontSize, equals(16.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should scale font for mobileLarge',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 16,
                );
                expect(fontSize, equals(16 * 1.1));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should use custom tablet size if provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 16,
                  tabletSize: 20,
                );
                expect(fontSize, equals(20.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should use custom desktop size if provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 16,
                  desktopSize: 24,
                );
                expect(fontSize, equals(24.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should fallback to calculated desktop size',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobileSize: 16,
                );
                expect(fontSize, equals(16 * 1.5));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getResponsivePadding', () {
      testWidgets('should return mobile padding for mobile device',
          (WidgetTester tester) async {
        const mobilePadding = EdgeInsets.all(16);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: mobilePadding,
                );
                expect(padding, equals(mobilePadding));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should reduce padding for mobileSmall',
          (WidgetTester tester) async {
        const mobilePadding = EdgeInsets.all(16);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: mobilePadding,
                );
                expect(padding, equals(EdgeInsets.all(16 * 0.8)));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return tablet padding for tablet device',
          (WidgetTester tester) async {
        const tabletPadding = EdgeInsets.all(24);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(
                  context,
                  tablet: tabletPadding,
                );
                expect(padding, equals(tabletPadding));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return desktop padding for desktop device',
          (WidgetTester tester) async {
        const desktopPadding = EdgeInsets.all(32);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(
                  context,
                  desktop: desktopPadding,
                );
                expect(padding, equals(desktopPadding));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should use default values when not provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getResponsivePadding(context);
                expect(padding, isA<EdgeInsets>());
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getGridColumns', () {
      testWidgets('should return mobile columns for mobile device',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(370, 640)),
            child: Builder(
              builder: (context) {
                final columns = ResponsiveHelper.getGridColumns(context);
                expect(columns, equals(2));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should reduce columns for mobileSmall',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: Builder(
              builder: (context) {
                final columns = ResponsiveHelper.getGridColumns(
                  context,
                  mobileColumns: 2,
                );
                expect(columns, equals(1));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return tablet columns for tablet device',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final columns = ResponsiveHelper.getGridColumns(context);
                expect(columns, equals(3));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return desktop columns for desktop device',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final columns = ResponsiveHelper.getGridColumns(context);
                expect(columns, equals(4));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should use custom column values',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final columns = ResponsiveHelper.getGridColumns(
                  context,
                  mobileColumns: 1,
                  tabletColumns: 5,
                  desktopColumns: 6,
                );
                expect(columns, equals(5));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getCardWidth', () {
      testWidgets('should calculate card width for mobile',
          (WidgetTester tester) async {
        const screenWidth = 370.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(screenWidth, 640)),
            child: Builder(
              builder: (context) {
                final width = ResponsiveHelper.getCardWidth(context);
                expect(width, equals(screenWidth - 48));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should calculate card width for mobileSmall',
          (WidgetTester tester) async {
        const screenWidth = 320.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(screenWidth, 640)),
            child: Builder(
              builder: (context) {
                final width = ResponsiveHelper.getCardWidth(context);
                expect(width, equals(screenWidth - 32));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should calculate card width for tablet',
          (WidgetTester tester) async {
        const screenWidth = 768.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(screenWidth, 1024)),
            child: Builder(
              builder: (context) {
                final width = ResponsiveHelper.getCardWidth(context);
                expect(width, equals((screenWidth - 72) / 2));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should calculate card width for desktop',
          (WidgetTester tester) async {
        const screenWidth = 1200.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(screenWidth, 800)),
            child: Builder(
              builder: (context) {
                final width = ResponsiveHelper.getCardWidth(context);
                expect(width, equals((screenWidth - 96) / 3));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('hasNotch', () {
      testWidgets('should return true for devices with notch',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              viewPadding: EdgeInsets.only(top: 44),
            ),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.hasNotch(context), isTrue);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return false for devices without notch',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              viewPadding: EdgeInsets.only(top: 20),
            ),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.hasNotch(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getSafeAreaPadding', () {
      testWidgets('should return correct padding for device with notch',
          (WidgetTester tester) async {
        const viewPadding = EdgeInsets.only(top: 44, bottom: 34);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              viewPadding: viewPadding,
            ),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getSafeAreaPadding(context);
                expect(padding.top, equals(44));
                expect(padding.bottom, equals(34));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return correct padding for device without notch',
          (WidgetTester tester) async {
        const viewPadding = EdgeInsets.only(top: 20, bottom: 0);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              viewPadding: viewPadding,
            ),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveHelper.getSafeAreaPadding(context);
                expect(padding.top, equals(0));
                expect(padding.bottom, equals(16));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getImageHeight', () {
      testWidgets('should reduce height for mobileSmall',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getImageHeight(
                  context,
                  baseHeight: 200,
                );
                expect(height, equals(200 * 0.8));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should keep height for mobileMedium',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(370, 640)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getImageHeight(
                  context,
                  baseHeight: 200,
                );
                expect(height, equals(200.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should increase height for tablet',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getImageHeight(
                  context,
                  baseHeight: 200,
                );
                expect(height, equals(200 * 1.3));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should increase height for desktop',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getImageHeight(
                  context,
                  baseHeight: 200,
                );
                expect(height, equals(200 * 1.5));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getApproximateRAMCategory', () {
      testWidgets('should return low for small screens',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              devicePixelRatio: 2.0,
            ),
            child: Builder(
              builder: (context) {
                final category =
                    ResponsiveHelper.getApproximateRAMCategory(context);
                // 320 * 640 * 2.0 = 409,600 pixels < 2,000,000
                expect(category, equals(DeviceRAMCategory.low));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return medium for medium screens',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(750, 1334),
              devicePixelRatio: 2.0,
            ),
            child: Builder(
              builder: (context) {
                final category =
                    ResponsiveHelper.getApproximateRAMCategory(context);
                // 750 * 1334 * 2.0 = 2,001,000 pixels (2M < x < 4M)
                expect(category, equals(DeviceRAMCategory.medium));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return high for large screens',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(1125, 2436),
              devicePixelRatio: 3.0,
            ),
            child: Builder(
              builder: (context) {
                final category =
                    ResponsiveHelper.getApproximateRAMCategory(context);
                // 1125 * 2436 * 3.0 = 8,216,100 pixels > 4,000,000
                expect(category, equals(DeviceRAMCategory.high));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('shouldUseHighQualityImages', () {
      testWidgets('should return false for low RAM devices',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              devicePixelRatio: 2.0,
            ),
            child: Builder(
              builder: (context) {
                expect(
                    ResponsiveHelper.shouldUseHighQualityImages(context), isFalse);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return true for medium/high RAM devices',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(750, 1334),
              devicePixelRatio: 2.0,
            ),
            child: Builder(
              builder: (context) {
                expect(
                    ResponsiveHelper.shouldUseHighQualityImages(context), isTrue);
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('getListItemHeight', () {
      testWidgets('should return compact height for mobileSmall',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getListItemHeight(context);
                expect(height, equals(72.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return standard height for mobileMedium',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(370, 640)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getListItemHeight(context);
                expect(height, equals(80.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return larger height for tablet',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getListItemHeight(context);
                expect(height, equals(96.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return largest height for desktop',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final height = ResponsiveHelper.getListItemHeight(context);
                expect(height, equals(104.0));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('DeviceType enum', () {
      test('should have all device types', () {
        expect(DeviceType.values.length, equals(6));
        expect(DeviceType.values, contains(DeviceType.mobileSmall));
        expect(DeviceType.values, contains(DeviceType.mobileMedium));
        expect(DeviceType.values, contains(DeviceType.mobileLarge));
        expect(DeviceType.values, contains(DeviceType.mobileXLarge));
        expect(DeviceType.values, contains(DeviceType.tablet));
        expect(DeviceType.values, contains(DeviceType.desktop));
      });
    });

    group('DeviceRAMCategory enum', () {
      test('should have all RAM categories', () {
        expect(DeviceRAMCategory.values.length, equals(3));
        expect(DeviceRAMCategory.values, contains(DeviceRAMCategory.low));
        expect(DeviceRAMCategory.values, contains(DeviceRAMCategory.medium));
        expect(DeviceRAMCategory.values, contains(DeviceRAMCategory.high));
      });
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('should build with correct device type',
        (WidgetTester tester) async {
      DeviceType? capturedDeviceType;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(768, 1024)),
          child: ResponsiveBuilder(
            builder: (context, deviceType) {
              capturedDeviceType = deviceType;
              return Container();
            },
          ),
        ),
      );

      expect(capturedDeviceType, equals(DeviceType.tablet));
    });

    testWidgets('should rebuild on size change', (WidgetTester tester) async {
      final deviceTypes = <DeviceType>[];

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: ResponsiveBuilder(
            builder: (context, deviceType) {
              deviceTypes.add(deviceType);
              return Container();
            },
          ),
        ),
      );

      expect(deviceTypes.last, equals(DeviceType.mobileLarge));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(768, 1024)),
          child: ResponsiveBuilder(
            builder: (context, deviceType) {
              deviceTypes.add(deviceType);
              return Container();
            },
          ),
        ),
      );

      expect(deviceTypes.last, equals(DeviceType.tablet));
    });
  });

  group('ResponsiveVisibility', () {
    testWidgets('should hide on mobile when hiddenOnMobile is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: const ResponsiveVisibility(
              hiddenOnMobile: true,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('should show on mobile when hiddenOnMobile is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: const ResponsiveVisibility(
              hiddenOnMobile: false,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should hide on tablet when hiddenOnTablet is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: const ResponsiveVisibility(
              hiddenOnTablet: true,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('should show on tablet when hiddenOnTablet is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: const ResponsiveVisibility(
              hiddenOnTablet: false,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should hide on desktop when hiddenOnDesktop is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: const ResponsiveVisibility(
              hiddenOnDesktop: true,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('should show on desktop when hiddenOnDesktop is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: const ResponsiveVisibility(
              hiddenOnDesktop: false,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
