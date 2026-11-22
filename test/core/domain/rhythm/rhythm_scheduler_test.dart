import 'dart:math' as math;

import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:dayzen/core/domain/rhythm/rhythm_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final morning = EnergyProfile.prior(RhythmPrior.morning);
  final evening = EnergyProfile.prior(RhythmPrior.evening);

  group('placement rules', () {
    test('high-priority work goes into the energy peak', () {
      final r = RhythmScheduler.schedule(
        items: const [
          ScheduleItem(id: 'deep', durationMinutes: 60, priority: SlotPriority.high),
        ],
        profile: morning,
      );
      final p = r.placementOf('deep')!;
      // Morning prior peaks 08:00–10:00.
      expect(p.startMinute, inInclusiveRange(8 * 60, 9 * 60));
    });

    test('the same task lands in the evening for an evening person', () {
      final r = RhythmScheduler.schedule(
        items: const [
          ScheduleItem(id: 'deep', durationMinutes: 60, priority: SlotPriority.high),
        ],
        profile: evening,
      );
      expect(r.placementOf('deep')!.startMinute, greaterThanOrEqualTo(18 * 60));
    });

    test('routine work goes into a trough, not the peak', () {
      final r = RhythmScheduler.schedule(
        items: const [
          ScheduleItem(id: 'deep', durationMinutes: 60, priority: SlotPriority.high),
          ScheduleItem(id: 'laundry', durationMinutes: 30, priority: SlotPriority.routine),
        ],
        profile: morning,
      );
      final laundry = r.placementOf('laundry')!;
      expect(morning.meanOver(laundry.startMinute, laundry.endMinute),
          lessThan(morning.at(morning.peakHour)));
    });

    test('a fixed task is never moved, even into the peak', () {
      final r = RhythmScheduler.schedule(
        items: const [
          ScheduleItem(
            id: 'standup',
            durationMinutes: 30,
            priority: SlotPriority.routine,
            fixedStartMinute: 9 * 60,
          ),
          ScheduleItem(id: 'deep', durationMinutes: 60, priority: SlotPriority.high),
        ],
        profile: morning,
      );
      final standup = r.placementOf('standup')!;
      expect(standup.startMinute, 9 * 60);
      expect(standup.fixed, isTrue);
      expect(r.placementOf('deep')!.overlaps(9 * 60, 9 * 60 + 30), isFalse);
    });

    test('nothing is placed before notBeforeMinute', () {
      final r = RhythmScheduler.schedule(
        items: const [
          ScheduleItem(id: 'a', durationMinutes: 30, priority: SlotPriority.high),
        ],
        profile: morning,
        notBeforeMinute: 14 * 60 + 7,
      );
      expect(r.placementOf('a')!.startMinute, greaterThanOrEqualTo(14 * 60 + 15));
    });

    test('an item longer than any free window is reported, not dropped', () {
      final r = RhythmScheduler.schedule(
        items: const [
          ScheduleItem(id: 'huge', durationMinutes: 600, priority: SlotPriority.high),
        ],
        profile: morning,
        notBeforeMinute: 20 * 60,
      );
      expect(r.unplaceable, ['huge']);
      expect(r.placementOf('huge'), isNull);
    });

    test('heavy work is split by a break after 90 minutes', () {
      final r = RhythmScheduler.schedule(
        items: const [
          ScheduleItem(id: 'h1', durationMinutes: 60, priority: SlotPriority.high, effort: 3),
          ScheduleItem(id: 'h2', durationMinutes: 30, priority: SlotPriority.high, effort: 3),
          ScheduleItem(id: 'h3', durationMinutes: 45, priority: SlotPriority.high, effort: 3),
        ],
        profile: morning,
      );
      expect(r.unplaceable, isEmpty);
      expect(_maxFlexibleHeavyRun(r), lessThanOrEqualTo(90));
      expect(r.breaks, isNotEmpty);
    });
  });

  group('properties over random days', () {
    for (var seed = 1; seed <= 200; seed++) {
      test('seed $seed', () {
        final rng = math.Random(seed);
        final items = _randomItems(rng);
        final profile = EnergyProfile.prior(
            RhythmPrior.values[rng.nextInt(RhythmPrior.values.length)]);
        final r = RhythmScheduler.schedule(items: items, profile: profile);

        // Every item is placed or reported, exactly once.
        final placedIds = r.placed.map((p) => p.id).toList();
        expect({...placedIds, ...r.unplaceable}, items.map((i) => i.id).toSet());
        expect(placedIds.toSet().length, placedIds.length);
        expect(placedIds.toSet().intersection(r.unplaceable.toSet()), isEmpty);

        for (final item in items) {
          final p = r.placementOf(item.id);
          if (item.isFixed) {
            // Fixed items never move and are never unplaceable.
            expect(p, isNotNull);
            expect(p!.startMinute, item.fixedStartMinute);
            expect(p.endMinute, item.fixedStartMinute! + item.durationMinutes);
          } else if (p != null) {
            expect(p.endMinute - p.startMinute, item.durationMinutes);
            expect(p.startMinute % RhythmScheduler.step, 0);
            expect(p.startMinute, greaterThanOrEqualTo(7 * 60));
            expect(p.endMinute, lessThanOrEqualTo(22 * 60));
          }
        }

        // A flexible item never overlaps anything.
        for (final a in r.placed.where((p) => !p.fixed)) {
          for (final b in r.placed) {
            if (identical(a, b)) continue;
            expect(a.overlaps(b.startMinute, b.endMinute), isFalse,
                reason: '${a.id} overlaps ${b.id}');
          }
        }

        // A run of heavy work that includes a flexible block stays within
        // the limit.
        expect(_maxFlexibleHeavyRun(r),
            lessThanOrEqualTo(RhythmScheduler.maxHeavyRunMinutes));

        // Breaks never sit on top of a task.
        for (final br in r.breaks) {
          for (final p in r.placed) {
            expect(p.overlaps(br.startMinute, br.endMinute), isFalse);
          }
        }
      });
    }
  });

  test('scheduleInBackground gives the same result as schedule', () async {
    final items = _randomItems(math.Random(42));
    final sync = RhythmScheduler.schedule(items: items, profile: morning);
    final bg =
        await RhythmScheduler.scheduleInBackground(items: items, profile: morning);
    expect(bg.placed.map((p) => '${p.id}@${p.startMinute}'),
        sync.placed.map((p) => '${p.id}@${p.startMinute}'));
    expect(bg.unplaceable, sync.unplaceable);
  });
}

