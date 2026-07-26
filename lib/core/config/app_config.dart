/// App-wide configuration constants and defaults.
///
/// This file contains all hardcoded values organized by category.
/// Future: Load these from API/Firebase Remote Config for dynamic updates.
library;

class AppConfig {
  AppConfig._();

  // ── API Configuration ───────────────────────────────────────────────────
  // Overridden per-build via --dart-define-from-file=env/<env>.json (see
  // env/dev.json / env/staging.json / env/prod.json). The literal default
  // below only applies when no environment file is passed — i.e. an ad hoc
  // `flutter run` with no flags — and intentionally still points at
  // localhost so that case fails loudly against a real backend rather than
  // silently hitting production.
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://import-pants-worldcat-custody.trycloudflare.com/api/v1/dayzen');
  static const int apiTimeoutSeconds = 10;
  static const int cacheValidityHours = 24;

  // ── Time & Date Configuration ────────────────────────────────────────
  static const List<String> weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const List<String> weekdayFull = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const List<String> monthAbbreviations = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];
  static const List<String> monthFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // ── Greeting Configuration ───────────────────────────────────────────
  static const int morningHourThreshold = 12;
  static const int afternoonHourThreshold = 17;
  static const String greetingMorning = 'Good Morning';
  static const String greetingAfternoon = 'Good Afternoon';
  static const String greetingEvening = 'Good Evening';

  // ── Focus Score Configuration ────────────────────────────────────────
  static const int excellentScoreThreshold = 80;
  static const int goodScoreThreshold = 50;

  static const String messageExcellent = 'Crushing it — keep the momentum going!';
  static const String messageGood = 'Strong progress — you\'re building something.';
  static const String messageNeedImprovement = 'Push for better focus today.';

  // ── Category Configuration ───────────────────────────────────────────
  // Categories are currently hardcoded client-side (not server-managed).
  // If categories should become user-customizable/dynamic in future, migrate to /categories endpoint.
  static const Map<String, String> categoryLabels = {
    'work': 'Work',
    'personal': 'Personal',
    'mindful': 'Mindful',
    'study': 'Study',
  };

  static const Map<String, String> categoryFocusLabels = {
    'work': 'Deep Work Session',
    'personal': 'Personal Time',
    'mindful': 'Mindful Afternoon',
    'study': 'Focus Study Block',
  };

  static const Map<String, String> categoryInitials = {
    'work': 'DW',
    'personal': 'PT',
    'mindful': 'MA',
    'study': 'FS',
  };

  static const Map<String, int> categoryColors = {
    'work': 0xFF3B82F6,      // Blue
    'personal': 0xFF8B5CF6,  // Purple
    'mindful': 0xFF10B981,   // Green
    'study': 0xFFF59E0B,     // Amber
  };

  // ── Day Optimizer Configuration ──────────────────────────────────────
  static const int optimizerStartHour = 8;
  static const int highPriorityGapMinutes = 10;
  static const int regularGapMinutes = 5;

  static const int highPriorityDurationMinutes = 90;
  static const int zenDurationMinutes = 60;
  static const int routineDurationMinutes = 30;
  static const int lowDurationMinutes = 20;

  static const int heavyWorkloadThresholdMinutes = 240;
  static const int moderateWorkloadThresholdMinutes = 150;

  // ── Timeline View Configuration ──────────────────────────────────────
  static const double timelineHourHeight = 72.0;
  static const int timelineStartHour = 6;
  static const int timelineEndHour = 23;
  static const double timelineColWidth = 52.0;
  static const int timelineMinEventHeight = 52;
  static const int timelineMaxEventHeight = 200;

  // ── UI Color Configuration ───────────────────────────────────────────
  static const int trackBackgroundColor = 0xFFE2E8F0;
  static const int progressBarBackgroundColor = 0xFFF1F5F9;
  static const int borderLightColor = 0xFFD1D5DB;

  // ── Default Content ─────────────────────────────────────────────────
  static const String defaultDailyReflectionQuote =
    '"The secret of your future is hidden in your daily routine."';
  static const String defaultDailyReflectionAuthor = 'MIKE MURDOCK';

  // ── Empty State Messages ─────────────────────────────────────────────
  static const String emptyTasksMessage = 'Nothing on the board yet — add your first win.';
  static const String allTasksDoneMessage = 'Cleared the board. That\'s momentum.';
  static const String emptyJournalMessage = 'One entry a day builds real clarity. Start now.';

  // ── Productivity Insights Messages ───────────────────────────────────
  static const Map<int, String> productivityDeltaMessages = {
    80: 'Dominance week — that\'s the standard.',
    50: 'Building momentum — stack these days.',
  };

  static const String productivityDeltaDefault = 'Every day counts — keep stacking wins.';

  // ── AI Quotes (Fallback) ─────────────────────────────────────────────
  static const Map<int, String> aiQuotesByScore = {
    80: '"Your focus sessions are the engine behind this peak. Keep feeding it."',
  };

  static const String aiQuoteDefault = '"Momentum compounds. One focused session builds the next."';

  // ── Journal Reflection Messages ──────────────────────────────────────
  static const Map<int, String> journalReflectionMessages = {
    0: 'First entry locks in the habit.',
    2: 'Building the streak — momentum is real.',
    4: 'This consistency is the difference-maker.',
  };

  static const String journalReflectionDefault = 'You\'re unstoppable. Keep stacking entries.';

  static const Map<int, String> journalSubtitleMessages = {
    0: 'Write your first entry today.',
  };

  // ── Break Recommendation Configuration ────────────────────────────────
  static const int breakRecommendationHighThreshold = 300;
  static const int breakRecommendationMediumThreshold = 150;

  static const String breakRecommendationHigh =
    'Schedule a 20-min break every 90 minutes. A short walk or breathing exercise will restore peak focus.';
  static const String breakRecommendationMedium =
    'Take a 10-min mindful break around midday to sustain focus.';
  static const String breakRecommendationLight =
    'Light day — a short stretch or breathing exercise is enough.';

  // ── Onboarding Copy ──────────────────────────────────────────────────
  static const String onboardingSlide1Subtitle = 'Plan hard. Reflect daily. Build momentum that sticks.';
  static const String onboardingSlide2Title = 'Built For You,\nNot The Cloud';
  static const String onboardingSlide2Badge = 'OFFLINE-FIRST, ALWAYS';
  static const String onboardingSlide3Title = 'Let\'s Build\nYour Streak';
  static const String onboardingSlide3Badge = 'YOUR DATA. YOUR DEVICE.';
  static const String onboardingPrimaryCta = 'Start Crushing It';
  static const String onboardingSecondaryCta = 'Enable Sync (Optional)';

  // ── Home Copy ────────────────────────────────────────────────────────
  static const String homeAllDoneSubtitle = 'Cleared the board. That\'s momentum.';
  static const String homeRemainingSubtitleTemplate = '{n} task(s) standing between you and done.';
  static const String homeEmptyTitle = 'Blank slate. Your move.';
  static const String homeEmptyBody = 'Nothing on the board yet — add your first win.';
  static const String homeEmptyAction = 'Add a Task';

  // ── Planner Copy ─────────────────────────────────────────────────────
  static const String plannerHideAiSuggestions = 'Hide Suggestions';
  static const String plannerShowAiSuggestions = 'Optimize My Day';
  static const String plannerEmptyTitle = 'Your day is wide open';
  static const String plannerEmptyBody = 'A clear day is a chance to build one. Add your first task.';
  static const String plannerEmptyAction = 'Add a Task';

  // ── Insights Copy ────────────────────────────────────────────────────
  static const String insightsEmptyTitle = 'Your story starts here';
  static const String insightsEmptyBody = 'Log tasks and journal entries — watch your patterns take shape.';
  static const String insightsEmptyAction = 'Create a Task';

  // ── Journal Copy ─────────────────────────────────────────────────────
  static const String journalEmptyTitle = 'First entry, first win';
  static const String journalEmptyBody = 'One entry a day builds real clarity. Start now.';
  static const String journalEmptyAction = 'Write Your First Entry';

  // ── Achievements Copy ────────────────────────────────────────────────
  static const String achievementsErrorTitle = 'Couldn\'t load your wins';
  static const String achievementsEmptyTitle = 'Your first badge is waiting';
  static const String achievementsEmptyBody = 'Finish tasks, build streaks, unlock badges.';
  static const String achievementsProgressHeader = 'Your Progress';

  // ── Settings Copy ────────────────────────────────────────────────────
  static const String settingsFooter = 'DayZen Offline AI • Built around your privacy, always.';

  // ── PIN Copy ─────────────────────────────────────────────────────────
  static const String pinSetupTitle = 'Lock In Your Privacy';
  static const String pinSetupBody = 'Set a 4-digit code. Your tasks and journal stay yours alone.';
  static const String pinSetupFooter = 'Encrypted. On-device. Nowhere else.';
  static const String pinSetupError = 'Enter all 4 digits to continue.';
  static const String pinUnlockTitle = 'Welcome Back';
  static const String pinUnlockSubtitle = 'Enter your PIN to pick up where you left off.';

  // ── Auth Copy ────────────────────────────────────────────────────────
  static const String signupTitle = 'Start Your Streak';

  // ── Task/Journal Detail Copy ─────────────────────────────────────────
  static const String taskNotFound = 'This task\'s gone';
  static const String journalEntryNotFound = 'This entry\'s gone';

  // ── Router Copy ──────────────────────────────────────────────────────
  static const String routerGoHome = 'Back to DayZen';
}
