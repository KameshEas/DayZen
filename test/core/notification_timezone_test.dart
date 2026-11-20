import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:dayzen/core/notification_service.dart';
import 'package:dayzen/features/home/models/task_model.dart';

/// Regression for docs/MOBILE_PROJECT_PLAN.md P0-2: reminders were scheduled
/// in UTC because `tz.local` was never pointed at the device zone.
void main() {
  setUpAll(tzdata.initializeTimeZones);
  tearDown(() => tz.setLocalLocation(tz.UTC));

  final task = DzTask(
    id: 't',
    title: 'Standup',
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 9, minute: 30),
    priority: TaskPriority.routine,
    category: TaskCategory.work,
    date: DateTime(2026, 11, 20),
  );

  test('a 09:00 task in Asia/Kolkata fires at 03:30 UTC', () {
    tz.setLocalLocation(NotificationService.resolveLocation('Asia/Kolkata'));
    expect(NotificationService.taskStart(task).toUtc(),
        DateTime.utc(2026, 11, 20, 3, 30));
  });

  test('a 09:00 task in America/New_York (EST in Nov) fires at 14:00 UTC', () {
    tz.setLocalLocation(NotificationService.resolveLocation('America/New_York'));
    expect(NotificationService.taskStart(task).toUtc(),
        DateTime.utc(2026, 11, 20, 14));
  });

  test('unknown zone name falls back to a zone with the device offset', () {
    final loc = NotificationService.resolveLocation('Not/AZone',
        deviceOffset: const Duration(hours: 5, minutes: 30));
    expect(loc.currentTimeZone.offset, const Duration(hours: 5, minutes: 30));
  });

  test('missing zone name also uses the device offset, not UTC', () {
    final loc = NotificationService.resolveLocation(null,
        deviceOffset: const Duration(hours: -3));
    expect(loc.currentTimeZone.offset, const Duration(hours: -3));
  });
}
