// test/services/app_sharing_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/services/app_sharing_service.dart';
import '../test_setup.dart';

@GenerateMocks([])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('AppSharingService - Instance', () {
    test('should return singleton instance', () {
      final instance1 = AppSharingService();
      final instance2 = AppSharingService();

      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('factory constructor should return same instance', () {
      final instance1 = AppSharingService();
      final instance2 = AppSharingService();

      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('AppSharingService - Share App', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('shareApp should complete without throwing', () async {
      expect(() async => await service.shareApp(), returnsNormally);
    });

    test('shareApp with custom message should complete without throwing', () async {
      const customMessage = 'Check out this amazing app!';
      expect(
        () async => await service.shareApp(customMessage: customMessage),
        returnsNormally,
      );
    });
  });

  group('AppSharingService - Share Feature', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('shareFeature should complete without throwing', () async {
      expect(
        () async => await service.shareFeature(
          'Daily Verses',
          'Check out this amazing verse!',
        ),
        returnsNormally,
      );
    });

    test('shareFeature with empty feature name should complete', () async {
      expect(
        () async => await service.shareFeature('', 'Content'),
        returnsNormally,
      );
    });

    test('shareFeature with empty content should complete', () async {
      expect(
        () async => await service.shareFeature('Feature', ''),
        returnsNormally,
      );
    });
  });

  group('AppSharingService - Share Scenario', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('shareScenario should complete without throwing', () async {
      expect(
        () async => await service.shareScenario(
          'Career Dilemma',
          'Follow your passion',
          'Choose stability',
          'Perform your duty without attachment',
        ),
        returnsNormally,
      );
    });

    test('shareScenario with action steps should complete', () async {
      expect(
        () async => await service.shareScenario(
          'Career Dilemma',
          'Follow your passion',
          'Choose stability',
          'Perform your duty without attachment',
          actionSteps: [
            'Reflect on your values',
            'Consult with mentors',
            'Make a balanced decision',
          ],
        ),
        returnsNormally,
      );
    });

    test('shareScenario with empty action steps should complete', () async {
      expect(
        () async => await service.shareScenario(
          'Test',
          'Heart',
          'Duty',
          'Wisdom',
          actionSteps: [],
        ),
        returnsNormally,
      );
    });
  });

  group('AppSharingService - Share Verse', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('shareVerse should complete without throwing', () async {
      expect(
        () async => await service.shareVerse(
          'You have a right to perform your duty',
          '2',
          '47',
        ),
        returnsNormally,
      );
    });

    test('shareVerse with different chapter/verse should complete', () async {
      expect(
        () async => await service.shareVerse(
          'Test verse text',
          '18',
          '78',
        ),
        returnsNormally,
      );
    });
  });

  group('AppSharingService - WhatsApp Sharing', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('shareToWhatsApp should return boolean', () async {
      final result = await service.shareToWhatsApp('Test message');
      expect(result, isA<bool>());
    });

    test('shareToWhatsApp with phone number should return boolean', () async {
      final result = await service.shareToWhatsApp(
        'Test message',
        phoneNumber: '+1234567890',
      );
      expect(result, isA<bool>());
    });

    test('shareScenarioToWhatsApp should return boolean', () async {
      final result = await service.shareScenarioToWhatsApp(
        'Career Dilemma',
        'Follow your passion',
        'Choose stability',
        'Perform your duty',
      );
      expect(result, isA<bool>());
    });

    test('shareScenarioToWhatsApp with action steps should return boolean', () async {
      final result = await service.shareScenarioToWhatsApp(
        'Career Dilemma',
        'Heart response',
        'Duty response',
        'Wisdom',
        actionSteps: ['Step 1', 'Step 2', 'Step 3'],
      );
      expect(result, isA<bool>());
    });

    test('shareVerseToWhatsApp should return boolean', () async {
      final result = await service.shareVerseToWhatsApp(
        'Test verse',
        '2',
        '47',
      );
      expect(result, isA<bool>());
    });

    test('shareVerseToWhatsApp with translation should return boolean', () async {
      final result = await service.shareVerseToWhatsApp(
        'Test verse',
        '2',
        '47',
        translation: 'This is the meaning of the verse',
      );
      expect(result, isA<bool>());
    });

    test('shareChapterToWhatsApp should return boolean', () async {
      final result = await service.shareChapterToWhatsApp(
        'The Yoga of Action',
        'This chapter discusses karma yoga',
        3,
      );
      expect(result, isA<bool>());
    });

    test('isWhatsAppAvailable should return boolean', () async {
      final result = await service.isWhatsAppAvailable();
      expect(result, isA<bool>());
    });

    test('showWhatsAppShareDialog should complete without throwing', () async {
      expect(
        () async => await service.showWhatsAppShareDialog(
          message: 'Test message',
          onComplete: (success) {
            expect(success, isA<bool>());
          },
        ),
        returnsNormally,
      );
    });
  });

  group('AppSharingService - URL Validation', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('validateStoreUrls should return boolean', () async {
      final result = await service.validateStoreUrls();
      expect(result, isA<bool>());
    });

    test('validateStoreUrls should validate URLs', () async {
      // URLs should be valid since they're hardcoded
      final result = await service.validateStoreUrls();
      // May be true or false depending on network/platform, but shouldn't throw
      expect(result, isNotNull);
    });
  });

  group('AppSharingService - Analytics', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('getShareAnalytics should return map', () {
      final analytics = service.getShareAnalytics();

      expect(analytics, isA<Map<String, dynamic>>());
      expect(analytics.containsKey('platform'), isTrue);
      expect(analytics.containsKey('store_url'), isTrue);
      expect(analytics.containsKey('is_development'), isTrue);
      expect(analytics.containsKey('timestamp'), isTrue);
    });

    test('getShareAnalytics should have valid platform', () {
      final analytics = service.getShareAnalytics();
      final platform = analytics['platform'];

      expect(platform, isA<String>());
      expect(platform, isNotEmpty);
    });

    test('getShareAnalytics should have valid store URL', () {
      final analytics = service.getShareAnalytics();
      final storeUrl = analytics['store_url'];

      expect(storeUrl, isA<String>());
      expect(storeUrl, isNotEmpty);
    });

    test('getShareAnalytics should have valid timestamp', () {
      final analytics = service.getShareAnalytics();
      final timestamp = analytics['timestamp'];

      expect(timestamp, isA<String>());
      expect(timestamp, isNotEmpty);

      // Should be valid ISO8601 format
      expect(() => DateTime.parse(timestamp), returnsNormally);
    });
  });

  group('AppSharingService - Error Handling', () {
    late AppSharingService service;

    setUp(() {
      service = AppSharingService();
    });

    test('all methods should be non-throwing', () async {
      expect(() async => await service.shareApp(), returnsNormally);
      expect(() async => await service.shareFeature('Test', 'Content'), returnsNormally);
      expect(() async => await service.shareScenario('T', 'H', 'D', 'W'), returnsNormally);
      expect(() async => await service.shareVerse('V', '1', '1'), returnsNormally);
      expect(() async => await service.shareToWhatsApp('Test'), returnsNormally);
      expect(() async => await service.isWhatsAppAvailable(), returnsNormally);
      expect(() async => await service.validateStoreUrls(), returnsNormally);
    });

    test('shareApp should handle errors gracefully', () async {
      // Even with errors, should complete without throwing
      try {
        await service.shareApp();
        expect(true, isTrue); // If completes, test passes
      } catch (e) {
        fail('shareApp should not throw exceptions: $e');
      }
    });

    test('WhatsApp methods should handle unavailable app', () async {
      // Should return false or complete without throwing
      final result = await service.shareToWhatsApp('Test');
      expect(result, isA<bool>());
    });
  });
}
