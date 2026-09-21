import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/planner/timeline_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PlannerEvent _e(
  String title,
  int hour, {
  int minute = 0,
  int minutes = 60,
  bool done = false,
}) =>
    PlannerEvent(
      title: title,
      subtitle: '',
      hour: hour,
      minute: minute,
      durationMinutes: minutes,
      accentColor: Colors.blue,
      icon: Icons.circle_outlined,
      isCompleted: done,
    );

Map<String, TimelineSlot> _byTitle(List<TimelineSlot> slots) =>
    {for (final s in slots) s.event.title: s};

void main() {
  group('events that do not overlap', () {
    test('each gets a full-width card', () {
      final slots = layoutTimeline([_e('a', 9), _e('b', 11), _e('c', 14)]);
      expect(slots.map((s) => (s.column, s.columns)), everyElement((0, 1)));
      expect(slots.map((s) => s.event.title), ['a', 'b', 'c']);
    });

    test('back to back is not an overlap', () {
      final s = _byTitle(layoutTimeline([_e('a', 9), _e('b', 10)]));
      expect((s['a']!.column, s['a']!.columns), (0, 1));
      expect((s['b']!.column, s['b']!.columns), (0, 1));
    });

    test('an empty day lays out to nothing', () {
      expect(layoutTimeline([]), isEmpty);
    });

    test('are ordered by start time whatever order they came in', () {
      final slots = layoutTimeline([_e('late', 15), _e('early', 8), _e('mid', 11)]);
      expect(slots.map((s) => s.event.title), ['early', 'mid', 'late']);
    });
  });

  group('events that overlap', () {
    test('sit side by side', () {
      final s = _byTitle(layoutTimeline([_e('a', 9), _e('b', 9, minute: 30)]));
      expect((s['a']!.column, s['a']!.columns), (0, 2));
      expect((s['b']!.column, s['b']!.columns), (1, 2));
    });

    test('a third event reuses a column that has freed up', () {
      // a: 9-11, b: 9-9:45, c: 10-11. b is done by 10, so c goes where b was.
      final s = _byTitle(layoutTimeline([
        _e('a', 9, minutes: 120),
        _e('b', 9, minutes: 45),
        _e('c', 10, minutes: 60),
      ]));
      expect(s['a']!.column, 0);
      expect(s['b']!.column, 1);
      expect(s['c']!.column, 1);
      expect(s.values.map((x) => x.columns), everyElement(2));
    });

    test('three at once need three columns', () {
      final slots = layoutTimeline([_e('a', 9), _e('b', 9), _e('c', 9, minute: 15)]);
      expect(slots.map((s) => s.column).toSet(), {0, 1, 2});
      expect(slots.map((s) => s.columns), everyElement(3));
    });

    test('a cluster does not widen the events after it', () {
      final s = _byTitle(layoutTimeline([_e('a', 9), _e('b', 9, minute: 30), _e('after', 13)]));
      expect(s['a']!.columns, 2);
      expect(s['after']!.columns, 1);
      expect(s['after']!.column, 0);
    });

    test('a short event still needs room for its text, so close ones share', () {
      // 10-minute event at 9:00 is drawn 43 minutes tall; the next at 9:30 overlaps that.
      final s = _byTitle(layoutTimeline([_e('a', 9, minutes: 15), _e('b', 9, minute: 30, minutes: 15)]));
      expect(s['a']!.columns, 2);
    });

    test('a short event is drawn tall enough to block the next one from its column', () {
      // b is 30 minutes long but drawn 43 minutes tall (until 10:13), so c at 10:00 can't share its column.
      final s = _byTitle(layoutTimeline([
        _e('a', 9, minutes: 120),
        _e('b', 9, minute: 30, minutes: 30),
        _e('c', 10, minutes: 60),
      ]));
      expect(s['c']!.column, 2);
    });

    test('but far enough apart they do not', () {
      final s = _byTitle(layoutTimeline([_e('a', 9, minutes: 15), _e('b', 9, minute: 45, minutes: 15)]));
      expect(s['a']!.columns, 1);
    });

    test('no two events in a cluster share a column at the same time', () {
      final events = [
        for (var i = 0; i < 12; i++) _e('e$i', 9 + i % 4, minute: (i * 7) % 60, minutes: 30 + (i % 3) * 30),
      ];
      final slots = layoutTimeline(events);
      for (final a in slots) {
        for (final b in slots) {
          if (identical(a, b) || a.column != b.column) continue;
          final aStart = a.event.hour * 60 + a.event.minute;
          final bStart = b.event.hour * 60 + b.event.minute;
          final aEnd = aStart + (a.event.durationMinutes < 43 ? 43 : a.event.durationMinutes);
          final bEnd = bStart + (b.event.durationMinutes < 43 ? 43 : b.event.durationMinutes);
          expect(aStart < bEnd && bStart < aEnd, isFalse, reason: '${a.event.title} vs ${b.event.title}');
        }
      }
    });
  });

  group('identical events', () {
    test('collapse to one card that says how many', () {
      final slots = layoutTimeline([_e('ffft', 18), _e('ffft', 18), _e('ffft', 18)]);
      expect(slots, hasLength(1));
      expect(slots.single.count, 3);
      expect((slots.single.column, slots.single.columns), (0, 1));
    });

    test('a single event has a count of one', () {
      expect(layoutTimeline([_e('a', 9)]).single.count, 1);
    });

    test('are not merged when the time or length differ', () {
      expect(layoutTimeline([_e('x', 9), _e('x', 10)]), hasLength(2));
      expect(layoutTimeline([_e('x', 9), _e('x', 9, minutes: 30)]), hasLength(2));
      expect(layoutTimeline([_e('x', 9), _e('y', 9)]), hasLength(2));
    });

    test('are done only when every copy is done', () {
      final some = layoutTimeline([_e('t', 9, done: true), _e('t', 9)]).single;
      expect(some.event.isCompleted, isFalse);
      expect(some.count, 2);

      final all = layoutTimeline([_e('t', 9, done: true), _e('t', 9, done: true)]).single;
      expect(all.event.isCompleted, isTrue);
    });

    test('a duplicate pair does not push a neighbour into a narrower column', () {
      // Before merging, two copies of "a" would have made three columns.
      final s = _byTitle(layoutTimeline([_e('a', 9), _e('a', 9), _e('b', 9, minute: 30)]));
      expect(s['a']!.count, 2);
      expect(s['a']!.columns, 2);
      expect(s['b']!.columns, 2);
    });
  });
}
