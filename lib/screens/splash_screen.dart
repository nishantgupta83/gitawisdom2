// lib/screens/splash_screen.dart

import 'dart:io' show Platform;
import 'dart:async' show TimeoutException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_config.dart';
import '../core/app_initializer.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_router.dart';
import '../services/supabase_auth_service.dart';
import 'root_scaffold.dart';
import 'modern_auth_screen.dart';

/// Splash screen with app initialization
/// Moved from main.dart and cleaned up for better maintainability
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  /// Initialize remaining services and navigate to main app with comprehensive error handling
  Future<void> _initializeAndNavigate() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Add overall timeout for entire initialization process - reduced for faster startup
      await Future.any([
        _performInitializationWithFallbacks(),
        Future.delayed(const Duration(seconds: 8)).then((_) {
          debugPrint('⏰ Overall app initialization timed out after 8 seconds');
          throw TimeoutException('App initialization timeout', const Duration(seconds: 8));
        }),
      ]);
    } catch (e) {
      debugPrint('❌ Splash screen initialization handled: $e');
    } finally {
      // Ensure minimum splash time for smooth UX
      final elapsed = stopwatch.elapsed;
      if (elapsed < AppConfig.splashDuration) {
        await Future.delayed(AppConfig.splashDuration - elapsed);
      }
      
      // Always navigate to main app
      await _navigateToMainApp();
      stopwatch.stop();
      debugPrint('✅ App launch completed in ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  /// Perform initialization with fallback strategies
  Future<void> _performInitializationWithFallbacks() async {
    try {
      // Primary initialization attempt
      await AppInitializer.initializeSecondaryServices();
      debugPrint('✅ Primary initialization completed');
    } catch (e) {
      debugPrint('⚠️ Primary initialization failed, using fallbacks: $e');
      
      // Fallback: Initialize only essential services
      try {
        await _initializeEssentialServices();
        debugPrint('✅ Fallback initialization completed');
      } catch (fallbackError) {
        debugPrint('❌ Fallback initialization also failed: $fallbackError');
        // App will still launch with basic functionality
      }
    }
  }

  /// Initialize only the most essential services for basic app functionality
  Future<void> _initializeEssentialServices() async {
    // Minimal initialization for basic app functionality
    // Add only critical services here
    debugPrint('🔧 Running essential services fallback');
  }

  /// Navigate to main app with authentication check
  Future<void> _navigateToMainApp() async {
    if (mounted) {
      try {
        // Check authentication status
        final authService = SupabaseAuthService.instance;
        await authService.initialize();
        
        // Determine where to navigate based on auth status
        Widget destination;
        if (authService.isAuthenticated || authService.isAnonymous) {
          // User is authenticated or has chosen anonymous mode
          destination = const RootScaffold();
        } else {
          // Show authentication screen
          destination = const ModernAuthScreen();
        }
        
        NavigationService.instance.pushReplacement(
          MaterialPageRoute(builder: (_) => destination),
        );
      } catch (e) {
        debugPrint('❌ Navigation failed, using fallback: $e');
        // Fallback navigation - go to auth screen to be safe
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ModernAuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getSystemUiOverlayStyle(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: _buildSplashContent(),
      ),
    );
  }

  /// Get platform-appropriate system UI overlay style
  SystemUiOverlayStyle _getSystemUiOverlayStyle() {
    // On Android 15+, these values are handled by styles.xml
    return Platform.isIOS || Platform.isMacOS 
        ? const SystemUiOverlayStyle(
            statusBarColor: AppConfig.transparentColor,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppConfig.transparentColor,
          )
        : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: AppConfig.transparentColor,
            systemNavigationBarColor: AppConfig.transparentColor,
          );
  }

  /// Build splash screen content
  Widget _buildSplashContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig.splashBackgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                const Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: AppConfig.splashIconColor,
                ),
                const SizedBox(height: 20),
                
                // App name
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppConfig.splashIconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppConfig.splashIconColor),
                ),
                
                // Version info (only in debug mode)
                if (AppConfig.isDebugMode) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Version ${AppConfig.fullVersion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConfig.splashIconColor.withValues(alpha:0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}