// test/models/supported_language_test.dart
// TEMPORARILY DISABLED FOR ENGLISH-ONLY MVP RELEASE

/* MULTILANG_TODO: Re-enable when multilingual support is restored

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../../lib/models/supported_language.dart';

void main() {
  group('SupportedLanguage', () {
    late SupportedLanguage englishLang;
    late SupportedLanguage hindiLang;
    late SupportedLanguage arabicLang;

    setUp(() {
      final now = DateTime.now();
      
      englishLang = SupportedLanguage(
        langCode: 'en',
        nativeName: 'English',
        englishName: 'English',
        flagEmoji: '🇺🇸',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );

      hindiLang = SupportedLanguage(
        langCode: 'hi',
        nativeName: 'हिन्दी',
        englishName: 'Hindi',
        flagEmoji: '🇮🇳',
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      );

      arabicLang = SupportedLanguage(
        langCode: 'ar',
        nativeName: 'العربية',
        englishName: 'Arabic',
        flagEmoji: '🇸🇦',
        isRTL: true,
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      );
    });

    group('Constructor and Basic Properties', () {
      test('should create instance with required properties', () {
        expect(englishLang.langCode, 'en');
        expect(englishLang.nativeName, 'English');
        expect(englishLang.englishName, 'English');
        expect(englishLang.flagEmoji, '🇺🇸');
        expect(englishLang.isRTL, false);
        expect(englishLang.isActive, true);
        expect(englishLang.sortOrder, 1);
      });

      test('should handle optional properties correctly', () {
        final langWithoutFlag = SupportedLanguage(
          langCode: 'test',
          nativeName: 'Test',
          englishName: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(langWithoutFlag.flagEmoji, isNull);
        expect(langWithoutFlag.isRTL, false);
        expect(langWithoutFlag.isActive, true);
        expect(langWithoutFlag.sortOrder, 100);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = englishLang.toJson();

        expect(json['lang_code'], 'en');
        expect(json['native_name'], 'English');
        expect(json['english_name'], 'English');
        expect(json['flag_emoji'], '🇺🇸');
        expect(json['is_rtl'], false);
        expect(json['is_active'], true);
        expect(json['sort_order'], 1);
        expect(json['created_at'], isA<String>());
        expect(json['updated_at'], isA<String>());
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'lang_code': 'fr',
          'native_name': 'Français',
          'english_name': 'French',
          'flag_emoji': '🇫🇷',
          'is_rtl': false,
          'is_active': true,
          'sort_order': 4,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        };

        final lang = SupportedLanguage.fromJson(json);

        expect(lang.langCode, 'fr');
        expect(lang.nativeName, 'Français');
        expect(lang.englishName, 'French');
        expect(lang.flagEmoji, '🇫🇷');
        expect(lang.isRTL, false);
        expect(lang.isActive, true);
        expect(lang.sortOrder, 4);
      });

      test('should handle null values in JSON', () {
        final json = {
          'lang_code': 'test',
          'native_name': 'Test',
          'english_name': 'Test',
          'flag_emoji': null,
          'is_rtl': null,
          'is_active': null,
          'sort_order': null,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        };

        final lang = SupportedLanguage.fromJson(json);

        expect(lang.flagEmoji, isNull);
        expect(lang.isRTL, false);
        expect(lang.isActive, true);
        expect(lang.sortOrder, 100);
      });
    });

    group('Display Methods', () {
      test('should return correct display name', () {
        expect(englishLang.displayName(), 'English');
        expect(englishLang.displayName(useNative: true), 'English');
        expect(englishLang.displayName(useNative: false), 'English');

        expect(hindiLang.displayName(), 'हिन्दी');
        expect(hindiLang.displayName(useNative: true), 'हिन्दी');
        expect(hindiLang.displayName(useNative: false), 'Hindi');
      });

      test('should return display name with flag', () {
        expect(englishLang.displayNameWithFlag(), '🇺🇸 English');
        expect(hindiLang.displayNameWithFlag(), '🇮🇳 हिन्दी');
        expect(hindiLang.displayNameWithFlag(useNative: false), '🇮🇳 Hindi');
      });

      test('should handle missing flag emoji', () {
        final langWithoutFlag = SupportedLanguage(
          langCode: 'test',
          nativeName: 'Test',
          englishName: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(langWithoutFlag.displayNameWithFlag(), 'Test');
      });
    });

    group('Language Classification', () {
      test('should identify English correctly', () {
        expect(englishLang.isEnglish, true);
        expect(hindiLang.isEnglish, false);
      });

      test('should identify Indian languages correctly', () {
        expect(englishLang.isIndianLanguage, false);
        expect(hindiLang.isIndianLanguage, true);

        final bengaliLang = SupportedLanguage(
          langCode: 'bn',
          nativeName: 'বাংলা',
          englishName: 'Bengali',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(bengaliLang.isIndianLanguage, true);
      });

      test('should identify European languages correctly', () {
        expect(englishLang.isEuropeanLanguage, true);
        expect(hindiLang.isEuropeanLanguage, false);

        final frenchLang = SupportedLanguage(
          langCode: 'fr',
          nativeName: 'Français',
          englishName: 'French',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(frenchLang.isEuropeanLanguage, true);
      });

      test('should return correct text direction', () {
        expect(englishLang.textDirection, TextDirection.ltr);
        expect(hindiLang.textDirection, TextDirection.ltr);
        expect(arabicLang.textDirection, TextDirection.rtl);
      });
    });

    group('Utility Methods', () {
      test('should create copy with updated fields', () {
        final updated = englishLang.copyWith(
          nativeName: 'Updated English',
          isActive: false,
        );

        expect(updated.langCode, 'en'); // Unchanged
        expect(updated.nativeName, 'Updated English'); // Changed
        expect(updated.isActive, false); // Changed
        expect(updated.englishName, 'English'); // Unchanged
      });

      test('should implement equality correctly', () {
        final englishLang2 = SupportedLanguage(
          langCode: 'en',
          nativeName: 'English',
          englishName: 'English',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(englishLang == englishLang2, true);
        expect(englishLang == hindiLang, false);
        expect(englishLang.hashCode, englishLang2.hashCode);
      });

      test('should have meaningful toString', () {
        final toString = englishLang.toString();
        expect(toString, contains('en'));
        expect(toString, contains('English'));
        expect(toString, contains('true')); // isActive
      });
    });

    group('Default Languages', () {
      test('should provide comprehensive default language list', () {
        final defaultLangs = SupportedLanguage.defaultLanguages;

        expect(defaultLangs.length, greaterThanOrEqualTo(10));
        expect(defaultLangs.any((lang) => lang.langCode == 'en'), true);
        expect(defaultLangs.any((lang) => lang.langCode == 'hi'), true);
        expect(defaultLangs.any((lang) => lang.langCode == 'es'), true);

        // Check that they're sorted
        for (int i = 1; i < defaultLangs.length; i++) {
          expect(defaultLangs[i].sortOrder, greaterThanOrEqualTo(defaultLangs[i - 1].sortOrder));
        }
      });

      test('should have valid flag emojis for default languages', () {
        final defaultLangs = SupportedLanguage.defaultLanguages;

        for (final lang in defaultLangs) {
          expect(lang.flagEmoji, isNotNull);
          expect(lang.flagEmoji!.isNotEmpty, true);
        }
      });
    });
  });

  group('SupportedLanguageListExtensions', () {
    late List<SupportedLanguage> languageList;

    setUp(() {
      final now = DateTime.now();
      languageList = [
        SupportedLanguage(
          langCode: 'en',
          nativeName: 'English',
          englishName: 'English',
          flagEmoji: '🇺🇸',
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
        SupportedLanguage(
          langCode: 'hi',
          nativeName: 'हिन्दी',
          englishName: 'Hindi',
          flagEmoji: '🇮🇳',
          sortOrder: 2,
          createdAt: now,
          updatedAt: now,
        ),
        SupportedLanguage(
          langCode: 'es',
          nativeName: 'Español',
          englishName: 'Spanish',
          flagEmoji: '🇪🇸',
          sortOrder: 3,
          createdAt: now,
          updatedAt: now,
        ),
        SupportedLanguage(
          langCode: 'de',
          nativeName: 'Deutsch',
          englishName: 'German',
          flagEmoji: '🇩🇪',
          sortOrder: 4,
          isActive: false, // Inactive language
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    test('should filter active languages only', () {
      final activeLanguages = languageList.activeOnly;
      expect(activeLanguages.length, 3);
      expect(activeLanguages.every((lang) => lang.isActive), true);
    });

    test('should sort languages correctly', () {
      final unsortedList = [languageList[2], languageList[0], languageList[1]];
      final sorted = unsortedList.sorted;

      expect(sorted[0].sortOrder, 1);
      expect(sorted[1].sortOrder, 2);
      expect(sorted[2].sortOrder, 3);
    });

    test('should filter Indian languages', () {
      final indianLanguages = languageList.indianLanguagesOnly;
      expect(indianLanguages.length, 1);
      expect(indianLanguages.first.langCode, 'hi');
    });

    test('should filter European languages', () {
      final europeanLanguages = languageList.europeanLanguagesOnly;
      expect(europeanLanguages.length, 3); // en, es, de
      expect(europeanLanguages.any((lang) => lang.langCode == 'en'), true);
      expect(europeanLanguages.any((lang) => lang.langCode == 'es'), true);
      expect(europeanLanguages.any((lang) => lang.langCode == 'de'), true);
    });

    test('should find language by code', () {
      final found = languageList.findByCode('hi');
      expect(found, isNotNull);
      expect(found!.langCode, 'hi');

      final notFound = languageList.findByCode('xx');
      expect(notFound, isNull);
    });

    test('should check if language is supported', () {
      expect(languageList.supports('en'), true);
      expect(languageList.supports('hi'), true);
      expect(languageList.supports('xx'), false);
    });

    test('should get display names', () {
      final displayNames = languageList.displayNames();
      expect(displayNames.length, 4);
      expect(displayNames[0], 'English');
      expect(displayNames[1], 'हिन्दी');
      expect(displayNames[2], 'Español');

      final englishNames = languageList.displayNames(useNative: false);
      expect(englishNames[1], 'Hindi');
      expect(englishNames[2], 'Spanish');
    });

    test('should get display names with flags', () {
      final displayNamesWithFlags = languageList.displayNamesWithFlags();
      expect(displayNamesWithFlags[0], '🇺🇸 English');
      expect(displayNamesWithFlags[1], '🇮🇳 हिन्दी');
      expect(displayNamesWithFlags[2], '🇪🇸 Español');
    });

    test('should create display map', () {
      final displayMap = languageList.toDisplayMap();
      expect(displayMap['en'], 'English');
      expect(displayMap['hi'], 'हिन्दी');
      expect(displayMap['es'], 'Español');

      final englishMap = languageList.toDisplayMap(useNative: false);
      expect(englishMap['hi'], 'Hindi');
      expect(englishMap['es'], 'Spanish');
    });

    test('should group languages by region', () {
      final grouped = languageList.groupedByRegion;
      
      expect(grouped['Indian Languages']!.length, 1);
      expect(grouped['European Languages']!.length, 3);
      expect(grouped['Other Languages']!.length, 0);

      expect(grouped['Indian Languages']!.first.langCode, 'hi');
      expect(grouped['European Languages']!.map((l) => l.langCode), 
             containsAll(['en', 'es', 'de']));
    });

    test('should identify complete translations', () {
      final withComplete = languageList.withCompleteTranslations;
      expect(withComplete.length, 1);
      expect(withComplete.first.langCode, 'en');
    });

    test('should identify partial translations', () {
      final withPartial = languageList.withPartialTranslations;
      expect(withPartial.length, 3);
      expect(withPartial.any((lang) => lang.langCode == 'hi'), true);
      expect(withPartial.any((lang) => lang.langCode == 'es'), true);
    });
  });

  group('LanguageCodes', () {
    test('should contain all expected language codes', () {
      expect(LanguageCodes.all.length, 15);
      expect(LanguageCodes.all, contains('en'));
      expect(LanguageCodes.all, contains('hi'));
      expect(LanguageCodes.all, contains('es'));
      expect(LanguageCodes.all, contains('sa')); // Sanskrit
    });

    test('should have primary languages subset', () {
      expect(LanguageCodes.primary.length, 4);
      expect(LanguageCodes.primary, containsAll(['en', 'hi', 'es', 'fr']));
    });

    test('should have Indian languages subset', () {
      expect(LanguageCodes.indian.length, 8);
      expect(LanguageCodes.indian, contains('hi'));
      expect(LanguageCodes.indian, contains('sa'));
      expect(LanguageCodes.indian, contains('ta'));
      expect(LanguageCodes.indian, isNot(contains('en')));
    });

    test('should have European languages subset', () {
      expect(LanguageCodes.european.length, 7);
      expect(LanguageCodes.european, contains('en'));
      expect(LanguageCodes.european, contains('es'));
      expect(LanguageCodes.european, contains('fr'));
      expect(LanguageCodes.european, isNot(contains('hi')));
    });
  });
}

END OF MULTILANG_TODO COMMENT BLOCK */

// Placeholder test for MVP
import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/supported_language.dart';

void main() {
  test('SupportedLanguage MVP placeholder', () {
    // Testing the simplified SupportedLanguage for English-only MVP
    const lang = SupportedLanguage(langCode: 'en');
    expect(lang.langCode, 'en');
    expect(lang.isActive, isTrue);
    expect(lang.displayName(), 'English');
    expect(SupportedLanguage.defaultLanguages.length, 1);
  });
}