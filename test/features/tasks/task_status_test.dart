import 'package:dayzen/features/home/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DzTask make({TaskStatus? status, bool isCompleted = false, DateTime? completedAt}) =>
    DzTask(
      id: 't',
      title: 't',
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      status: status,
      isCompleted: isCompleted,
      completedAt: completedAt,
      date: DateTime(2027, 1, 12),
    );

void main() {
  final now = DateTime(2027, 1, 12, 16, 20);

  test('isCompleted is derived from status', () {
    expect(make().status, TaskStatus.active);
    expect(make(isCompleted: true).status, TaskStatus.done);
    expect(make(status: TaskStatus.released).isCompleted, isFalse);
    expect(make(status: TaskStatus.done).isCompleted, isTrue);
  });

  test('completing stamps completedAt', () {
    final done = make().copyWith(isCompleted: true, now: now);
    expect(done.status, TaskStatus.done);
    expect(done.completedAt, now);
  });

  test('un-completing clears completedAt', () {
    final reopened =
        make(isCompleted: true, completedAt: now).copyWith(isCompleted: false);
    expect(reopened.status, TaskStatus.active);
    expect(reopened.completedAt, isNull);
  });

  test('an unrelated copy keeps the original completedAt', () {
    final done = make(isCompleted: true, completedAt: now);
    expect(done.copyWith(rolloverCount: 2).completedAt, now);
  });

  test('un-completing a released task leaves it released', () {
    expect(make(status: TaskStatus.released).copyWith(isCompleted: false).status,
        TaskStatus.released);
  });

  test('legacy JSON round trip keeps v2 fields', () {
    final t = DzTask(
      id: 'j',
      title: 'j',
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      status: TaskStatus.released,
      rolloverCount: 2,
      effort: 3,
      originalDate: DateTime(2027, 1, 10),
      date: DateTime(2027, 1, 12),
    );
    final back = DzTask.fromJson(t.toJson());
    expect(back.status, TaskStatus.released);
    expect((back.rolloverCount, back.effort), (2, 3));
    expect(back.originalDate, DateTime(2027, 1, 10));
  });

  test('pre-v2 JSON (no status) reads isCompleted', () {
    final back = DzTask.fromJson({'id': 'x', 'title': 'x', 'isCompleted': true});
    expect(back.status, TaskStatus.done);
    expect(back.rolloverCount, 0);
  });
}
