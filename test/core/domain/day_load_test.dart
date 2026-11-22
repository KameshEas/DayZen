import 'package:dayzen/core/domain/day_load.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2027, 3, 10, 9);

  /// [doneLoads] completed efforts for consecutive days before today.
  List<LoadTask> history(List<int> doneLoads) => [
        for (var i = 0; i < doneLoads.length; i++)
          LoadTask(
            id: 'h$i',
            date: today.subtract(Duration(days: i + 1)),
            status: LoadStatus.done,
            effort: doneLoads[i],
          ),
      ];

  LoadTask todayTask(String id, {int? effort, int rank = 1, int start = 0}) =>
      LoadTask(
        id: id,
        date: today,
        status: LoadStatus.active,
        effort: effort,
        priorityRank: rank,
        startMinute: start,
      );

  test('no history → Balanced with no suggestion', () {
    final r = DayLoad.compute(
      today: today,
      tasks: [for (var i = 0; i < 10; i++) todayTask('t$i', effort: 3)],
    );
    expect(r.level, DayLoadLevel.balanced);
    expect(r.hasHistory, isFalse);
    expect(r.suggestMoveId, isNull);
    expect(r.load, 30);
  });

  test('fewer than 3 history days still counts as no history', () {
    final r = DayLoad.compute(
      today: today,
      tasks: [...history([4, 4]), todayTask('a', effort: 3)],
    );
    expect(r.hasHistory, isFalse);
  });

  test('a history of nothing completed counts as no history', () {
    final r = DayLoad.compute(
      today: today,
      tasks: [
        for (var i = 1; i <= 5; i++)
          LoadTask(
            id: 'x$i',
            date: today.subtract(Duration(days: i)),
            status: LoadStatus.active,
          ),
        todayTask('a'),
      ],
    );
    expect(r.hasHistory, isFalse);
    expect(r.level, DayLoadLevel.balanced);
  });

  test('missing effort counts as 2', () {
    final r = DayLoad.compute(today: today, tasks: [todayTask('a'), todayTask('b')]);
    expect(r.load, 4);
  });

  test('only active tasks count toward today', () {
    final r = DayLoad.compute(today: today, tasks: [
      todayTask('a', effort: 3),
      LoadTask(id: 'd', date: today, status: LoadStatus.done, effort: 3),
      LoadTask(id: 'r', date: today, status: LoadStatus.released, effort: 3),
    ]);
    expect(r.load, 3);
  });

  group('levels against a median of 6', () {
    final past = history([6, 6, 6, 5, 7]);

    test('Light below 75 %', () {
      final r = DayLoad.compute(today: today, tasks: [...past, todayTask('a', effort: 3)]);
      expect(r.baseline, 6);
      expect(r.level, DayLoadLevel.light);
    });

    test('Heavy above 125 %, Balanced at exactly 125 %', () {
      final r = DayLoad.compute(
        today: today,
        tasks: [...past, todayTask('a', effort: 3), todayTask('b', effort: 3), todayTask('c', effort: 1), todayTask('d', effort: 1), todayTask('e', effort: 1)],
      );
      expect(r.load, 9);
      expect(r.level, DayLoadLevel.heavy, reason: '9/6 = 1.5');
      final edge = DayLoad.compute(
        today: today,
        tasks: [...history([8, 8, 8]), for (var i = 0; i < 5; i++) todayTask('t$i', effort: 2)],
      );
      expect(edge.load, 10);
      expect(edge.level, DayLoadLevel.balanced, reason: '10/8 = 1.25 is not above');
    });

    test('Heavy suggests the lowest-priority, latest task', () {
      final r = DayLoad.compute(today: today, tasks: [
        ...past,
        todayTask('important', effort: 3, rank: 4, start: 20 * 60),
        todayTask('early-low', effort: 3, rank: 1, start: 8 * 60),
        todayTask('late-low', effort: 3, rank: 1, start: 18 * 60),
      ]);
      expect(r.level, DayLoadLevel.heavy);
      expect(r.suggestMoveId, 'late-low');
    });
  });

  test('history older than 14 days is ignored', () {
    final r = DayLoad.compute(today: today, tasks: [
      for (var i = 15; i < 25; i++)
        LoadTask(
          id: 'old$i',
          date: today.subtract(Duration(days: i)),
          status: LoadStatus.done,
          effort: 3,
        ),
      todayTask('a'),
    ]);
    expect(r.hasHistory, isFalse);
  });

  test('a heavy day with one task suggests nothing (moving it empties the day)', () {
    final r = DayLoad.compute(
      today: today,
      tasks: [...history([1, 1, 1]), todayTask('only', effort: 3)],
    );
    expect(r.level, DayLoadLevel.heavy);
    expect(r.suggestMoveId, isNull);
  });
}
