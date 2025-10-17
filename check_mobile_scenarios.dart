import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

// Quick script to check how many scenarios contain "mobile" in Supabase
void main() async {
  // Load environment variables
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? '';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('❌ Missing Supabase credentials');
    print('Run with: source .env.development && dart check_mobile_scenarios.dart');
    exit(1);
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final supabase = Supabase.instance.client;

  print('🔍 Searching for scenarios containing "mobile"...\n');

  try {
    // Search in title
    final titleResults = await supabase
        .from('scenarios')
        .select('id, title, description')
        .ilike('title', '%mobile%');

    print('📱 Scenarios with "mobile" in TITLE: ${titleResults.length}');
    for (var scenario in titleResults) {
      print('  - ${scenario['title']}');
    }

    print('\n');

    // Search in description
    final descResults = await supabase
        .from('scenarios')
        .select('id, title, description')
        .ilike('description', '%mobile%');

    print('📝 Scenarios with "mobile" in DESCRIPTION: ${descResults.length}');
    for (var scenario in descResults) {
      print('  - ${scenario['title']}');
    }

    print('\n');

    // Search in either title OR description
    final allResults = await supabase
        .from('scenarios')
        .select('id, title, description')
        .or('title.ilike.%mobile%,description.ilike.%mobile%');

    print('🎯 Total unique scenarios with "mobile": ${allResults.length}');
    print('\nDetails:');
    for (var scenario in allResults) {
      print('\n📋 ${scenario['title']}');
      final desc = scenario['description'] as String?;
      if (desc != null && desc.toLowerCase().contains('mobile')) {
        final index = desc.toLowerCase().indexOf('mobile');
        final start = (index - 50).clamp(0, desc.length);
        final end = (index + 100).clamp(0, desc.length);
        print('   ...${desc.substring(start, end)}...');
      }
    }

    // Also search for related terms
    print('\n\n🔍 Searching for related terms...');

    final phoneResults = await supabase
        .from('scenarios')
        .select('id, title')
        .or('title.ilike.%phone%,description.ilike.%phone%');
    print('📱 Scenarios with "phone": ${phoneResults.length}');

    final deviceResults = await supabase
        .from('scenarios')
        .select('id, title')
        .or('title.ilike.%device%,description.ilike.%device%');
    print('📱 Scenarios with "device": ${deviceResults.length}');

    final smartphoneResults = await supabase
        .from('scenarios')
        .select('id, title')
        .or('title.ilike.%smartphone%,description.ilike.%smartphone%');
    print('📱 Scenarios with "smartphone": ${smartphoneResults.length}');

  } catch (e) {
    print('❌ Error: $e');
  }

  exit(0);
}
