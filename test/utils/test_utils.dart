import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUtils {
  static void setupMethodChannels() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock package_info
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/package_info'),
      (MethodCall methodCall) async {
        return {
          'appName': 'OldWisdom',
          'packageName': 'com.example.oldwisdom',
          'version': '1.0.0',
          'buildNumber': '1',
        };
      },
    );

    // Mock shared_preferences
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      },
    );

    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '/tmp/test';
      },
    );

    // Mock url_launcher
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (MethodCall methodCall) async {
        return true;
      },
    );

    // Mock share_plus
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/share_plus'),
      (MethodCall methodCall) async {
        return null;
      },
    );

    // Mock just_audio
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ryanheise.just_audio.methods'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'init':
            return 'test_player';
          case 'setAsset':
            return {'duration': 180000};
          case 'play':
          case 'pause':
          case 'stop':
          case 'setLoopMode':
          case 'setVolume':
          case 'dispose':
            return null;
          default:
            return null;
        }
      },
    );
  }
}
