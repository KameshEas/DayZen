import 'package:dayzen/core/services/task_service.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A server task as the API returns it. [v2] adds the migration-012 keys; an
/// older server sends none of them.
Map<String, dynamic> serverJson({bool completed = false, Map<String, dynamic>? v2}) => {
      'id': 't1',
      'title': 'Write',
      'description': null,
      'category': 'study',
      'priority': 'high',
      'is_completed': completed,
      'scheduled_date': '2027-01-12',
      'start_hour': 9,
      'start_minute': 0,
      'end_hour': 10,
      'end_minute': 30,
      'created_at': '2027-01-10T08:00:00',
      'updated_at': '2027-01-12T08:00:00',
      ...?v2,
    };

DzTask local({
  TaskStatus status = TaskStatus.active,
  DateTime? completedAt,
  int rolloverCount = 0,
  int? effort,
  DateTime? originalDate,
}) =>
    DzTask(
      id: 't1',
      title: 'Write',
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 30),
      status: status,
      completedAt: completedAt,
      rolloverCount: rolloverCount,
      effort: effort,
      originalDate: originalDate,
      date: DateTime(2027, 1, 12),
    );

DzTask read(Map<String, dynamic> json, {DzTask? mine}) =>
    TaskApiResponse.fromJson(json).toDzTask(local: mine);

void main() {
  group('reading a response from an older server (no v2 keys)', () {
    test('keeps the local released status', () {
      final t = read(serverJson(), mine: local(status: TaskStatus.released));
      expect(t.status, TaskStatus.released);
    });

    test('keeps local rolloverCount, effort and originalDate', () {
      final mine = local(
          rolloverCount: 2, effort: 3, originalDate: DateTime(2027, 1, 10));
      final t = read(serverJson(), mine: mine);
      expect((t.rolloverCount, t.effort), (2, 3));
      expect(t.originalDate, DateTime(2027, 1, 10));
    });

    test('still follows is_completed from another old device', () {
      final mine = local(completedAt: null);
      expect(read(serverJson(completed: true), mine: mine).status, TaskStatus.done);
      final done = local(status: TaskStatus.done, completedAt: DateTime(2027, 1, 12, 9));
      final reopened = read(serverJson(completed: false), mine: done);
      expect(reopened.status, TaskStatus.active);
      expect(reopened.completedAt, isNull);
    });

    test('a task new to this phone gets defaults', () {
      final t = read(serverJson());
      expect((t.status, t.rolloverCount, t.effort), (TaskStatus.active, 0, null));
    });
  });

  group('reading a v2 response', () {
    test('server values win', () {
      final t = read(
        serverJson(completed: true, v2: {
          'status': 'done',
          'completed_at': '2027-01-12T07:15:00+00:00',
          'rollover_count': 4,
          'effort': 2,
          'original_date': '2027-01-08',
        }),
        mine: local(rolloverCount: 1, effort: 3),
      );
      expect(t.status, TaskStatus.done);
      expect(t.completedAt, DateTime.utc(2027, 1, 12, 7, 15).toLocal());
      expect((t.rolloverCount, t.effort), (4, 2));
      expect(t.originalDate, DateTime(2027, 1, 8));
    });

    test('an explicit null clears effort and originalDate', () {
      final t = read(
        serverJson(v2: {'status': 'active', 'effort': null, 'original_date': null}),
        mine: local(effort: 3, originalDate: DateTime(2027, 1, 10)),
      );
      expect(t.effort, isNull);
      expect(t.originalDate, isNull);
    });

    test('server released wins over local active', () {
      final t = read(serverJson(v2: {'status': 'released'}), mine: local());
      expect(t.status, TaskStatus.released);
    });
  });

  test('the push carries every v2 field', () {
    final t = local(
      status: TaskStatus.done,
      completedAt: DateTime.utc(2027, 1, 12, 7, 15),
      rolloverCount: 2,
      effort: 1,
      originalDate: DateTime(2027, 1, 10),
    );
    final json = TaskService.taskSyncJson(t);
    expect(json['status'], 'done');
    expect(json['is_completed'], isTrue);
    expect(json['completed_at'], '2027-01-12T07:15:00.000Z');
    expect(json['rollover_count'], 2);
    expect(json['effort'], 1);
    expect(json['original_date'], '2027-01-10');
  });

  test('the push sends nulls explicitly so the server can clear them', () {
    final json = TaskService.taskSyncJson(local());
    expect(json.containsKey('effort'), isTrue);
    expect(json['effort'], isNull);
    expect(json.containsKey('completed_at'), isTrue);
    expect(json['original_date'], isNull);
  });
}
