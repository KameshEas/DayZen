/// Manages offline-first synchronization between local and remote task storage.
library;

import 'dart:async';

import 'sync_coordinator.dart';
import 'task_service.dart';
import '../data/task_repository.dart';
import '../../features/home/models/task_model.dart';
import '../../features/task_controller.dart';
import '../../core/logging/app_logger.dart';

/// Task sync: push the rows marked dirty, pull what changed on the server.
///
/// 1. Read dirty rows (edits *and* soft-deleted tombstones) from SQLite.
/// 2. POST them with the persisted cursor to `/tasks/sync`.
/// 3. Mark each sent row clean, unless it changed while the request was in
///    flight (it then stays dirty and goes out next time).
/// 4. Apply the server's changes through [TaskController.applyServerChanges],
///    which writes them clean and never queues another push, and skips rows
///    that still have unpushed local edits.
/// 5. Save the server's `synced_at` as the next cursor.
///
/// Controllers trigger this with [requestSync] after a local write. Nothing
/// here calls a controller mutator, which is what used to make every add or
/// delete loop forever (audit item P0-1).
class SyncManager extends SyncCoordinator<TaskController> {
  SyncManager._();

  static final SyncManager _instance = SyncManager._();

  static SyncManager get instance => _instance;

  static final TaskService _taskService = TaskService.instance;

  static const String cursorKey = 'sync_cursor_tasks';

  @override
  String get entityLabel => 'Task';

  @override
  Future<SyncOutcome> performSync(TaskController controller) async {
    final dirty = await TaskRepository.dirtyRows();
    final cursor = await SyncCursor.load(cursorKey);
    final requestStartedAt = DateTime.now().toUtc();

    final result = await _taskService.syncTasks(
      lastSyncAt: cursor,
      localTasks: dirty.map(TaskRepository.fromRow).toList(),
      deletedAt: {
        for (final row in dirty)
          if (row.deletedAt != null) row.id: row.deletedAt!,
      },
    );

    await TaskRepository.markSynced(dirty);

    await controller.applyServerChanges(
      upserts: (result['server_tasks'] as List<dynamic>).cast<DzTask>(),
      deletedIds: (result['deleted_ids'] as List<dynamic>).cast<String>(),
    );

    await SyncCursor.save(
      cursorKey,
      (result['synced_at'] as DateTime?) ?? requestStartedAt,
    );

    final conflicts = (result['conflicts'] as List<dynamic>).cast<SyncConflict>();
    for (final conflict in conflicts) {
      AppLogger.debug('  - Task ${conflict.taskId}: ${conflict.resolution}');
    }
    return SyncOutcome(conflictCount: conflicts.length);
  }

  /// Also forgets the persisted cursor, so the next account starts with a
  /// full pull.
  @override
  void clearSyncState() {
    super.clearSyncState();
    unawaited(SyncCursor.clear(cursorKey));
  }

  /// Sync tasks with server. Alias for [sync] matching the original public
  /// method name used by `TaskController`/UI call sites.
  Future<void> syncTasks(TaskController controller) => sync(controller);

  /// Manual retry sync. Alias for [retrySync] matching the original public
  /// method name.
  Future<void> retrySyncTasks(TaskController controller) =>
      retrySync(controller);
}
