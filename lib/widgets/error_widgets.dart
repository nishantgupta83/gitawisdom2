// lib/widgets/error_widgets.dart

import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../config/environment.dart';
import '../core/navigation/navigation_service.dart';

/// Error widgets for the app
/// Centralized error UI components for better consistency
class ErrorWidgets {
  /// Error app shown when initialization fails
  static Widget initializationError(Object error) {
    return MaterialApp(
      title: '${AppConfig.appName} - Configuration Error',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'The app could not initialize properly. Please check your configuration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (Environment.isDevelopment) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.red,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    // In production, this could trigger a restart mechanism
                    debugPrint('🔄 User requested app restart');
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Generic error widget for use within the app
  static Widget genericError({
    required String title,
    required String message,
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (details != null && AppConfig.isDebugMode) ...[
              const SizedBox(height: 16),
              Text(
                'Details: $details',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null) ...[
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                ],
                ElevatedButton(
                  onPressed: onGoHome ?? () => NavigationService.instance.goToHome(),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Network error widget
  static Widget networkError({VoidCallback? onRetry}) {
    return genericError(
      title: 'Network Error',
      message: 'Unable to connect to the internet. Please check your connection and try again.',
      onRetry: onRetry,
    );
  }

  /// Loading error widget
  static Widget loadingError({
    required String message,
    VoidCallback? onRetry,
  }) {
    return genericError(
      title: 'Loading Error',
      message: message,
      onRetry: onRetry,
    );
  }

  /// Not found error widget
  static Widget notFound({
    required String title,
    String? message,
  }) {
    return genericError(
      title: title,
      message: message ?? 'The requested content could not be found.',
    );
  }

  /// Service unavailable error widget
  static Widget serviceUnavailable({VoidCallback? onRetry}) {
    return genericError(
      title: 'Service Unavailable',
      message: 'The service is temporarily unavailable. Please try again later.',
      onRetry: onRetry,
    );
  }
}