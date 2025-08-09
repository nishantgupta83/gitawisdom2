// lib/config/environment.dart

/// Environment configuration service for GitaWisdom
/// Manages API keys and environment-specific settings securely
class Environment {
  // Private constructor to prevent instantiation
  Environment._();

  /// Supabase configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wlfwdtdtiedlcczfoslt.supabase.co', // Your actual Supabase URL
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU', // Your actual anon key
  );

  /// App environment settings
  static const String appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  /// Audio configuration
  static const String audioBaseUrl = String.fromEnvironment(
    'AUDIO_BASE_URL',
    defaultValue: 'assets/audio/',
  );

  /// API configuration
  static const int apiTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 30,
  );

  /// Validation methods
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  static bool get isDevelopment => appEnvironment == 'development';
  static bool get isProduction => appEnvironment == 'production';
  static bool get isStaging => appEnvironment == 'staging';

  /// Debug helper to check configuration (never logs sensitive data)
  static void validateConfiguration() {
    if (!isConfigured) {
      throw Exception(
        'Missing required environment variables. Please check your build configuration.',
      );
    }

    if (enableLogging && isDevelopment) {
      print('🏗️ Environment: $appEnvironment');
      print('🔧 Supabase URL configured: ${supabaseUrl.isNotEmpty}');
      print('🔑 Supabase Key configured: ${supabaseAnonKey.isNotEmpty}');
      print('📊 Analytics enabled: $enableAnalytics');
      print('📱 API timeout: ${apiTimeoutSeconds}s');
    }
  }

  /// Get configuration summary for debugging (safe for logs)
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': appEnvironment,
      'supabase_configured': supabaseUrl.isNotEmpty,
      'analytics_enabled': enableAnalytics,
      'logging_enabled': enableLogging,
      'api_timeout': apiTimeoutSeconds,
    };
  }
}