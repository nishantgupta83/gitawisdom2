import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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

  /// Dilemmas tab label in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Dilemmas'**
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

  /// Mindful verse carousel section title
  ///
  /// In en, this message translates to:
  /// **'Mindful Verse'**
  String get verseRefresher;

  /// Real life scenarios section title
  ///
  /// In en, this message translates to:
  /// **'Real Life Dilemma'**
  String get modernDilemma;

  /// Subtitle text for Real Life Dilemma section in home screen
  ///
  /// In en, this message translates to:
  /// **'Win battle of Emotions over Duty'**
  String get winBattleText;

  /// Button text to view scenario wisdom
  ///
  /// In en, this message translates to:
  /// **'Show Wisdom'**
  String get showWisdom;

  /// Subtitle text describing app purpose
  ///
  /// In en, this message translates to:
  /// **'Win Daily Battle of life choices by bite sized guidance'**
  String get applyGitaTeaching;

  /// Button text to view all dilemmas with count
  ///
  /// In en, this message translates to:
  /// **'View Dilemmas ({count})'**
  String viewScenarios(int count);

  /// Button text to read all verses with count
  ///
  /// In en, this message translates to:
  /// **'Read All Verses ({count})'**
  String readAllVerses(int count);

  /// Section title for related dilemmas in chapter detail
  ///
  /// In en, this message translates to:
  /// **'Related Dilemmas'**
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

  /// Button text to expand dilemma list
  ///
  /// In en, this message translates to:
  /// **'View {count} more dilemmas'**
  String viewMoreScenarios(int count);

  /// Button text to collapse scenario list
  ///
  /// In en, this message translates to:
  /// **'Show fewer situations'**
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

  /// Label for dilemma count
  ///
  /// In en, this message translates to:
  /// **'Dilemmas'**
  String get scenariosCount;

  /// Main title for dilemmas screen
  ///
  /// In en, this message translates to:
  /// **'DILEMMAS'**
  String get scenarios;

  /// Subtitle for dilemmas screen
  ///
  /// In en, this message translates to:
  /// **'Real-world dilemmas guided by Gita wisdom'**
  String get realWorldSituations;

  /// Search hint text for dilemmas
  ///
  /// In en, this message translates to:
  /// **'Search dilemmas by title or description...'**
  String get searchScenarios;

  /// Empty state when no dilemmas exist
  ///
  /// In en, this message translates to:
  /// **'No dilemmas available'**
  String get noScenariosAvailable;

  /// Empty state when search has no results
  ///
  /// In en, this message translates to:
  /// **'No dilemmas match your search'**
  String get noScenariosMatch;

  /// Error message when refresh fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh dilemmas'**
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
  /// **'A bite-size guide to the Bhagavad Gita, offering chapters, situations, and reflections—now with custom themes, language support, and more.'**
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
  /// **'GitaWisdom v2.2.8'**
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
  /// **'LIFE DILEMMA'**
  String get modernScenario;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Subtitle for chapters screen
  ///
  /// In en, this message translates to:
  /// **'Explore Scripture, Word for Word'**
  String get immersiveKnowledge;

  /// Header title for scenarios screen
  ///
  /// In en, this message translates to:
  /// **'LIFE\'S DILEMMA'**
  String get lifeScenarios;

  /// Subtitle for dilemmas screen
  ///
  /// In en, this message translates to:
  /// **'Get clarity for your Dilemmas'**
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

  /// Dilemma category option
  ///
  /// In en, this message translates to:
  /// **'Dilemma'**
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

  /// Title for chapter-specific dilemmas screen
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {chapter} DILEMMAS'**
  String chapterScenarios(int chapter);

  /// Subtitle for chapter-specific dilemmas
  ///
  /// In en, this message translates to:
  /// **'Dilemmas from Bhagavad Gita Chapter {chapter}'**
  String chapterScenariosSubtitle(int chapter);

  /// Filter status message for chapter dilemmas
  ///
  /// In en, this message translates to:
  /// **'Showing dilemmas for Chapter {chapter}'**
  String showingScenariosForChapter(int chapter);

  /// Filter status message for tag-filtered scenarios
  ///
  /// In en, this message translates to:
  /// **'Showing scenarios tagged with \"{tag}\"'**
  String showingScenariosTaggedWith(String tag);

  /// Button text to clear active filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// Label prefix for category descriptions
  ///
  /// In en, this message translates to:
  /// **'Includes: '**
  String get includes;

  /// Chapter label with number
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapter(int number);

  /// Retry button text for failed operations
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button text to reveal wisdom guidance (replaces 'Show Wisdom')
  ///
  /// In en, this message translates to:
  /// **'GET GUIDANCE'**
  String get getGuidance;

  /// Tooltip text for the Get Guidance button
  ///
  /// In en, this message translates to:
  /// **'By tapping, I will receive helpful guidance'**
  String get getGuidanceTooltip;

  /// Explanation tooltip for the Heart Says section
  ///
  /// In en, this message translates to:
  /// **'What your emotions or desires tell you'**
  String get heartSaysExplanation;

  /// Explanation tooltip for the Duty Says section
  ///
  /// In en, this message translates to:
  /// **'What your sense of duty or dharma recommends'**
  String get dutySaysExplanation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
