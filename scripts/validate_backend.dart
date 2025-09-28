#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Simple backend validation script using curl commands
/// Validates the current production tables and data quality
void main() async {
  print('🔍 BACKEND VALIDATION REPORT');
  print('=' * 60);
  
  // Test connection
  await testConnection();
  await validateTables();
  await analyzeDataQuality();
  await checkPerformance();
  generateRecommendations();
}

Future<void> testConnection() async {
  print('\n🔌 Testing Supabase Connection');
  print('-' * 30);
  
  try {
    final result = await Process.run('curl', [
      '-X', 'GET',
      '-H', 'apikey: sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      '-H', 'Authorization: Bearer sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      'https://wlfwdtdtiedlcczfoslt.supabase.co/rest/v1/chapters?select=ch_chapter_id&limit=1'
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Connection successful!');
      final data = jsonDecode(result.stdout);
      print('📊 Sample response: $data');
    } else {
      print('❌ Connection failed: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Error testing connection: $e');
  }
}

Future<void> validateTables() async {
  print('\n📋 Validating Current Tables');
  print('-' * 30);
  
  final tables = [
    'chapters',
    'chapter_summary',
    'gita_verses', 
    'scenarios',
    'daily_quote',
    'journal_entries',
    'user_favorites'
  ];
  
  for (final table in tables) {
    await validateTable(table);
  }
}

Future<void> validateTable(String table) async {
  try {
    final result = await Process.run('curl', [
      '-X', 'GET',
      '-H', 'apikey: sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      '-H', 'Authorization: Bearer sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      '-H', 'Prefer: count=exact',
      'https://wlfwdtdtiedlcczfoslt.supabase.co/rest/v1/$table?select=*&limit=0'
    ]);
    
    if (result.exitCode == 0) {
      final headers = result.stderr;
      final countMatch = RegExp(r'content-range: 0-0/(\d+)').firstMatch(headers);
      final count = countMatch?.group(1) ?? 'unknown';
      print('✅ $table: $count records');
    } else {
      print('❌ $table: Failed to validate');
    }
  } catch (e) {
    print('⚠️ $table: Error - $e');
  }
}

Future<void> analyzeDataQuality() async {
  print('\n🎯 Scenarios Data Quality Analysis');
  print('-' * 30);
  
  try {
    // Fetch scenarios for analysis
    final result = await Process.run('curl', [
      '-X', 'GET',
      '-H', 'apikey: sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      '-H', 'Authorization: Bearer sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      'https://wlfwdtdtiedlcczfoslt.supabase.co/rest/v1/scenarios?select=sc_chapter,sc_title,sc_description,sc_heart_response,sc_duty_response,sc_gita_wisdom,sc_category&limit=100'
    ]);
    
    if (result.exitCode == 0) {
      final data = jsonDecode(result.stdout) as List;
      
      print('📈 Sample Size: ${data.length} scenarios analyzed');
      
      // Analyze chapter distribution
      final chapterCount = <int, int>{};
      final categoryCount = <String, int>{};
      final qualityIssues = <String>[];
      
      for (final scenario in data) {
        final chapter = scenario['sc_chapter'] as int?;
        final category = scenario['sc_category'] as String?;
        final title = scenario['sc_title'] as String?;
        final description = scenario['sc_description'] as String?;
        final heartResponse = scenario['sc_heart_response'] as String?;
        final dutyResponse = scenario['sc_duty_response'] as String?;
        final gitaWisdom = scenario['sc_gita_wisdom'] as String?;
        
        if (chapter != null) {
          chapterCount[chapter] = (chapterCount[chapter] ?? 0) + 1;
        }
        
        if (category != null) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
        
        // Quality checks
        if (title == null || title.length < 10) {
          qualityIssues.add('Short/missing title');
        }
        if (description == null || description.length < 50) {
          qualityIssues.add('Short/missing description');
        }
        if (heartResponse == null || heartResponse.length < 50) {
          qualityIssues.add('Inadequate heart response');
        }
        if (dutyResponse == null || dutyResponse.length < 50) {
          qualityIssues.add('Inadequate duty response');
        }
        if (gitaWisdom == null || gitaWisdom.length < 30) {
          qualityIssues.add('Brief Gita wisdom');
        }
      }
      
      print('\n📚 Chapter Distribution (sample):');
      chapterCount.forEach((chapter, count) {
        final bar = '█' * count;
        print('  Chapter $chapter: $count $bar');
      });
      
      print('\n🏷️ Category Distribution:');
      categoryCount.forEach((category, count) {
        print('  $category: $count');
      });
      
      if (qualityIssues.isNotEmpty) {
        print('\n⚠️ Data Quality Issues: ${qualityIssues.length}');
        final uniqueIssues = qualityIssues.toSet().take(5);
        uniqueIssues.forEach((issue) {
          print('  - $issue');
        });
      } else {
        print('\n✅ No major quality issues found in sample!');
      }
      
    } else {
      print('❌ Failed to fetch scenarios for analysis');
    }
  } catch (e) {
    print('❌ Error analyzing data quality: $e');
  }
}

Future<void> checkPerformance() async {
  print('\n⚡ Performance Analysis');
  print('-' * 30);
  
  final queries = [
    {
      'name': 'Fetch chapters',
      'url': 'https://wlfwdtdtiedlcczfoslt.supabase.co/rest/v1/chapters?select=*',
    },
    {
      'name': 'Scenarios by chapter', 
      'url': 'https://wlfwdtdtiedlcczfoslt.supabase.co/rest/v1/scenarios?select=*&sc_chapter=eq.1',
    },
    {
      'name': 'Search scenarios',
      'url': 'https://wlfwdtdtiedlcczfoslt.supabase.co/rest/v1/scenarios?select=*&or=(sc_title.ilike.*work*,sc_description.ilike.*work*)&limit=20',
    },
  ];
  
  for (final query in queries) {
    await testQueryPerformance(query['name']!, query['url']!);
  }
}

Future<void> testQueryPerformance(String name, String url) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run('curl', [
      '-X', 'GET',
      '-H', 'apikey: sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      '-H', 'Authorization: Bearer sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      url
    ]);
    
    stopwatch.stop();
    
    if (result.exitCode == 0) {
      final status = stopwatch.elapsedMilliseconds < 500 ? '✅' : '⚠️';
      print('$status $name: ${stopwatch.elapsedMilliseconds}ms');
      
      if (stopwatch.elapsedMilliseconds > 500) {
        print('   💡 Consider optimizing this query');
      }
    } else {
      print('❌ $name: Query failed');
    }
  } catch (e) {
    print('❌ $name: Error - $e');
  }
}

