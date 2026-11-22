import '../../features/home/models/task_model.dart';
import '../../features/journal/models/journal_entry.dart';

/// Pure, stateless journal analytics.
///
/// Extracted from `JournalController` — see `TaskAnalytics` for the
/// rationale, which applies identically here.
class JournalAnalytics {
  JournalAnalytics._();

  /// Count of [entries] logged in the current calendar week (Mon–Sun).
  static int thisWeekCount(List<JournalEntry> entries) {
    final now = DateTime.now();
    final monday =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return entries.where((e) {
      final d = e.timestamp;
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(monday);
    }).length;
  }

  // ── "What lifts you" (plan M-4.1) ─────────────────────────────────────

  /// Moods counted as "lifted". Overwhelmed never appears in a lift insight:
  /// these insights are positive only.
  static const liftMoods = {
    JournalMood.happy,
    JournalMood.peaceful,
    JournalMood.inspired,
  };

  /// Minimum days (with both a mood and that category done) before saying
  /// anything about a category (OPEN-3: n >= 8).
  static const liftMinDays = 8;

  /// How much more often the mood must show up on that category's days than
  /// on mood days in general before it counts as a pattern.
  static const liftMargin = 0.10;

  /// Relates each day's mood to the categories finished that day.
  ///
  /// - A day's mood is its Close the Day reflection's mood if there is one,
  ///   otherwise its latest journal entry's.
  /// - A category needs [liftMinDays] such days before it can appear.
  /// - It appears only when one lifted mood is clearly more common on its
  ///   days than overall (by [liftMargin]) and seen at least three times.
  /// Positive framing only; returns the strongest first.
  static List<LiftInsight> liftsYou(
    List<JournalEntry> entries,
    List<DzTask> tasks, {
    int minDays = liftMinDays,
    String reflectionTitle = 'Evening reflection',
  }) {
    // Each day's mood: its latest reflection if any, else its latest entry.
    final byDay = <DateTime, List<JournalEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      byDay.putIfAbsent(day, () => []).add(e);
    }
    final moodByDay = <DateTime, JournalMood>{
      for (final MapEntry(key: day, value: list) in byDay.entries)
        day: (list.where((e) => e.title == reflectionTitle).toList().isNotEmpty
                ? list.where((e) => e.title == reflectionTitle).toList()
                : list)
            .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
            .mood,
    };
    if (moodByDay.isEmpty) return const [];

    final overall = <JournalMood, int>{};
    for (final m in moodByDay.values) {
      overall[m] = (overall[m] ?? 0) + 1;
    }

    final catDays = <TaskCategory, Set<DateTime>>{};
    for (final t in tasks) {
      if (t.status != TaskStatus.done) continue;
      if (!moodByDay.containsKey(t.date)) continue;
      catDays.putIfAbsent(t.category, () => {}).add(t.date);
    }

    final out = <LiftInsight>[];
    for (final entry in catDays.entries) {
      final days = entry.value;
      if (days.length < minDays) continue;
      final counts = <JournalMood, int>{};
      for (final d in days) {
        final m = moodByDay[d]!;
        counts[m] = (counts[m] ?? 0) + 1;
      }
      LiftInsight? best;
      for (final m in liftMoods) {
        final c = counts[m] ?? 0;
        if (c < 3) continue;
        final share = c / days.length;
        final base = (overall[m] ?? 0) / moodByDay.length;
        final lift = share - base;
        if (lift < liftMargin) continue;
        if (best == null || lift > best.lift) {
          best = LiftInsight(
            category: entry.key,
            mood: m,
            days: days.length,
            share: share,
            lift: lift,
          );
        }
      }
      if (best != null) out.add(best);
    }
    out.sort((a, b) => b.lift.compareTo(a.lift));
    return out;
  }
}

/// "Study days tend to feel Inspired."
class LiftInsight {
  const LiftInsight({
    required this.category,
    required this.mood,
    required this.days,
    required this.share,
    required this.lift,
  });

  final TaskCategory category;
  final JournalMood mood;

  /// Days behind it.
  final int days;

  /// How often [mood] shows up on this category's days (0..1).
  final double share;

  /// [share] minus how often it shows up on mood days overall.
  final double lift;

  String get sentence => '${category.label} days tend to feel ${moodLabel(mood)}.';

  static String moodLabel(JournalMood m) => switch (m) {
        JournalMood.happy => 'happy',
        JournalMood.peaceful => 'peaceful',
        JournalMood.inspired => 'inspired',
        JournalMood.overwhelmed => 'overwhelmed',
      };
}
