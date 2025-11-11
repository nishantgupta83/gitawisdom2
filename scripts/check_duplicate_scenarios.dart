import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script to check for duplicate scenarios in Supabase
/// Duplicates are defined as scenarios with same title, chapter, and category
void main() async {
  print('🔍 Checking for duplicate scenarios in Supabase...\n');

  // Get Supabase credentials
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? '';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('❌ Error: SUPABASE_URL and SUPABASE_ANON_KEY environment variables required');
    exit(1);
  }

  try {
    // Fetch all scenarios using REST API
    print('📥 Fetching all scenarios from Supabase...');
    final url = Uri.parse('$supabaseUrl/rest/v1/scenarios?select=id,sc_title,sc_chapter,sc_category&order=sc_chapter.asc,sc_title.asc');
    final response = await http.get(
      url,
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );

    if (response.statusCode != 200) {
      print('❌ Error fetching scenarios: ${response.statusCode}');
      print(response.body);
      exit(1);
    }

    final scenarios = jsonDecode(response.body) as List<dynamic>;
    print('✅ Fetched ${scenarios.length} scenarios\n');

    // Group scenarios by (sc_title, sc_chapter, sc_category)
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var scenario in scenarios) {
      final key = '${scenario['sc_title']}|${scenario['sc_chapter']}|${scenario['sc_category']}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(scenario);
    }

    // Find duplicates
    final duplicates = grouped.entries.where((e) => e.value.length > 1).toList();

    if (duplicates.isEmpty) {
      print('✅ No duplicate scenarios found!');
      print('📊 Total unique scenarios: ${scenarios.length}');
    } else {
      print('⚠️  Found ${duplicates.length} groups of duplicate scenarios:\n');

      int totalDuplicates = 0;
      for (var duplicate in duplicates) {
        final parts = duplicate.key.split('|');
        final title = parts[0];
        final chapter = parts[1];
        final category = parts[2];
        final count = duplicate.value.length;
        totalDuplicates += count;

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📌 Duplicate Group (${count} copies):');
        print('   Title: $title');
        print('   Chapter: $chapter');
        print('   Category: $category');
        print('   IDs:');
        for (var scenario in duplicate.value) {
          print('      - ${scenario['id']}');
        }
        print('');
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Summary:');
      print('   Total scenarios: ${scenarios.length}');
      print('   Duplicate groups: ${duplicates.length}');
      print('   Total duplicate entries: $totalDuplicates');
      print('   Unique scenarios: ${scenarios.length - totalDuplicates + duplicates.length}');
    }
  } catch (e) {
    print('❌ Error checking duplicates: $e');
    exit(1);
  }

  exit(0);
}
