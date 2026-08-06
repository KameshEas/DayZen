import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../features/home/models/task_model.dart';
import './logging/app_logger.dart';

/// Handles scheduling and cancelling local notifications for planned tasks.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // â”€â”€ Initialise â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€ Request permission (Android 13+) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€ Schedule a notification for a task â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    // Build timezone-aware datetimes
    const preReminderMinutes = 5;
    final preDateTime = taskDateTime.subtract(const Duration(minutes: preReminderMinutes));

    // Don't schedule notifications in the past
    final shouldScheduleOnTime = taskDateTime.isAfter(now);
    final shouldSchedulePre = preDateTime.isAfter(now);

    AppLogger.debug('NotificationService: scheduling task ${task.id}');
    AppLogger.debug(' - now: $now');
    AppLogger.debug(' - preDateTime: $preDateTime (will schedule: $shouldSchedulePre)');
    AppLogger.debug(' - taskDateTime: $taskDateTime (will schedule: $shouldScheduleOnTime)');

    // Deterministic, non-colliding IDs: use a compact base and map to two ids
    final base = task.id.hashCode.abs() % 0x3FFFFFFF; // keep base small
    final onTimeId = (base * 2) % 0x7FFFFFFF;
    final preId = (base * 2 + 1) % 0x7FFFFFFF;

    final priorityEmoji = switch (task.priority) {
      TaskPriority.high => 'ðŸ”´',
      TaskPriority.zen => 'ðŸ§˜',
      TaskPriority.routine => 'ðŸ“‹',
      TaskPriority.low => 'ðŸ”µ',
    };

    const details = NotificationDetails(
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
    );

    // Schedule pre-reminder 5 minutes before (if in future)
    if (shouldSchedulePre) {
      await _plugin.zonedSchedule(
        id: preId,
        title: '$priorityEmoji ${task.title} â€” Upcoming',
        body: 'Starting in $preReminderMinutes minutes',
        scheduledDate: preDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
      AppLogger.debug('NotificationService: scheduled pre-reminder id=$preId at $preDateTime');
    }

    // Schedule on-time reminder
    if (shouldScheduleOnTime) {
      await _plugin.zonedSchedule(
        id: onTimeId,
        title: '$priorityEmoji ${task.title}',
        body: 'Scheduled for ${task.timeRange}',
        scheduledDate: taskDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
      AppLogger.debug('NotificationService: scheduled on-time id=$onTimeId at $taskDateTime');
    }
  }

  // â”€â”€ Cancel a single task's notification â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> cancelForTask(String taskId) async {
    if (!_initialized) return;
    final base = taskId.hashCode.abs() % 0x3FFFFFFF;
    final onTimeId = (base * 2) % 0x7FFFFFFF;
    final preId = (base * 2 + 1) % 0x7FFFFFFF;
    await _plugin.cancel(id: onTimeId);
    AppLogger.debug('NotificationService: cancelled on-time id=$onTimeId for task $taskId');
    await _plugin.cancel(id: preId);
    AppLogger.debug('NotificationService: cancelled pre-reminder id=$preId for task $taskId');
  }

  /// Send an immediate notification (useful for debugging).
  Future<void> showImmediateNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    const details = NotificationDetails(
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
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Return pending notification requests (debugging helper).
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    if (!_initialized) return <PendingNotificationRequest>[];
    return await _plugin.pendingNotificationRequests();
  }

  // â”€â”€ Cancel all notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  // â”€â”€ Re-schedule all upcoming tasks â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

