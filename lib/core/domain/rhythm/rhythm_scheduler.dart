import 'dart:isolate';

import 'energy_profile.dart';

/// Scheduling weight of a task. Mirrors `TaskPriority` without importing the
/// Flutter model, so this file stays pure Dart.
enum SlotPriority { high, zen, routine, low }

/// One task to place. A task with [fixedStartMinute] is never moved.
class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.durationMinutes,
    required this.priority,
    this.effort = 2,
    this.fixedStartMinute,
  }) : assert(durationMinutes > 0);

  final String id;
  final int durationMinutes;
  final SlotPriority priority;

  /// 1 (light) to 3 (heavy).
  final int effort;

  /// Minutes after midnight; null = flexible.
  final int? fixedStartMinute;

  bool get isFixed => fixedStartMinute != null;
  bool get isHeavy => effort >= 3;
}

/// Where an item ended up. [startMinute]/[endMinute] are minutes after
/// midnight; [endMinute] may pass 1440 for a fixed overnight task.
class PlacedItem {
  const PlacedItem({
    required this.id,
    required this.startMinute,
    required this.endMinute,
    required this.fixed,
    required this.heavy,
  });

  final String id;
  final int startMinute;
  final int endMinute;
  final bool fixed;
  final bool heavy;

  bool overlaps(int start, int end) => start < endMinute && startMinute < end;
}

typedef BreakSlot = ({int startMinute, int endMinute});

class ScheduleResult {
  const ScheduleResult({
    required this.placed,
    required this.unplaceable,
    required this.breaks,
  });

  /// Every placed item, fixed ones included, sorted by start.
  final List<PlacedItem> placed;

  /// Ids of flexible items that did not fit.
  final List<String> unplaceable;

  /// Suggested rests after long runs of heavy work.
  final List<BreakSlot> breaks;

