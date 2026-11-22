import 'package:flutter/foundation.dart';

import '../../core/domain/brain_dump_parser.dart';
import '../../core/domain/rhythm/energy_profile.dart';
import '../home/models/task_model.dart';
import 'onboarding_plan.dart';

/// Everything onboarding does outside its own state. The real wiring lives
/// in `onboarding_v2_page.dart`; tests pass fakes, so no step ever needs a
/// device dialog or a database.
class OnboardingEffects {
  const OnboardingEffects({
    required this.saveTasks,
    required this.requestNotificationPermission,
    required this.setRemindersEnabled,
    required this.savePrior,
    required this.markDone,
    required this.countStarted,
    required this.countCompleted,
    required this.recordTimeToFirstPlan,
  });

  final Future<void> Function(List<DzTask> tasks) saveTasks;

  /// Only ever called after the user picks "Yes" in step 4 (M-1.7).
  final Future<bool> Function() requestNotificationPermission;
  final Future<void> Function(bool enabled) setRemindersEnabled;
  final Future<void> Function(RhythmPrior prior) savePrior;
  final Future<void> Function() markDone;
  final Future<void> Function() countStarted;
  final Future<void> Function() countCompleted;
  final Future<void> Function(Duration elapsed) recordTimeToFirstPlan;
}

enum OnboardingStep { welcome, plate, sharpest, preview, nudge }

/// Plan M-1.6: "Plan today in 60 seconds".
///
/// Holds every answer for the whole flow, so going back a step keeps what
/// was typed and picked.
class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required this.effects,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final OnboardingEffects effects;
  final DateTime Function() _clock;

  OnboardingStep _step = OnboardingStep.welcome;
  OnboardingStep get step => _step;

  String dumpText = '';

  List<TaskDraft> _drafts = [];
  List<TaskDraft> get drafts => List.unmodifiable(_drafts);

  RhythmPrior? _prior;
  RhythmPrior? get prior => _prior;

  bool? _wantsNudge;
  bool? get wantsNudge => _wantsNudge;

  DateTime? _startedAt;
  bool _saving = false;
  bool get saving => _saving;

  bool _finished = false;
  bool get finished => _finished;

  // ── Step flow ─────────────────────────────────────────────────────────

  /// Welcome → "What's on your plate?". Starts the time-to-first-plan clock.
  Future<void> begin() async {
    if (_startedAt == null) {
      _startedAt = _clock();
      await effects.countStarted();
    }
    _go(OnboardingStep.plate);
  }

  bool get canContinueFromPlate => _drafts.isNotEmpty;

  void continueFromPlate() {
    if (!canContinueFromPlate) return;
    _go(OnboardingStep.sharpest);
  }

  void choosePrior(RhythmPrior prior) {
    _prior = prior;
    notifyListeners();
  }

  void continueFromSharpest() {
    if (_prior == null) return;
    _go(OnboardingStep.preview);
  }

  void continueFromPreview() => _go(OnboardingStep.nudge);

  /// One step back; false on the welcome step (the caller leaves the page).
  bool back() {
    if (_step == OnboardingStep.welcome) return false;
    _go(OnboardingStep.values[_step.index - 1]);
    return true;
  }

  void _go(OnboardingStep s) {
    _step = s;
    notifyListeners();
  }

  // ── Step 1: brain dump → editable chips ───────────────────────────────

  void setDumpText(String text) {
    dumpText = text;
  }

  /// Appends an example chip's text to the box.
  void addExample(String example) {
    final t = dumpText.trim();
    dumpText = t.isEmpty ? example : '$t, $example';
    notifyListeners();
  }

  /// Parses the box into chips, replacing earlier chips.
  void parseDump() {
    _drafts = BrainDumpParser.parse(dumpText);
    notifyListeners();
  }

  void updateDraft(int index, TaskDraft draft) {
    if (index < 0 || index >= _drafts.length) return;
    _drafts = [..._drafts]..[index] = draft;
    notifyListeners();
  }

  void removeDraft(int index) {
    if (index < 0 || index >= _drafts.length) return;
    _drafts = [..._drafts]..removeAt(index);
    notifyListeners();
  }

  /// Adds a hand-made task. Its category comes from the title, like a
  /// parsed one. A leftover "gentle start" suggestion is replaced.
  void addDraft(TaskDraft draft) {
    final t = draft.title.trim();
    if (t.isEmpty) return;
    _drafts = [
      ..._drafts.where((d) => !d.isSuggestion),
      draft.copyWith(title: t, category: BrainDumpParser.categoryFor(t)),
    ];
    notifyListeners();
  }

  // ── Step 3: preview ───────────────────────────────────────────────────

  /// The plan as it would be saved now. Uses "Not sure" until step 2 is
  /// answered.
  List<PlannedDraft> get plan => OnboardingPlan.build(
        drafts: _drafts,
        prior: _prior ?? RhythmPrior.notSure,
        now: _clock(),
      );

  List<PlannedDraft> get todayPlan =>
      plan.where((p) => p.dayOffset == 0).toList();

  List<PlannedDraft> get tomorrowPlan =>
      plan.where((p) => p.dayOffset == 1).toList();

  /// Dragging a block in the preview pins that task to a time on its day.
  void moveDraft(int index, {required int startMinute, required int dayOffset}) {
    if (index < 0 || index >= _drafts.length) return;
    final snapped = (startMinute / 15).round() * 15;
    final clamped = snapped.clamp(0, 24 * 60 - _drafts[index].durationMinutes);
    updateDraft(
      index,
      _drafts[index].copyWith(startMinute: clamped, dayOffset: dayOffset),
    );
  }

  // ── Step 4: nudge + finish ────────────────────────────────────────────

  /// Saves the plan and finishes. The permission prompt appears only when
  /// [wantsNudge] is true.
  Future<void> finish({required bool wantsNudge}) async {
    if (_saving || _finished) return;
    _saving = true;
    _wantsNudge = wantsNudge;
    notifyListeners();
    try {
      if (wantsNudge) {
        await effects.requestNotificationPermission();
      }
      await effects.setRemindersEnabled(wantsNudge);
      await effects.savePrior(_prior ?? RhythmPrior.notSure);
      final now = _clock();
      await effects.saveTasks(OnboardingPlan.toTasks(
        plan,
        now: now,
        idPrefix: 'ob${now.millisecondsSinceEpoch}',
      ));
      await effects.markDone();
      await effects.countCompleted();
      if (_startedAt != null) {
        await effects.recordTimeToFirstPlan(now.difference(_startedAt!));
      }
      _finished = true;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  /// "Skip" on the welcome step: no tasks, no prompts.
  Future<void> skip() async {
    await effects.markDone();
    _finished = true;
    notifyListeners();
  }
}
