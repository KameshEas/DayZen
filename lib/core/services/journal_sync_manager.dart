/// Manages offline-first synchronization for journal entries.
library;

import 'package:flutter/material.dart';
import 'journal_service.dart';
import 'sync_coordinator.dart';
import '../../features/journal/models/journal_entry.dart';
import '../../features/journal_controller.dart';
import '../../core/logging/app_logger.dart';

/// Handles journal sync coordination with conflict resolution.
///
/// The shared sync state machine lives in [SyncCoordinator] â€” see
/// docs/DEVELOPMENT_PLAN.md Phase 3.2 and [SyncManager] (the task
/// equivalent of this class). This class owns only what's journal-specific:
/// building the sync request and reconciling the response.
class JournalSyncManager extends SyncCoordinator<JournalController> {
  JournalSyncManager._();

  static final JournalSyncManager _instance = JournalSyncManager._();

  static JournalSyncManager get instance => _instance;

  static final JournalService _journalService = JournalService.instance;

  @override
  String get entityLabel => 'Journal entry';

  /// Sync all journal entries with server (offline-first).
  @override
  Future<SyncOutcome> performSync(JournalController controller) async {
    final localEntries = controller.all
        .map((e) => JournalApiResponse(
              id: e.id,
              title: e.title,
              body: e.body,
              mood: e.mood.name,
              timestampMs: e.timestamp.millisecondsSinceEpoch,
              entryTimestamp: e.timestamp.toIso8601String(),
              accentColorValue: e.accentColor?.toARGB32(),
              createdAt: e.timestamp,
              updatedAt: e.timestamp,
            ))
        .toList();

    final result = await _journalService.syncEntries(
      lastSyncAt: lastSuccessfulSync,
      localEntries: localEntries,
    );

    final serverEntries = result['entries'] as List<JournalApiResponse>;
    final deletedIds = result['deleted_ids'] as List<String>;
    final conflicts = result['conflicts'] as List<JournalSyncConflict>;

    await _applyServerEntries(controller, serverEntries, deletedIds);

    for (final conflict in conflicts) {
      AppLogger.debug('  - Entry ${conflict.entryId}: ${conflict.resolution}');
    }

    return SyncOutcome(conflictCount: conflicts.length);
  }

  /// Apply server state to local controller.
  Future<void> _applyServerEntries(
    JournalController controller,
    List<JournalApiResponse> serverEntries,
    List<String> deletedIds,
  ) async {
    // Delete entries removed on server
    for (final id in deletedIds) {
      await controller.deleteEntry(id);
    }

    // Update local entries with server versions
    for (final serverEntry in serverEntries) {
      final localIdx = controller.all.indexWhere((e) => e.id == serverEntry.id);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(serverEntry.timestampMs);
      final accentColor = serverEntry.accentColorValue != null
          ? Color(serverEntry.accentColorValue!)
          : null;

      if (localIdx == -1) {
        // New entry from server
        final newEntry = JournalEntry(
          id: serverEntry.id,
          title: serverEntry.title,
          body: serverEntry.body,
          mood: JournalMood.values.asNameMap()[serverEntry.mood] ?? JournalMood.peaceful,
          timestamp: timestamp,
          accentColor: accentColor,
        );
        await controller.addEntry(newEntry);
      } else {
        // Update existing entry - for now, server wins
        final updatedEntry = JournalEntry(
          id: serverEntry.id,
          title: serverEntry.title,
          body: serverEntry.body,
          mood: JournalMood.values.asNameMap()[serverEntry.mood] ??
                controller.all[localIdx].mood,
          timestamp: timestamp,
          accentColor: accentColor,
        );

        await controller.deleteEntry(serverEntry.id);
        await controller.addEntry(updatedEntry);
      }
    }
  }

  /// Create a new entry locally and queue for sync.
  Future<void> createEntryWithSync(
    JournalController controller,
    JournalEntry entry,
  ) =>
      withSync(controller, () => controller.addEntry(entry));

  /// Delete an entry locally and queue for sync.
  Future<void> deleteEntryWithSync(
    JournalController controller,
    String entryId,
  ) =>
      withSync(controller, () => controller.deleteEntry(entryId));

  /// Sync entries with server. Alias for [sync] matching the original
  /// public method name used by `JournalController`/UI call sites.
  Future<void> syncEntries(JournalController controller) => sync(controller);

  /// Manual retry sync. Alias for [retrySync] matching the original public
  /// method name.
  Future<void> retrySyncEntries(JournalController controller) =>
      retrySync(controller);
}


