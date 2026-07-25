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
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000/v1');
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

  static const String messageExcellent = 'Excellent focus — keep it up!';
  static const String messageGood = 'Good progress — keep going!';
  static const String messageNeedImprovement = 'Let\'s try to improve focus today.';

  // ── Category Configuration ───────────────────────────────────────────
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
  static const String emptyTasksMessage = 'Add your first task to get started.';
  static const String allTasksDoneMessage = 'All tasks done. Great work!';
  static const String emptyJournalMessage = 'No entries yet. Tap + to write your first.';

  // ── Productivity Insights Messages ───────────────────────────────────
  static const Map<int, String> productivityDeltaMessages = {
    80: 'Great week!',
    50: 'Making progress',
  };

  static const String productivityDeltaDefault = 'Keep going!';

  // ── AI Quotes (Fallback) ─────────────────────────────────────────────
  static const Map<int, String> aiQuotesByScore = {
    80: '"Your morning focus sessions are driving this peak."',
  };

  static const String aiQuoteDefault = '"Consistency beats perfection. Every small step counts."';

  // ── Journal Reflection Messages ──────────────────────────────────────
  static const Map<int, String> journalReflectionMessages = {
    0: 'Start your journey',
    2: 'Good start!',
    4: 'Keep it up!',
  };

  static const String journalReflectionDefault = 'You\'re on fire!';

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
}
