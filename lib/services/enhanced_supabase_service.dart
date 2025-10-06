// lib/services/enhanced_supabase_service.dart

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:hive/hive.dart';

import '../models/journal_entry.dart';
import '../models/chapter.dart';
import '../models/chapter_summary.dart';
import '../models/scenario.dart';
import '../models/verse.dart';
import 'supabase_auth_service.dart';
/* MOVED TO UNUSED: import '../models/daily_quote.dart'; */
/* MULTILANG_TODO: import '../models/supported_language.dart'; */

/// ---------------------------------------------
/// ENHANCED SUPABASE SERVICE - ENGLISH ONLY (MVP)
/// ---------------------------------------------
/// Simplified service for English-only MVP release.
/// MULTILANG_TODO: Restore multilingual support after MVP
/// All multilingual code is commented out with MULTILANG_TODO prefix.

class EnhancedSupabaseService {
  /// Shared Supabase client
  final SupabaseClient client = Supabase.instance.client;

  /// Test Supabase connection
  Future<bool> testConnection() async {
    try {
      debugPrint('🧪 Testing Supabase connection...');
      final response = await client.from('chapters').select('ch_chapter_id').limit(1);
      debugPrint('✅ Supabase connection successful! Found ${response.length} chapters');
      return true;
    } catch (e) {
      debugPrint('❌ Supabase connection failed: $e');
      return false;
    }
  }

  /* MULTILANG_TODO: Restore language support
  /// Currently selected language code
  String _currentLanguage = 'en';

  /// Cached supported languages
  List<SupportedLanguage> _supportedLanguages = [];

  /// Cache box for offline language support
  static const String _languageCacheBox = 'language_cache';

  /// Getters
  String get currentLanguage => _currentLanguage;
  List<SupportedLanguage> get supportedLanguages => _supportedLanguages;
  */

