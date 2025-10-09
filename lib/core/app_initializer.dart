// lib/core/app_initializer.dart

import 'dart:io' show Platform;
import 'dart:async' show TimeoutException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/environment.dart';
import '../services/settings_service.dart';
import '../services/daily_verse_service.dart';
import '../services/progressive_scenario_service.dart';
import '../services/journal_service.dart';
// import '../services/audio_service.dart'; // Removed - using EnhancedAudioService with lazy loading
import '../services/app_lifecycle_manager.dart';
import '../services/background_music_service.dart';
import '../services/service_locator.dart';
import '../services/notification_permission_service.dart';
// import 'hive_manager.dart'; // Removed for simplification
import 'performance_monitor.dart';
import 'ios_performance_optimizer.dart';
import 'ios_audio_session_manager.dart';
import 'ios_metal_optimizer.dart';
import 'app_config.dart';
import '../models/journal_entry.dart';
import '../models/scenario.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import '../models/chapter_summary.dart';
import '../models/daily_verse_set.dart';
import '../models/bookmark.dart';

/// Handles all app initialization logic
/// Separated from main.dart for better maintainability and testing
class AppInitializer {
  static Future<void> initializeCriticalServices() async {
    // Set full-screen app layout - ensure app uses full device size
    // Modern edge-to-edge handling compatible with Android 15
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // Only set SystemUiOverlayStyle on platforms where it's still effective (not Android 15+)
    // Android 15+ handles this through styles.xml configuration
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ));
      }
    } catch (e) {
      // Platform operations not supported on web
      debugPrint('⚠️ Platform operations skipped for web: $e');
    }

    try {
      // ✅ Critical initialization only - everything else will be lazy loaded
      Environment.validateConfiguration();

      // ✅ Initialize Supabase (essential for app functionality)
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
      );

      // ✅ Basic Hive setup only
      final appDocDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocDir.path);
      await SettingsService.init();

      // ✅ Initialize performance monitoring (debug builds only)
      PerformanceMonitor.instance.initialize();

      debugPrint('✅ Critical services initialized successfully');
    } catch (error, stackTrace) {
      debugPrint('❌ Critical initialization failed: $error');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Lazy initialization function called after app starts
  /// Non-critical services that can be loaded in background with timeout
  static Future<void> initializeSecondaryServices() async {
    try {
      // Add timeout to prevent hanging on slow devices - reduced for faster startup
      await Future.any([
        _performSecondaryInitialization(),
        Future.delayed(const Duration(seconds: 6)).then((_) {
          debugPrint('⏰ Secondary service initialization timed out after 6 seconds');
          throw TimeoutException('Secondary initialization timeout', const Duration(seconds: 6));
        }),
      ]);
    } catch (e) {
      debugPrint('⚠️ Secondary service initialization handled: $e');
      // Continue with app launch even if secondary services fail
    }
  }

  /// Perform secondary initialization with optimizations
  static Future<void> _performSecondaryInitialization() async {
    // Register Hive adapters first
    await Future.microtask(() async {
      try {
        // Register ALL required model adapters with correct typeIds
        // REMOVED: _clearOldHiveData() - was deleting all user data on every startup!
        if (!Hive.isAdapterRegistered(0)) {
          Hive.registerAdapter(JournalEntryAdapter()); // typeId: 0
        }
        if (!Hive.isAdapterRegistered(1)) {
          Hive.registerAdapter(ChapterAdapter()); // typeId: 1
        }
        if (!Hive.isAdapterRegistered(2)) {
          Hive.registerAdapter(DailyVerseSetAdapter()); // typeId: 2
        }
        if (!Hive.isAdapterRegistered(3)) {
          Hive.registerAdapter(ChapterSummaryAdapter()); // typeId: 3
        }
        if (!Hive.isAdapterRegistered(4)) {
          Hive.registerAdapter(VerseAdapter()); // typeId: 4
        }
        if (!Hive.isAdapterRegistered(5)) {
          Hive.registerAdapter(ScenarioAdapter()); // typeId: 5
        }
        if (!Hive.isAdapterRegistered(9)) {
          Hive.registerAdapter(BookmarkAdapter()); // typeId: 9
        }

        debugPrint('✅ Hive adapters registered successfully - user data preserved');
      } catch (e) {
        debugPrint('⚠️ Hive adapter registration warning: $e');
      }
    });

    // Initialize core services in parallel where possible
    await Future.wait([
      Future.microtask(() => _initializeCoreServices()),
      Future.microtask(() => _initializeBackgroundServices()),
    ]);

    debugPrint('✅ Secondary services initialized successfully');
  }

  static Future<void> _initializeCoreServices() async {
    // Initialize critical services first (fast ones)
    await Future.wait([
      // Journal service (fast - local only)
      JournalService.instance.initialize(),
      
      // Enhanced Supabase Service via Service Locator (fast - connection only)
      ServiceLocator.instance.initialize(),
      
      // Daily verse service (fast - cached)
      DailyVerseService.instance.initialize(),
    ]);
    
    // Initialize lightweight services immediately
    await Future.wait([
      // Practice services removed for Apple compliance simplification

      // iOS performance optimizations (fast - device detection only)
      IOSPerformanceOptimizer.instance.initialize(),

      // iOS audio session configuration (fast - audio setup only)
      IOSAudioSessionManager.instance.initialize(),

      // iOS Metal rendering optimizations (fast - Metal detection only)
      IOSMetalOptimizer.instance.initialize(),
    ]);
    
    // Initialize notification service last (can be deferred)
    // Practice notification service removed for Apple compliance
    
    // Initialize heavy services during splash screen (users expect splash to load)
    // Changed from unawaited() to await - scenarios load before home screen
    await _initializeHeavyServicesInBackground();

    // Initialize search indexing in background to prevent UI blocking on search screen access
    // unawaited(IntelligentScenarioSearch.instance.initialize()); // Temporarily disabled for auth testing
  }
  
  /// Initialize heavy services in background with proper thread management
  /// This prevents blocking the main UI thread during heavy operations
  static Future<void> _initializeHeavyServicesInBackground() async {
    try {
      debugPrint('🚀 Starting heavy service initialization in background');
      
      // Use chunked initialization to prevent blocking
      await _initializeScenarioServiceChunked();
      
      debugPrint('✅ Heavy services initialized successfully in background');
    } catch (e) {
      debugPrint('❌ Heavy service initialization failed: $e');
      // Continue gracefully - app can still function without scenarios initially
    }
  }
  
  /// Initialize ProgressiveScenarioService with instant startup
  static Future<void> _initializeScenarioServiceChunked() async {
    try {
      // Initialize progressive scenario service (instant startup with critical scenarios)
      await ProgressiveScenarioService.instance.initialize();

      debugPrint('📊 ProgressiveScenarioService initialized with instant startup');
      debugPrint('✅ Scenario service ready - critical scenarios available immediately');

      // No need for chunked loading - background loading happens automatically

    } catch (e) {
      debugPrint('❌ Progressive scenario initialization failed: $e');
      // Continue gracefully - app can function without scenarios initially
      // Removed problematic double initialization that caused "Future already completed" errors
    }
  }
  
  /// Progressive scenario loading is now handled automatically by ProgressiveScenarioService
  /// This method is no longer needed as background loading happens intelligently

  static Future<void> _initializeBackgroundServices() async {
    // Test Supabase connection
    try {
      final isConnected = await ServiceLocator.instance.enhancedSupabaseService.testConnection();
      if (!isConnected) {
        debugPrint('⚠️ Warning: Supabase connection failed - app may not load content properly');
      }
    } catch (e) {
      debugPrint('❌ Supabase connection test failed: $e');
    }

    // Request notification permissions (Android 13+)
    try {
      await NotificationPermissionService.instance.requestPermissionIfNeeded();
      debugPrint('🔔 Notification permission check completed');
    } catch (e) {
      debugPrint('⚠️ Notification permission request failed (non-critical): $e');
    }

    // Audio initialization is now handled lazily by EnhancedAudioService
    debugPrint('🎵 Audio system will initialize on-demand');

    // Initialize app lifecycle manager for background music control
    try {
      AppLifecycleManager.instance.initialize();
      debugPrint('🎵 App lifecycle manager initialized successfully');
    } catch (e) {
      debugPrint('❌ App lifecycle manager initialization failed: $e');
    }

    // Initialize background music service
    try {
      await BackgroundMusicService.instance.initialize();
      debugPrint('🎵 Background music service initialized successfully');

      // Start music if default enabled in config
      if (AppConfig.defaultMusicEnabled) {
        await BackgroundMusicService.instance.startMusic();
        debugPrint('🎵 Background music started automatically');
      }
    } catch (e) {
      debugPrint('❌ Background music initialization failed: $e');
    }
  }


}