
// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../models/journal_entry.dart';
import '../models/chapter.dart';
import '../models/chapter_summary.dart';
import '../models/scenario.dart';
import '../models/verse.dart';
import '../screens/daily_quote.dart';

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
      return data
          .map((e) => Scenario.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching scenarios for chapter $chapterId: $e');
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

  /// Insert a journal entry (offline: Hive + online: Supabase)
  Future<void> insertJournalEntry(JournalEntry entry) async {
    try {
      await client
          .from('journal_entry')
          .insert({
        'je_id': entry.id,
        'je_reflection': entry.reflection,
        'je_rating': entry.rating,
        'je_date_created': entry.dateCreated.toIso8601String(),
      });
    } catch (e) {
      print('Error inserting journal entry: $e');
    }
  }

  /// Fetch all journal entries from Supabase
  Future<List<JournalEntry>> fetchJournalEntries() async {
    try {
      final response = await client
          .from('journal_entry')
          .select()
          .order('je_date_created', ascending: false);
      final data = response as List;
      return data
          .map((e) => JournalEntry(
                id: e['je_id'] as String,
                reflection: e['je_reflection'] as String,
                rating: e['je_rating'] as int,
                dateCreated: DateTime.parse(e['je_date_created'] as String),
              ))
          .toList();
    } catch (e) {
      print('Error fetching journal entries: $e');
      return [];
    }
  }
}