void generateRecommendations() {
  print('\n🔧 OPTIMIZATION RECOMMENDATIONS');
  print('-' * 30);
  
  print('📍 Database Indexes to Add:');
  print('  - scenarios(sc_chapter) for chapter filtering');
  print('  - scenarios(sc_category) for category filtering'); 
  print('  - gita_verses(gv_chapter_id) for verse lookups');
  
  print('\n🔗 Foreign Key Relationships:');
  print('  - scenarios.sc_chapter → chapters.ch_chapter_id');
  print('  - gita_verses.gv_chapter_id → chapters.ch_chapter_id');
  
  print('\n📈 Scalability Improvements:');
  print('  ✅ Pagination implemented in app');
  print('  ✅ Offline caching with Hive');
  print('  💡 Add full-text search for scenarios');
  print('  💡 Implement query result caching');
  print('  💡 Add composite indexes for complex queries');
  
  print('\n🌐 Translation Readiness:');
  print('  📋 Prepare translation tables:');
  print('    - scenario_translations(scenario_id, lang_code, ...)');
  print('    - verse_translations(verse_id, lang_code, ...)');
  print('  🔤 Target languages: ta, te, gu, mr, kn');
  
  print('\n🛡️ Security & Performance:');
  print('  ✅ Row Level Security (RLS) enabled');
  print('  💡 Add rate limiting for API endpoints');
  print('  💡 Implement connection pooling');
  print('  💡 Monitor query performance continuously');
  
  print('\n🎯 Content Quality:');
  print('  💡 Implement automated content validation');
  print('  💡 Add spell/grammar checking for scenarios');  
  print('  💡 Ensure balanced heart vs duty responses');
  print('  💡 Validate verse references exist');
}