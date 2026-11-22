import 'dart:async';

import '../core/domain/quiet_window.dart';
import '../core/domain/rollover.dart';

import 'package:flutter/material.dart';
import '../core/data/task_repository.dart';
import '../core/domain/task_analytics.dart';
import '../core/notification_service.dart';
import '../core/services/sync_manager.dart';
import 'home/models/task_model.dart';

class TaskController extends ChangeNotifier {
  List<DzTask> _tasks = [];
  bool _notificationsEnabled = true;

  List<DzTask> get all => List.unmodifiable(_tasks);

  /// Call once to tell the controller whether to schedule notifications.
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    if (!value) {
      NotificationService.instance.cancelAll();
    } else {
      NotificationService.instance.rescheduleAll(_tasks);
    }
  }

  /// Applies the Settings reminder choices: on/off and quiet hours.
  /// Re-schedules every reminder so the new window applies to existing ones.
  void applyReminderSettings({required bool enabled, QuietWindow? quietWindow}) {
    NotificationService.instance.quietWindow = quietWindow;
    setNotificationsEnabled(enabled);
  }

  /// Re-creates all reminders (e.g. after the device time zone changed).
  /// No-op when reminders are off.
  Future<void> rescheduleNotifications() async {
    if (_notificationsEnabled) {
      await NotificationService.instance.rescheduleAll(_tasks);
    }
  }

  // ── Queries ───────────────────────────────────────────────────────

  List<DzTask> forDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _tasks
        .where((t) => t.isSameDay(day))
        .toList()
      ..sort((a, b) {
        final am = a.startTime.hour * 60 + a.startTime.minute;
        final bm = b.startTime.hour * 60 + b.startTime.minute;
        return am.compareTo(bm);
      });
  }

  List<DzTask> forWeek(DateTime weekStart) {
    final monday = DateTime(
        weekStart.year, weekStart.month, weekStart.day);
    return _tasks.where((t) {
      final diff = t.date.difference(monday).inDays;
      return diff >= 0 && diff < 7;
    }).toList();
  }

  // ── Derived stats ─────────────────────────────────────────────────
  // Thin delegates to TaskAnalytics (lib/core/domain/task_analytics.dart)
  // — no business logic lives here as of Phase 3.1. Same names/signatures
  // as before the extraction, so no UI call site changes.

  /// Completion fraction for [date] (0.0–1.0).
  double completionFraction(DateTime date) =>
      TaskAnalytics.completionFraction(_tasks, date);

  /// Productivity score (0–100) for today.
  int get todayScore => TaskAnalytics.score(_tasks, DateTime.now());

  /// Sum of completed-task durations for today in minutes.
  int get todayFocusMinutes =>
      TaskAnalytics.focusMinutes(_tasks, DateTime.now());

  String get todayFocusLabel =>
      TaskAnalytics.focusLabel(_tasks, DateTime.now());

  /// Completion fractions for each day Mon–Sun of the week containing [anchor].
  List<double> weekBarFractions(DateTime anchor) =>
      TaskAnalytics.weekBarFractions(_tasks, anchor);

  /// Count of completed tasks in the week containing [anchor].
  int weekCompletedCount(DateTime anchor) =>
      TaskAnalytics.weekCompletedCount(_tasks, anchor);

  /// Most-used priority this week (or null if no tasks).
  TaskPriority? topPriority(DateTime anchor) =>
      TaskAnalytics.topPriority(_tasks, anchor);

  /// Zen tasks (mindfulness) this week.
  List<DzTask> zenTasksThisWeek(DateTime anchor) =>
      TaskAnalytics.zenTasksThisWeek(_tasks, anchor);

  /// The in-memory copy of task [id] (soft-deleted tasks aren't loaded).
  DzTask? taskById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ── CRUD ──────────────────────────────────────────────────────────

  Future<void> load() async {
    _tasks = await TaskRepository.loadAll();
    notifyListeners();
    if (_notificationsEnabled) {
      await NotificationService.instance.rescheduleAll(_tasks);
    }
    // Push anything left unsynced from the last session, pull server
    // changes, then carry yesterday's unfinished tasks to today.
    unawaited(syncThenRollOver());
  }

  /// Pulls first, so a task completed on another device overnight arrives
  /// as done before rollover looks at it (otherwise this phone would move it
  /// to today as active and push that over the completion). Offline or
  /// signed out, the sync is a no-op or fails quietly and rollover still runs.
  Future<void> syncThenRollOver({DateTime? now}) async {
    await syncWithServer();
    await rollOver(now: now);
  }

  /// Gentle Rollover (see [Rollover]): moves unfinished tasks from past days
  /// to today. Safe to call repeatedly. Returns how many tasks moved.
  Future<int> rollOver({DateTime? now}) async {
    final moved = Rollover.apply(_tasks, now ?? DateTime.now());
    if (moved.isEmpty) return 0;
    for (final task in moved) {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) _tasks[idx] = task;
      await TaskRepository.updateTask(task);
    }
    notifyListeners();
    for (final task in moved) {
      await _syncReminders(task);
    }
    unawaited(SyncManager.instance.requestSync(this));
    return moved.length;
  }

  /// Sync tasks with server (background operation). Never throws; failed
  /// changes stay dirty in SQLite and go out on the next sync.
  Future<void> syncWithServer() => SyncManager.instance.requestSync(this);

  Future<void> addTask(DzTask task) async {
    _tasks.add(task);
    // Single-row insert. Replaces the old "re-serialize and rewrite the
    // entire task list" pattern.
    await TaskRepository.insertTask(task);
    notifyListeners();
    if (_notificationsEnabled) {
      await NotificationService.instance.scheduleForTask(task);
    }
    // Queue for sync (fire-and-forget)
    unawaited(SyncManager.instance.requestSync(this));
  }

  /// Done ⇄ active. A released task becomes done.
  Future<void> toggleTask(String id) async {
    final task = taskById(id);
    if (task == null) return;
    await setStatus(
        id, task.isCompleted ? TaskStatus.active : TaskStatus.done);
  }

  /// Marks task [id] done, released (let go) or active again. Entering done
  /// stamps completedAt; leaving it clears it. Reminders only stay scheduled
  /// for active tasks.
  Future<void> setStatus(String id, TaskStatus status) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1 || _tasks[idx].status == status) return;
    final updatedTask = _tasks[idx].copyWith(status: status);
    _tasks[idx] = updatedTask;
    await TaskRepository.updateTask(updatedTask);
    notifyListeners();
    await _syncReminders(updatedTask);
    unawaited(SyncManager.instance.requestSync(this));
  }

  /// Schedules reminders for an active task, cancels them otherwise.
  Future<void> _syncReminders(DzTask task) async {
    if (!_notificationsEnabled) return;
    if (task.status == TaskStatus.active) {
      await NotificationService.instance.scheduleForTask(task);
    } else {
      await NotificationService.instance.cancelForTask(task.id);
    }
  }

  Future<void> updateTask(String id, DzTask updatedTask) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tasks[idx] = updatedTask;
    await TaskRepository.updateTask(updatedTask);
    notifyListeners();
    await _syncReminders(updatedTask);
    // Queue for sync (fire-and-forget)
    unawaited(SyncManager.instance.requestSync(this));
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    // Soft delete (deleted_at set, row retained so sync can push the delete).
    await TaskRepository.deleteTask(id);
    notifyListeners();
    if (_notificationsEnabled) {
      await NotificationService.instance.cancelForTask(id);
    }
    // Queue for sync (fire-and-forget)
    unawaited(SyncManager.instance.requestSync(this));
  }

  /// Applies changes pulled from the server. Unlike the CRUD methods above,
  /// this writes rows clean and never requests another sync. A task with a
  /// local edit still waiting to be pushed is left alone; that edit goes out
  /// on the next sync and the server resolves it.
  Future<void> applyServerChanges({
    required List<DzTask> upserts,
    required List<String> deletedIds,
  }) async {
    if (upserts.isEmpty && deletedIds.isEmpty) return;

    for (final id in deletedIds) {
      if (await TaskRepository.hasPendingChanges(id)) continue;
      await TaskRepository.deleteFromServer(id);
      _tasks.removeWhere((t) => t.id == id);
      if (_notificationsEnabled) {
        await NotificationService.instance.cancelForTask(id);
      }
    }

    for (final task in upserts) {
      if (await TaskRepository.hasPendingChanges(task.id)) continue;
      await TaskRepository.upsertFromServer(task);
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx == -1) {
        _tasks.add(task);
      } else {
        _tasks[idx] = task;
      }
      await _syncReminders(task);
    }

    notifyListeners();
  }

  Future<void> clearAll() async {
    _tasks.clear();
    // Hard delete every row — this is the one place that's actually
    // destructive; everyday deletes go through deleteTask's soft delete.
    await TaskRepository.clearAll();
    notifyListeners();
    await NotificationService.instance.cancelAll();
  }
}


