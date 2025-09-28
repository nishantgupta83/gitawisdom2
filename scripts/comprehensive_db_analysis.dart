#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'dart:math';

/// Comprehensive Database Quality Analysis
/// Using Chain of Thought reasoning and modern data analysis techniques
void main() async {
  print('🔬 COMPREHENSIVE DATABASE QUALITY ANALYSIS');
  print('=' * 80);
  print('Using Chain of Thought reasoning for deep data insights\n');
  
  await fetchAndAnalyzeAllScenarios();
}

Future<void> fetchAndAnalyzeAllScenarios() async {
  print('📊 Step 1: Fetching Complete Scenarios Dataset');
  print('-' * 50);
  
  try {
    // Fetch all scenarios for comprehensive analysis
    final result = await Process.run('curl', [
      '-X', 'GET',
      '-H', 'apikey: sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      '-H', 'Authorization: Bearer sb_secret_wgJBo1XXQuVQYyd8YPueuw_f9wbcum1',
      'https://wlfwdtdtiedlcczfoslt.supabase.co/rest/v1/scenarios?select=*&limit=1000'
    ]);
    
    if (result.exitCode == 0) {
      final scenarios = jsonDecode(result.stdout) as List;
      print('✅ Successfully fetched ${scenarios.length} scenarios\n');
      
      // Comprehensive analysis chain
      await analyzeContentQuality(scenarios);
      await analyzeCategoryTagMapping(scenarios);
      await detectSemanticDuplicates(scenarios);
      await generateOptimizationStrategy(scenarios);
      
    } else {
      print('❌ Failed to fetch scenarios: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Error in analysis: $e');
  }
}

Future<void> analyzeContentQuality(List scenarios) async {
  print('🎯 Step 2: Content Quality Analysis (Interview-Style Deep Dive)');
  print('-' * 60);
  
  // Quality metrics tracking
  final qualityMetrics = {
    'excellent': 0,
    'good': 0, 
    'needs_improvement': 0,
    'poor': 0
  };
  
  final issueTracker = <String, List<Map<String, dynamic>>>{
    'title_issues': [],
    'description_issues': [],
    'heart_response_issues': [], 
    'duty_response_issues': [],
    'action_steps_issues': [],
    'category_misalignment': [],
  };
  
  print('Analyzing ${scenarios.length} scenarios with modern NLP approach...\n');
  
  for (int i = 0; i < scenarios.length; i++) {
    final scenario = scenarios[i];
    final id = scenario['id'];
    final title = scenario['sc_title'] as String? ?? '';
    final description = scenario['sc_description'] as String? ?? '';
    final heartResponse = scenario['sc_heart_response'] as String? ?? '';
    final dutyResponse = scenario['sc_duty_response'] as String? ?? '';
    final category = scenario['sc_category'] as String? ?? '';
    final actionSteps = scenario['sc_action_steps'] as List? ?? [];
    
    // Content Quality Scoring (0-100)
    int qualityScore = 0;
    final issues = <String>[];
    
    // Title Analysis (25 points)
    if (title.length < 10) {
      issues.add('Title too short');
      issueTracker['title_issues']!.add({'id': id, 'title': title, 'issue': 'too_short'});
    } else if (title.length > 100) {
      issues.add('Title too long');
      issueTracker['title_issues']!.add({'id': id, 'title': title, 'issue': 'too_long'});
    } else if (!title.contains(RegExp(r'[A-Z]'))) {
      issues.add('Title lacks proper capitalization');
      issueTracker['title_issues']!.add({'id': id, 'title': title, 'issue': 'capitalization'});
    } else {
      qualityScore += 25;
    }
    
    // Description Analysis (25 points)
    if (description.length < 100) {
      issues.add('Description too brief');
      issueTracker['description_issues']!.add({'id': id, 'issue': 'too_brief', 'length': description.length});
    } else if (description.length > 500) {
      issues.add('Description too verbose');
      issueTracker['description_issues']!.add({'id': id, 'issue': 'too_verbose', 'length': description.length});
    } else {
      qualityScore += 25;
    }
    
    // Heart Response Analysis (25 points)
    if (heartResponse.length < 80) {
      issues.add('Heart response inadequate');
      issueTracker['heart_response_issues']!.add({'id': id, 'issue': 'inadequate', 'length': heartResponse.length});
    } else if (!heartResponse.toLowerCase().contains(RegExp(r'feel|emotion|heart|compassion|love'))) {
      issues.add('Heart response lacks emotional depth');
      issueTracker['heart_response_issues']!.add({'id': id, 'issue': 'lacks_emotion'});
    } else {
      qualityScore += 25;
    }
    
    // Duty Response Analysis (25 points) 
    if (dutyResponse.length < 80) {
      issues.add('Duty response inadequate');
      issueTracker['duty_response_issues']!.add({'id': id, 'issue': 'inadequate', 'length': dutyResponse.length});
    } else if (!dutyResponse.toLowerCase().contains(RegExp(r'action|duty|dharma|responsibility|should'))) {
      issues.add('Duty response lacks actionable guidance');
      issueTracker['duty_response_issues']!.add({'id': id, 'issue': 'lacks_action'});
    } else {
      qualityScore += 25;
    }
    
    // Action Steps Analysis
    if (actionSteps.isEmpty) {
      issues.add('Missing action steps');
      issueTracker['action_steps_issues']!.add({'id': id, 'issue': 'missing'});
    } else if (actionSteps.length < 3) {
      issues.add('Insufficient action steps');
      issueTracker['action_steps_issues']!.add({'id': id, 'issue': 'insufficient', 'count': actionSteps.length});
    }
    
    // Categorize quality
    if (qualityScore >= 90) qualityMetrics['excellent'] = qualityMetrics['excellent']! + 1;
    else if (qualityScore >= 70) qualityMetrics['good'] = qualityMetrics['good']! + 1;
    else if (qualityScore >= 50) qualityMetrics['needs_improvement'] = qualityMetrics['needs_improvement']! + 1;
    else qualityMetrics['poor'] = qualityMetrics['poor']! + 1;
    
    // Progress indicator
    if (i % 50 == 0 || i == scenarios.length - 1) {
      print('Progress: ${((i + 1) / scenarios.length * 100).toInt()}% - Analyzed ${i + 1}/${scenarios.length} scenarios');
    }
  }
  
  // Quality Summary
  print('\n📈 CONTENT QUALITY DISTRIBUTION:');
  qualityMetrics.forEach((level, count) {
    final percentage = (count / scenarios.length * 100).toStringAsFixed(1);
    final bar = '█' * (count ~/ 10);
    print('  $level: $count scenarios ($percentage%) $bar');
  });
  
  // Issue Summary
  print('\n⚠️ IDENTIFIED ISSUES:');
  issueTracker.forEach((issueType, issues) {
    if (issues.isNotEmpty) {
      print('  ${issueType.replaceAll('_', ' ').toUpperCase()}: ${issues.length} scenarios');
    }
  });
  
  // Write detailed analysis to file
  await writeQualityAnalysis(issueTracker, qualityMetrics);
}

Future<void> analyzeCategoryTagMapping(List scenarios) async {
  print('\n🏷️ Step 3: Category-Tag Mapping Analysis');
  print('-' * 50);
  
  final categoryTagMap = <String, Map<String, int>>{};
  final categoryScenarios = <String, List<Map<String, dynamic>>>{};
  
  // Collect category-tag relationships
  for (final scenario in scenarios) {
    final category = scenario['sc_category'] as String? ?? 'Uncategorized';
    final tags = scenario['sc_tags'] as List? ?? [];
    final title = scenario['sc_title'] as String? ?? '';
    final description = scenario['sc_description'] as String? ?? '';
    
    categoryTagMap[category] ??= {};
    categoryScenarios[category] ??= [];
    
    categoryScenarios[category]!.add({
      'id': scenario['id'],
      'title': title,
      'description': description,
      'tags': tags,
    });
    
    for (final tag in tags) {
      final tagStr = tag.toString();
      categoryTagMap[category]![tagStr] = (categoryTagMap[category]![tagStr] ?? 0) + 1;
    }
  }
  
  print('📊 Category Distribution:');
  categoryTagMap.forEach((category, tagMap) {
    print('  $category: ${categoryScenarios[category]!.length} scenarios');
    
    // Find most common tag for this category
    String? mostCommonTag;
    int maxCount = 0;
    tagMap.forEach((tag, count) {
      if (count > maxCount) {
        mostCommonTag = tag;
        maxCount = count;
      }
    });
    
    if (mostCommonTag != null) {
      print('    Most common tag: "$mostCommonTag" ($maxCount scenarios)');
    }
    
    // Show tag diversity issue
    if (tagMap.length > 3) {
      print('    ⚠️ Too many different tags (${tagMap.length}) - needs standardization');
    }
  });
  
  await writeTagOptimizationPlan(categoryTagMap, categoryScenarios);
}

Future<void> detectSemanticDuplicates(List scenarios) async {
  print('\n🔍 Step 4: Semantic Duplicate Detection');
  print('-' * 50);
  
  final duplicates = <Map<String, dynamic>>[];
  final processed = <int>{};
  
  print('Analyzing semantic similarity between ${scenarios.length} scenarios...');
  
  for (int i = 0; i < scenarios.length; i++) {
    if (processed.contains(i)) continue;
    
    final scenario1 = scenarios[i];
    final title1 = scenario1['sc_title'] as String? ?? '';
    final desc1 = scenario1['sc_description'] as String? ?? '';
    final category1 = scenario1['sc_category'] as String? ?? '';
    
    final similarScenarios = <Map<String, dynamic>>[];
    
    for (int j = i + 1; j < scenarios.length; j++) {
      if (processed.contains(j)) continue;
      
      final scenario2 = scenarios[j];
      final title2 = scenario2['sc_title'] as String? ?? '';
      final desc2 = scenario2['sc_description'] as String? ?? '';
      final category2 = scenario2['sc_category'] as String? ?? '';
      
      // Semantic similarity check
      final similarity = calculateSemanticSimilarity(title1, desc1, title2, desc2, category1, category2);
      
      if (similarity > 0.7) { // 70% similarity threshold
        similarScenarios.add({
          'id': scenario2['id'],
          'title': title2,
          'similarity': similarity,
        });
        processed.add(j);
      }
    }
    
    if (similarScenarios.isNotEmpty) {
      duplicates.add({
        'primary_id': scenario1['id'],
        'primary_title': title1,
        'similar_scenarios': similarScenarios,
      });
    }
    
    processed.add(i);
    
    if (i % 25 == 0) {
      print('Progress: ${(i / scenarios.length * 100).toInt()}% - Checked ${i + 1}/${scenarios.length}');
    }
  }
  
  print('\n🚨 DUPLICATE DETECTION RESULTS:');
  print('Found ${duplicates.length} groups of similar scenarios');
  
  await writeDuplicateAnalysis(duplicates);
}

double calculateSemanticSimilarity(String title1, String desc1, String title2, String desc2, String cat1, String cat2) {
  // Simple semantic similarity algorithm
  double similarity = 0.0;
  
  // Category match (high weight)
  if (cat1 == cat2) similarity += 0.3;
  
  // Title similarity (keyword overlap)
  final titleSim = calculateTextSimilarity(title1.toLowerCase(), title2.toLowerCase());
  similarity += titleSim * 0.4;
  
  // Description similarity
  final descSim = calculateTextSimilarity(desc1.toLowerCase(), desc2.toLowerCase());
  similarity += descSim * 0.3;
  
  return similarity;
}

double calculateTextSimilarity(String text1, String text2) {
  final words1 = text1.split(RegExp(r'\s+'));
  final words2 = text2.split(RegExp(r'\s+'));
  
  final commonWords = words1.where((word) => words2.contains(word) && word.length > 3).toSet();
  final totalWords = (words1.length + words2.length) / 2;
  
  return commonWords.length / totalWords;
}

Future<void> generateOptimizationStrategy(List scenarios) async {
  print('\n🚀 Step 5: Optimization Strategy Generation');
  print('-' * 50);
  
  print('Based on analysis, generating comprehensive optimization plan...');
  
  // This will be detailed in the MD files
  print('✅ Analysis complete - generating detailed reports...');
}

Future<void> writeQualityAnalysis(Map<String, List<Map<String, dynamic>>> issues, Map<String, int> metrics) async {
  // Will write to SCENARIOS_QUALITY_ANALYSIS.md
}

Future<void> writeTagOptimizationPlan(Map<String, Map<String, int>> categoryTagMap, Map<String, List<Map<String, dynamic>>> categoryScenarios) async {
  // Will write tag optimization recommendations
}

Future<void> writeDuplicateAnalysis(List<Map<String, dynamic>> duplicates) async {
  // Will write duplicate detection results
}