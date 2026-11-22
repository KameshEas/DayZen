/// Day Load (plan M-2.6): how heavy today looks next to what you usually get
/// done. Pure Dart.
library;

enum DayLoadLevel { light, balanced, heavy }

extension DayLoadLevelX on DayLoadLevel {
  String get label => switch (this) {
        DayLoadLevel.light => 'Light',
        DayLoadLevel.balanced => 'Balanced',
        DayLoadLevel.heavy => 'Heavy',
      };
}

enum LoadStatus { active, done, released }

/// The few task facts Day Load needs.
class LoadTask {
  const LoadTask({
    required this.id,
    required this.date,
    required this.status,
    this.effort,
    this.priorityRank = 1,
    this.startMinute = 0,
  });

  final String id;

  /// The task's day (time part ignored).
  final DateTime date;
  final LoadStatus status;

  /// 1 to 3; null counts as [DayLoad.defaultEffort].
  final int? effort;

  /// Higher = more important. Used only to pick which task to suggest moving.
  final int priorityRank;
  final int startMinute;
}

class DayLoadResult {
  const DayLoadResult({
    required this.level,
    required this.load,
    this.baseline,
    this.suggestMoveId,
  });

  final DayLoadLevel level;

  /// Σ effort of today's active tasks.
  final int load;

  /// 14-day median of completed load; null without enough history.
  final double? baseline;

  /// When heavy: the task to suggest moving to tomorrow.
  final String? suggestMoveId;

  bool get hasHistory => baseline != null;
}

class DayLoad {
  DayLoad._();

  static const defaultEffort = 2;
  static const historyDays = 14;

  /// Days with at least one planned task needed before comparing.
  static const minHistoryDays = 3;

  static const lightBelow = 0.75;
  static const heavyAbove = 1.25;

  static DayLoadResult compute({
    required DateTime today,
    required Iterable<LoadTask> tasks,
  }) {
    final day = _day(today);
    final todays = tasks.where((t) => _day(t.date) == day).toList();
    final active = todays.where((t) => t.status == LoadStatus.active).toList();
    final load = active.fold<int>(0, (s, t) => s + (t.effort ?? defaultEffort));

    final baseline = _baseline(day, tasks);
    if (baseline == null) {
      return DayLoadResult(level: DayLoadLevel.balanced, load: load);
    }

    final ratio = load / baseline;
    final level = ratio > heavyAbove
        ? DayLoadLevel.heavy
        : ratio < lightBelow
            ? DayLoadLevel.light
            : DayLoadLevel.balanced;

    String? suggest;
    if (level == DayLoadLevel.heavy && active.length > 1) {
      final candidates = [...active]..sort((a, b) {
          final p = a.priorityRank.compareTo(b.priorityRank);
          if (p != 0) return p;
          return b.startMinute.compareTo(a.startMinute);
        });
      suggest = candidates.first.id;
    }

    return DayLoadResult(
      level: level,
      load: load,
      baseline: baseline,
      suggestMoveId: suggest,
    );
  }

  /// Median completed load over the [historyDays] before [day], counting only
  /// days that had something planned. Null when fewer than
  /// [minHistoryDays] such days exist, or nothing was ever completed.
  static double? _baseline(DateTime day, Iterable<LoadTask> tasks) {
    final start = day.subtract(const Duration(days: historyDays));
    final perDay = <DateTime, int>{};
    for (final t in tasks) {
      final d = _day(t.date);
      if (!d.isBefore(day) || d.isBefore(start)) continue;
      perDay.putIfAbsent(d, () => 0);
      if (t.status == LoadStatus.done) {
        perDay[d] = perDay[d]! + (t.effort ?? defaultEffort);
      }
    }
    if (perDay.length < minHistoryDays) return null;
    final values = perDay.values.toList()..sort();
    final mid = values.length ~/ 2;
    final median = values.length.isOdd
        ? values[mid].toDouble()
        : (values[mid - 1] + values[mid]) / 2;
    return median <= 0 ? null : median;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
