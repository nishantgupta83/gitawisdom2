
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService()
      : client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchChapters() async {
    final response = await client
        .from('chapters')
        .select()
        .order('number', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchScenarios({int? chapter}) async {
    final query = client.from('scenarios').select();
    if (chapter != null) {
      query.eq('chapter', chapter);
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
}
