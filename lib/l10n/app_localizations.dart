import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gu'),
    Locale('hi'),
    Locale('it'),
    Locale('kn'),
    Locale('mr'),
    Locale('pt'),
    Locale('ru'),
    Locale('sa'),
    Locale('ta'),
    Locale('te')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'GitaWisdom'**
  String get appTitle;

  /// Home tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// Chapters tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chaptersTab;

  /// Scenarios tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Scenarios'**
  String get scenariosTab;

  /// Journal tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTab;

  /// More tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTab;

  /// Daily verse section title
  ///
  /// In en, this message translates to:
  /// **'Verse of the Day'**
  String get verseOfTheDay;

  /// Verse carousel section title
  ///
  /// In en, this message translates to:
  /// **'Verse Refresher'**
  String get verseRefresher;

  /// Modern scenarios section title
  ///
  /// In en, this message translates to:
  /// **'Modern Dilemma'**
  String get modernDilemma;

  /// Button text to view scenario wisdom
  ///
  /// In en, this message translates to:
  /// **'Show Wisdom'**
  String get showWisdom;

  /// Subtitle text describing app purpose
  ///
  /// In en, this message translates to:
  /// **'Apply Gita Teaching to Modern Day Situations'**
  String get applyGitaTeaching;

  /// Button text to view all scenarios with count
  ///
  /// In en, this message translates to:
  /// **'View Scenarios ({count})'**
  String viewScenarios(int count);

  /// Button text to read all verses with count
  ///
  /// In en, this message translates to:
  /// **'Read All Verses ({count})'**
  String readAllVerses(int count);

  /// Section title for related scenarios in chapter detail
  ///
  /// In en, this message translates to:
  /// **'Related Scenarios'**
  String get relatedScenarios;

  /// Section title for key teachings in chapter detail
  ///
  /// In en, this message translates to:
  /// **'Key Teachings'**
  String get keyTeachings;

  /// Section title for chapter exploration buttons
  ///
  /// In en, this message translates to:
  /// **'Explore This Chapter'**
  String get exploreChapter;

  /// Button text to expand scenario list
  ///
  /// In en, this message translates to:
  /// **'View {count} more scenarios'**
  String viewMoreScenarios(int count);

  /// Button text to collapse scenario list
  ///
  /// In en, this message translates to:
  /// **'Show fewer scenarios'**
  String get showFewerScenarios;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message for data loading failures
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Appearance settings section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode toggle setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Background music toggle setting
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// Font size setting
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Text shadow effect setting
  ///
  /// In en, this message translates to:
  /// **'Text Shadow'**
  String get textShadow;

  /// Background transparency setting
  ///
  /// In en, this message translates to:
  /// **'Background Opacity'**
  String get backgroundOpacity;

  /// Storage and cache settings section
  ///
  /// In en, this message translates to:
  /// **'Storage & Cache'**
  String get storageAndCache;

  /// Cache size display
  ///
  /// In en, this message translates to:
  /// **'Cache Size'**
  String get cacheSize;

  /// Clear cache button
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Extras settings section
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;

  /// Share app option
  ///
  /// In en, this message translates to:
  /// **'Share this App'**
  String get shareThisApp;

  /// Resources settings section
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// About screen link
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// References screen link
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// Support and legal settings section
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get supportAndLegal;

  /// Send feedback option
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms and conditions link
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// App language setting label
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Hindi language option
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// Header title for chapters screen
  ///
  /// In en, this message translates to:
  /// **'GITA CHAPTERS'**
  String get gitaChapters;

  /// Subtitle for chapters screen
  ///
  /// In en, this message translates to:
  /// **'Immerse into the ocean of knowledge'**
  String get immerseInKnowledge;

  /// Empty state message when no chapters found
  ///
  /// In en, this message translates to:
  /// **'No chapters available.'**
  String get noChaptersAvailable;

  /// Label for verse count
  ///
  /// In en, this message translates to:
  /// **'Verses'**
  String get versesCount;

  /// Label for scenario count
  ///
  /// In en, this message translates to:
  /// **'Scenarios'**
  String get scenariosCount;

  /// Main title for scenarios screen
  ///
  /// In en, this message translates to:
  /// **'SCENARIOS'**
  String get scenarios;

  /// Subtitle for scenarios screen
  ///
  /// In en, this message translates to:
  /// **'Real-world situations guided by Gita wisdom'**
  String get realWorldSituations;

  /// Search hint text for scenarios
  ///
  /// In en, this message translates to:
  /// **'Search scenarios by title or description...'**
  String get searchScenarios;

  /// Empty state when no scenarios exist
  ///
  /// In en, this message translates to:
  /// **'No scenarios available'**
  String get noScenariosAvailable;

  /// Empty state when search has no results
  ///
  /// In en, this message translates to:
  /// **'No scenarios match your search'**
  String get noScenariosMatch;

  /// Error message when refresh fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh scenarios'**
  String get failedToRefresh;

  /// Title for About screen
  ///
  /// In en, this message translates to:
  /// **'About GitaWisdom'**
  String get aboutGitaWisdom;

  /// Dedication message in About screen
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for spiritual seekers everywhere'**
  String get madeWithLove;

  /// App description in About screen
  ///
  /// In en, this message translates to:
  /// **'A bite-size guide to the Bhagavad Gita, offering chapters, scenarios, and reflections—now with custom themes, language support, and more.'**
  String get aboutDescription;

  /// Famous Gita quote in About screen
  ///
  /// In en, this message translates to:
  /// **'\"You have the right to perform your actions, but you are not entitled to the fruits of action.\"'**
  String get gitaQuote;

  /// Reference for the Gita quote
  ///
  /// In en, this message translates to:
  /// **'- Bhagavad Gita 2.47'**
  String get gitaQuoteReference;

  /// App version display
  ///
  /// In en, this message translates to:
  /// **'GitaWisdom v1.0.0'**
  String get appVersion;

  /// Title for References screen
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get referencesTitle;

  /// First reference source
  ///
  /// In en, this message translates to:
  /// **'* Bhagavad-gītā As It Is (A. C. Bhaktivedanta Swami Prabhupāda)'**
  String get reference1;

  /// Second reference source
  ///
  /// In en, this message translates to:
  /// **'* The Bhagavad Gita: A New Translation (Stephen Mitchell)'**
  String get reference2;

  /// Third reference source
  ///
  /// In en, this message translates to:
  /// **'• Other academic and traditional commentaries'**
  String get reference3;

  /// Main title for journal screen
  ///
  /// In en, this message translates to:
  /// **'MY JOURNAL'**
  String get myJournal;

  /// Subtitle for journal screen
  ///
  /// In en, this message translates to:
  /// **'Track your spiritual reflections and growth'**
  String get trackSpiritual;

  /// Empty state title when no journal entries exist
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get noJournalEntries;

  /// Empty state subtitle for journal screen
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first reflection'**
  String get tapPlusButton;

  /// Floating action button tooltip
  ///
  /// In en, this message translates to:
  /// **'Add Journal Entry'**
  String get addJournalEntry;

  /// Button text to view full journal entry
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// Button text to collapse expanded text
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// Heart response section title in scenarios
  ///
  /// In en, this message translates to:
  /// **'Heart Says'**
  String get heartSays;

  /// Duty response section title in scenarios
  ///
  /// In en, this message translates to:
  /// **'Duty Says'**
  String get dutySays;

  /// Action steps section title in scenarios
  ///
  /// In en, this message translates to:
  /// **'Wisdom Steps'**
  String get wisdomSteps;

  /// Header title for scenario detail view
  ///
  /// In en, this message translates to:
  /// **'MODERN DAY SCENARIO'**
  String get modernScenario;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Subtitle for chapters screen
  ///
  /// In en, this message translates to:
  /// **'Immerse into the ocean of knowledge'**
  String get immersiveKnowledge;

  /// Header title for scenarios screen
  ///
  /// In en, this message translates to:
  /// **'LIFE SCENARIOS'**
  String get lifeScenarios;

  /// Subtitle for scenarios screen
  ///
  /// In en, this message translates to:
  /// **'Apply Gita wisdom to real-world situations'**
  String get applyGitaWisdom;

  /// Back button tooltip
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Home button tooltip
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Error message when saving journal entry fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save journal entry'**
  String get failedToSaveEntry;

  /// Title for journal entry detail view
  ///
  /// In en, this message translates to:
  /// **'JOURNAL ENTRY'**
  String get journalEntry;

  /// Subtitle for journal entry detail with date
  ///
  /// In en, this message translates to:
  /// **'Reflection from {date}'**
  String reflectionFrom(String date);

  /// Date metadata in journal entry detail
  ///
  /// In en, this message translates to:
  /// **'Written on {date}'**
  String writtenOn(String date);

  /// Title for new journal entry dialog
  ///
  /// In en, this message translates to:
  /// **'New Journal Entry'**
  String get newJournalEntry;

  /// Label for reflection text field
  ///
  /// In en, this message translates to:
  /// **'Your Reflection'**
  String get yourReflection;

  /// Label for category dropdown
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Label for rating stars
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// General category option
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// Personal Growth category option
  ///
  /// In en, this message translates to:
  /// **'Personal Growth'**
  String get categoryPersonalGrowth;

  /// Meditation category option
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get categoryMeditation;

  /// Daily Reflection category option
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection'**
  String get categoryDailyReflection;

  /// Scenario Wisdom category option
  ///
  /// In en, this message translates to:
  /// **'Scenario Wisdom'**
  String get categoryScenarioWisdom;

  /// Chapter Insights category option
  ///
  /// In en, this message translates to:
  /// **'Chapter Insights'**
  String get categoryChapterInsights;

  /// Success message when journal entry is saved
  ///
  /// In en, this message translates to:
  /// **'Journal entry saved!'**
  String get journalEntrySaved;

  /// Title for delete journal entry dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteEntry;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirmation message for deleting journal entry
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this journal entry? This action cannot be undone.'**
  String get deleteConfirmation;

  /// Success message when journal entry is deleted
  ///
  /// In en, this message translates to:
  /// **'Journal entry deleted'**
  String get entryDeleted;

  /// Undo button text for restoring deleted entry
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Success message when deleted journal entry is restored
  ///
  /// In en, this message translates to:
  /// **'Journal entry restored'**
  String get entryRestored;

  /// Error message when restoring journal entry fails
  ///
  /// In en, this message translates to:
  /// **'Failed to restore entry'**
  String get failedToRestoreEntry;

  /// Error message when deleting journal entry fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete entry'**
  String get failedToDeleteEntry;

  /// Validation message when no rating is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'de',
        'en',
        'es',
        'fr',
        'gu',
        'hi',
        'it',
        'kn',
        'mr',
        'pt',
        'ru',
        'sa',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sa':
      return AppLocalizationsSa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
