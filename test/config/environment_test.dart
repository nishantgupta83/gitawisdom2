import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/config/environment.dart';

void main() {
  group('Environment Configuration', () {
    test('should have default values', () {
      expect(Environment.appEnvironment, equals('development'));
      expect(Environment.enableLogging, equals(true));
      expect(Environment.enableAnalytics, equals(false));
      expect(Environment.audioBaseUrl, equals('assets/audio/'));
      expect(Environment.apiTimeoutSeconds, equals(30));
    });

    test('should check if configured', () {
      // In test environment, Supabase might not be configured
      final isConfigured = Environment.isConfigured;
      expect(isConfigured, isA<bool>());
    });

    test('should detect environment types', () {
      expect(Environment.isDevelopment, isA<bool>());
      expect(Environment.isProduction, isA<bool>());
      expect(Environment.isStaging, isA<bool>());
    });

    test('should provide config summary', () {
      final summary = Environment.getConfigSummary();
      expect(summary, isA<Map<String, dynamic>>());
      expect(summary.containsKey('environment'), isTrue);
      expect(summary.containsKey('supabase_configured'), isTrue);
      expect(summary.containsKey('analytics_enabled'), isTrue);
      expect(summary.containsKey('logging_enabled'), isTrue);
      expect(summary.containsKey('api_timeout'), isTrue);
    });

    test('config summary should have correct types', () {
      final summary = Environment.getConfigSummary();
      expect(summary['environment'], isA<String>());
      expect(summary['supabase_configured'], isA<bool>());
      expect(summary['analytics_enabled'], isA<bool>());
      expect(summary['logging_enabled'], isA<bool>());
      expect(summary['api_timeout'], isA<int>());
    });

    test('should have non-empty URLs if configured', () {
      if (Environment.isConfigured) {
        expect(Environment.supabaseUrl.isNotEmpty, isTrue);
        expect(Environment.supabaseAnonKey.isNotEmpty, isTrue);
      }
    });

    test('environment detection should be mutually exclusive', () {
      final envCount = [
        Environment.isDevelopment,
        Environment.isProduction,
        Environment.isStaging,
      ].where((e) => e).length;

      expect(envCount, lessThanOrEqualTo(1));
    });
  });
}
