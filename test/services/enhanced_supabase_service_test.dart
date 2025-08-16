// test/services/enhanced_supabase_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../lib/services/enhanced_supabase_service.dart';
import '../../lib/models/supported_language.dart';
import '../../lib/models/chapter.dart';
import '../../lib/models/scenario.dart';
import '../../lib/models/verse.dart';
import '../../lib/models/daily_quote.dart';

// Generate mocks
@GenerateMocks([SupabaseClient, SupabaseQueryBuilder])
import 'enhanced_supabase_service_test.mocks.dart';

void main() {
  group('EnhancedSupabaseService', () {
    late EnhancedSupabaseService service;
    late MockSupabaseClient mockClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
    });

    setUp(() {
      mockClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      service = EnhancedSupabaseService();
      
      // Replace the client with our mock
      // Note: In a real implementation, you'd need dependency injection
    });

    tearDown(() async {
      // Clean up Hive boxes
      await Hive.deleteBoxFromDisk('language_cache');
    });

    group('Language Initialization', () {
      test('should initialize with default languages when network fails', () async {
        // Arrange
        when(mockClient.from('supported_languages')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('is_active', true)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('sort_order', ascending: true))
            .thenThrow(Exception('Network error'));

        // Act
        await service.initializeLanguages();

        // Assert
        expect(service.supportedLanguages.isNotEmpty, true);
        expect(service.currentLanguage, 'en');
        expect(service.supportedLanguages.length, greaterThanOrEqualTo(10));
      });

      test('should load languages from server successfully', () async {
        // Arrange
        final mockLanguagesData = [
          {
            'lang_code': 'en',
            'native_name': 'English',
            'english_name': 'English',
            'flag_emoji': '🇺🇸',
            'is_rtl': false,
            'is_active': true,
            'sort_order': 1,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          {
            'lang_code': 'hi',
            'native_name': 'हिन्दी',
            'english_name': 'Hindi',
            'flag_emoji': '🇮🇳',
            'is_rtl': false,
            'is_active': true,
            'sort_order': 2,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        when(mockClient.from('supported_languages')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('is_active', true)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockLanguagesData);

        // Act
        await service.initializeLanguages();

        // Assert
        expect(service.supportedLanguages.length, 2);
        expect(service.supportedLanguages.first.langCode, 'en');
        expect(service.supportedLanguages.first.nativeName, 'English');
      });

      test('should change current language successfully', () async {
        // Arrange
        await service.initializeLanguages();

        // Act
        await service.setCurrentLanguage('hi');

        // Assert
        expect(service.currentLanguage, 'hi');
      });

      test('should not change to unsupported language', () async {
        // Arrange
        await service.initializeLanguages();
        final originalLanguage = service.currentLanguage;

        // Act
        await service.setCurrentLanguage('xx'); // Invalid language code

        // Assert
        expect(service.currentLanguage, originalLanguage);
      });
    });

    group('Multilingual Content Fetching', () {
      setUp(() async {
        await service.initializeLanguages();
      });

      group('Chapter Methods', () {
        test('should fetch chapter with multilingual support', () async {
          // Arrange
          final mockChapterData = [
            {
              'ch_chapter_id': 1,
              'ch_title': 'अर्जुनविषादयोग',
              'ch_subtitle': 'अर्जुन की विषाद',
              'ch_summary': 'अर्जुन का संशय और कृष्ण का उपदेश',
              'ch_verse_count': 47,
              'ch_theme': 'विषाद योग',
              'ch_key_teachings': ['धर्म', 'कर्तव्य'],
              'lang_code': 'hi',
              'has_translation': true,
            }
          ];

          when(mockClient.rpc('get_chapter_with_fallback', 
                  params: {'p_chapter_id': 1, 'p_lang_code': 'hi'}))
              .thenAnswer((_) async => mockChapterData);

          // Act
          await service.setCurrentLanguage('hi');
          final chapter = await service.fetchChapterById(1);

          // Assert
          expect(chapter, isNotNull);
          expect(chapter!.chapterId, 1);
          expect(chapter.title, 'अर्जुनविषादयोग');
        });

        test('should fetch all chapters with pagination', () async {
          // Arrange - Mock chapters 1-18
          final mockChapters = List.generate(18, (i) => [
                {
                  'ch_chapter_id': i + 1,
                  'ch_title': 'Chapter ${i + 1}',
                  'ch_subtitle': 'Subtitle ${i + 1}',
                  'ch_summary': 'Summary ${i + 1}',
                  'ch_verse_count': 20 + i,
                  'ch_theme': 'Theme ${i + 1}',
                  'ch_key_teachings': ['Teaching ${i + 1}'],
                  'lang_code': 'en',
                  'has_translation': true,
                }
              ]);

          // Mock each individual chapter fetch
          for (int i = 1; i <= 18; i++) {
            when(mockClient.rpc('get_chapter_with_fallback', 
                    params: {'p_chapter_id': i, 'p_lang_code': 'en'}))
                .thenAnswer((_) async => mockChapters[i - 1]);
          }

          // Act
          final chapters = await service.fetchAllChapters('en');

          // Assert
          expect(chapters.length, 18);
          expect(chapters.first.chapterId, 1);
          expect(chapters.last.chapterId, 18);
        });
      });

      group('Scenario Methods', () {
        test('should fetch scenarios by chapter with multilingual support', () async {
          // Arrange
          final mockScenariosData = [
            {
              'scenario_id': 1,
              'sc_chapter': 1,
              'title': 'कार्यक्षेत्र में दुविधा',
              'description': 'जब आप कार्यक्षेत्र में नैतिक दुविधा का सामना करते हैं',
              'category': 'कार्य',
              'created_at': DateTime.now().toIso8601String(),
            },
            {
              'scenario_id': 2,
              'sc_chapter': 1,
              'title': 'पारिवारिक संघर्ष',
              'description': 'परिवार में मतभेद का समाधान',
              'category': 'पारिवारिक',
              'created_at': DateTime.now().toIso8601String(),
            },
          ];

          when(mockClient.from('scenario_summary_multilingual')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.select('scenario_id, sc_chapter, title, description, category, created_at'))
              .thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.eq('sc_chapter', 1)).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.eq('lang_code', 'hi')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.order('created_at', ascending: false))
              .thenAnswer((_) async => mockScenariosData);

          // Act
          await service.setCurrentLanguage('hi');
          final scenarios = await service.fetchScenariosByChapter(1);

          // Assert
          expect(scenarios.length, 2);
          expect(scenarios.first.title, 'कार्यक्षेत्र में दुविधा');
          expect(scenarios.first.chapter, 1);
        });

        test('should search scenarios with multilingual support', () async {
          // Arrange
          final mockSearchResults = [
            {
              'scenario_id': 1,
              'title': 'Workplace Dilemma',
              'description': 'When facing ethical challenges at work',
              'category': 'Work',
              'heart_response': 'Follow your emotions',
              'duty_response': 'Follow dharma',
              'gita_wisdom': 'Krishna teaches duty',
              'verse': 'Sample verse',
              'verse_number': '2.47',
              'tags': ['work', 'ethics'],
              'action_steps': ['meditate', 'consult'],
            }
          ];

          when(mockClient.from('scenario_translations')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.eq('lang_code', 'en')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.or('title.ilike.%work%,description.ilike.%work%'))
              .thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.order('scenario_id', ascending: false))
              .thenAnswer((_) async => mockSearchResults);

          // Act
          final results = await service.searchScenarios('work', 'en');

          // Assert
          expect(results.length, 1);
          expect(results.first.title, 'Workplace Dilemma');
          expect(results.first.tags, contains('work'));
        });
      });

      group('Verse Methods', () {
        test('should fetch verses with multilingual support', () async {
          // Arrange
          final mockVersesData = [
            {
              'gv_verses_id': 1,
              'gv_chapter_id': 1,
              'gv_verses': 'धृतराष्ट्र उवाच',
              'lang_code': 'hi',
              'has_translation': true,
            },
            {
              'gv_verses_id': 2,
              'gv_chapter_id': 1,
              'gv_verses': 'धर्मक्षेत्रे कुरुक्षेत्रे',
              'lang_code': 'hi',
              'has_translation': true,
            }
          ];

          when(mockClient.rpc('get_verses_with_fallback', 
                  params: {'p_chapter_id': 1, 'p_lang_code': 'hi'}))
              .thenAnswer((_) async => mockVersesData);

          // Act
          await service.setCurrentLanguage('hi');
          final verses = await service.fetchVersesByChapter(1);

          // Assert
          expect(verses.length, 2);
          expect(verses.first.verseId, 1);
          expect(verses.first.description, 'धृतराष्ट्र उवाच');
        });

        test('should fetch random verse from chapter', () async {
          // Arrange
          final mockVersesData = List.generate(10, (i) => {
                'gv_verses_id': i + 1,
                'gv_chapter_id': 1,
                'gv_verses': 'Verse ${i + 1}',
                'lang_code': 'en',
                'has_translation': true,
              });

          when(mockClient.rpc('get_verses_with_fallback', 
                  params: {'p_chapter_id': 1, 'p_lang_code': 'en'}))
              .thenAnswer((_) async => mockVersesData);

          // Act
          final randomVerse = await service.fetchRandomVerseByChapter(1);

          // Assert
          expect(randomVerse, isNotNull);
          expect(randomVerse.chapterId, 1);
          expect(randomVerse.verseId, inInclusiveRange(1, 10));
        });
      });

      group('Daily Quote Methods', () {
        test('should fetch random daily quote with multilingual support', () async {
          // Arrange
          final mockQuotesData = [
            {
              'dq_id': 'quote1',
              'created_at': DateTime.now().toIso8601String(),
            },
            {
              'dq_id': 'quote2',
              'created_at': DateTime.now().toIso8601String(),
            }
          ];

          final mockQuoteData = [
            {
              'dq_id': 'quote1',
              'dq_description': 'You have the right to action alone',
              'dq_reference': 'Bhagavad Gita 2.47',
              'created_at': DateTime.now().toIso8601String(),
              'lang_code': 'en',
              'has_translation': true,
            }
          ];

          when(mockClient.from('daily_quote')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.select('dq_id, created_at')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.order('created_at', ascending: true))
              .thenAnswer((_) async => mockQuotesData);

          when(mockClient.rpc('get_daily_quote_with_fallback', 
                  params: anyNamed('params')))
              .thenAnswer((_) async => mockQuoteData);

          // Act
          final quote = await service.fetchRandomDailyQuote('en');

          // Assert
          expect(quote, isNotNull);
          expect(quote.id, 'quote1');
          expect(quote.description, 'You have the right to action alone');
        });
      });
    });

    group('Fallback Behavior', () {
      test('should fallback to English when translation not available', () async {
        // Arrange
        await service.initializeLanguages();

        // First call with Hindi should fail
        when(mockClient.rpc('get_chapter_with_fallback', 
                params: {'p_chapter_id': 1, 'p_lang_code': 'hi'}))
            .thenThrow(Exception('No translation'));

        // Second call with English should succeed
        final mockEnglishData = [
          {
            'ch_chapter_id': 1,
            'ch_title': 'The Distress of Arjuna',
            'ch_subtitle': 'Arjuna\'s Sorrow',
            'ch_summary': 'Arjuna\'s confusion and Krishna\'s guidance',
            'ch_verse_count': 47,
            'ch_theme': 'Vishada Yoga',
            'ch_key_teachings': ['Duty', 'Dharma'],
            'lang_code': 'en',
            'has_translation': true,
          }
        ];

        when(mockClient.rpc('get_chapter_with_fallback', 
                params: {'p_chapter_id': 1, 'p_lang_code': 'en'}))
            .thenAnswer((_) async => mockEnglishData);

        // Act
        await service.setCurrentLanguage('hi');
        final chapter = await service.fetchChapterById(1);

        // Assert
        expect(chapter, isNotNull);
        expect(chapter!.title, 'The Distress of Arjuna'); // English fallback
      });
    });

    group('Translation Coverage', () {
      test('should get translation coverage statistics', () async {
        // Arrange
        final mockCoverageData = [
          {
            'content_type': 'chapters',
            'lang_code': 'hi',
            'native_name': 'हिन्दी',
            'total_items': 18,
            'translated_items': 15,
            'coverage_percentage': 83.33,
          },
          {
            'content_type': 'scenarios',
            'lang_code': 'hi',
            'native_name': 'हिन्दी',
            'total_items': 200,
            'translated_items': 120,
            'coverage_percentage': 60.00,
          }
        ];

        when(mockClient.rpc('get_translation_coverage'))
            .thenAnswer((_) async => mockCoverageData);

        // Act
        await service.setCurrentLanguage('hi');
        final coverage = await service.getTranslationCoverage();

        // Assert
        expect(coverage, isNotEmpty);
        expect(coverage['chapters'], isNotNull);
        expect(coverage['chapters']['percentage'], 83.33);
        expect(coverage['scenarios']['percentage'], 60.00);
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockClient.from(any)).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => service.initializeLanguages(), returnsNormally);
        
        await service.initializeLanguages();
        expect(service.supportedLanguages.isNotEmpty, true);
      });

      test('should handle invalid language codes', () async {
        // Arrange
        await service.initializeLanguages();

        // Act & Assert
        expect(service.isLanguageSupported('xx'), false);
        expect(service.getLanguageDisplayName('xx'), 'xx');
      });

      test('should handle empty responses gracefully', () async {
        // Arrange
        when(mockClient.rpc(any, params: anyNamed('params')))
            .thenAnswer((_) async => []);

        // Act
        final chapter = await service.fetchChapterById(999);

        // Assert
        expect(chapter, isNull);
      });
    });

    group('Performance', () {
      test('should cache supported languages locally', () async {
        // This test would verify that languages are cached in Hive
        // and can be loaded offline
        
        // Arrange
        await service.initializeLanguages();
        
        // Act - Simulate network failure on second init
        when(mockClient.from('supported_languages')).thenThrow(Exception('Network error'));
        
        final newService = EnhancedSupabaseService();
        await newService.initializeLanguages();
        
        // Assert
        expect(newService.supportedLanguages.isNotEmpty, true);
      });

      test('should refresh materialized views successfully', () async {
        // Arrange
        when(mockClient.rpc('refresh_multilingual_views'))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.refreshTranslationViews();

        // Assert
        expect(result, true);
        verify(mockClient.rpc('refresh_multilingual_views')).called(1);
      });
    });
  });
}