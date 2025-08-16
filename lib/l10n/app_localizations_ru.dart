// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'ГитаМудрость';

  @override
  String get homeTab => 'Главная';

  @override
  String get chaptersTab => 'Главы';

  @override
  String get scenariosTab => 'Сценарии';

  @override
  String get journalTab => 'Дневник';

  @override
  String get moreTab => 'Ещё';

  @override
  String get verseOfTheDay => 'Стих дня';

  @override
  String get verseRefresher => 'Обновление стихов';

  @override
  String get modernDilemma => 'Современная дилемма';

  @override
  String get showWisdom => 'Показать мудрость';

  @override
  String get applyGitaTeaching =>
      'Применить учения Гиты к современным ситуациям';

  @override
  String viewScenarios(int count) {
    return 'Просмотреть сценарии ($count)';
  }

  @override
  String readAllVerses(int count) {
    return 'Прочитать все стихи ($count)';
  }

  @override
  String get relatedScenarios => 'Связанные сценарии';

  @override
  String get keyTeachings => 'Ключевые учения';

  @override
  String get exploreChapter => 'Исследовать эту главу';

  @override
  String viewMoreScenarios(int count) {
    return 'Просмотреть ещё $count сценариев';
  }

  @override
  String get showFewerScenarios => 'Показать меньше сценариев';

  @override
  String get loading => 'Загрузка...';

  @override
  String get errorLoadingData => 'Ошибка загрузки данных';

  @override
  String get language => 'Язык';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get backgroundMusic => 'Фоновая музыка';

  @override
  String get fontSize => 'Размер шрифта';

  @override
  String get textShadow => 'Тень текста';

  @override
  String get backgroundOpacity => 'Прозрачность фона';

  @override
  String get storageAndCache => 'Хранилище и кэш';

  @override
  String get cacheSize => 'Размер кэша';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get extras => 'Дополнительно';

  @override
  String get shareThisApp => 'Поделиться приложением';

  @override
  String get resources => 'Ресурсы';

  @override
  String get about => 'О приложении';

  @override
  String get references => 'Ссылки';

  @override
  String get supportAndLegal => 'Поддержка и правовая информация';

  @override
  String get sendFeedback => 'Отправить отзыв';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsAndConditions => 'Условия использования';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get hindi => 'हिंदी';

  @override
  String get german => 'Deutsch';

  @override
  String get french => 'Français';

  @override
  String get italian => 'Italiano';

  @override
  String get gitaChapters => 'ГЛАВЫ ГИТЫ';

  @override
  String get immerseInKnowledge => 'Погрузитесь в океан знаний';

  @override
  String get noChaptersAvailable => 'Главы недоступны.';

  @override
  String get versesCount => 'Стихи';

  @override
  String get scenariosCount => 'Сценарии';

  @override
  String get scenarios => 'СЦЕНАРИИ';

  @override
  String get realWorldSituations =>
      'Реальные жизненные ситуации, направляемые мудростью Гиты';

  @override
  String get searchScenarios => 'Поиск сценариев по названию или описанию...';

  @override
  String get noScenariosAvailable => 'Сценарии недоступны';

  @override
  String get noScenariosMatch =>
      'Ни один сценарий не соответствует вашему поиску';

  @override
  String get failedToRefresh => 'Не удалось обновить сценарии';

  @override
  String get aboutGitaWisdom => 'О ГитаМудрости';

  @override
  String get madeWithLove =>
      'Создано с ❤️ для духовных искателей по всему миру';

  @override
  String get aboutDescription =>
      'Практическое руководство по Бхагавад Гите, предлагающее главы, сценарии и размышления—теперь с пользовательскими темами, поддержкой языков и многим другим.';

  @override
  String get gitaQuote =>
      '\"У вас есть право выполнять свои действия, но вы не имеете права на плоды действий.\"';

  @override
  String get gitaQuoteReference => '- Бхагавад Гита 2.47';

  @override
  String get appVersion => 'ГитаМудрость v1.0.0';

  @override
  String get referencesTitle => 'Ссылки';

  @override
  String get reference1 =>
      '* Бхагавад-гита как она есть (А. Ч. Бхактиведанта Свами Прабхупада)';

  @override
  String get reference2 => '* Бхагавад Гита: Новый перевод (Стивен Митчелл)';

  @override
  String get reference3 => '• Другие академические и традиционные комментарии';

  @override
  String get myJournal => 'МОЙ ДНЕВНИК';

  @override
  String get trackSpiritual => 'Отслеживайте свои духовные размышления и рост';

  @override
  String get noJournalEntries => 'Пока нет записей в дневнике';

  @override
  String get tapPlusButton =>
      'Нажмите кнопку +, чтобы создать ваше первое размышление';

  @override
  String get addJournalEntry => 'Добавить запись в дневник';

  @override
  String get readMore => 'Читать далее';

  @override
  String get failedToSaveEntry => 'Не удалось сохранить запись дневника';

  @override
  String get journalEntry => 'ЗАПИСЬ ДНЕВНИКА';

  @override
  String reflectionFrom(String date) {
    return 'Размышление от $date';
  }

  @override
  String writtenOn(String date) {
    return 'Написано $date';
  }

  @override
  String get newJournalEntry => 'Новая запись дневника';

  @override
  String get yourReflection => 'Ваше размышление';

  @override
  String get category => 'Категория';

  @override
  String get rating => 'Оценка';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get categoryGeneral => 'Общее';

  @override
  String get categoryPersonalGrowth => 'Личностный рост';

  @override
  String get categoryMeditation => 'Медитация';

  @override
  String get categoryDailyReflection => 'Ежедневные размышления';

  @override
  String get categoryScenarioWisdom => 'Мудрость сценариев';

  @override
  String get categoryChapterInsights => 'Понимание глав';

  @override
  String get journalEntrySaved => 'Запись дневника сохранена!';

  @override
  String get deleteEntry => 'Удалить запись';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteConfirmation =>
      'Вы уверены, что хотите удалить эту запись дневника? Это действие нельзя отменить.';

  @override
  String get entryDeleted => 'Запись дневника удалена';

  @override
  String get undo => 'Отменить';

  @override
  String get entryRestored => 'Запись дневника восстановлена';

  @override
  String get failedToRestoreEntry => 'Не удалось восстановить запись';

  @override
  String get failedToDeleteEntry => 'Не удалось удалить запись';

  @override
  String get pleaseSelectRating => 'Пожалуйста, выберите оценку';
}
