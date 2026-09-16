// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DayZen';

  @override
  String get appDescription => 'Offline AI Day Optimizer';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get messageExcellent => 'Excellent focus — keep it up!';

  @override
  String get messageGood => 'Good progress — keep going!';

  @override
  String get messageNeedImprovement => 'Let\'s try to improve focus today.';

  @override
  String get emptyTasksMessage => 'Add your first task to get started.';

  @override
  String get allTasksDoneMessage => 'All tasks done. Great work!';

  @override
  String get emptyJournalMessage =>
      'No entries yet. Tap + to write your first.';

  @override
  String get productivityDeltaDefault => 'Keep going!';

  @override
  String get aiQuoteDefault =>
      '\"Consistency beats perfection. Every small step counts.\"';

  @override
  String get journalReflectionDefault => 'You\'re on fire!';

  @override
  String get breakRecommendationHigh =>
      'Time for a break! You\'ve been focused for a while.';

  @override
  String get breakRecommendationMedium =>
      'Consider taking a brief break to recharge.';

  @override
  String get breakRecommendationLight => 'Good pace — keep it up.';

  @override
  String get defaultDailyReflectionQuote =>
      'The secret of getting ahead is getting started.';

  @override
  String get defaultDailyReflectionAuthor => 'MARK TWAIN';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonNext => 'Next';

  @override
  String get buttonSkip => 'Skip';

  @override
  String get buttonDone => 'Done';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonOK => 'OK';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonCreate => 'Create';

  @override
  String get buttonCreateTask => 'Create task';

  @override
  String get buttonLogin => 'Log In';

  @override
  String get buttonSignUp => 'Sign Up';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonRetrySynC => 'Retry sync';

  @override
  String get buttonReset => 'Reset';

  @override
  String get buttonSendResetEmail => 'Send Reset Email';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonSignOut => 'Sign Out';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelTitle => 'Title';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelPriority => 'Priority';

  @override
  String get labelStartTime => 'Start Time';

  @override
  String get labelEndTime => 'End Time';

  @override
  String get labelDate => 'Date';

  @override
  String get labelTime => 'Time';

  @override
  String get labelMood => 'How are you feeling?';

  @override
  String get labelReflection => 'Your reflection';

  @override
  String get hintEmail => 'name@example.com';

  @override
  String get hintPassword => '••••••••';

  @override
  String get hintTaskTitle => 'What needs to be done?';

  @override
  String get hintTaskDescription => 'Add details (optional)';

  @override
  String get hintJournalEntry => 'What\'s on your mind?';

  @override
  String get errorEmailRequired => 'Email is required';

  @override
  String get errorPasswordRequired => 'Password is required';

  @override
  String get errorInvalidEmail => 'Please enter a valid email';

  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get errorPasswordsMismatch => 'Passwords don\'t match';

  @override
  String get errorTitleRequired => 'Task title is required';

  @override
  String get errorNetworkError =>
      'Network error. Please check your connection.';

  @override
  String get errorAuthFailed => 'Login failed. Please check your credentials.';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again.';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationPlanner => 'Planner';

  @override
  String get navigationInsights => 'Insights';

  @override
  String get navigationJournal => 'Journal';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get navigationDebug => 'Debug';

  @override
  String get navigationAccount => 'Account';

  @override
  String get navigationAppearance => 'Appearance';

  @override
  String get navigationPrivacy => 'Privacy';

  @override
  String get navigationAbout => 'About';

  @override
  String get homeTabTitle => 'DayZen';

  @override
  String get plannerTabTitle => 'Planner';

  @override
  String get insightsTabTitle => 'Insights';

  @override
  String get journalTabTitle => 'Journal';

  @override
  String get homeNoTasks => 'You\'re all set for today!';

  @override
  String get homeNoTasksSubtitle => 'No tasks scheduled. Enjoy your day!';

  @override
  String get journalNoEntries => 'No reflections yet';

  @override
  String get journalNoEntriesSubtitle =>
      'Start journaling to track your thoughts';

  @override
  String get insightsNoData => 'Come back after creating tasks';

  @override
  String get insightsNoDataSubtitle =>
      'Analytics will appear as you complete tasks';

  @override
  String get taskCompleted => 'Task completed';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get taskSaved => 'Task saved';

  @override
  String get taskCreated => 'Task created';

  @override
  String get syncInProgress => 'Syncing...';

  @override
  String get syncCompleted => 'Sync completed';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncStatus => 'Sync status';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get themeLightMode => 'Light';

  @override
  String get themeDarkMode => 'Dark';

  @override
  String get themeSystemDefault => 'System default';

  @override
  String get accentPrimary => 'Primary';

  @override
  String get accentIndigo => 'Indigo';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentOrange => 'Orange';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsAbout => 'About DayZen';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsFontSize => 'Font Size';

  @override
  String get settingsQuietHours => 'Quiet Hours';

  @override
  String get settingsFocusAlerts => 'Focus Alerts';

  @override
  String get settingsDataExport => 'Data Export';

  @override
  String get settingsClearHistory => 'Clear History';

  @override
  String get settingsSignIn => 'Sign In & Sync';

  @override
  String get settingsOfflineMode => 'Offline mode — tap to sign in';

  @override
  String get settingsSignedIn => 'Signed in';

  @override
  String get settingsBiometricLock => 'Biometric Lock';

  @override
  String get settingsDeviceHasBiometrics => 'Device supports biometrics';

  @override
  String get settingsDeviceNoBiometrics => 'Not available on this device';

  @override
  String get settingsBiometricEnabled => 'Enabled';

  @override
  String get settingsBiometricDisabled => 'Disabled';

  @override
  String get onboardingSlide1Title => 'Stay Organized';

  @override
  String get onboardingSlide1Subtitle => 'Plan your day with ease';

  @override
  String get onboardingSlide2Title => 'Work Smarter';

  @override
  String get onboardingSlide2Subtitle => 'Get AI-powered insights';

  @override
  String get onboardingSlide3Title => 'Reflect Daily';

  @override
  String get onboardingSlide3Subtitle => 'Track your progress';

  @override
  String get welcomeToast => 'Welcome to DayZen!';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get offlineModeExplanation =>
      'You can use all features without signing in.';

  @override
  String get permissionNotifications =>
      'DayZen needs permission to send notifications';

  @override
  String get permissionCamera =>
      'DayZen needs permission to access your camera';

  @override
  String get permissionMicrophone =>
      'DayZen needs permission to access your microphone';
}