  /* MULTILANG_TODO: Restore language initialization
  /// Initialize language support - call this once at app startup
  Future<void> initializeLanguages() async {
    try {
      debugPrint('🌐 Initializing multilingual support...');
      debugPrint('🏗️ Platform: Connected');
      
      // Open cache box for offline support
      if (!Hive.isBoxOpen(_languageCacheBox)) {
        await Hive.openBox(_languageCacheBox);
        debugPrint('📦 Opened language cache box');
      }
      
      // Load supported languages from Supabase
      await _loadSupportedLanguages();
      
      // Set current language from settings or default to English
      await _loadCurrentLanguageFromSettings();
      
      debugPrint('✅ Multilingual support initialized. Current: $_currentLanguage');
      debugPrint('📋 Supported languages: ${_supportedLanguages.length}');
      
      // Test connection on Android
      await _testConnection();
      
    } catch (e) {
      debugPrint('❌ Error initializing languages: $e');
      // Fallback to default languages if network fails
      _supportedLanguages = SupportedLanguage.defaultLanguages;
      /* MULTILANG_TODO: _currentLanguage = 'en'; */
      debugPrint('🔧 Using fallback configuration');
    }
  }
  */

  /// MVP: Simplified initialization for English-only
  Future<void> initializeLanguages() async {
    try {
      // Debug output disabled for production release
      await _testConnection();
      // Service initialized successfully
    } catch (e) {
      // Error initializing service: will rethrow for handling
      rethrow;
    }
  }

  /// Test database connection and schema compatibility
  Future<void> _testConnection() async {
    try {
      // Testing database connection...
      
      // Test basic chapter query
      final testResponse = await client
          .from('chapters')
          .select('ch_chapter_id, ch_title')
          .limit(1);
      
      if (testResponse.isNotEmpty) {
        // Database connection test successful
      } else {
        // Database connection test returned empty result
      }
      
    } catch (e) {
      // Database connection test failed
      rethrow;
    }
  }

  /* MULTILANG_TODO: Restore language loading
  /// Load supported languages from Supabase with caching
  Future<void> _loadSupportedLanguages() async {
    try {
      final response = await client
          .from('supported_languages')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      
      final data = response as List;
      _supportedLanguages = data
          .map((e) => SupportedLanguage.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Cache languages for offline use
      final cacheBox = Hive.box(_languageCacheBox);
      await cacheBox.put('supported_languages', 
          _supportedLanguages.map((lang) => lang.toJson()).toList());
      
      debugPrint('📥 Loaded ${_supportedLanguages.length} languages from server');
      
    } catch (e) {
      debugPrint('⚠️ Failed to load languages from server: $e');
      
      // Try to load from cache
      final cacheBox = Hive.box(_languageCacheBox);
      final cachedLanguages = cacheBox.get('supported_languages');
      
      if (cachedLanguages != null) {
        _supportedLanguages = (cachedLanguages as List)
            .map((e) => SupportedLanguage.fromJson(e as Map<String, dynamic>))
            .toList();
        debugPrint('📤 Loaded ${_supportedLanguages.length} languages from cache');
      } else {
        // Ultimate fallback to default languages
        _supportedLanguages = SupportedLanguage.defaultLanguages;
        debugPrint('🔧 Using default languages');
      }
    }
  }
  */

  /// Load current language from settings
  Future<void> _loadCurrentLanguageFromSettings() async {
    try {
      // This will be integrated with SettingsService
      // For now, default to English
      /* MULTILANG_TODO: _currentLanguage = 'en'; */
    } catch (e) {
      debugPrint('⚠️ Error loading language setting: $e');
      /* MULTILANG_TODO: _currentLanguage = 'en'; */
    }
  }

  /// Change the current language
  Future<void> setCurrentLanguage(String langCode) async {
    /* MULTILANG_TODO: if (_supportedLanguages.any((lang) => lang.langCode == langCode)) { */
    if (langCode == 'en') { // MVP: Only support English
      /* MULTILANG_TODO: final oldLanguage = _currentLanguage; */
      /* MULTILANG_TODO: _currentLanguage = langCode; */
      final oldLanguage = 'en';
      debugPrint('🔄 Language changed from $oldLanguage to: $langCode');
      
      // Clear any cached data that might be language-specific
      await _clearLanguageCache();
      
      // Save to settings - to be integrated with SettingsService
      // await _settingsService.setLanguage(langCode);
      
      debugPrint('✅ Language switch completed successfully');
    } else {
      debugPrint('❌ Unsupported language: $langCode');
    }
  }

  /// Clear language-specific cache when switching languages
  Future<void> _clearLanguageCache() async {
    try {
      // Clear Hive cache if needed
      /* MULTILANG_TODO: if (Hive.isBoxOpen(_languageCacheBox)) { */
      /* MULTILANG_TODO: final cacheBox = Hive.box(_languageCacheBox); */
      if (false) { // MVP: No cache to clear
        /* MULTILANG_TODO: await cacheBox.clear(); */
        debugPrint('🧹 Cleared language cache');
      }
      
      // Force refresh of materialized views if they exist
      await refreshTranslationViews();
      
    } catch (e) {
      debugPrint('⚠️ Error clearing language cache: $e');
    }
  }

  /// ========================================================================
  /// MULTILINGUAL CHAPTER METHODS
  /// ========================================================================

  /* MULTILANG_TODO: Restore multilingual chapter summaries
  /// Fetch all chapter summaries with multilingual support
  Future<List<ChapterSummary>> fetchChapterSummaries([String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      // Try materialized view first, then fallback to direct queries
      try {
        final response = await client
            .from('chapter_summary_multilingual')
            .select('ch_chapter_id, title, subtitle, ch_verse_count, scenario_count')
            .eq('lang_code', language)
            .order('ch_chapter_id', ascending: true);
        
        final data = response as List;
        return data.map((e) {
          return ChapterSummary(
            chapterId: e['ch_chapter_id'] as int,
            title: e['title'] as String,
            subtitle: e['subtitle'] as String?,
            verseCount: (e['ch_verse_count'] as int?) ?? 0,
            scenarioCount: (e['scenario_count'] as int?) ?? 0,
          );
        }).toList();
      } catch (viewError) {
        debugPrint('⚠️ Materialized view error, using direct query fallback: $viewError');
        
        // Fallback: Direct query from chapters table with manual translation lookup
        final chaptersResponse = await client
            .from('chapters')
            .select('ch_chapter_id, ch_title, ch_subtitle, ch_verse_count')
            .order('ch_chapter_id', ascending: true);
        
        final List<ChapterSummary> summaries = [];
        
        for (final chapter in chaptersResponse) {
          String title = chapter['ch_title'] as String;
          String? subtitle = chapter['ch_subtitle'] as String?;
          
          // Try to get translation if not English
          if (language != 'en') {
            try {
              final translationResponse = await client
                  .from('chapter_translations')
                  .select('title, subtitle')
                  .eq('chapter_id', chapter['ch_chapter_id'])
                  .eq('lang_code', language)
                  .maybeSingle();
              
              if (translationResponse != null) {
                title = translationResponse['title'] ?? title;
                subtitle = translationResponse['subtitle'] ?? subtitle;
              }
            } catch (translationError) {
              debugPrint('⚠️ Translation not found for chapter ${chapter['ch_chapter_id']} in $language');
            }
          }
          
          // Get scenario count
          final scenarioCountResponse = await client
              .from('scenarios')
              .select('scenario_id')
              .eq('sc_chapter', chapter['ch_chapter_id'])
              .count();
          
          summaries.add(ChapterSummary(
            chapterId: chapter['ch_chapter_id'] as int,
            title: title,
            subtitle: subtitle,
            verseCount: (chapter['ch_verse_count'] as int?) ?? 0,
            scenarioCount: scenarioCountResponse.count,
          ));
        }
        
        return summaries;
      }
      
    } catch (e) {
      // Error fetching chapter summaries
      
      // Fallback to English if current language fails
      if (language != 'en') {
        debugPrint('🔄 Falling back to English...');
        return fetchChapterSummaries('en');
      }
      
      return [];
    }
  }
  */

  /// MVP: Permanently cached chapter summaries (FIXES SLOW LOADING)
  Future<List<ChapterSummary>> fetchChapterSummaries([String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    try {
      // Open cache box for permanent storage
      if (!Hive.isBoxOpen('chapter_summaries_permanent')) {
        await Hive.openBox<ChapterSummary>('chapter_summaries_permanent');
      }
      final cacheBox = Hive.box<ChapterSummary>('chapter_summaries_permanent');
      
      // Check permanent cache first
      if (cacheBox.isNotEmpty) {
        final cachedSummaries = cacheBox.values.toList();
        // Using permanently cached chapter summaries
        return cachedSummaries;
      }
      
      // Fetching fresh chapter summaries for permanent cache
      
      // Direct query from chapters table - reliable and simple
      final chaptersResponse = await client
          .from('chapters')
          .select('ch_chapter_id, ch_title, ch_subtitle, ch_verse_count')
          .order('ch_chapter_id', ascending: true);
      
      debugPrint('📊 Found ${chaptersResponse.length} chapters');
      
      final List<ChapterSummary> summaries = [];
      
      for (final chapter in chaptersResponse) {
        // Get real-time scenario count from scenarios table
        final scenarioCountResponse = await client
            .from('scenarios')
            .select('scenario_id')
            .eq('sc_chapter', chapter['ch_chapter_id'])
            .count();
        
        final summary = ChapterSummary(
          chapterId: chapter['ch_chapter_id'] as int,
          title: chapter['ch_title'] as String,
          subtitle: chapter['ch_subtitle'] as String?,
          verseCount: (chapter['ch_verse_count'] as int?) ?? 0,
          scenarioCount: scenarioCountResponse.count,
        );
        
        summaries.add(summary);
        debugPrint('✅ Chapter ${summary.chapterId}: ${summary.scenarioCount} scenarios');
      }
      
      // Permanently cache the results
      await cacheBox.clear();
      for (int i = 0; i < summaries.length; i++) {
        await cacheBox.put(summaries[i].chapterId, summaries[i]);
      }
      
      // Successfully loaded and permanently cached chapter summaries
      return summaries;
      
    } catch (e) {
      // Error fetching chapter summaries
      return [];
    }
  }

  /// Fetch a single chapter with multilingual support and fallback
  Future<Chapter?> fetchChapterById(int chapterId, [String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      // Direct query approach - more reliable than RPC
      final response = await client
          .from('chapters')
          .select('''
            ch_chapter_id,
            ch_title,
            ch_subtitle,
            ch_summary,
            ch_verse_count,
            ch_theme,
            ch_key_teachings,
            created_at
          ''')
          .eq('ch_chapter_id', chapterId)
          .single();
      
      if (response != null) {
        // Try to get translation for this chapter
        if (language != 'en') {
          try {
            final translationResponse = await client
                .from('chapter_translations')
                .select('*')
                .eq('chapter_id', chapterId)
                .eq('lang_code', language)
                .maybeSingle();
            
            if (translationResponse != null) {
              // Apply translations
              final data = Map<String, dynamic>.from(response);
              if (translationResponse['title'] != null) data['ch_title'] = translationResponse['title'];
              if (translationResponse['subtitle'] != null) data['ch_subtitle'] = translationResponse['subtitle'];
              if (translationResponse['summary'] != null) data['ch_summary'] = translationResponse['summary'];
              if (translationResponse['theme'] != null) data['ch_theme'] = translationResponse['theme'];
              if (translationResponse['key_teachings'] != null) data['ch_key_teachings'] = translationResponse['key_teachings'];
              
              return Chapter.fromJson(data);
            }
          } catch (translationError) {
            debugPrint('⚠️ Translation not found for chapter $chapterId in $language, using English');
          }
        }
        
        // Use English version (original data)
        return Chapter.fromJson(response);
      }
      
      return null;
      
    } catch (e) {
      debugPrint('❌ Error fetching chapter $chapterId for $language: $e');
      
      // Fallback to original method
      return _fallbackFetchChapterById(chapterId);
    }
  }

  /// Fetch all chapters with multilingual support
  Future<List<Chapter>> fetchAllChapters([String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      final List<Chapter> chapters = [];
      
      // Fetch chapters 1-18 (standard Bhagavad Gita structure)
      for (int i = 1; i <= 18; i++) {
        final chapter = await fetchChapterById(i, language);
        if (chapter != null) {
          chapters.add(chapter);
        }
      }
      
      return chapters;
      
    } catch (e) {
      debugPrint('❌ Error fetching all chapters for $language: $e');
      return [];
    }
  }

  /// ========================================================================
  /// MULTILINGUAL SCENARIO METHODS
  /// ========================================================================

  /* MULTILANG_TODO: Restore multilingual scenarios
  /// Fetch scenarios with multilingual support
  Future<List<Scenario>> fetchScenariosByChapter(int chapterId, [String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      // Direct query to get full scenario data including heart, duty, gita wisdom, and action steps
      final response = await client
          .from('scenarios')
          .select('''
            scenario_id,
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .eq('sc_chapter', chapterId)
          .order('created_at', ascending: false);
      
      if (response.isEmpty) return [];
      
      // Convert to scenarios with potential translations
      final List<Scenario> scenarios = [];
      
      for (final item in response) {
        Map<String, dynamic> scenarioData = Map<String, dynamic>.from(item);
        
        // Try to get translations if not English
        if (language != 'en') {
          try {
            final translationResponse = await client
                .from('scenario_translations')
                .select('*')
                .eq('scenario_id', item['scenario_id'])
                .eq('lang_code', language)
                .maybeSingle();
            
            if (translationResponse != null) {
              // Apply translations
              if (translationResponse['title'] != null) scenarioData['sc_title'] = translationResponse['title'];
              if (translationResponse['description'] != null) scenarioData['sc_description'] = translationResponse['description'];
              if (translationResponse['category'] != null) scenarioData['sc_category'] = translationResponse['category'];
              if (translationResponse['heart_response'] != null) scenarioData['sc_heart_response'] = translationResponse['heart_response'];
              if (translationResponse['duty_response'] != null) scenarioData['sc_duty_response'] = translationResponse['duty_response'];
              if (translationResponse['gita_wisdom'] != null) scenarioData['sc_gita_wisdom'] = translationResponse['gita_wisdom'];
              if (translationResponse['action_steps'] != null) scenarioData['sc_action_steps'] = translationResponse['action_steps'];
            }
          } catch (translationError) {
            debugPrint('⚠️ Translation not found for scenario ${item['scenario_id']} in $language, using English');
          }
        }
        
        // Create scenario with all data
        final scenario = Scenario(
          title: scenarioData['sc_title'] as String? ?? '',
          description: scenarioData['sc_description'] as String? ?? '',
          category: scenarioData['sc_category'] as String? ?? '',
          chapter: scenarioData['sc_chapter'] as int? ?? chapterId,
          heartResponse: scenarioData['sc_heart_response'] as String? ?? '',
          dutyResponse: scenarioData['sc_duty_response'] as String? ?? '',
          gitaWisdom: scenarioData['sc_gita_wisdom'] as String? ?? '',
          actionSteps: (scenarioData['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
          createdAt: DateTime.parse(scenarioData['created_at'] as String),
        );
        
        scenarios.add(scenario);
      }
      
      return scenarios;
      
    } catch (e) {
      debugPrint('❌ Error fetching scenarios for chapter $chapterId, language $language: $e');
      
      // Fallback to English or original method
      if (language != 'en') {
        return fetchScenariosByChapter(chapterId, 'en');
      }
      
      return _fallbackFetchScenariosByChapter(chapterId);
    }
  }
  */

  /// MVP: Simplified English-only scenario fetching (FIXES COUNT ISSUE)
  Future<List<Scenario>> fetchScenariosByChapter(int chapterId, [String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    try {
      debugPrint('🎯 Fetching scenarios for chapter $chapterId (English-only)');
      
      // Simple direct query to scenarios table - no translation complexity
      final response = await client
          .from('scenarios')
          .select('''
            scenario_id,
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .eq('sc_chapter', chapterId)
          .order('created_at', ascending: false);
      
      debugPrint('📊 Found ${response.length} scenarios for chapter $chapterId');
      
      if (response.isEmpty) return [];
      
      // Direct conversion without translation logic - much more reliable
      final List<Scenario> scenarios = response.map((item) {
        return Scenario(
          title: item['sc_title'] as String? ?? '',
          description: item['sc_description'] as String? ?? '',
          category: item['sc_category'] as String? ?? '',
          chapter: item['sc_chapter'] as int? ?? chapterId,
          heartResponse: item['sc_heart_response'] as String? ?? '',
          dutyResponse: item['sc_duty_response'] as String? ?? '',
          gitaWisdom: item['sc_gita_wisdom'] as String? ?? '',
          actionSteps: (item['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
          createdAt: DateTime.parse(item['created_at'] as String),
        );
      }).toList();
      
      debugPrint('✅ Successfully converted ${scenarios.length} scenarios');
      return scenarios;
      
    } catch (e) {
      debugPrint('❌ Error fetching scenarios for chapter $chapterId: $e');
      return _fallbackFetchScenariosByChapter(chapterId);
    }
  }

  /// Fallback method for fetching scenarios by chapter (basic implementation)
  Future<List<Scenario>> _fallbackFetchScenariosByChapter(int chapterId) async {
    try {
      debugPrint('🔧 Using fallback method for chapter $chapterId scenarios');
      
      // Simple fallback query without translation complexity
      final response = await client
          .from('scenarios')
          .select('''
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .eq('sc_chapter', chapterId)
          .limit(100); // Reasonable limit for fallback
      
      return response.map((item) => Scenario(
        title: item['sc_title'] as String? ?? '',
        description: item['sc_description'] as String? ?? '',
        category: item['sc_category'] as String? ?? '',
        chapter: item['sc_chapter'] as int? ?? chapterId,
        heartResponse: item['sc_heart_response'] as String? ?? '',
        dutyResponse: item['sc_duty_response'] as String? ?? '',
        gitaWisdom: item['sc_gita_wisdom'] as String? ?? '',
        actionSteps: (item['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
        createdAt: DateTime.parse(item['created_at'] as String),
      )).toList();
      
    } catch (e) {
      debugPrint('❌ Fallback method also failed: $e');
      return [];
    }
  }

  /// Fetch a single scenario with full details and multilingual support
  Future<Scenario?> fetchScenarioById(int scenarioId, [String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      // Direct query to get complete scenario data
      final response = await client
          .from('scenarios')
          .select('''
            scenario_id,
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .eq('scenario_id', scenarioId)
          .single();
      
      if (response != null) {
        Map<String, dynamic> scenarioData = Map<String, dynamic>.from(response);
        
        // Try to get translations if not English
        if (language != 'en') {
          try {
            final translationResponse = await client
                .from('scenario_translations')
                .select('*')
                .eq('scenario_id', scenarioId)
                .eq('lang_code', language)
                .maybeSingle();
            
            if (translationResponse != null) {
              // Apply translations
              if (translationResponse['title'] != null) scenarioData['sc_title'] = translationResponse['title'];
              if (translationResponse['description'] != null) scenarioData['sc_description'] = translationResponse['description'];
              if (translationResponse['category'] != null) scenarioData['sc_category'] = translationResponse['category'];
              if (translationResponse['heart_response'] != null) scenarioData['sc_heart_response'] = translationResponse['heart_response'];
              if (translationResponse['duty_response'] != null) scenarioData['sc_duty_response'] = translationResponse['duty_response'];
              if (translationResponse['gita_wisdom'] != null) scenarioData['sc_gita_wisdom'] = translationResponse['gita_wisdom'];
              if (translationResponse['action_steps'] != null) scenarioData['sc_action_steps'] = translationResponse['action_steps'];
            }
          } catch (translationError) {
            debugPrint('⚠️ Translation not found for scenario $scenarioId in $language, using English');
          }
        }
        
        // Create scenario with all data
        return Scenario(
          title: scenarioData['sc_title'] as String? ?? '',
          description: scenarioData['sc_description'] as String? ?? '',
          category: scenarioData['sc_category'] as String? ?? '',
          chapter: scenarioData['sc_chapter'] as int? ?? 1,
          heartResponse: scenarioData['sc_heart_response'] as String? ?? '',
          dutyResponse: scenarioData['sc_duty_response'] as String? ?? '',
          gitaWisdom: scenarioData['sc_gita_wisdom'] as String? ?? '',
          actionSteps: (scenarioData['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
          createdAt: DateTime.parse(scenarioData['created_at'] as String),
        );
      }
      
      return null;
      
    } catch (e) {
      debugPrint('❌ Error fetching scenario $scenarioId for $language: $e');
      
      // Fallback to original method
      return _fallbackFetchScenarioById(scenarioId);
    }
  }

  /// Fallback method for fetching scenario by ID
  Future<Scenario?> _fallbackFetchScenarioById(int scenarioId) async {
    try {
      debugPrint('🔧 Using fallback method for scenario $scenarioId');
      
      final response = await client
          .from('scenarios')
          .select('''
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .eq('scenario_id', scenarioId)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Scenario(
        title: response['sc_title'] as String? ?? '',
        description: response['sc_description'] as String? ?? '',
        category: response['sc_category'] as String? ?? '',
        chapter: response['sc_chapter'] as int? ?? 1,
        heartResponse: response['sc_heart_response'] as String? ?? '',
        dutyResponse: response['sc_duty_response'] as String? ?? '',
        gitaWisdom: response['sc_gita_wisdom'] as String? ?? '',
        actionSteps: (response['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
        createdAt: DateTime.parse(response['created_at'] as String),
      );
      
    } catch (e) {
      debugPrint('❌ Fallback scenario fetch failed: $e');
      return null;
    }
  }

  /// Search scenarios with multilingual support
  Future<List<Scenario>> searchScenarios(String query, [String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    if (query.trim().isEmpty) {
      return fetchScenarios(langCode: language);
    }
    
    try {
      // Search in translation tables with full-text search
      final response = await client
          .from('scenario_translations')
          .select('''
            scenario_id,
            title,
            description,
            category,
            heart_response,
            duty_response,
            gita_wisdom,
            verse,
            verse_number,
            tags,
            action_steps
          ''')
          .eq('lang_code', language)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('scenario_id', ascending: false);
      
      final data = response as List;
      
      // Convert to Scenario objects (need to fetch additional data)
      final List<Scenario> scenarios = [];
      for (final item in data) {
        // For now, create basic scenario - could be enhanced with joins
        scenarios.add(Scenario(
          title: item['title'] as String,
          description: item['description'] as String,
          category: item['category'] as String? ?? 'General',
          chapter: 1, // Would need to be fetched from scenarios table
          heartResponse: item['heart_response'] as String? ?? '',
          dutyResponse: item['duty_response'] as String? ?? '',
          gitaWisdom: item['gita_wisdom'] as String? ?? '',
          verse: item['verse'] as String?,
          verseNumber: item['verse_number'] as String?,
          tags: (item['tags'] as List<dynamic>?)?.cast<String>(),
          actionSteps: (item['action_steps'] as List<dynamic>?)?.cast<String>(),
          createdAt: DateTime.now(), // Would need to be fetched from scenarios table
        ));
      }
      
      return scenarios;
      
    } catch (e) {
      debugPrint('❌ Error searching scenarios for "$query" in $language: $e');
      
      // Fallback to English search or original method
      if (language != 'en') {
        return searchScenarios(query, 'en');
      }
      
      return _fallbackSearchScenarios(query);
    }
  }

  /// Fetch paginated scenarios with multilingual support
  Future<List<Scenario>> fetchScenarios({
    int limit = 2000,
    int offset = 0,
    String? langCode,
  }) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      // Get full scenario data from scenarios table
      final response = await client
          .from('scenarios')
          .select('''
            scenario_id,
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1)
          .limit(limit);
      
      if (response.isEmpty) return [];
      
      final List<Scenario> scenarios = [];
      
      for (final item in response) {
        Map<String, dynamic> scenarioData = Map<String, dynamic>.from(item);
        
        // Try to get translations if not English
        if (language != 'en') {
          try {
            final translationResponse = await client
                .from('scenario_translations')
                .select('*')
                .eq('scenario_id', item['scenario_id'])
                .eq('lang_code', language)
                .maybeSingle();
            
            if (translationResponse != null) {
              // Apply translations
              if (translationResponse['title'] != null) scenarioData['sc_title'] = translationResponse['title'];
              if (translationResponse['description'] != null) scenarioData['sc_description'] = translationResponse['description'];
              if (translationResponse['category'] != null) scenarioData['sc_category'] = translationResponse['category'];
              if (translationResponse['heart_response'] != null) scenarioData['sc_heart_response'] = translationResponse['heart_response'];
              if (translationResponse['duty_response'] != null) scenarioData['sc_duty_response'] = translationResponse['duty_response'];
              if (translationResponse['gita_wisdom'] != null) scenarioData['sc_gita_wisdom'] = translationResponse['gita_wisdom'];
              if (translationResponse['action_steps'] != null) scenarioData['sc_action_steps'] = translationResponse['action_steps'];
            }
          } catch (translationError) {
            debugPrint('⚠️ Translation not found for scenario ${item['scenario_id']} in $language, using English');
          }
        }
        
        final scenario = Scenario(
          title: scenarioData['sc_title'] as String? ?? '',
          description: scenarioData['sc_description'] as String? ?? '',
          category: scenarioData['sc_category'] as String? ?? '',
          chapter: scenarioData['sc_chapter'] as int? ?? 1,
          heartResponse: scenarioData['sc_heart_response'] as String? ?? '',
          dutyResponse: scenarioData['sc_duty_response'] as String? ?? '',
          gitaWisdom: scenarioData['sc_gita_wisdom'] as String? ?? '',
          actionSteps: (scenarioData['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
          createdAt: DateTime.parse(scenarioData['created_at'] as String),
        );
        
        scenarios.add(scenario);
      }
      
      return scenarios;
      
    } catch (e) {
      debugPrint('❌ Error fetching paginated scenarios for $language: $e');
      
      if (language != 'en') {
        return fetchScenarios(limit: limit, offset: offset, langCode: 'en');
      }
      
      return _fallbackFetchScenarios(limit: limit, offset: offset);
    }
  }

  /// Fallback method for fetching scenarios
  Future<List<Scenario>> _fallbackFetchScenarios({int limit = 2000, int offset = 0}) async {
    try {
      debugPrint('🔧 Using fallback method for scenarios (limit: $limit, offset: $offset)');
      
      final response = await client
          .from('scenarios')
          .select('''
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response.map((item) => Scenario(
        title: item['sc_title'] as String? ?? '',
        description: item['sc_description'] as String? ?? '',
        category: item['sc_category'] as String? ?? '',
        chapter: item['sc_chapter'] as int? ?? 1,
        heartResponse: item['sc_heart_response'] as String? ?? '',
        dutyResponse: item['sc_duty_response'] as String? ?? '',
        gitaWisdom: item['sc_gita_wisdom'] as String? ?? '',
        actionSteps: (item['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
        createdAt: DateTime.parse(item['created_at'] as String),
      )).toList();
      
    } catch (e) {
      debugPrint('❌ Fallback scenarios fetch failed: $e');
      return [];
    }
  }

  /// Get total scenario count from server (for checking new content)
  Future<int> getScenarioCount() async {
    try {
      debugPrint('📊 Getting scenario count from server...');
      
      // Use count() method to get total count
      final response = await client
          .from('scenarios')
          .select('scenario_id')
          .count(CountOption.exact);
      
      final count = response.count ?? 0;
      debugPrint('✅ Server has $count total scenarios');
      return count;
      
    } catch (e) {
      debugPrint('❌ Error getting scenario count: $e');
      return 0;
    }
  }

  /// ========================================================================
  /// MULTILINGUAL VERSE METHODS
  /// ========================================================================

  /// Fetch verses with multilingual support
  Future<List<Verse>> fetchVersesByChapter(int chapterId, [String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      // Use RPC function for automatic fallback
      final response = await client
          .rpc('get_verses_with_fallback', params: {
            'p_chapter_id': chapterId,
            'p_lang_code': language,
          });
      
      final data = response as List;
      return data
          .map((e) => VerseMultilingualExtensions.fromMultilingualJson(e as Map<String, dynamic>))
          .toList();
      
    } catch (e) {
      debugPrint('❌ Error fetching verses for chapter $chapterId, language $language: $e');
      
      // Fallback to English or original method
      if (language != 'en') {
        return fetchVersesByChapter(chapterId, 'en');
      }
      
      return _fallbackFetchVersesByChapter(chapterId);
    }
  }

  /// Fetch random verse with multilingual support
  Future<Verse> fetchRandomVerseByChapter(int chapterId, [String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      final verses = await fetchVersesByChapter(chapterId, language);
      if (verses.isEmpty) {
        throw Exception('No verses found for chapter $chapterId');
      }
      
      return verses[Random().nextInt(verses.length)];
      
    } catch (e) {
      debugPrint('❌ Error fetching random verse: $e');
      rethrow;
    }
  }

  /// ========================================================================
  /// MULTILINGUAL DAILY QUOTE METHODS
  /// ========================================================================

  /* MOVED TO UNUSED: DailyQuote functionality
  /// Fetch daily quote with multilingual support
  Future<DailyQuote> fetchRandomDailyQuote([String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      // Get all quote IDs first
      final quotesResponse = await client
          .from('daily_quote')
          .select('dq_id, created_at')
          .order('created_at', ascending: true);
      
      if (quotesResponse.isEmpty) {
        throw Exception('No daily quotes found');
      }
      
      // Pick a random quote ID
      final quotes = quotesResponse as List;
      final randomQuote = quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];
      final quoteId = randomQuote['dq_id'] as String;
      
      // Use RPC function to get the quote with fallback
      final response = await client
          .rpc('get_daily_quote_with_fallback', params: {
            'p_quote_id': quoteId,
            'p_lang_code': language,
          });
      
      if (response.isEmpty) {
        throw Exception('Quote not found: $quoteId');
      }
      
      final data = response[0] as Map<String, dynamic>;
      return DailyQuoteMultilingualExtensions.fromMultilingualJson(data);
      
    } catch (e) {
      debugPrint('❌ Error fetching daily quote for $language: $e');
      
      // Fallback to English or original method
      if (language != 'en') {
        return fetchRandomDailyQuote('en');
      }
      
      rethrow;
    }
  }
  */

  /// ========================================================================
  /// FALLBACK METHODS (ORIGINAL IMPLEMENTATION)
  /// ========================================================================

  Future<Chapter?> _fallbackFetchChapterById(int chapterId) async {
    try {
      final response = await client
          .from('chapters')
          .select()
          .eq('ch_chapter_id', chapterId)
          .single();
      return Chapter.fromJson(response);
    } catch (e) {
      debugPrint('❌ Fallback chapter fetch failed: $e');
      return null;
    }
  }

  /// Fallback method for searching scenarios
  Future<List<Scenario>> _fallbackSearchScenarios(String query) async {
    try {
      debugPrint('🔧 Using fallback search for query: $query');
      
      final response = await client
          .from('scenarios')
          .select('''
            sc_title,
            sc_description,
            sc_category,
            sc_chapter,
            sc_heart_response,
            sc_duty_response,
            sc_gita_wisdom,
            sc_action_steps,
            created_at
          ''')
          .or('sc_title.ilike.%$query%,sc_description.ilike.%$query%')
          .order('created_at', ascending: false);
      
      return response.map((item) => Scenario(
        title: item['sc_title'] as String? ?? '',
        description: item['sc_description'] as String? ?? '',
        category: item['sc_category'] as String? ?? '',
        chapter: item['sc_chapter'] as int? ?? 1,
        heartResponse: item['sc_heart_response'] as String? ?? '',
        dutyResponse: item['sc_duty_response'] as String? ?? '',
        gitaWisdom: item['sc_gita_wisdom'] as String? ?? '',
        actionSteps: (item['sc_action_steps'] as List<dynamic>?)?.cast<String>(),
        createdAt: DateTime.parse(item['created_at'] as String),
      )).toList();
      
    } catch (e) {
      debugPrint('❌ Fallback search failed: $e');
      return [];
    }
  }

  /// Fallback method for fetching verses by chapter
  Future<List<Verse>> _fallbackFetchVersesByChapter(int chapterId) async {
    try {
      debugPrint('🔧 Using fallback method for verses in chapter $chapterId');
      
      final response = await client
          .from('gita_verses')
          .select('''
            gv_verses_id,
            gv_chapter_id,
            gv_verses
          ''')
          .eq('gv_chapter_id', chapterId)
          .order('gv_verses_id', ascending: true);
      
      return response.map((item) => Verse(
        verseId: item['gv_verses_id'] as int? ?? 0,
        chapterId: item['gv_chapter_id'] as int? ?? chapterId,
        description: item['gv_verses'] as String? ?? '',
      )).toList();
      
    } catch (e) {
      debugPrint('❌ Fallback verses fetch failed: $e');
      return [];
    }
  }

  /// ========================================================================
  /// NON-MULTILINGUAL METHODS (UNCHANGED)
  /// ========================================================================

  /// Fetch a random scenario (using current language)
  Future<Scenario?> fetchRandomScenario() async {
    try {
      final scenarios = await fetchScenarios(limit: 100); // Get more for variety
      if (scenarios.isEmpty) return null;
      
      final randomIndex = math.Random().nextInt(scenarios.length);
      return scenarios[randomIndex];
    } catch (e) {
      debugPrint('❌ Error fetching random scenario: $e');
      return null;
    }
  }

  /// Count scenarios for a chapter (using current language)
  Future<int> fetchScenarioCount(int chapterId) async {
    try {
      final scenarios = await fetchScenariosByChapter(chapterId);
      return scenarios.length;
    } catch (e) {
      debugPrint('❌ Error fetching scenario count: $e');
      return 0;
    }
  }

  /// Journal entry methods - now supports authenticated and anonymous users
  Future<void> insertJournalEntry(JournalEntry entry) async {
    try {
      final jsonData = entry.toJson();

      if (!jsonData.containsKey('je_id') || jsonData['je_id'] == null || (jsonData['je_id'] as String).isEmpty) {
        throw ArgumentError('Journal entry must have a valid ID');
      }

      if (!jsonData.containsKey('je_reflection') || jsonData['je_reflection'] == null || (jsonData['je_reflection'] as String).trim().isEmpty) {
        throw ArgumentError('Journal entry must have a reflection');
      }

      // Add user identification for authenticated and anonymous users
      final user = client.auth.currentUser;
      if (user != null) {
        // Authenticated user
        jsonData['user_id'] = user.id;
        debugPrint('📔 Inserting journal entry for authenticated user: ${user.id}');
      } else {
        // Anonymous user - get device ID from auth service
        final authService = SupabaseAuthService.instance;
        final deviceId = authService.databaseUserId;
        jsonData['user_device_id'] = deviceId;
        debugPrint('📔 Inserting journal entry for anonymous user: $deviceId');
      }

      await client
          .from('journal_entries')
          .insert(jsonData);
      debugPrint('✅ Journal entry inserted to Supabase: ${entry.id}');
    } catch (e) {
      debugPrint('❌ Error inserting journal entry to Supabase: $e');
      rethrow;
    }
  }

  Future<void> deleteJournalEntry(String entryId) async {
    try {
      if (entryId.isEmpty) {
        throw ArgumentError('Entry ID cannot be empty');
      }

      // Build query with user filtering
      var query = client.from('journal_entries').delete().eq('je_id', entryId);

      final user = client.auth.currentUser;
      if (user != null) {
        // Authenticated user - filter by user_id
        query = query.eq('user_id', user.id);
        debugPrint('📔 Deleting journal entry for authenticated user: ${user.id}');
      } else {
        // Anonymous user - filter by device_id
        final authService = SupabaseAuthService.instance;
        final deviceId = authService.databaseUserId;
        query = query.eq('user_device_id', deviceId);
        debugPrint('📔 Deleting journal entry for anonymous user: $deviceId');
      }

      await query;
      debugPrint('✅ Journal entry deleted from Supabase: $entryId');
    } catch (e) {
      debugPrint('❌ Error deleting journal entry from Supabase: $e');
      rethrow;
    }
  }

  Future<List<JournalEntry>> fetchJournalEntries() async {
    try {
      // Build query with user filtering - eq() must come before order()
      final user = client.auth.currentUser;
      late var query;

      if (user != null) {
        // Authenticated user - filter by user_id
        query = client.from('journal_entries').select('*');
        query = query.eq('user_id', user.id);
        query = query.order('created_at');
        debugPrint('📔 Fetching journal entries for authenticated user: ${user.id}');
      } else {
        // Anonymous user - filter by device_id
        final authService = SupabaseAuthService.instance;
        final deviceId = authService.databaseUserId;
        query = client.from('journal_entries').select('*');
        query = query.eq('user_device_id', deviceId);
        query = query.order('created_at');
        debugPrint('📔 Fetching journal entries for anonymous user: $deviceId');
      }

      final response = await query;

      if (response.isEmpty) {
        debugPrint('⚠️ Empty response from Supabase journal entries');
        return [];
      }

      final data = response as List;
      final List<JournalEntry> validEntries = [];

      for (final item in data) {
        try {
          if (item is Map<String, dynamic>) {
            if (item['je_id'] != null &&
                item['je_reflection'] != null &&
                item['je_rating'] != null &&
                item['je_date_created'] != null) {

              final entry = JournalEntry.fromJson(item);
              validEntries.add(entry);
            } else {
              debugPrint('⚠️ Skipping journal entry with missing required fields');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing journal entry, skipping: $e');
        }
      }

      debugPrint('✅ Fetched ${validEntries.length} valid journal entries from Supabase');
      return validEntries;
    } catch (e) {
      debugPrint('❌ Error fetching journal entries from Supabase: $e');
      rethrow;
    }
  }

  // Favorites methods (unchanged - not multilingual)
  Future<void> insertFavorite(String scenarioTitle) async {
    try {
      await client
          .from('user_favorites')
          .insert({'scenario_title': scenarioTitle});
      debugPrint('✅ Favorite inserted to Supabase: $scenarioTitle');
    } catch (e) {
      debugPrint('❌ Error inserting favorite to Supabase: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String scenarioTitle) async {
    try {
      await client
          .from('user_favorites')
          .delete()
          .eq('scenario_title', scenarioTitle);
      debugPrint('✅ Favorite removed from Supabase: $scenarioTitle');
    } catch (e) {
      debugPrint('❌ Error removing favorite from Supabase: $e');
      rethrow;
    }
  }

  Future<List<String>> fetchFavorites() async {
    try {
      final response = await client
          .from('user_favorites')
          .select('scenario_title')
          .order('id', ascending: false);
      final data = response as List;
      final favorites = data
          .map((e) => e['scenario_title'] as String)
          .toList();
      debugPrint('✅ Fetched ${favorites.length} favorites from Supabase');
      return favorites;
    } catch (e) {
      debugPrint('❌ Error fetching favorites from Supabase: $e');
      rethrow;
    }
  }

  /// ========================================================================
  /// UTILITY METHODS
  /// ========================================================================

  /// Get translation coverage statistics
  Future<Map<String, dynamic>> getTranslationCoverage([String? langCode]) async {
    /* MULTILANG_TODO: final language = langCode ?? _currentLanguage; */
    final language = 'en'; // MVP: English-only
    
    try {
      final response = await client
          .rpc('get_translation_coverage');
      
      final data = response as List;
      final coverage = <String, Map<String, dynamic>>{};
      
      for (final item in data) {
        final contentType = item['content_type'] as String;
        final itemLangCode = item['lang_code'] as String;
        final nativeName = item['native_name'] as String;
        final totalItems = item['total_items'] as int;
        final translatedItems = item['translated_items'] as int;
        final percentage = item['coverage_percentage'] as double;
        
        if (itemLangCode == language) {
          coverage[contentType] = {
            'language': nativeName,
            'total': totalItems,
            'translated': translatedItems,
            'percentage': percentage,
          };
        }
      }
      
      return coverage;
      
    } catch (e) {
      debugPrint('❌ Error getting translation coverage: $e');
      return {};
    }
  }

  /// Refresh materialized views (admin function)
  Future<bool> refreshTranslationViews() async {
    try {
      await client.rpc('refresh_multilingual_views');
      debugPrint('✅ Translation views refreshed');
      return true;
    } catch (e) {
      debugPrint('❌ Error refreshing translation views: $e');
      return false;
    }
  }

  /* MULTILANG_TODO: Language support methods
  /// Check if a language is supported
  bool isLanguageSupported(String langCode) {
    return _supportedLanguages.any((lang) => lang.langCode == langCode && lang.isActive);
  }

  /// Get language display name
  String getLanguageDisplayName(String langCode, {bool useNative = true}) {
    final lang = _supportedLanguages
        .where((lang) => lang.langCode == langCode)
        .firstOrNull;
    return lang?.displayName(useNative: useNative) ?? langCode;
  }
  */

  /// MVP: Simplified language support methods
  bool isLanguageSupported(String langCode) => langCode == 'en';
  String getLanguageDisplayName(String langCode, {bool useNative = true}) => 'English';

  /// Dispose resources
  void dispose() {
    // Clean up if needed
    debugPrint('🧹 EnhancedSupabaseService disposed');
  }
}