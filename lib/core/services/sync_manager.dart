/// Manages offline-first synchronization between local and remote task storage.
library;

import 'package:flutter/foundation.dart';
import 'task_service.dart';
import '../../features/home/models/task_model.dart';
import '../../features/task_controller.dart';

/// Handles sync coordination with conflict resolution.
class SyncManager extends ChangeNotifier {
  SyncManager._();

  static final SyncManager _instance = SyncManager._();

  static SyncManager get instance => _instance;

  static final TaskService _taskService = TaskService.instance;

  bool _isSyncing = false;
  DateTime? _lastSuccessfulSync;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  /// Sync all tasks with server (offline-first).
  ///
  /// Strategy:
  /// 1. First sync (last_sync_at = null): Download all server tasks
  /// 2. Subsequent syncs: Send local changes + merge with server state
  /// 3. Conflict resolution: Last-Write-Wins (server timestamp wins)
  /// 4. On error: Keep local state, retry later
  Future<void> syncTasks(TaskController taskController) async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // Get local tasks
      final localTasks = taskController.all;

      // Call sync endpoint
      final result = await _taskService.syncTasks(
        lastSyncAt: _lastSuccessfulSync,
        localTasks: localTasks,
      );

      // Process sync result
      final serverTasks = result['server_tasks'] as List<DzTask>;
      final deletedIds = result['deleted_ids'] as List<String>;
      final conflicts = result['conflicts'] as List<SyncConflict>;

      // Update local state with server result
      await _applyServerTasks(taskController, serverTasks, deletedIds);

      // Log conflicts for debugging
      if (conflicts.isNotEmpty) {
        debugPrint('Sync conflicts detected: ${conflicts.length}');
        for (final conflict in conflicts) {
          debugPrint('  - Task ${conflict.taskId}: ${conflict.resolution}');
        }
      }

      _lastSuccessfulSync = DateTime.now();
      debugPrint('Sync successful at $_lastSuccessfulSync');
    } catch (e) {
      debugPrint('Sync failed: $e');
      // Fail gracefully - local state is preserved
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Apply server state to local controller.
  /// Deletes tasks marked as deleted on server.
  /// Adds/updates tasks from server.
  Future<void> _applyServerTasks(
    TaskController controller,
    List<DzTask> serverTasks,
    List<String> deletedIds,
  ) async {
    // Delete tasks removed on server
    for (final id in deletedIds) {
      await controller.deleteTask(id);
    }

    // Update local tasks with server versions
    for (final serverTask in serverTasks) {
      final localIdx = controller.all.indexWhere((t) => t.id == serverTask.id);

      if (localIdx == -1) {
        // New task from server
        await controller.addTask(serverTask);
      } else {
        // Update existing task - but preserve local completion state if changed
        // (User might have marked task complete locally but not synced yet)
        final localTask = controller.all[localIdx];
        if (localTask.isCompleted != serverTask.isCompleted) {
          debugPrint(
            'Completion state differs for ${serverTask.id}: '
            'local=${localTask.isCompleted}, server=${serverTask.isCompleted}',
          );
        }
        // For now, server wins on all fields (can be customized)
        await controller.updateTask(serverTask.id, serverTask);
      }
    }
  }

  /// Create a new task locally and queue for sync.
  Future<void> createTaskWithSync(
    TaskController controller,
    DzTask task,
  ) async {
    try {
      // Add locally first (optimistic)
      await controller.addTask(task);

      // Try to sync immediately
      await syncTasks(controller);
    } catch (e) {
      debugPrint('Task created locally but sync failed: $e');
      // Task is in local state, will sync on next retry
    }
  }

  /// Update a task locally and queue for sync.
  Future<void> updateTaskWithSync(
    TaskController controller,
    String taskId,
    DzTask updatedTask,
  ) async {
    try {
      // Update locally first (optimistic)
      final idx = controller.all.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        await controller.deleteTask(taskId);
        await controller.addTask(updatedTask);
      }

      // Try to sync immediately
      await syncTasks(controller);
    } catch (e) {
      debugPrint('Task updated locally but sync failed: $e');
      // Task is in local state, will sync on next retry
    }
  }

  /// Delete a task locally and queue for sync.
  Future<void> deleteTaskWithSync(
    TaskController controller,
    String taskId,
  ) async {
    try {
      // Delete locally first (optimistic)
      await controller.deleteTask(taskId);

      // Try to sync immediately
      await syncTasks(controller);
    } catch (e) {
      debugPrint('Task deleted locally but sync failed: $e');
      // Task is in local state, will sync on next retry
    }
  }

  /// Manual retry sync.
  Future<void> retrySyncTasks(TaskController taskController) async {
    try {
      await syncTasks(taskController);
    } catch (e) {
      debugPrint('Sync retry failed: $e');
      rethrow;
    }
  }

  /// Clear sync state (on logout).
  void clearSyncState() {
    _lastSuccessfulSync = null;
    _isSyncing = false;
  }

  /// Get sync status for UI.
  String get syncStatus {
    if (_isSyncing) return 'Syncing...';
    if (_lastSuccessfulSync == null) return 'Never synced';

    final minutesAgo = DateTime.now().difference(_lastSuccessfulSync!).inMinutes;
    if (minutesAgo == 0) return 'Just now';
    if (minutesAgo < 60) return '$minutesAgo min ago';

    final hoursAgo = (minutesAgo / 60).floor();
    if (hoursAgo < 24) return '$hoursAgo h ago';

    final daysAgo = (hoursAgo / 24).floor();
    return '$daysAgo d ago';
  }
}
