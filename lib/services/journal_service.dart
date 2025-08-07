
import 'package:hive/hive.dart';
import '../models/journal_entry.dart';
import '../services/supabase_service.dart';

class JournalService {
  final Box<JournalEntry> _box = Hive.box<JournalEntry>('journal_entries');
  final SupabaseService _supabase = SupabaseService();

  /// read everything from Hive
  Future<List<JournalEntry>> fetchEntries() async {
    // always show a “Welcome” entry at the top
    final welcome = JournalEntry(
      id: 'welcome',
      reflection: 'Welcome to your journal! Tap + to add your first note.',
      rating: 0,
      dateCreated: DateTime.now(),
    );
    return [welcome, ..._box.values.toList()];
  }

  /// store locally, then push to Supabase
  Future<void> createEntry(JournalEntry e) async {
    await _box.put(e.id, e);
    await _supabase.insertJournalEntry(e);
  }
}

