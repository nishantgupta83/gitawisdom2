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
import '../models/daily_quote.dart';
import '../models/supported_language.dart';

/// ---------------------------------------------
/// ENHANCED SUPABASE SERVICE WITH MULTILINGUAL SUPPORT
/// ---------------------------------------------
/// This service provides multilingual content support with automatic fallback
/// to English when translations are not available. It uses the new normalized
/// translation schema while maintaining backward compatibility.

class EnhancedSupabaseService {
  /// Shared Supabase client
  final SupabaseClient client = Supabase.instance.client;

  /// Currently selected language code
  String _currentLanguage = 'en';

  /// Cached supported languages
  List<SupportedLanguage> _supportedLanguages = [];

  /// Cache box for offline language support
  static const String _languageCacheBox = 'language_cache';

  /// Getters
  String get currentLanguage => _currentLanguage;
  List<SupportedLanguage> get supportedLanguages => _supportedLanguages;

  /// Initialize language support - call this once at app startup
  Future<void> initializeLanguages() async {
    try {
      debugPrint('🌐 Initializing multilingual support...');
      
      // Open cache box for offline support
      if (!Hive.isBoxOpen(_languageCacheBox)) {
        await Hive.openBox(_languageCacheBox);
      }
      
      // Load supported languages from Supabase
      await _loadSupportedLanguages();
      
      // Set current language from settings or default to English
      await _loadCurrentLanguageFromSettings();
      
      debugPrint('✅ Multilingual support initialized. Current: $_currentLanguage');
      debugPrint('📋 Supported languages: ${_supportedLanguages.length}');
      
    } catch (e) {
      debugPrint('❌ Error initializing languages: $e');
      // Fallback to default languages if network fails
      _supportedLanguages = SupportedLanguage.defaultLanguages;
    }
  }

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

  /// Load current language from settings
  Future<void> _loadCurrentLanguageFromSettings() async {
    try {
      // This will be integrated with SettingsService
      // For now, default to English
      _currentLanguage = 'en';
    } catch (e) {
      debugPrint('⚠️ Error loading language setting: $e');
      _currentLanguage = 'en';
    }
  }

  /// Change the current language
  Future<void> setCurrentLanguage(String langCode) async {
    if (_supportedLanguages.any((lang) => lang.langCode == langCode)) {
      _currentLanguage = langCode;
      debugPrint('🔄 Language changed to: $langCode');
      
      // Save to settings - to be integrated with SettingsService
      // await _settingsService.setLanguage(langCode);
    } else {
      debugPrint('❌ Unsupported language: $langCode');
    }
  }

  /// ========================================================================
  /// MULTILINGUAL CHAPTER METHODS
  /// ========================================================================

