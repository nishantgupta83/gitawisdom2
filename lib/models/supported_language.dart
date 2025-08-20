// lib/models/supported_language.dart

/* MULTILANG_TODO: Restore entire SupportedLanguage model for multilingual support

import 'package:hive/hive.dart';
import 'package:flutter/widgets.dart';

part 'supported_language.g.dart';

/// ---------------------------------------------
/// MODEL: SupportedLanguage
/// ---------------------------------------------
/// Represents a language supported by the GitaWisdom app.
/// Maps to the `supported_languages` table in Supabase.
/// Provides language metadata, display helpers, and localization support.

@HiveType(typeId: 10) // Use typeId 10 to avoid conflicts with existing models
class SupportedLanguage extends HiveObject {
  /// ISO 639-1 language code (e.g., 'en', 'hi', 'es')
  @HiveField(0)
  final String langCode;

  /// Native name of the language (e.g., 'हिन्दी', 'English', 'Español')
  @HiveField(1)
  final String nativeName;

  /// English name of the language (e.g., 'Hindi', 'English', 'Spanish')
  @HiveField(2)
  final String englishName;

  /// Flag emoji for the language (e.g., '🇮🇳', '🇺🇸', '🇪🇸')
  @HiveField(3)
  final String? flagEmoji;

  /// Whether this is a right-to-left language
  @HiveField(4)
  final bool isRTL;

  /// Whether this language is currently active/enabled
  @HiveField(5)
  final bool isActive;

  /// Sort order for displaying in UI (lower numbers first)
  @HiveField(6)
  final int sortOrder;

  /// When this language was created
  @HiveField(7)
  final DateTime createdAt;

  /// When this language was last updated
  @HiveField(8)
  final DateTime updatedAt;

  SupportedLanguage({
    required this.langCode,
    required this.nativeName,
    required this.englishName,
    this.flagEmoji,
    this.isRTL = false,
    this.isActive = true,
    this.sortOrder = 100,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [SupportedLanguage] from a JSON map returned by Supabase
  factory SupportedLanguage.fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      langCode: json['lang_code'] as String,
      nativeName: json['native_name'] as String,
      englishName: json['english_name'] as String,
      flagEmoji: json['flag_emoji'] as String?,
      isRTL: json['is_rtl'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 100,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [SupportedLanguage] to a JSON map suitable for Supabase
  Map<String, dynamic> toJson() => {
        'lang_code': langCode,
        'native_name': nativeName,
        'english_name': englishName,
        'flag_emoji': flagEmoji,
        'is_rtl': isRTL,
        'is_active': isActive,
        'sort_order': sortOrder,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Returns the display name for this language based on user preference
  /// If [useNative] is true, returns native name, otherwise English name
  String displayName({bool useNative = true}) {
    return useNative ? nativeName : englishName;
  }

  /// Returns a formatted display string with flag emoji and name
  /// Example: "🇮🇳 हिन्दी" or "🇺🇸 English"
  String displayNameWithFlag({bool useNative = true}) {
    final name = displayName(useNative: useNative);
    return flagEmoji != null ? '$flagEmoji $name' : name;
  }

  /// Returns true if this is the English language
  bool get isEnglish => langCode.toLowerCase() == 'en';

  /// Returns true if this is an Indian language
  bool get isIndianLanguage => const [
        'hi', // Hindi
        'bn', // Bengali
        'gu', // Gujarati
        'kn', // Kannada
        'mr', // Marathi
        'ta', // Tamil
        'te', // Telugu
        'sa', // Sanskrit
      ].contains(langCode.toLowerCase());

  /// Returns true if this is a European language
  bool get isEuropeanLanguage => const [
        'en', // English
        'es', // Spanish
        'fr', // French
        'de', // German
        'it', // Italian
        'pt', // Portuguese
        'ru', // Russian
      ].contains(langCode.toLowerCase());

  /// Returns the text direction for this language
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Creates a copy of this language with updated fields
  SupportedLanguage copyWith({
    String? langCode,
    String? nativeName,
    String? englishName,
    String? flagEmoji,
    bool? isRTL,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportedLanguage(
      langCode: langCode ?? this.langCode,
      nativeName: nativeName ?? this.nativeName,
      englishName: englishName ?? this.englishName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      isRTL: isRTL ?? this.isRTL,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedLanguage &&
          runtimeType == other.runtimeType &&
          langCode == other.langCode;

  @override
  int get hashCode => langCode.hashCode;

  @override
  String toString() =>
      'SupportedLanguage(langCode: $langCode, nativeName: $nativeName, isActive: $isActive)';

  /// Default supported languages for offline usage
  static List<SupportedLanguage> get defaultLanguages {
    final now = DateTime.now();
    return [
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
        langCode: 'fr',
        nativeName: 'Français',
        englishName: 'French',
        flagEmoji: '🇫🇷',
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'de',
        nativeName: 'Deutsch',
        englishName: 'German',
        flagEmoji: '🇩🇪',
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'pt',
        nativeName: 'Português',
        englishName: 'Portuguese',
        flagEmoji: '🇧🇷',
        sortOrder: 6,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'it',
        nativeName: 'Italiano',
        englishName: 'Italian',
        flagEmoji: '🇮🇹',
        sortOrder: 7,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'ru',
        nativeName: 'Русский',
        englishName: 'Russian',
        flagEmoji: '🇷🇺',
        sortOrder: 8,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'bn',
        nativeName: 'বাংলা',
        englishName: 'Bengali',
        flagEmoji: '🇧🇩',
        sortOrder: 9,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'gu',
        nativeName: 'ગુજરાતી',
        englishName: 'Gujarati',
        flagEmoji: '🇮🇳',
        sortOrder: 10,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'kn',
        nativeName: 'ಕನ್ನಡ',
        englishName: 'Kannada',
        flagEmoji: '🇮🇳',
        sortOrder: 11,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'mr',
        nativeName: 'मराठी',
        englishName: 'Marathi',
        flagEmoji: '🇮🇳',
        sortOrder: 12,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'ta',
        nativeName: 'தமிழ்',
        englishName: 'Tamil',
        flagEmoji: '🇮🇳',
        sortOrder: 13,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'te',
        nativeName: 'తెలుగు',
        englishName: 'Telugu',
        flagEmoji: '🇮🇳',
        sortOrder: 14,
        createdAt: now,
        updatedAt: now,
      ),
      SupportedLanguage(
        langCode: 'sa',
        nativeName: 'संस्कृतम्',
        englishName: 'Sanskrit',
        flagEmoji: '🕉️',
        sortOrder: 15,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

/// ---------------------------------------------
/// EXTENSIONS FOR LIST<SUPPORTED_LANGUAGE>
/// ---------------------------------------------

extension SupportedLanguageListExtensions on List<SupportedLanguage> {
  /// Returns only active languages
  List<SupportedLanguage> get activeOnly =>
      where((lang) => lang.isActive).toList();

  /// Returns languages sorted by sort order
  List<SupportedLanguage> get sorted =>
      [...this]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// Returns only Indian languages
  List<SupportedLanguage> get indianLanguagesOnly =>
      where((lang) => lang.isIndianLanguage).toList();

  /// Returns only European languages
  List<SupportedLanguage> get europeanLanguagesOnly =>
      where((lang) => lang.isEuropeanLanguage).toList();

  /// Returns only RTL languages
  List<SupportedLanguage> get rtlLanguagesOnly =>
      where((lang) => lang.isRTL).toList();

  /// Finds a language by language code
  SupportedLanguage? findByCode(String langCode) {
    try {
      return firstWhere(
        (lang) => lang.langCode.toLowerCase() == langCode.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Returns true if the given language code is supported
  bool supports(String langCode) => findByCode(langCode) != null;

  /// Gets the display names for all languages
  List<String> displayNames({bool useNative = true}) =>
      map((lang) => lang.displayName(useNative: useNative)).toList();

  /// Gets the display names with flags for all languages
  List<String> displayNamesWithFlags({bool useNative = true}) =>
      map((lang) => lang.displayNameWithFlag(useNative: useNative)).toList();

  /// Creates a map of language codes to display names
  Map<String, String> toDisplayMap({bool useNative = true}) => {
        for (final lang in this)
          lang.langCode: lang.displayName(useNative: useNative),
      };

  /// Groups languages by region/family
  Map<String, List<SupportedLanguage>> get groupedByRegion => {
        'Indian Languages': indianLanguagesOnly.sorted,
        'European Languages': europeanLanguagesOnly.sorted,
        'Other Languages': where((lang) => 
            !lang.isIndianLanguage && !lang.isEuropeanLanguage).toList().sorted,
      };

  /// Returns languages that have complete translations available
  /// This would be determined by checking translation coverage
  List<SupportedLanguage> get withCompleteTranslations {
    // For now, return only English as it has complete content
    // This can be enhanced with actual translation coverage data
    return where((lang) => lang.langCode == 'en').toList();
  }

  /// Returns languages that have partial translations available
  List<SupportedLanguage> get withPartialTranslations {
    // Return non-English languages as they may have partial translations
    return where((lang) => lang.langCode != 'en').toList();
  }
}

/// ---------------------------------------------
/// LANGUAGE CONSTANTS
/// ---------------------------------------------

class LanguageCodes {
  static const String english = 'en';
  static const String hindi = 'hi';
  static const String spanish = 'es';
  static const String french = 'fr';
  static const String german = 'de';
  static const String portuguese = 'pt';
  static const String italian = 'it';
  static const String russian = 'ru';
  static const String bengali = 'bn';
  static const String gujarati = 'gu';
  static const String kannada = 'kn';
  static const String marathi = 'mr';
  static const String tamil = 'ta';
  static const String telugu = 'te';
  static const String sanskrit = 'sa';

  /// List of all supported language codes
  static const List<String> all = [
    english, hindi, spanish, french, german, portuguese, italian, 
    russian, bengali, gujarati, kannada, marathi, tamil, telugu, sanskrit,
  ];

  /// Primary languages (most commonly used)
  static const List<String> primary = [english, hindi, spanish, french];

  /// Indian languages
  static const List<String> indian = [
    hindi, bengali, gujarati, kannada, marathi, tamil, telugu, sanskrit,
  ];

  /// European languages
  static const List<String> european = [
    english, spanish, french, german, portuguese, italian, russian,
  ];
}

END OF MULTILANG_TODO COMMENT BLOCK */

/// MVP: Empty SupportedLanguage placeholder for English-only release
/// This prevents compilation errors while maintaining clean structure
class SupportedLanguage {
  // Minimal implementation for compilation compatibility
  final String langCode;
  const SupportedLanguage({required this.langCode});
  
  // Static method to prevent errors in existing code
  static List<SupportedLanguage> get defaultLanguages => [
    const SupportedLanguage(langCode: 'en')
  ];
  
  // Compatibility methods to prevent errors
  bool get isActive => true;
  String displayName({bool useNative = true}) => 'English';
  String displayNameWithFlag({bool useNative = true}) => '🇺🇸 English';
}

/// MVP: Empty adapter for compatibility - no Hive functionality
class SupportedLanguageAdapter {
  // Empty implementation for Hive compatibility
  int get typeId => 10;
  SupportedLanguage read(dynamic reader) => const SupportedLanguage(langCode: 'en');
  void write(dynamic writer, SupportedLanguage obj) {}
}