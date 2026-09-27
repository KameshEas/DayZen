import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'app_prefs.dart';
import 'config/app_config.dart';
import 'data/task_repository.dart';
import '../features/home/models/task_model.dart';
import './logging/app_logger.dart';

const _followUpCategoryId = 'task_followup';
const _followUpDoneActionId = 'task_done';
const _followUpSkipActionId = 'task_skip';

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
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          _followUpCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              _followUpDoneActionId,
              AppConfig.taskFollowUpDoneAction,
            ),
            DarwinNotificationAction.plain(
              _followUpSkipActionId,
              AppConfig.taskFollowUpSkipAction,
            ),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        unawaited(_handleFollowUpResponse(response.actionId, response.payload));
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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

  /// Schedules a pre-reminder, an on-time reminder, and a completion
  /// follow-up (a few minutes after [DzTask.endTime]) asking whether the
  /// task actually happened, with "Done"/"Didn't happen" actions.
  /// Uses the task [id] hashCode as the notification ID base for determinism.
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
    final taskEndDateTime = tz.TZDateTime(
      tz.local,
      task.date.year,
      task.date.month,
      task.date.day,
      task.endTime.hour,
      task.endTime.minute,
    );
    // Build timezone-aware datetimes
    const preReminderMinutes = 5;
    final preDateTime = taskDateTime.subtract(const Duration(minutes: preReminderMinutes));
    final followUpDateTime =
        taskEndDateTime.add(const Duration(minutes: AppConfig.taskFollowUpDelayMinutes));

    // Don't schedule notifications in the past
    final shouldScheduleOnTime = taskDateTime.isAfter(now);
    final shouldSchedulePre = preDateTime.isAfter(now);
    final shouldScheduleFollowUp = followUpDateTime.isAfter(now);

    AppLogger.debug('NotificationService: scheduling task ${task.id}');
    AppLogger.debug(' - now: $now');
    AppLogger.debug(' - preDateTime: $preDateTime (will schedule: $shouldSchedulePre)');
    AppLogger.debug(' - taskDateTime: $taskDateTime (will schedule: $shouldScheduleOnTime)');
    AppLogger.debug(' - followUpDateTime: $followUpDateTime (will schedule: $shouldScheduleFollowUp)');

    // Deterministic, non-colliding IDs: one base per task, mapped to three ids.
    final base = task.id.hashCode.abs() % 0x2AAAAAAA; // keep base small
    final onTimeId = (base * 3) % 0x7FFFFFFF;
    final preId = (base * 3 + 1) % 0x7FFFFFFF;
    final followUpId = (base * 3 + 2) % 0x7FFFFFFF;

    final priorityEmoji = switch (task.priority) {
      TaskPriority.high => '🔴',
      TaskPriority.zen => '🧘',
      TaskPriority.routine => '📋',
      TaskPriority.low => '🔵',
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

    const followUpDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'dayzen_tasks',
        'Task Reminders',
        channelDescription: 'Notifications for your planned activities',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        actions: [
          AndroidNotificationAction(
            _followUpDoneActionId,
            AppConfig.taskFollowUpDoneAction,
          ),
          AndroidNotificationAction(
            _followUpSkipActionId,
            AppConfig.taskFollowUpSkipAction,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: _followUpCategoryId,
      ),
    );

    // Schedule pre-reminder 5 minutes before (if in future)
    if (shouldSchedulePre) {
      await _plugin.zonedSchedule(
        id: preId,
        title: '$priorityEmoji ${task.title} — Upcoming',
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

    // Schedule the completion follow-up, a few minutes after the task's
    // session ends, asking whether it actually happened.
    if (shouldScheduleFollowUp) {
      await _plugin.zonedSchedule(
        id: followUpId,
        title: '${task.title} — did you get to it?',
        body: 'Let us know so your day stays accurate.',
        scheduledDate: followUpDateTime,
        notificationDetails: followUpDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        payload: task.id,
      );
      AppLogger.debug(
          'NotificationService: scheduled completion follow-up id=$followUpId at $followUpDateTime');
    }
  }

  // ── Cancel a single task's notification ───────────────────────────────

  Future<void> cancelForTask(String taskId) async {
    if (!_initialized) return;
    final base = taskId.hashCode.abs() % 0x2AAAAAAA;
    final onTimeId = (base * 3) % 0x7FFFFFFF;
    final preId = (base * 3 + 1) % 0x7FFFFFFF;
    final followUpId = (base * 3 + 2) % 0x7FFFFFFF;
    await _plugin.cancel(id: onTimeId);
    AppLogger.debug('NotificationService: cancelled on-time id=$onTimeId for task $taskId');
    await _plugin.cancel(id: preId);
    AppLogger.debug('NotificationService: cancelled pre-reminder id=$preId for task $taskId');
    await _plugin.cancel(id: followUpId);
    AppLogger.debug('NotificationService: cancelled completion follow-up id=$followUpId for task $taskId');
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

// ─────────────────────────────────────────────────────────────────────────────
// Notification action handling
// ─────────────────────────────────────────────────────────────────────────────

/// Entry point for a tapped notification action when the app process is
/// not running (Android). Runs in its own isolate — no access to any live
/// controller, so it goes straight to [TaskRepository]/[AppPrefs] instead.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  unawaited(_handleFollowUpResponse(response.actionId, response.payload));
}

/// Shared by the foreground and background callbacks. [payload] is the
/// task id set in [NotificationService.scheduleForTask]'s follow-up
/// notification.
Future<void> _handleFollowUpResponse(String? actionId, String? payload) async {
  if (payload == null) return;
  final taskId = payload;

  if (actionId == _followUpSkipActionId) {
    // Just an acknowledgement — the task stays whatever it already was,
    // it's simply not asked about again.
    await AppPrefs.markOverdueTaskPrompted(taskId);
    return;
  }

  if (actionId == _followUpDoneActionId) {
    final tasks = await TaskRepository.loadAll();
    DzTask? task;
    for (final t in tasks) {
      if (t.id == taskId) {
        task = t;
        break;
      }
    }
    if (task == null || task.isCompleted) return;
    await TaskRepository.updateTask(task.copyWith(isCompleted: true));
    await NotificationService.instance.cancelForTask(taskId);
  }
}