  /// Fetch all chapter summaries with multilingual support
  Future<List<ChapterSummary>> fetchChapterSummaries([String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
    try {
      // Use materialized view for better performance
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
      
    } catch (e) {
      debugPrint('❌ Error fetching chapter summaries for $language: $e');
      
      // Fallback to English if current language fails
      if (language != 'en') {
        debugPrint('🔄 Falling back to English...');
        return fetchChapterSummaries('en');
      }
      
      return [];
    }
  }

  /// Fetch a single chapter with multilingual support and fallback
  Future<Chapter?> fetchChapterById(int chapterId, [String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
    try {
      // Use RPC function for automatic fallback
      final response = await client
          .rpc('get_chapter_with_fallback', params: {
            'p_chapter_id': chapterId,
            'p_lang_code': language,
          });
      
      if (response.isEmpty) return null;
      
      final data = response[0] as Map<String, dynamic>;
      return ChapterMultilingualExtensions.fromMultilingualJson(data);
      
    } catch (e) {
      debugPrint('❌ Error fetching chapter $chapterId for $language: $e');
      
      // Fallback to original method
      return _fallbackFetchChapterById(chapterId);
    }
  }

  /// Fetch all chapters with multilingual support
  Future<List<Chapter>> fetchAllChapters([String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
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

  /// Fetch scenarios with multilingual support
  Future<List<Scenario>> fetchScenariosByChapter(int chapterId, [String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
    try {
      // Use materialized view or direct query with joins
      final response = await client
          .from('scenario_summary_multilingual')
          .select('scenario_id, sc_chapter, title, description, category, created_at')
          .eq('sc_chapter', chapterId)
          .eq('lang_code', language)
          .order('created_at', ascending: false);
      
      final data = response as List;
      return data.map((e) {
        return Scenario(
          title: e['title'] as String,
          description: e['description'] as String,
          category: e['category'] as String,
          chapter: e['sc_chapter'] as int,
          heartResponse: '', // Will be loaded separately if needed
          dutyResponse: '', // Will be loaded separately if needed
          gitaWisdom: '', // Will be loaded separately if needed
          createdAt: DateTime.parse(e['created_at'] as String),
        );
      }).toList();
      
    } catch (e) {
      debugPrint('❌ Error fetching scenarios for chapter $chapterId, language $language: $e');
      
      // Fallback to English or original method
      if (language != 'en') {
        return fetchScenariosByChapter(chapterId, 'en');
      }
      
      return _fallbackFetchScenariosByChapter(chapterId);
    }
  }

  /// Fetch a single scenario with full details and multilingual support
  Future<Scenario?> fetchScenarioById(int scenarioId, [String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
    try {
      // Use RPC function for automatic fallback
      final response = await client
          .rpc('get_scenario_with_fallback', params: {
            'p_scenario_id': scenarioId,
            'p_lang_code': language,
          });
      
      if (response.isEmpty) return null;
      
      final data = response[0] as Map<String, dynamic>;
      return ScenarioMultilingualExtensions.fromMultilingualJson(data);
      
    } catch (e) {
      debugPrint('❌ Error fetching scenario $scenarioId for $language: $e');
      
      // Fallback to original method
      return _fallbackFetchScenarioById(scenarioId);
    }
  }

  /// Search scenarios with multilingual support
  Future<List<Scenario>> searchScenarios(String query, [String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
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
    int limit = 20,
    int offset = 0,
    String? langCode,
  }) async {
    final language = langCode ?? _currentLanguage;
    
    try {
      final response = await client
          .from('scenario_summary_multilingual')
          .select('scenario_id, sc_chapter, title, description, category, created_at')
          .eq('lang_code', language)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      final data = response as List;
      return data.map((e) {
        return Scenario(
          title: e['title'] as String,
          description: e['description'] as String,
          category: e['category'] as String,
          chapter: e['sc_chapter'] as int,
          heartResponse: '', // Summary view - full details loaded separately
          dutyResponse: '',
          gitaWisdom: '',
          createdAt: DateTime.parse(e['created_at'] as String),
        );
      }).toList();
      
    } catch (e) {
      debugPrint('❌ Error fetching paginated scenarios for $language: $e');
      
      if (language != 'en') {
        return fetchScenarios(limit: limit, offset: offset, langCode: 'en');
      }
      
      return _fallbackFetchScenarios(limit: limit, offset: offset);
    }
  }

  /// ========================================================================
  /// MULTILINGUAL VERSE METHODS
  /// ========================================================================

  /// Fetch verses with multilingual support
  Future<List<Verse>> fetchVersesByChapter(int chapterId, [String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
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
    final language = langCode ?? _currentLanguage;
    
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

  /// Fetch daily quote with multilingual support
  Future<DailyQuote> fetchRandomDailyQuote([String? langCode]) async {
    final language = langCode ?? _currentLanguage;
    
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

  Future<List<Scenario>> _fallbackFetchScenariosByChapter(int chapterId) async {
    try {
      final response = await client
          .from('scenarios')
          .select()
          .eq('sc_chapter', chapterId);
      final data = response as List;
      return data
          .map((e) => Scenario.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Fallback scenario fetch failed: $e');
      return [];
    }
  }

  Future<Scenario?> _fallbackFetchScenarioById(int id) async {
    try {
      final response = await client
          .from('scenarios')
          .select()
          .eq('id', id)
          .single();
      return Scenario.fromJson(response);
    } catch (e) {
      debugPrint('❌ Fallback scenario by ID fetch failed: $e');
      return null;
    }
  }

  Future<List<Scenario>> _fallbackSearchScenarios(String query) async {
    try {
      final response = await client
          .from('scenarios')
          .select()
          .or('sc_title.ilike.%$query%,sc_description.ilike.%$query%')
          .order('created_at', ascending: false);
      final data = response as List;
      return data
          .map((e) => Scenario.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Fallback search failed: $e');
      return [];
    }
  }

  Future<List<Scenario>> _fallbackFetchScenarios({int limit = 20, int offset = 0}) async {
    try {
      final response = await client
          .from('scenarios')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final data = response as List;
      return data
          .map((e) => Scenario.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Fallback paginated scenarios failed: $e');
      return [];
    }
  }

  Future<List<Verse>> _fallbackFetchVersesByChapter(int chapterId) async {
    try {
      final response = await client
          .from('gita_verses')
          .select()
          .eq('gv_chapter_id', chapterId)
          .order('gv_verses_id', ascending: true);
      final data = response as List;
      return data
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Fallback verses fetch failed: $e');
      return [];
    }
  }

  /// ========================================================================
  /// NON-MULTILINGUAL METHODS (UNCHANGED)
  /// ========================================================================

  /// Get total scenario count from server
  Future<int> getScenarioCount() async {
    try {
      final response = await client
          .from('scenarios')
          .select('id')
          .count();
      return response.count;
    } catch (e) {
      debugPrint('❌ Error getting scenario count: $e');
      try {
        final scenarios = await _fallbackFetchScenarios(limit: 2000);
        return scenarios.length;
      } catch (e2) {
        debugPrint('❌ Error with fallback scenario count: $e2');
        return 0;
      }
    }
  }

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

  /// Journal entry methods (unchanged - not multilingual)
  Future<void> insertJournalEntry(JournalEntry entry) async {
    try {
      final jsonData = entry.toJson();
      
      if (!jsonData.containsKey('je_id') || jsonData['je_id'] == null || (jsonData['je_id'] as String).isEmpty) {
        throw ArgumentError('Journal entry must have a valid ID');
      }
      
      if (!jsonData.containsKey('je_reflection') || jsonData['je_reflection'] == null || (jsonData['je_reflection'] as String).trim().isEmpty) {
        throw ArgumentError('Journal entry must have a reflection');
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
      
      await client
          .from('journal_entries')
          .delete()
          .eq('je_id', entryId);
      debugPrint('✅ Journal entry deleted from Supabase: $entryId');
    } catch (e) {
      debugPrint('❌ Error deleting journal entry from Supabase: $e');
      rethrow;
    }
  }

  Future<List<JournalEntry>> fetchJournalEntries() async {
    try {
      final response = await client
          .from('journal_entries')
          .select()
          .order('je_date_created', ascending: false);
      
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
    final language = langCode ?? _currentLanguage;
    
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

  /// Dispose resources
  void dispose() {
    // Clean up if needed
    debugPrint('🧹 EnhancedSupabaseService disposed');
  }
}