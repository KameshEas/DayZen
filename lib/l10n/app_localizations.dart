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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DayZen'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Offline AI Day Optimizer'**
  String get appDescription;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// No description provided for @messageExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent focus — keep it up!'**
  String get messageExcellent;

  /// No description provided for @messageGood.
  ///
  /// In en, this message translates to:
  /// **'Good progress — keep going!'**
  String get messageGood;

  /// No description provided for @messageNeedImprovement.
  ///
  /// In en, this message translates to:
  /// **'Let\'s try to improve focus today.'**
  String get messageNeedImprovement;

  /// No description provided for @emptyTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to get started.'**
  String get emptyTasksMessage;

  /// No description provided for @allTasksDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'All tasks done. Great work!'**
  String get allTasksDoneMessage;

  /// No description provided for @emptyJournalMessage.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Tap + to write your first.'**
  String get emptyJournalMessage;

  /// No description provided for @productivityDeltaDefault.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get productivityDeltaDefault;

  /// No description provided for @aiQuoteDefault.
  ///
  /// In en, this message translates to:
  /// **'\"Consistency beats perfection. Every small step counts.\"'**
  String get aiQuoteDefault;

  /// No description provided for @journalReflectionDefault.
  ///
  /// In en, this message translates to:
  /// **'You\'re on fire!'**
  String get journalReflectionDefault;

  /// No description provided for @breakRecommendationHigh.
  ///
  /// In en, this message translates to:
  /// **'Time for a break! You\'ve been focused for a while.'**
  String get breakRecommendationHigh;

  /// No description provided for @breakRecommendationMedium.
  ///
  /// In en, this message translates to:
  /// **'Consider taking a brief break to recharge.'**
  String get breakRecommendationMedium;

  /// No description provided for @breakRecommendationLight.
  ///
  /// In en, this message translates to:
  /// **'Good pace — keep it up.'**
  String get breakRecommendationLight;

  /// No description provided for @defaultDailyReflectionQuote.
  ///
  /// In en, this message translates to:
  /// **'The secret of getting ahead is getting started.'**
  String get defaultDailyReflectionQuote;

  /// No description provided for @defaultDailyReflectionAuthor.
  ///
  /// In en, this message translates to:
  /// **'MARK TWAIN'**
  String get defaultDailyReflectionAuthor;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// No description provided for @buttonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get buttonSkip;

  /// No description provided for @buttonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get buttonDone;

  /// No description provided for @buttonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonContinue;

  /// No description provided for @buttonOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOK;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get buttonCreate;

  /// No description provided for @buttonCreateTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get buttonCreateTask;

  /// No description provided for @buttonLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get buttonLogin;

  /// No description provided for @buttonSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get buttonSignUp;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @buttonRetrySynC.
  ///
  /// In en, this message translates to:
  /// **'Retry sync'**
  String get buttonRetrySynC;

  /// No description provided for @buttonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonReset;

  /// No description provided for @buttonSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get buttonSendResetEmail;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get buttonSignOut;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @labelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelTitle;

  /// No description provided for @labelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelDescription;

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @labelPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get labelPriority;

  /// No description provided for @labelStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get labelStartTime;

  /// No description provided for @labelEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get labelEndTime;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get labelTime;

  /// No description provided for @labelMood.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get labelMood;

  /// No description provided for @labelReflection.
  ///
  /// In en, this message translates to:
  /// **'Your reflection'**
  String get labelReflection;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get hintEmail;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get hintPassword;

  /// No description provided for @hintTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get hintTaskTitle;

  /// No description provided for @hintTaskDescription.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get hintTaskDescription;

  /// No description provided for @hintJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get hintJournalEntry;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get errorEmailRequired;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errorPasswordRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get errorPasswordsMismatch;

  /// No description provided for @errorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Task title is required'**
  String get errorTitleRequired;

  /// No description provided for @errorNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetworkError;

  /// No description provided for @errorAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get errorAuthFailed;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnknown;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get navigationPlanner;

  /// No description provided for @navigationInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navigationInsights;

  /// No description provided for @navigationJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navigationJournal;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @navigationDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get navigationDebug;

  /// No description provided for @navigationAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navigationAccount;

  /// No description provided for @navigationAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get navigationAppearance;

  /// No description provided for @navigationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get navigationPrivacy;

  /// No description provided for @navigationAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navigationAbout;

  /// No description provided for @homeTabTitle.
  ///
  /// In en, this message translates to:
  /// **'DayZen'**
  String get homeTabTitle;

  /// No description provided for @plannerTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get plannerTabTitle;

  /// No description provided for @insightsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTabTitle;

  /// No description provided for @journalTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTabTitle;

  /// No description provided for @homeNoTasks.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set for today!'**
  String get homeNoTasks;

  /// No description provided for @homeNoTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks scheduled. Enjoy your day!'**
  String get homeNoTasksSubtitle;

  /// No description provided for @journalNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No reflections yet'**
  String get journalNoEntries;

  /// No description provided for @journalNoEntriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start journaling to track your thoughts'**
  String get journalNoEntriesSubtitle;

  /// No description provided for @insightsNoData.
  ///
  /// In en, this message translates to:
  /// **'Come back after creating tasks'**
  String get insightsNoData;

  /// No description provided for @insightsNoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics will appear as you complete tasks'**
  String get insightsNoDataSubtitle;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompleted;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @taskSaved.
  ///
  /// In en, this message translates to:
  /// **'Task saved'**
  String get taskSaved;

  /// No description provided for @taskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get taskCreated;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncInProgress;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get syncCompleted;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncStatus;

  /// No description provided for @categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// No description provided for @categoryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get categoryPersonal;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @themeLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLightMode;

  /// No description provided for @themeDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDarkMode;

  /// No description provided for @themeSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystemDefault;

  /// No description provided for @accentPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get accentPrimary;

  /// No description provided for @accentIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get accentIndigo;

  /// No description provided for @accentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// No description provided for @accentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About DayZen'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settingsFontSize;

  /// No description provided for @settingsQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get settingsQuietHours;

  /// No description provided for @settingsFocusAlerts.
  ///
  /// In en, this message translates to:
  /// **'Focus Alerts'**
  String get settingsFocusAlerts;

  /// No description provided for @settingsDataExport.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get settingsDataExport;

  /// No description provided for @settingsClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get settingsClearHistory;

  /// No description provided for @settingsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In & Sync'**
  String get settingsSignIn;

  /// No description provided for @settingsOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode — tap to sign in'**
  String get settingsOfflineMode;

  /// No description provided for @settingsSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get settingsSignedIn;

  /// No description provided for @settingsBiometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Lock'**
  String get settingsBiometricLock;

  /// No description provided for @settingsDeviceHasBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Device supports biometrics'**
  String get settingsDeviceHasBiometrics;

  /// No description provided for @settingsDeviceNoBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get settingsDeviceNoBiometrics;

  /// No description provided for @settingsBiometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsBiometricEnabled;

  /// No description provided for @settingsBiometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsBiometricDisabled;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Stay Organized'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your day with ease'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Work Smarter'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered insights'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Reflect Daily'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @welcomeToast.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DayZen!'**
  String get welcomeToast;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineModeExplanation.
  ///
  /// In en, this message translates to:
  /// **'You can use all features without signing in.'**
  String get offlineModeExplanation;

  /// No description provided for @permissionNotifications.
  ///
  /// In en, this message translates to:
  /// **'DayZen needs permission to send notifications'**
  String get permissionNotifications;

  /// No description provided for @permissionCamera.
  ///
  /// In en, this message translates to:
  /// **'DayZen needs permission to access your camera'**
  String get permissionCamera;

  /// No description provided for @permissionMicrophone.
  ///
  /// In en, this message translates to:
  /// **'DayZen needs permission to access your microphone'**
  String get permissionMicrophone;
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
    'that was used.',
  );
}