  PlacedItem? placementOf(String id) {
    for (final p in placed) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Rhythm-aware day scheduler (plan M-2.3). Output is a set of suggestions;
/// nothing here writes tasks.
///
/// Rules:
/// - Fixed-time items stay exactly where they are.
/// - High and Zen items go into the free window with the highest mean energy.
/// - Routine and Low items go into the free window with the lowest mean
///   energy (the troughs), keeping the peaks for focused work.
/// - Heavy (effort 3) work never runs longer than [maxHeavyRunMinutes]
///   without a [breakMinutes] gap; a break is suggested after each run that
///   reaches the limit.
/// - Ties go to the earliest start. Items that fit nowhere are reported in
///   [ScheduleResult.unplaceable], never dropped silently.
class RhythmScheduler {
  RhythmScheduler._();

  static const int step = 15;
  static const int breakMinutes = 15;
  static const int maxHeavyRunMinutes = 90;

  static ScheduleResult schedule({
    required List<ScheduleItem> items,
    required EnergyProfile profile,
    int dayStartMinute = 7 * 60,
    int dayEndMinute = 22 * 60,
    int? notBeforeMinute,
  }) {
    final placed = <PlacedItem>[
      for (final i in items.where((i) => i.isFixed))
        PlacedItem(
          id: i.id,
          startMinute: i.fixedStartMinute!,
          endMinute: i.fixedStartMinute! + i.durationMinutes,
          fixed: true,
          heavy: i.isHeavy,
        ),
    ];

    final earliest = _roundUp(
      notBeforeMinute == null
          ? dayStartMinute
          : (notBeforeMinute > dayStartMinute ? notBeforeMinute : dayStartMinute),
    );

    final flexible = items.where((i) => !i.isFixed).toList()
      ..sort(_placementOrder);
    final unplaceable = <String>[];

    for (final item in flexible) {
      final seekHigh = item.priority == SlotPriority.high ||
          item.priority == SlotPriority.zen;
      int? bestStart;
      double? bestScore;
      for (var start = earliest;
          start + item.durationMinutes <= dayEndMinute;
          start += step) {
        final end = start + item.durationMinutes;
        if (placed.any((p) => p.overlaps(start, end))) continue;
        if (item.isHeavy && _heavyRunWith(placed, start, end) > maxHeavyRunMinutes) {
          continue;
        }
        final energy = profile.meanOver(start, end);
        final score = seekHigh ? energy : -energy;
        if (bestScore == null || score > bestScore + 1e-9) {
          bestScore = score;
          bestStart = start;
        }
      }
      if (bestStart == null) {
        unplaceable.add(item.id);
      } else {
        placed.add(PlacedItem(
          id: item.id,
          startMinute: bestStart,
          endMinute: bestStart + item.durationMinutes,
          fixed: false,
          heavy: item.isHeavy,
        ));
      }
    }

    placed.sort((a, b) => a.startMinute.compareTo(b.startMinute));
    return ScheduleResult(
      placed: List.unmodifiable(placed),
      unplaceable: List.unmodifiable(unplaceable),
      breaks: List.unmodifiable(_breaks(placed, dayEndMinute)),
    );
  }

  /// Runs [schedule] on a background isolate (plan: `Isolate.run`).
  static Future<ScheduleResult> scheduleInBackground({
    required List<ScheduleItem> items,
    required EnergyProfile profile,
    int dayStartMinute = 7 * 60,
    int dayEndMinute = 22 * 60,
    int? notBeforeMinute,
  }) =>
      Isolate.run(() => schedule(
            items: items,
            profile: profile,
            dayStartMinute: dayStartMinute,
            dayEndMinute: dayEndMinute,
            notBeforeMinute: notBeforeMinute,
          ));

  /// High, then Zen, then Routine, then Low; within a priority, heavier and
  /// then longer items first (they are the hardest to fit).
  static int _placementOrder(ScheduleItem a, ScheduleItem b) {
    final p = a.priority.index.compareTo(b.priority.index);
    if (p != 0) return p;
    final e = b.effort.compareTo(a.effort);
    if (e != 0) return e;
    final d = b.durationMinutes.compareTo(a.durationMinutes);
    if (d != 0) return d;
    return a.id.compareTo(b.id);
  }

  static int _roundUp(int minute) => ((minute + step - 1) ~/ step) * step;

  /// Length of the contiguous heavy run that a heavy block at
  /// [start, end) would join. Blocks less than [breakMinutes] apart count
  /// as contiguous.
  static int _heavyRunWith(List<PlacedItem> placed, int start, int end) {
    var runStart = start;
    var runEnd = end;
    var changed = true;
    final heavy = placed.where((p) => p.heavy).toList();
    while (changed) {
      changed = false;
      for (final p in heavy) {
        final touches = p.startMinute < runEnd + breakMinutes &&
            runStart - breakMinutes < p.endMinute;
        if (!touches) continue;
        if (p.startMinute < runStart) {
          runStart = p.startMinute;
          changed = true;
        }
        if (p.endMinute > runEnd) {
          runEnd = p.endMinute;
          changed = true;
        }
      }
    }
    return runEnd - runStart;
  }

  /// A break right after every heavy run that reached the limit, where the
  /// slot is free.
  static List<BreakSlot> _breaks(List<PlacedItem> placed, int dayEndMinute) {
    final heavy = placed.where((p) => p.heavy).toList()
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    final runs = <({int start, int end})>[];
    for (final p in heavy) {
      if (runs.isNotEmpty && p.startMinute < runs.last.end + breakMinutes) {
        final last = runs.removeLast();
        runs.add((
          start: last.start,
          end: p.endMinute > last.end ? p.endMinute : last.end,
        ));
      } else {
        runs.add((start: p.startMinute, end: p.endMinute));
      }
    }
    final out = <BreakSlot>[];
    for (final r in runs) {
      if (r.end - r.start < maxHeavyRunMinutes) continue;
      final s = r.end;
      final e = r.end + breakMinutes;
      if (e > dayEndMinute) continue;
      if (placed.any((p) => p.overlaps(s, e))) continue;
      out.add((startMinute: s, endMinute: e));
    }
    return out;
  }
}
