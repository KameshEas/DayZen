import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/domain/task_analytics.dart';
import '../../app_data.dart';
import '../../home/models/task_model.dart';

/// Everything the Insights screen shows, computed from the user's own tasks and
/// journal. A plain value: build it with [InsightsData.from] in the UI, or with
/// [InsightsData.fromTasks] anywhere else (tests, previews).
class InsightsData {
  const InsightsData({
    required this.productivityScore,
    required this.todayDone,
    required this.todayPlanned,
    required this.streakDays,
    required this.focusBars,
    required this.weekFocusMinutes,
    required this.completionBars,
    required this.weeklyTasksDone,
    required this.topCategory,
    required this.mindfulDone,
    required this.mindfulPlanned,
    required this.peak,
    required this.journalCount,
    required this.today,
  });

  factory InsightsData.fromTasks(
    List<DzTask> tasks, {
    required int journalCount,
    required DateTime now,
  }) {
    final todays = tasks.where((t) => t.isSameDay(now)).toList();
    final mindful = TaskAnalytics.mindfulProgress(tasks, now);
    return InsightsData(
      productivityScore: TaskAnalytics.score(tasks, now),
      todayDone: todays.where((t) => t.isCompleted).length,
      todayPlanned: todays.length,
      streakDays: TaskAnalytics.streakDays(tasks, now),
      focusBars: TaskAnalytics.weekFocusFractions(tasks, now),
      weekFocusMinutes: TaskAnalytics.weekFocusMinutes(tasks, now)
          .fold<int>(0, (sum, m) => sum + m),
      completionBars: TaskAnalytics.weekBarFractions(tasks, now),
      weeklyTasksDone: TaskAnalytics.weekCompletedCount(tasks, now),
      topCategory: TaskAnalytics.topCategory(tasks, now),
      mindfulDone: mindful.done,
      mindfulPlanned: mindful.planned,
      peak: TaskAnalytics.peakWindow(tasks, now),
      journalCount: journalCount,
      today: DateTime(now.year, now.month, now.day),
    );
  }

  factory InsightsData.from(BuildContext context) => InsightsData.fromTasks(
        TaskScope.of(context).all,
        journalCount: JournalScope.of(context).thisWeekCount,
        now: DateTime.now(),
      );

  /// Today's completion, 0-100.
  final int productivityScore;
  final int todayDone;
  final int todayPlanned;
  final int streakDays;

  /// Focus time per weekday (Mon-Sun) as a fraction of the busiest day.
  final List<double> focusBars;
  final int weekFocusMinutes;

  /// Completion fraction per weekday (Mon-Sun).
  final List<double> completionBars;
  final int weeklyTasksDone;
  final CategoryStat? topCategory;
  final int mindfulDone;
  final int mindfulPlanned;
  final PeakWindow? peak;
  final int journalCount;
  final DateTime today;

  static const focusDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const completionDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// 0 (Monday) - 6 (Sunday): the bar to highlight.
  int get todayIndex => today.weekday - 1;

  String get weekFocusLabel => TaskAnalytics.formatMinutes(weekFocusMinutes);
  bool get hasFocusTime => weekFocusMinutes > 0;

  /// One honest line under "Hello": the streak if there is one, otherwise where
  /// today stands.
  String get greetingSubtitle {
    if (streakDays >= 2) {
      return "You're on a $streakDays-day streak. Keep it going.";
    }
    if (todayPlanned == 0) {
      return 'Nothing planned for today yet. Add a task to get started.';
    }
    if (todayDone == todayPlanned) {
      return 'All $todayPlanned of today\'s tasks are done. Well done.';
    }
    if (todayDone == 0) {
      final noun = todayPlanned == 1 ? 'task' : 'tasks';
      return '$todayPlanned $noun planned for today. Start with one.';
    }
    return '$todayDone of $todayPlanned tasks done today. Keep going.';
  }

  /// "3 of 5 tasks done today", or null when nothing is planned.
  String? get todaySummary {
    if (todayPlanned == 0) return null;
    return '$todayDone of $todayPlanned ${todayPlanned == 1 ? 'task' : 'tasks'} done today';
  }

  String get productivityDelta {
    if (productivityScore >= AppConfig.excellentScoreThreshold) {
      return AppConfig.productivityDeltaMessages[AppConfig.excellentScoreThreshold] ?? AppConfig.productivityDeltaDefault;
    }
    if (productivityScore >= AppConfig.goodScoreThreshold) {
      return AppConfig.productivityDeltaMessages[AppConfig.goodScoreThreshold] ?? AppConfig.productivityDeltaDefault;
    }
    return AppConfig.productivityDeltaDefault;
  }

  String get aiQuote {
    if (productivityScore >= AppConfig.excellentScoreThreshold) {
      return AppConfig.aiQuotesByScore[AppConfig.excellentScoreThreshold] ?? AppConfig.aiQuoteDefault;
    }
    return AppConfig.aiQuoteDefault;
  }

  /// The suggestion for the Zen card, or null until there is a real pattern.
  String? get suggestion {
    final p = peak;
    if (p == null) return null;
    final when = switch (p.part) {
      DayPart.morning => 'in the morning',
      DayPart.afternoon => 'in the afternoon',
      DayPart.evening => 'in the evening',
    };
    return 'You complete most of your tasks $when: ${p.completed} of your last '
        '${p.total}. Schedule your most demanding work then.';
  }
}
