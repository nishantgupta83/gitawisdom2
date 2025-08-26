
// lib/services/supabase_service.dart

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../models/journal_entry.dart';
import '../models/chapter.dart';
import '../models/chapter_summary.dart';
import '../models/scenario.dart';
import '../models/verse.dart';
/* MOVED TO UNUSED: import '../models/daily_quote.dart'; */

class SupabaseService {
  /// Shared Supabase client
  final SupabaseClient client = Supabase.instance.client;

  /// Fetch all chapter summaries
  Future<List<ChapterSummary>> fetchChapterSummaries() async {
    try {
      final response = await client
          .from('chapter_summary')
          .select('cs_chapter_id, cs_title, cs_subtitle, cs_verse_count, cs_scenario_count')
          .order('cs_chapter_id', ascending: true);
      final data = response as List;
      return data
          .map((e) => ChapterSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching chapter summaries: $e');
      return [];
    }
  }

  /// Fetch a single chapter by its ID
  Future<Chapter?> fetchChapterById(int chapterId) async {
    try {
      final response = await client
          .from('chapters')
          .select()
          .eq('ch_chapter_id', chapterId)
          .single();
      return Chapter.fromJson(response);
    } catch (e) {
      print('Error fetching chapter $chapterId: $e');
      return null;
    }
  }

  /// Fetch scenarios for a given chapter
  Future<List<Scenario>> fetchScenariosByChapter(int chapterId) async {
    try {
      final response = await client
          .from('scenarios')
          .select()
          .eq('sc_chapter', chapterId);
      final data = response as List;
      
      final scenarios = data
          .map((e) => Scenario.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return scenarios;
    } catch (e) {
      return [];
    }
  }

  /// Fetch a single scenario by its ID
  Future<Scenario?> fetchScenarioById(int id) async {
    try {
      final response = await client
          .from('scenarios')
          .select()
          .eq('id', id)
          .single();
      return Scenario.fromJson(response);
    } catch (e) {
      print('Error fetching scenario $id: $e');
      return null;
    }
  }

  /// Fetch paginated scenarios (useful for infinite scroll)
  Future<List<Scenario>> fetchScenarios({int limit = 20, int offset = 0}) async {
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
      print('Error fetching paginated scenarios: $e');
      return [];
    }
  }

  /// Search scenarios by title and description
  Future<List<Scenario>> searchScenarios(String query) async {
    if (query.trim().isEmpty) {
      return fetchScenarios(); // Return all scenarios if query is empty
    }

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
      print('Error searching scenarios: $e');
      return [];
    }
  }

  /// Fetch a random scenario for home screen preview
  Future<Scenario?> fetchRandomScenario() async {
    try {
      final response = await client
          .from('scenarios')
          .select()
          .order('created_at', ascending: false);
      final data = response as List;
      if (data.isEmpty) return null;
      
      // Pick a random scenario from the list
      final scenarios = data
          .map((e) => Scenario.fromJson(e as Map<String, dynamic>))
          .toList();
      final randomIndex = math.Random().nextInt(scenarios.length);
      return scenarios[randomIndex];
    } catch (e) {
      print('Error fetching random scenario: $e');
      return null;
    }
  }

  /// Count scenarios for a chapter
  Future<int> fetchScenarioCount(int chapterId) async {
    try {
      // fallback to fetching full list and counting locally
      final scenarios = await fetchScenariosByChapter(chapterId);
      return scenarios.length;
    } catch (e) {
      print('Error fetching scenario count: $e');
      return 0;
    }
  }

  /// Get total scenario count from server
  Future<int> getScenarioCount() async {
    try {
      // Use the correct Supabase count syntax
      final response = await client
          .from('scenarios')
          .select('id')
          .count();
      return response.count;
    } catch (e) {
      debugPrint('Error getting scenario count: $e');
      // Fallback: fetch a larger batch and count
      try {
        final scenarios = await fetchScenarios(limit: 2000);
        debugPrint('📊 Fallback count: ${scenarios.length} scenarios');
        return scenarios.length;
      } catch (e2) {
        debugPrint('Error with fallback scenario count: $e2');
        return 0;
      }
    }
  }

