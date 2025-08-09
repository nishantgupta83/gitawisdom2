// Test configuration and utilities
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/journal_entry.dart';
import 'package:GitaWisdom/models/chapter.dart';
import 'package:GitaWisdom/models/chapter_summary.dart';

class TestConfig {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration networkDelay = Duration(milliseconds: 500);
  static const Duration cacheTimeout = Duration(hours: 24);
  
  static Future<void> pumpWithSettle(WidgetTester tester, [Duration? duration]) async {
    await tester.pump(duration);
    await tester.pumpAndSettle();
  }
  
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: child,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

// Comprehensive test data for all models
class TestData {
  // Legacy test data
  static const sampleVerseText = "Test verse content for unit testing";
  static const sampleChapterTitle = "Sample Chapter Title";
  static const sampleScenarioDescription = "Sample scenario description for testing";

  // Enhanced Verse test data
  static final sampleVerse = Verse(
    verseId: 1,
    description: "dhritarashtra uvacha dharma-kshetre kuru-kshetre samaveta yuyutsavah",
    chapterId: 1,
  );

  static final sampleVerseWithoutChapter = Verse(
    verseId: 2,
    description: "You have a right to perform your prescribed duty, but never to the fruits of action",
  );

  // DailyVerseSet test data
  static final sampleDailyVerseSet = DailyVerseSet(
    date: '2024-01-15',
    verses: [sampleVerse, sampleVerseWithoutChapter],
    chapterIds: [1, 2],
    createdAt: DateTime(2024, 1, 15, 6, 0),
  );

  static final todayDailyVerseSet = DailyVerseSet.forToday(
    verses: [sampleVerse],
    chapterIds: [1],
  );

  // Scenario test data
  static final sampleScenario = Scenario(
    title: 'Career Transition Dilemma',
    description: 'Should I leave my stable job to pursue my passion?',
    category: 'Career',
    chapter: 2,
    heartResponse: 'Follow your passion and dreams, life is too short for unfulfilling work',
    dutyResponse: 'Consider your responsibilities to family and financial obligations',
    gitaWisdom: 'Perform your duty without attachment to results. Focus on action, not outcomes',
    verse: 'You have a right to perform your prescribed duty, but do not covet the fruits of action',
    verseNumber: '2.47',
    tags: ['career', 'transition', 'duty', 'passion'],
    actionSteps: [
      'Analyze your current financial situation',
      'Research the new career path thoroughly', 
      'Consult with trusted mentors',
      'Create a transition plan with timeline'
    ],
    createdAt: DateTime(2024, 1, 15, 10, 30),
  );

  static final relationshipScenario = Scenario(
    title: 'Family Conflict Resolution',
    description: 'How to handle disagreements with family members?',
    category: 'Relationships',
    chapter: 3,
    heartResponse: 'Express your feelings openly and honestly',
    dutyResponse: 'Maintain family harmony and show respect to elders',
    gitaWisdom: 'Act with compassion while staying true to righteousness',
    verse: 'One who is not disturbed by the incessant flow of desires achieves peace',
    verseNumber: '2.70',
    tags: ['family', 'conflict', 'harmony'],
    actionSteps: ['Listen actively', 'Speak with kindness', 'Find common ground'],
    createdAt: DateTime(2024, 1, 16, 15, 45),
  );

  // JournalEntry test data
  static final sampleJournalEntry = JournalEntry(
    id: 'test-journal-001',
    reflection: 'Today I practiced detachment by not getting upset when my project was delayed. I focused on doing my best work without worrying about the timeline.',
    rating: 4,
    dateCreated: DateTime(2024, 1, 15, 20, 30),
  );

  static final lowRatingEntry = JournalEntry(
    id: 'test-journal-002', 
    reflection: 'Struggled with anger today when dealing with difficult colleagues. Need to work more on patience.',
    rating: 2,
    dateCreated: DateTime(2024, 1, 16, 19, 15),
  );

  // Chapter test data
  static final sampleChapter = Chapter(
    chapterId: 1,
    title: 'Observing the Armies',
    subtitle: 'Arjuna Vishada Yoga',
    summary: 'Arjuna\'s moral dilemma on the battlefield of Kurukshetra, where he becomes overwhelmed by doubt and sorrow.',
    verseCount: 47,
    theme: 'Duty vs Personal Attachment',
    keyTeachings: ['dharma', 'duty', 'righteousness', 'moral_conflict'],
  );

  static final secondChapter = Chapter(
    chapterId: 2,
    title: 'Contents of the Gita Summarized', 
    subtitle: 'Sankhya Yoga',
    summary: 'Krishna begins his teachings to Arjuna about the nature of the soul and the importance of duty.',
    verseCount: 72,
    theme: 'Self-realization and Detached Action',
    keyTeachings: ['soul', 'detachment', 'action', 'wisdom'],
  );

  // ChapterSummary test data
  static final sampleChapterSummary = ChapterSummary(
    chapterId: 1,
    title: 'Observing the Armies',
    subtitle: 'Arjuna Vishada Yoga', 
    verseCount: 47,
    scenarioCount: 8,
  );

  // Lists for comprehensive testing
  static final allTestVerses = [sampleVerse, sampleVerseWithoutChapter];
  static final allTestScenarios = [sampleScenario, relationshipScenario];
  static final allTestJournalEntries = [sampleJournalEntry, lowRatingEntry];
  static final allTestChapters = [sampleChapter, secondChapter];

  // Test data for caching scenarios
  static final cacheTestData = {
    'daily_verses_today': todayDailyVerseSet,
    'daily_verses_past': sampleDailyVerseSet,
    'scenarios_cached': allTestScenarios,
    'journal_entries': allTestJournalEntries,
  };

  // JSON test data for serialization tests
  static final verseJson = {
    'gv_verses_id': 1,
    'gv_verses': 'Test verse content',
    'gv_chapter_id': 1,
  };

  static final scenarioJson = {
    'sc_title': 'Test Scenario',
    'sc_description': 'Test description',
    'sc_category': 'Test',
    'sc_chapter': 1,
    'sc_heart_response': 'Heart response',
    'sc_duty_response': 'Duty response', 
    'sc_gita_wisdom': 'Gita wisdom',
    'sc_verse': 'Test verse',
    'sc_verse_number': '1.1',
    'sc_tags': ['test', 'sample'],
    'sc_action_steps': ['Step 1', 'Step 2'],
    'created_at': '2024-01-15T10:30:00Z',
  };
}
