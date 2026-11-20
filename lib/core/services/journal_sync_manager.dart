/// Manages offline-first synchronization for journal entries.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'journal_service.dart';
import 'sync_coordinator.dart';
import '../data/journal_repository.dart';
import '../../features/journal/models/journal_entry.dart';
import '../../features/journal_controller.dart';
import '../../core/logging/app_logger.dart';

/// Journal sync. Same protocol as [SyncManager] (tasks): push dirty rows
/// (tombstones included), mark sent rows clean, apply server changes clean
/// through [JournalController.applyServerChanges], persist the cursor.
class JournalSyncManager extends SyncCoordinator<JournalController> {
  JournalSyncManager._();

  static final JournalSyncManager _instance = JournalSyncManager._();

  static JournalSyncManager get instance => _instance;

  static final JournalService _journalService = JournalService.instance;

  static const String cursorKey = 'sync_cursor_journal';

  @override
  String get entityLabel => 'Journal entry';

  @override
  Future<SyncOutcome> performSync(JournalController controller) async {
    final dirty = await JournalRepository.dirtyRows();
    final cursor = await SyncCursor.load(cursorKey);
    final requestStartedAt = DateTime.now().toUtc();

    final localEntries = dirty
        .map((row) => JournalApiResponse(
              id: row.id,
              title: row.title,
              body: row.body,
              mood: row.mood,
              timestampMs: row.timestamp.millisecondsSinceEpoch,
              entryTimestamp: row.timestamp.toIso8601String(),
              accentColorValue: row.accentColorValue,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              deletedAt: row.deletedAt,
            ))
        .toList();

    final result = await _journalService.syncEntries(
      lastSyncAt: cursor,
      localEntries: localEntries,
    );

    await JournalRepository.markSynced(dirty);

    final serverEntries =
        (result['entries'] as List<dynamic>).cast<JournalApiResponse>();
    await controller.applyServerChanges(
      upserts: serverEntries.map(_toEntry).toList(),
      deletedIds: (result['deleted_ids'] as List<dynamic>).cast<String>(),
    );

    await SyncCursor.save(
      cursorKey,
      (result['synced_at'] as DateTime?) ?? requestStartedAt,
    );

    final conflicts =
        (result['conflicts'] as List<dynamic>).cast<JournalSyncConflict>();
    for (final conflict in conflicts) {
      AppLogger.debug('  - Entry ${conflict.entryId}: ${conflict.resolution}');
    }
    return SyncOutcome(conflictCount: conflicts.length);
  }

  static JournalEntry _toEntry(JournalApiResponse e) => JournalEntry(
        id: e.id,
        title: e.title,
        body: e.body,
        mood: JournalMood.values.asNameMap()[e.mood] ?? JournalMood.peaceful,
        timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestampMs),
        accentColor:
            e.accentColorValue != null ? Color(e.accentColorValue!) : null,
      );

  @override
  void clearSyncState() {
    super.clearSyncState();
    unawaited(SyncCursor.clear(cursorKey));
  }

  /// Sync entries with server. Alias for [sync] matching the original
  /// public method name used by `JournalController`/UI call sites.
  Future<void> syncEntries(JournalController controller) => sync(controller);

  /// Manual retry sync. Alias for [retrySync] matching the original public
  /// method name.
  Future<void> retrySyncEntries(JournalController controller) =>
      retrySync(controller);
}
