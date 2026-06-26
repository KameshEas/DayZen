import 'package:flutter/material.dart';
import '../core/data/task_repository.dart';
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

  /// Completion fraction for [date] (0.0–1.0).
  double completionFraction(DateTime date) {
    final tasks = forDate(date);
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t.isCompleted).length / tasks.length;
  }

  /// Productivity score (0–100) for today.
  int get todayScore =>
      (completionFraction(DateTime.now()) * 100).round();

  /// Sum of completed-task durations for today in minutes.
  int get todayFocusMinutes {
    int total = 0;
    for (final t in forDate(DateTime.now()).where((t) => t.isCompleted)) {
      final start = t.startTime.hour * 60 + t.startTime.minute;
      final end = t.endTime.hour * 60 + t.endTime.minute;
      if (end > start) total += end - start;
    }
    return total;
  }

  String get todayFocusLabel {
    final m = todayFocusMinutes;
    if (m == 0) return '0m';
    final h = m ~/ 60;
    final mn = m % 60;
    return h > 0 ? '${h}h ${mn}m' : '${mn}m';
  }

  /// Completion fractions for each day Mon–Sun of the week containing [anchor].
  List<double> weekBarFractions(DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return List.generate(
        7, (i) => completionFraction(monday.add(Duration(days: i))));
  }

  /// Count of completed tasks in the week containing [anchor].
  int weekCompletedCount(DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return forWeek(monday).where((t) => t.isCompleted).length;
  }

  /// Most-used priority this week (or null if no tasks).
  TaskPriority? topPriority(DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final tasks = forWeek(monday);
    if (tasks.isEmpty) return null;
    final counts = <TaskPriority, int>{};
    for (final t in tasks) {
      counts[t.priority] = (counts[t.priority] ?? 0) + 1;
    }
    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Zen tasks (mindfulness) this week.
  List<DzTask> zenTasksThisWeek(DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return forWeek(monday)
        .where((t) => t.priority == TaskPriority.zen)
        .toList();
  }

  // ── CRUD ──────────────────────────────────────────────────────────

  Future<void> load() async {
    _tasks = await TaskRepository.load();
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
      debugPrint('Background sync failed: $e');
      // Silently fail - local state is preserved
    }
  }

  Future<void> addTask(DzTask task) async {
    _tasks.add(task);
    await TaskRepository.save(_tasks);
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
    await TaskRepository.save(_tasks);
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
    await TaskRepository.save(_tasks);
    notifyListeners();
    if (_notificationsEnabled) {
      if (updatedTask.isCompleted) {
        await NotificationService.instance.cancelForTask(id);
      } else {
        await NotificationService.instance.scheduleForTask(updatedTask);
      }
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await TaskRepository.save(_tasks);
    notifyListeners();
    if (_notificationsEnabled) {
      await NotificationService.instance.cancelForTask(id);
    }
    // Queue for sync (fire-and-forget)
    SyncManager.instance.deleteTaskWithSync(this, id);
  }

  Future<void> clearAll() async {
    _tasks.clear();
    await TaskRepository.save(_tasks);
    notifyListeners();
    await NotificationService.instance.cancelAll();
  }
}
