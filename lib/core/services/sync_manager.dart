/// Manages offline-first synchronization between local and remote task storage.
library;

import 'sync_coordinator.dart';
import 'task_service.dart';
import '../../features/home/models/task_model.dart';
import '../../features/task_controller.dart';
import '../../core/logging/app_logger.dart';

/// Handles task sync coordination with conflict resolution.
///
/// The shared sync state machine (isSyncing guard, sync-status formatting,
/// retry/withSync wrappers) lives in [SyncCoordinator] â€” see
/// docs/DEVELOPMENT_PLAN.md Phase 3.2. This class owns only what's
/// task-specific: building the sync request and reconciling the response.
class SyncManager extends SyncCoordinator<TaskController> {
  SyncManager._();

  static final SyncManager _instance = SyncManager._();

  static SyncManager get instance => _instance;

  static final TaskService _taskService = TaskService.instance;

  @override
  String get entityLabel => 'Task';

  /// Sync all tasks with server (offline-first).
  ///
  /// Strategy:
  /// 1. First sync (last_sync_at = null): Download all server tasks
  /// 2. Subsequent syncs: Send local changes + merge with server state
  /// 3. Conflict resolution: Last-Write-Wins (server timestamp wins)
  /// 4. On error: Keep local state, retry later
  @override
  Future<SyncOutcome> performSync(TaskController controller) async {
    final localTasks = controller.all;

    final result = await _taskService.syncTasks(
      lastSyncAt: lastSuccessfulSync,
      localTasks: localTasks,
    );

    final serverTasks = result['server_tasks'] as List<DzTask>;
    final deletedIds = result['deleted_ids'] as List<String>;
    final conflicts = result['conflicts'] as List<SyncConflict>;

    await _applyServerTasks(controller, serverTasks, deletedIds);

    for (final conflict in conflicts) {
      AppLogger.debug('  - Task ${conflict.taskId}: ${conflict.resolution}');
    }

    return SyncOutcome(conflictCount: conflicts.length);
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
          AppLogger.debug(
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
  Future<void> createTaskWithSync(TaskController controller, DzTask task) =>
      withSync(controller, () => controller.addTask(task));

  /// Update a task locally and queue for sync.
  Future<void> updateTaskWithSync(
    TaskController controller,
    String taskId,
    DzTask updatedTask,
  ) =>
      withSync(controller, () async {
        // Preserves the original delete+re-add pattern rather than calling
        // controller.updateTask directly â€” see git history for context;
        // not changed here since Phase 3.2 is about where sync logic
        // lives, not about revisiting this specific update strategy.
        final idx = controller.all.indexWhere((t) => t.id == taskId);
        if (idx != -1) {
          await controller.deleteTask(taskId);
          await controller.addTask(updatedTask);
        }
      });

  /// Delete a task locally and queue for sync.
  Future<void> deleteTaskWithSync(TaskController controller, String taskId) =>
      withSync(controller, () => controller.deleteTask(taskId));

  /// Sync tasks with server. Alias for [sync] matching the original public
  /// method name used by `TaskController`/UI call sites.
  Future<void> syncTasks(TaskController controller) => sync(controller);

  /// Manual retry sync. Alias for [retrySync] matching the original public
  /// method name.
  Future<void> retrySyncTasks(TaskController controller) =>
      retrySync(controller);
}