List<ScheduleItem> _randomItems(math.Random rng) {
  final out = <ScheduleItem>[];
  final n = 1 + rng.nextInt(12);
  for (var i = 0; i < n; i++) {
    final fixed = rng.nextDouble() < 0.3;
    out.add(ScheduleItem(
      id: 't$i',
      durationMinutes: 15 * (1 + rng.nextInt(8)),
      priority: SlotPriority.values[rng.nextInt(4)],
      effort: 1 + rng.nextInt(3),
      fixedStartMinute: fixed ? 15 * (24 + rng.nextInt(60)) : null,
    ));
  }
  return out;
}

/// Longest contiguous run of heavy blocks that includes a flexible one
/// (fixed blocks alone may already break the rule; the scheduler can't fix
/// those).
int _maxFlexibleHeavyRun(ScheduleResult r) {
  final heavy = r.placed.where((p) => p.heavy).toList()
    ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
  var best = 0;
  var start = -1, end = -1;
  var hasFlexible = false;
  for (final p in heavy) {
    if (start >= 0 && p.startMinute < end + RhythmScheduler.breakMinutes) {
      end = math.max(end, p.endMinute);
      hasFlexible |= !p.fixed;
    } else {
      if (hasFlexible) best = math.max(best, end - start);
      start = p.startMinute;
      end = p.endMinute;
      hasFlexible = !p.fixed;
    }
  }
  if (hasFlexible) best = math.max(best, end - start);
  return best;
}
