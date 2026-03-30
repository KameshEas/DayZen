import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../features/home/models/task_model.dart';

/// Handles scheduling and cancelling local notifications for planned tasks.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Initialise ────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final localTz = tz.local;
    // Use device-local timezone (falls back to UTC if unknown)
    tz.setLocalLocation(localTz);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
    );
    _initialized = true;
  }

  // ── Request permission (Android 13+) ──────────────────────────────────

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    // iOS permission is handled via DarwinInitializationSettings
    return true;
  }

  // ── Schedule a notification for a task ────────────────────────────────

  /// Schedules a notification at the task's [startTime] on its [date].
  /// Uses the task [id] hashCode as the notification ID for determinism.
  Future<void> scheduleForTask(DzTask task) async {
    if (!_initialized) return;

    final now = tz.TZDateTime.now(tz.local);
    final taskDateTime = tz.TZDateTime(
      tz.local,
      task.date.year,
      task.date.month,
      task.date.day,
      task.startTime.hour,
      task.startTime.minute,
    );

    // Don't schedule if the time has already passed
    if (taskDateTime.isBefore(now)) return;

    final notifId = task.id.hashCode.abs() % 0x7FFFFFFF; // keep within 32-bit int

    final priorityEmoji = switch (task.priority) {
      TaskPriority.high => '🔴',
      TaskPriority.zen => '🧘',
      TaskPriority.routine => '📋',
      TaskPriority.low => '🔵',
    };

    await _plugin.zonedSchedule(
      id: notifId,
      title: '$priorityEmoji ${task.title}',
      body: 'Scheduled for ${task.timeRange}',
      scheduledDate: taskDateTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'dayzen_tasks',
          'Task Reminders',
          channelDescription: 'Notifications for your planned activities',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  // ── Cancel a single task's notification ───────────────────────────────

  Future<void> cancelForTask(String taskId) async {
    if (!_initialized) return;
    final notifId = taskId.hashCode.abs() % 0x7FFFFFFF;
    await _plugin.cancel(id: notifId);
  }

  // ── Cancel all notifications ──────────────────────────────────────────

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  // ── Re-schedule all upcoming tasks ────────────────────────────────────

  /// Cancels everything, then schedules notifications for all future tasks.
  Future<void> rescheduleAll(List<DzTask> tasks) async {
    if (!_initialized) return;
    await _plugin.cancelAll();
    final now = DateTime.now();
    for (final task in tasks) {
      if (task.isCompleted) continue;
      final taskDt = DateTime(
        task.date.year,
        task.date.month,
        task.date.day,
        task.startTime.hour,
        task.startTime.minute,
      );
      if (taskDt.isAfter(now)) {
        await scheduleForTask(task);
      }
    }
  }
}