  /// Fetch all verses for a chapter
  Future<List<Verse>> fetchVersesByChapter(int chapterId) async {
    try {
      final response = await client
          .from('gita_verses')
          .select()
          .eq('gv_chapter_id', chapterId)
          .order('gv_verses_id',ascending: true);
      final data = response as List;
      return data
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching verses for chapter $chapterId: $e');
      return [];
    }
  }

 /// Fetch *all* verses for the given chapter, then pick one at random
  Future<Verse> fetchRandomVerseByChapter(int chapterId) async {
    try {
      final response = await client
        .from('gita_verses')
        .select()
        .eq('gv_chapter_id', chapterId);
      final List data = response as List;
      final verses = data
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList();

      if (verses.isEmpty) {
        throw Exception('No verses found for chapter $chapterId');
      }

      // Now Random() is in scope
      return verses[Random().nextInt(verses.length)];
    } catch (e) {
      print('Error fetching random verse: $e');
      rethrow;
    }
  }

/// Fetch all chapters from Supabase and return as a List<Chapter>.
/*  Future<List<Chapter>> fetchAllChapters() async {
    try {
      final response = await client
          .from('chapters')      // or whatever your table is named
          .select()
          .order('ch_chapter_id', ascending: true);
      final data = response as List<dynamic>;
      return data
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('❌ fetchAllChapters error $e\n$st');
      return [];
    }
  }
  
  */
  
  /// Fetch *all* chapters from Supabase (selects *all* columns).
  Future<List<Chapter>> fetchAllChapters() async {
    try {
      // no column list = select all columns
      final response = await client.from('chapters').select();
      final data = response as List;
      return data
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all chapters: $e');
      return [];
    }
  }
  
  /* MOVED TO UNUSED: DailyQuote functionality
  /// Fetch a random daily quote
  Future<DailyQuote> fetchRandomDailyQuote() async {
    try {
      final response = await client
          .from('daily_quote')
          .select()
          .order('created_at', ascending: true);
      final data = response as List;
      final quotes = data
          .map((e) => DailyQuote.fromJson(e as Map<String, dynamic>))
          .toList();
      if (quotes.isEmpty) throw Exception('No daily quotes found');
      return quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];
    } catch (e) {
      print('Error fetching daily quote: $e');
      rethrow;
    }
  }
  */

  /// Insert a journal entry to Supabase
  Future<void> insertJournalEntry(JournalEntry entry) async {
    try {
      final jsonData = entry.toJson();
      
      // Validate required fields before insertion
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
      rethrow; // Let the calling service handle the error
    }
  }

  /// Delete a journal entry from Supabase
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
      rethrow; // Let the calling service handle the error
    }
  }

  /// Fetch all journal entries from Supabase with error recovery
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
      
      // Process each entry with individual error handling
      for (final item in data) {
        try {
          if (item is Map<String, dynamic>) {
            // Ensure required fields exist
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
          // Continue processing other entries
        }
      }
      
      debugPrint('✅ Fetched ${validEntries.length} valid journal entries from Supabase');
      return validEntries;
    } catch (e) {
      debugPrint('❌ Error fetching journal entries from Supabase: $e');
      rethrow; // Let the calling service handle the error
    }
  }

  /// Insert a favorite scenario to Supabase
  Future<void> insertFavorite(String scenarioTitle) async {
    try {
      await client
          .from('user_favorites')
          .insert({
            'scenario_title': scenarioTitle,
            // Remove favorited_at since column doesn't exist yet
            // Will be handled by database DEFAULT now() if column exists
          });
      debugPrint('✅ Favorite inserted to Supabase: $scenarioTitle');
    } catch (e) {
      debugPrint('❌ Error inserting favorite to Supabase: $e');
      rethrow;
    }
  }

  /// Remove a favorite scenario from Supabase
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

  /// Fetch all favorite scenario titles from Supabase
  Future<List<String>> fetchFavorites() async {
    try {
      final response = await client
          .from('user_favorites')
          .select('scenario_title')
          // Remove ordering by favorited_at since column doesn't exist yet
          // .order('favorited_at', ascending: false);
          .order('id', ascending: false); // Order by id instead (most recent first)
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
}
