// lib/services/post_login_data_loader.dart

import 'package:flutter/foundation.dart';
import 'dart:async';

import '../services/progressive_scenario_service.dart';
import '../services/enhanced_supabase_service.dart';
import '../services/service_locator.dart';

/// Smart background data loader that starts after user login
/// Loads all 1200+ scenarios without impacting home screen performance
class PostLoginDataLoader {
  static final PostLoginDataLoader instance = PostLoginDataLoader._();
  PostLoginDataLoader._();

  late final ProgressiveScenarioService _scenarioService = ProgressiveScenarioService.instance;
  late final EnhancedSupabaseService _supabaseService = ServiceLocator.instance.enhancedSupabaseService;

  bool _isLoading = false;
  bool _isCompleted = false;
  int _totalScenarios = 0;
  int _loadedScenarios = 0;

  // Progress tracking for UI
  final StreamController<LoadingProgress> _progressController = StreamController<LoadingProgress>.broadcast();
  Stream<LoadingProgress> get progressStream => _progressController.stream;

  /// Start loading all scenarios in background after user login
  /// This is non-blocking and allows home screen to show immediately
  Future<void> startBackgroundLoading() async {
    if (_isLoading || _isCompleted) {
      debugPrint('📚 Background loading already in progress or completed');
      return;
    }

    _isLoading = true;
    debugPrint('🚀 Starting post-login background data loading...');

    // Start immediately but don't block
    Future.microtask(() async {
      try {
        await _loadAllScenariosInBackground();
        _isCompleted = true;
        debugPrint('✅ Post-login background loading completed successfully');

        // Notify that all data is ready
        _progressController.add(LoadingProgress(
          isCompleted: true,
          totalScenarios: _totalScenarios,
          loadedScenarios: _loadedScenarios,
          message: 'All scenarios loaded! Full AI search available.',
        ));

      } catch (e) {
        debugPrint('❌ Post-login background loading failed: $e');
        _progressController.add(LoadingProgress(
          isCompleted: false,
          totalScenarios: _totalScenarios,
          loadedScenarios: _loadedScenarios,
          message: 'Loading encountered issues, but app remains functional.',
          hasError: true,
        ));
      } finally {
        _isLoading = false;
      }
    });
  }

  /// Load all 1200+ scenarios progressively in background
  Future<void> _loadAllScenariosInBackground() async {
    debugPrint('📊 Getting total scenario count from server...');

    // Get total count from server
    _totalScenarios = await _supabaseService.getScenarioCount();
    debugPrint('📊 Server has $_totalScenarios total scenarios');

    if (_totalScenarios == 0) {
      debugPrint('⚠️ No scenarios found on server');
      return;
    }

    // Update progress
    _progressController.add(LoadingProgress(
      isCompleted: false,
      totalScenarios: _totalScenarios,
      loadedScenarios: 0,
      message: 'Loading scenarios in background...',
    ));

    // Load scenarios in intelligent batches
    await _loadScenariosInBatches();
  }

  /// Load scenarios in optimized batches for background processing
  Future<void> _loadScenariosInBatches() async {
    const int batchSize = 100; // Optimized batch size for background loading
    const Duration batchDelay = Duration(milliseconds: 200); // Gentle delay

    int offset = 0;
    while (offset < _totalScenarios) {
      try {
        // Load batch from server
        final scenarios = await _supabaseService.fetchScenarios(
          limit: batchSize,
          offset: offset,
        );

        if (scenarios.isEmpty) break;

        _loadedScenarios += scenarios.length;
        debugPrint('📦 Loaded batch: $_loadedScenarios/$_totalScenarios scenarios');

        // Update progress
        _progressController.add(LoadingProgress(
          isCompleted: false,
          totalScenarios: _totalScenarios,
          loadedScenarios: _loadedScenarios,
          message: 'Loading scenarios: $_loadedScenarios/$_totalScenarios',
        ));

        offset += batchSize;

        // Small delay to prevent overwhelming the system
        if (offset < _totalScenarios) {
          await Future.delayed(batchDelay);
        }

      } catch (e) {
        debugPrint('❌ Error loading batch at offset $offset: $e');
        // Continue with next batch
        offset += batchSize;
      }
    }

    debugPrint('🎉 Background scenario loading completed: $_loadedScenarios scenarios');
  }

  /// Force refresh all scenarios from server
  Future<void> refreshAllScenarios() async {
    debugPrint('🔄 Force refreshing all scenarios...');

    _isCompleted = false;
    _loadedScenarios = 0;

    // Clear existing cache and reload
    await _scenarioService.refreshFromServer();
    await startBackgroundLoading();
  }

  /// Check if background loading is completed
  bool get isCompleted => _isCompleted;
  bool get isLoading => _isLoading;
  int get totalScenarios => _totalScenarios;
  int get loadedScenarios => _loadedScenarios;
  double get progress => _totalScenarios > 0 ? _loadedScenarios / _totalScenarios : 0.0;

  /// Get current loading status
  LoadingProgress get currentProgress => LoadingProgress(
    isCompleted: _isCompleted,
    totalScenarios: _totalScenarios,
    loadedScenarios: _loadedScenarios,
    message: _isCompleted
        ? 'All scenarios loaded'
        : _isLoading
            ? 'Loading scenarios: $_loadedScenarios/$_totalScenarios'
            : 'Ready to load',
  );

  /// Dispose resources
  void dispose() {
    _progressController.close();
  }
}

/// Progress information for UI updates
class LoadingProgress {
  final bool isCompleted;
  final int totalScenarios;
  final int loadedScenarios;
  final String message;
  final bool hasError;

  LoadingProgress({
    required this.isCompleted,
    required this.totalScenarios,
    required this.loadedScenarios,
    required this.message,
    this.hasError = false,
  });

  double get progress => totalScenarios > 0 ? loadedScenarios / totalScenarios : 0.0;
  int get percentage => (progress * 100).round();
}