import 'package:flutter/foundation.dart';

import '../../core/data/day_close_repository.dart';
import '../../core/utils/ids.dart';
import '../home/models/task_model.dart';
import '../journal/models/journal_entry.dart';
import '../journal_controller.dart';
import '../task_controller.dart';

enum CloseStep { review, mood, note, summary }

/// What happened to one task during review, for undo.
enum CloseAction { done, carried, released }

class _UndoEntry {
  const _UndoEntry(this.before, this.action);
  final DzTask before;
  final CloseAction action;
}

/// Plan M-1.10: Close the Day.
///
/// 1. Review: each unfinished task of the day is swiped right (tomorrow),
///    left (let go) or tapped (done). Every choice can be undone.
/// 2. Mood: one tap, using the journal moods.
/// 3. Note: an optional line. Mood and note become one journal entry.
/// 4. Summary: "Day closed. ✓ 4 done · 2 carried · 1 released", written to
///    `day_closes`.
///
/// Closing the same day again edits that day's record and journal entry
/// instead of adding new ones. Everything here works offline.
class DayCloseController extends ChangeNotifier {
  DayCloseController({
    required this.tasks,
    required this.journal,
    required this.store,
    DateTime Function()? clock,
    this.onFirstClose,
  }) : _clock = clock ?? DateTime.now;

  final TaskController tasks;
  final JournalController journal;
  final DayCloseStore store;
  final DateTime Function() _clock;

  /// Called once per day, on the first close (the `days_closed` counter).
  final Future<void> Function()? onFirstClose;

  late DateTime _day;

  /// The day being closed (local midnight).
  DateTime get day => _day;

  CloseStep _step = CloseStep.review;
  CloseStep get step => _step;

  /// Unfinished tasks still to sort, in time order.
  List<DzTask> _queue = [];
  List<DzTask> get remaining => List.unmodifiable(_queue);

  final List<_UndoEntry> _undo = [];
  bool get canUndo => _undo.isNotEmpty;

  int _carriedThisSession = 0;

  JournalMood? mood;
  String note = '';

  DayCloseRecord? _previous;

  /// True when this day was already closed once; finishing edits it.
  bool get isEdit => _previous != null;

  DayCloseRecord? _result;
  DayCloseRecord? get result => _result;

  bool _lastWasEdit = false;

  /// Whether the last [finish] updated an earlier close of the same day.
  bool get lastFinishWasEdit => _lastWasEdit;

  bool _loaded = false;
  bool get loaded => _loaded;

  bool _saving = false;
  bool get saving => _saving;

  /// Prepares the close for [_clock]'s day: loads any earlier close and the
  /// tasks still open. An earlier close's mood and note are pre-filled.
  Future<void> load() async {
    final now = _clock();
    _day = DayCloseRepository.midnight(now);
    _previous = await store.forDay(_day);
    _queue = _openTasks();
    final entryId = _previous?.journalEntryId;
    if (entryId != null) {
      final entry = journal.entryById(entryId);
      if (entry != null) {
        mood = entry.mood;
        note = entry.body;
      }
    }
    _step = _queue.isEmpty ? CloseStep.mood : CloseStep.review;
    _loaded = true;
    notifyListeners();
  }

  List<DzTask> _openTasks() => tasks
      .forDate(_day)
      .where((t) => t.status == TaskStatus.active)
      .toList();

  // ── Step 1: review ────────────────────────────────────────────────────

  Future<void> markDone(DzTask task) =>
      _act(task, CloseAction.done, () => tasks.setStatus(task.id, TaskStatus.done));

  Future<void> letGo(DzTask task) => _act(
      task, CloseAction.released, () => tasks.setStatus(task.id, TaskStatus.released));

  /// Moves the task to tomorrow, same time. Counts as carried, like a
  /// Gentle Rollover would at midnight.
  Future<void> carry(DzTask task) => _act(task, CloseAction.carried, () {
        final tomorrow = _day.add(const Duration(days: 1));
        return tasks.updateTask(
          task.id,
          task.copyWith(
            date: tomorrow,
            rolloverCount: task.rolloverCount + 1,
            originalDate: task.originalDate ?? task.date,
          ),
        );
      });

  Future<void> _act(
      DzTask task, CloseAction action, Future<void> Function() apply) async {
    final current = tasks.taskById(task.id) ?? task;
    await apply();
    _undo.add(_UndoEntry(current, action));
    if (action == CloseAction.carried) _carriedThisSession++;
    _queue.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  /// Puts the last sorted task back exactly as it was.
  Future<void> undo() async {
    if (_undo.isEmpty) return;
    final last = _undo.removeLast();
    await tasks.updateTask(last.before.id, last.before);
    if (last.action == CloseAction.carried) _carriedThisSession--;
    _queue = _openTasks();
    if (_step != CloseStep.review) _step = CloseStep.review;
    notifyListeners();
  }

  void continueFromReview() => _go(CloseStep.mood);

  // ── Steps 2–3 ─────────────────────────────────────────────────────────

  void chooseMood(JournalMood m) {
    mood = m;
    notifyListeners();
  }

  void continueFromMood() => _go(CloseStep.note);

  void back() {
    switch (_step) {
      case CloseStep.mood:
        _go(CloseStep.review);
      case CloseStep.note:
        _go(CloseStep.mood);
      case CloseStep.review:
      case CloseStep.summary:
        break;
    }
  }

  void _go(CloseStep s) {
    _step = s;
    notifyListeners();
  }

  // ── Finish ────────────────────────────────────────────────────────────

  /// Writes the journal entry (if there's a mood or a note) and the day's
  /// record, then shows the summary.
  Future<void> finish() async {
    if (_saving) return;
    _saving = true;
    notifyListeners();
    try {
      final now = _clock();
      final entryId = await _saveJournal(now);
      final today = tasks.forDate(_day);
      final record = DayCloseRecord(
        date: _day,
        closedAt: now,
        done: today.where((t) => t.status == TaskStatus.done).length,
        carried: (_previous?.carried ?? 0) + _carriedThisSession,
        released: today.where((t) => t.status == TaskStatus.released).length,
        journalEntryId: entryId,
      );
      await store.save(record);
      _lastWasEdit = _previous != null;
      if (_previous == null) await onFirstClose?.call();
      _previous = record;
      _carriedThisSession = 0;
      _undo.clear();
      _result = record;
      _step = CloseStep.summary;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  static const reflectionTitle = 'Evening reflection';

  Future<String?> _saveJournal(DateTime now) async {
    final text = note.trim();
    final existingId = _previous?.journalEntryId;
    final existing = existingId == null ? null : journal.entryById(existingId);
    if (mood == null && text.isEmpty) {
      // Nothing to say this time; keep an earlier entry as it is.
      return existing?.id;
    }
    final entry = JournalEntry(
      id: existing?.id ?? newId('close', now: now),
      title: reflectionTitle,
      body: text,
      mood: mood ?? JournalMood.peaceful,
      timestamp: existing?.timestamp ?? now,
    );
    if (existing == null) {
      await journal.addEntry(entry);
    } else {
      await journal.updateEntry(entry);
    }
    return entry.id;
  }

  /// "✓ 4 done · 2 carried · 1 released".
  static String summaryLine(DayCloseRecord r) =>
      '✓ ${r.done} done · ${r.carried} carried · ${r.released} released';
}
