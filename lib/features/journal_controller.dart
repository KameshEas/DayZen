import 'dart:async';

import 'package:flutter/material.dart';
import '../core/data/journal_repository.dart';
import '../core/domain/journal_analytics.dart';
import '../core/services/journal_sync_manager.dart';
import 'journal/models/journal_entry.dart';

class JournalController extends ChangeNotifier {
  List<JournalEntry> _entries = [];

  /// Entries sorted newest-first.
  List<JournalEntry> get all => List.unmodifiable(_entries);

  /// Count of entries logged in the current calendar week (Mon–Sun).
  /// Thin delegate to JournalAnalytics (lib/core/domain/journal_analytics.dart)
  /// — no business logic lives here as of Phase 3.1.
  int get thisWeekCount => JournalAnalytics.thisWeekCount(_entries);

  // ── CRUD ──────────────────────────────────────────────────────────

  Future<void> load() async {
    _entries = await JournalRepository.loadAll();
    _sortNewestFirst();
    notifyListeners();
    // Push anything left unsynced from the last session, pull server changes.
    unawaited(syncWithServer());
  }

  Future<void> addEntry(JournalEntry entry) async {
    _entries.insert(0, entry);
    // Single-row insert — see docs/DATABASE_SCHEMA.md.
    await JournalRepository.insertEntry(entry);
    notifyListeners();
    unawaited(JournalSyncManager.instance.requestSync(this));
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    // Soft delete (deleted_at set, row retained so the delete can be pushed).
    await JournalRepository.deleteEntry(id);
    notifyListeners();
    unawaited(JournalSyncManager.instance.requestSync(this));
  }

  /// Sync entries with server (background operation). Never throws; failed
  /// changes stay dirty in SQLite and go out on the next sync.
  Future<void> syncWithServer() =>
      JournalSyncManager.instance.requestSync(this);

  /// Applies changes pulled from the server: written clean, never triggers
  /// another sync, and skips entries with an unpushed local change.
  Future<void> applyServerChanges({
    required List<JournalEntry> upserts,
    required List<String> deletedIds,
  }) async {
    if (upserts.isEmpty && deletedIds.isEmpty) return;

    for (final id in deletedIds) {
      if (await JournalRepository.hasPendingChanges(id)) continue;
      await JournalRepository.deleteFromServer(id);
      _entries.removeWhere((e) => e.id == id);
    }

    for (final entry in upserts) {
      if (await JournalRepository.hasPendingChanges(entry.id)) continue;
      await JournalRepository.upsertFromServer(entry);
      final idx = _entries.indexWhere((e) => e.id == entry.id);
      if (idx == -1) {
        _entries.add(entry);
      } else {
        _entries[idx] = entry;
      }
    }

    _sortNewestFirst();
    notifyListeners();
  }

  void _sortNewestFirst() =>
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  Future<void> clearAll() async {
    _entries.clear();
    // Hard delete every row — this is the one place that's actually
    // destructive; everyday deletes go through deleteEntry's soft delete.
    await JournalRepository.clearAll();
    notifyListeners();
  }
}
