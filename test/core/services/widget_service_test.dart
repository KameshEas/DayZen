import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:dayzen/core/services/widget_service.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2027, 6, 7, 10, 15);

  DzTask task(String id, DateTime day, int hour,
          {TaskStatus status = TaskStatus.active}) =>
      DzTask(
        id: id,
        title: 'Task $id',
        startTime: TimeOfDay(hour: hour, minute: 30),
        endTime: TimeOfDay(hour: hour + 1, minute: 0),
        status: status,
        date: day,
      );

  test('today and tomorrow, active only, sorted by start, in minutes', () {
    final today = DateTime(2027, 6, 7);
    final tomorrow = DateTime(2027, 6, 8);
    final payload = WidgetService.daysPayload([
      task('late', today, 15),
      task('early', today, 9),
      task('done', today, 11, status: TaskStatus.done),
      task('gone', today, 12, status: TaskStatus.released),
      task('next', tomorrow, 8),
      task('far', DateTime(2027, 6, 10), 8),
    ], now);

    expect(payload.keys, ['2027-06-07', '2027-06-08']);
    expect(payload['2027-06-07']!.map((t) => t['id']), ['early', 'late']);
    expect(payload['2027-06-07']!.first,
        {'id': 'early', 'title': 'Task early', 'start': 9 * 60 + 30, 'end': 10 * 60});
    expect(payload['2027-06-08']!.map((t) => t['id']), ['next']);
  });

  test('rhythm is 24 comma-separated values; the label matches the window', () {
    final p = EnergyProfile.prior(RhythmPrior.morning);
    expect(WidgetService.rhythmPayload(p).split(','), hasLength(24));
    expect(WidgetService.windowLabel(p), 'Sharpest ~8 am–10 am · forming');
  });

  test('widget tap URIs map to task ids; anything else is ignored', () {
    expect(WidgetService.taskIdFromUri(Uri.parse('dayzen://widget/task?id=task-1-abc')),
        'task-1-abc');
    expect(WidgetService.taskIdFromUri(Uri.parse('dayzen://widget/planner')), isNull);
    expect(WidgetService.taskIdFromUri(Uri.parse('https://evil.example/task?id=x')), isNull);
    expect(WidgetService.taskIdFromUri(null), isNull);
  });

  test('flush without a widget host does not throw', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await WidgetService.instance.flush(now: now);
  });
}
