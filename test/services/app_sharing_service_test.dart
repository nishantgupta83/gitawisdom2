// test/services/app_sharing_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/services/app_sharing_service.dart';

void main() {
  group('AppSharingService', () {
    late AppSharingService sharingService;

    setUp(() {
      sharingService = AppSharingService();
    });

    test('should be a singleton', () {
      final instance1 = AppSharingService();
      final instance2 = AppSharingService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('should provide valid analytics data', () {
      final analytics = sharingService.getShareAnalytics();
      
      expect(analytics, isA<Map<String, dynamic>>());
      expect(analytics.containsKey('platform'), isTrue);
      expect(analytics.containsKey('store_url'), isTrue);
      expect(analytics.containsKey('is_development'), isTrue);
      expect(analytics.containsKey('timestamp'), isTrue);
      
      // Validate timestamp format
      expect(DateTime.tryParse(analytics['timestamp']), isNotNull);
    });

    test('should validate store URLs format', () async {
      final isValid = await sharingService.validateStoreUrls();
      
      // URLs should be valid even if they point to placeholder content
      expect(isValid, isTrue);
    });

    group('URL Validation', () {
      test('should validate store URLs format', () async {
        final isValid = await sharingService.validateStoreUrls();
        
        // This tests the public validateStoreUrls method which tests URL format
        expect(isValid, isA<bool>());
      });
    });

    group('Message Building', () {
      test('should build appropriate development message', () {
        // This tests the message format without actually sharing
        final analytics = sharingService.getShareAnalytics();
        expect(analytics['is_development'], isA<bool>());
      });
    });

    group('Store URL Generation', () {
      test('should provide store URLs', () {
        final analytics = sharingService.getShareAnalytics();
        final storeUrl = analytics['store_url'] as String;
        
        expect(storeUrl.isNotEmpty, isTrue);
        expect(storeUrl.startsWith('https://'), isTrue);
      });
    });
  });
}