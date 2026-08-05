import 'package:flutter/material.dart';
import '../core/data/task_repository.dart';
import '../core/domain/task_analytics.dart';
import '../core/notification_service.dart';
import '../core/services/sync_manager.dart';
import 'home/models/task_model.dart';
import '../core/logging/app_logger.dart';

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

  // â”€â”€ Queries â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€ Derived stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Thin delegates to TaskAnalytics (lib/core/domain/task_analytics.dart)
  // â€” no business logic lives here as of Phase 3.1. Same names/signatures
  // as before the extraction, so no UI call site changes.

  /// Completion fraction for [date] (0.0â€“1.0).
  double completionFraction(DateTime date) =>
      TaskAnalytics.completionFraction(_tasks, date);

  /// Productivity score (0â€“100) for today.
  int get todayScore => TaskAnalytics.score(_tasks, DateTime.now());

  /// Sum of completed-task durations for today in minutes.
  int get todayFocusMinutes =>
      TaskAnalytics.focusMinutes(_tasks, DateTime.now());

  String get todayFocusLabel =>
      TaskAnalytics.focusLabel(_tasks, DateTime.now());

  /// Completion fractions for each day Monâ€“Sun of the week containing [anchor].
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

  // â”€â”€ CRUD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> load() async {
    _tasks = await TaskRepository.loadAll();
    notifyListeners();
    if (_notificationsEnabled) {
      await NotificationService.instance.rescheduleAll(_tasks);
    }
    // Sync with server in background
    syncWithServer();
  }

  /// Sync tasks with server (background operation).
  Future<void> syncWithServer() async {
    try {
      await SyncManager.instance.syncTasks(this);
    } catch (e) {
      AppLogger.debug('Background sync failed: $e');
      // Silently fail - local state is preserved
    }
  }

  Future<void> addTask(DzTask task) async {
    _tasks.add(task);
    // Single-row insert â€” see docs/DATABASE_SCHEMA.md. Replaces the old
    // "re-serialize and rewrite the entire task list" pattern.
    await TaskRepository.insertTask(task);
    notifyListeners();
    if (_notificationsEnabled) {
      await NotificationService.instance.scheduleForTask(task);
    }
    // Queue for sync (fire-and-forget)
    SyncManager.instance.createTaskWithSync(this, task);
  }

  Future<void> toggleTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final updatedTask = _tasks[idx].copyWith(isCompleted: !_tasks[idx].isCompleted);
    _tasks[idx] = updatedTask;
    await TaskRepository.updateTask(updatedTask);
    notifyListeners();
    // Cancel notification if completed; re-schedule if unchecked
    if (_notificationsEnabled) {
      if (updatedTask.isCompleted) {
        await NotificationService.instance.cancelForTask(id);
      } else {
        await NotificationService.instance.scheduleForTask(updatedTask);
      }
    }
    // Queue for sync (fire-and-forget)
    SyncManager.instance.updateTaskWithSync(this, id, updatedTask);
  }

  Future<void> updateTask(String id, DzTask updatedTask) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tasks[idx] = updatedTask;
    await TaskRepository.updateTask(updatedTask);
    notifyListeners();
    if (_notificationsEnabled) {
      if (updatedTask.isCompleted) {
        await NotificationService.instance.cancelForTask(id);
      } else {
        await NotificationService.instance.scheduleForTask(updatedTask);
      }
    }
    // Queue for sync (fire-and-forget)
    SyncManager.instance.updateTaskWithSync(this, id, updatedTask);
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    // Soft delete (deleted_at set, row retained for sync visibility) â€” see
    // docs/DATABASE_SCHEMA.md.
    await TaskRepository.deleteTask(id);
    notifyListeners();
    if (_notificationsEnabled) {
      await NotificationService.instance.cancelForTask(id);
    }
    // Queue for sync (fire-and-forget)
    SyncManager.instance.deleteTaskWithSync(this, id);
  }

  Future<void> clearAll() async {
    _tasks.clear();
    // Hard delete every row â€” this is the one place that's actually
    // destructive; everyday deletes go through deleteTask's soft delete.
    await TaskRepository.clearAll();
    notifyListeners();
    await NotificationService.instance.cancelAll();
  }
}


