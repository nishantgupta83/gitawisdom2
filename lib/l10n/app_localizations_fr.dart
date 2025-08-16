// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GitaSagesse';

  @override
  String get homeTab => 'Accueil';

  @override
  String get chaptersTab => 'Chapitres';

  @override
  String get scenariosTab => 'Scénarios';

  @override
  String get journalTab => 'Journal';

  @override
  String get moreTab => 'Plus';

  @override
  String get verseOfTheDay => 'Verset du Jour';

  @override
  String get verseRefresher => 'Rafraîchisseur de Versets';

  @override
  String get modernDilemma => 'Dilemme Moderne';

  @override
  String get showWisdom => 'Montrer la Sagesse';

  @override
  String get applyGitaTeaching =>
      'Appliquer les enseignements de la Gita aux situations modernes';

  @override
  String viewScenarios(int count) {
    return 'Voir les Scénarios ($count)';
  }

  @override
  String readAllVerses(int count) {
    return 'Lire Tous les Versets ($count)';
  }

  @override
  String get relatedScenarios => 'Scénarios Connexes';

  @override
  String get keyTeachings => 'Enseignements Clés';

  @override
  String get exploreChapter => 'Explorer ce Chapitre';

  @override
  String viewMoreScenarios(int count) {
    return 'Voir $count scénarios de plus';
  }

  @override
  String get showFewerScenarios => 'Afficher moins de scénarios';

  @override
  String get loading => 'Chargement...';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get language => 'Langue';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get backgroundMusic => 'Musique de Fond';

  @override
  String get fontSize => 'Taille de Police';

  @override
  String get textShadow => 'Ombre de Texte';

  @override
  String get backgroundOpacity => 'Opacité de l\'Arrière-plan';

  @override
  String get storageAndCache => 'Stockage et Cache';

  @override
  String get cacheSize => 'Taille du Cache';

  @override
  String get clearCache => 'Vider le Cache';

  @override
  String get extras => 'Extras';

  @override
  String get shareThisApp => 'Partager cette App';

  @override
  String get resources => 'Ressources';

  @override
  String get about => 'À propos';

  @override
  String get references => 'Références';

  @override
  String get supportAndLegal => 'Support et Légal';

  @override
  String get sendFeedback => 'Envoyer des Commentaires';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get termsAndConditions => 'Conditions Générales';

  @override
  String get appLanguage => 'Langue de l\'App';

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
  String get gitaChapters => 'CHAPITRES DE LA GITA';

  @override
  String get immerseInKnowledge => 'Plongez dans l\'océan de la connaissance';

  @override
  String get noChaptersAvailable => 'Aucun chapitre disponible.';

  @override
  String get versesCount => 'Versets';

  @override
  String get scenariosCount => 'Scénarios';

  @override
  String get scenarios => 'SCÉNARIOS';

  @override
  String get realWorldSituations =>
      'Situations réelles guidées par la sagesse de la Gita';

  @override
  String get searchScenarios =>
      'Rechercher des scénarios par titre ou description...';

  @override
  String get noScenariosAvailable => 'Aucun scénario disponible';

  @override
  String get noScenariosMatch =>
      'Aucun scénario ne correspond à votre recherche';

  @override
  String get failedToRefresh => 'Échec de l\'actualisation des scénarios';

  @override
  String get aboutGitaWisdom => 'À propos de GitaSagesse';

  @override
  String get madeWithLove =>
      'Fait avec ❤️ pour les chercheurs spirituels du monde entier';

  @override
  String get aboutDescription =>
      'Un guide pratique de la Bhagavad Gita, offrant chapitres, scénarios et réflexions—maintenant avec des thèmes personnalisés, support de langues et plus encore.';

  @override
  String get gitaQuote =>
      '\"Vous avez le droit d\'accomplir vos actions, mais vous n\'avez pas droit aux fruits de l\'action.\"';

  @override
  String get gitaQuoteReference => '- Bhagavad Gita 2.47';

  @override
  String get appVersion => 'GitaSagesse v1.0.0';

  @override
  String get referencesTitle => 'Références';

  @override
  String get reference1 =>
      '* Bhagavad-gītā Tel Qu\'Il Est (A. C. Bhaktivedanta Swami Prabhupāda)';

  @override
  String get reference2 =>
      '* La Bhagavad Gita: Une Nouvelle Traduction (Stephen Mitchell)';

  @override
  String get reference3 => '• Autres commentaires académiques et traditionnels';

  @override
  String get myJournal => 'MON JOURNAL';

  @override
  String get trackSpiritual =>
      'Suivez vos réflexions spirituelles et votre croissance';

  @override
  String get noJournalEntries => 'Aucune entrée de journal pour le moment';

  @override
  String get tapPlusButton =>
      'Appuyez sur le bouton + pour créer votre première réflexion';

  @override
  String get addJournalEntry => 'Ajouter une Entrée de Journal';

  @override
  String get readMore => 'Lire Plus';

  @override
  String get failedToSaveEntry =>
      'Échec de la sauvegarde de l\'entrée du journal';

  @override
  String get journalEntry => 'ENTRÉE DE JOURNAL';

  @override
  String reflectionFrom(String date) {
    return 'Réflexion du $date';
  }

  @override
  String writtenOn(String date) {
    return 'Écrit le $date';
  }

  @override
  String get newJournalEntry => 'Nouvelle Entrée de Journal';

  @override
  String get yourReflection => 'Votre Réflexion';

  @override
  String get category => 'Catégorie';

  @override
  String get rating => 'Évaluation';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Sauvegarder';

  @override
  String get categoryGeneral => 'Général';

  @override
  String get categoryPersonalGrowth => 'Croissance Personnelle';

  @override
  String get categoryMeditation => 'Méditation';

  @override
  String get categoryDailyReflection => 'Réflexion Quotidienne';

  @override
  String get categoryScenarioWisdom => 'Sagesse de Scénario';

  @override
  String get categoryChapterInsights => 'Aperçus de Chapitre';

  @override
  String get journalEntrySaved => 'Entrée de journal sauvegardée!';

  @override
  String get deleteEntry => 'Supprimer l\'Entrée';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette entrée de journal? Cette action ne peut pas être annulée.';

  @override
  String get entryDeleted => 'Entrée de journal supprimée';

  @override
  String get undo => 'Annuler';

  @override
  String get entryRestored => 'Entrée de journal restaurée';

  @override
  String get failedToRestoreEntry => 'Échec de la restauration de l\'entrée';

  @override
  String get failedToDeleteEntry => 'Échec de la suppression de l\'entrée';

  @override
  String get pleaseSelectRating => 'Veuillez sélectionner une évaluation';
}
