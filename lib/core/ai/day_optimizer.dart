import '../config/app_config.dart';
import '../domain/rhythm/energy_profile.dart';
import '../domain/rhythm/rhythm_scheduler.dart';
import '../../features/home/models/task_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Day Optimizer (rule-based)
//
// Runs entirely on-device with no network calls.  It analyses today's tasks
// and produces a prioritised schedule along with a short rationale for each
// suggestion — the same "AI-style" experience the README describes, without
// any external model dependency.
// ─────────────────────────────────────────────────────────────────────────────

/// A single suggestion produced by the optimiser.
class AiSuggestion {
  const AiSuggestion({
    required this.task,
    required this.suggestedSlot,
    required this.reason,
  });

  final DzTask task;

  /// Human-readable time slot, e.g. "9:00 AM – 10:30 AM".
  final String suggestedSlot;

  /// Short plain-English rationale.
  final String reason;
}

/// The full optimiser output for a day.
class DayOptimizationResult {
  const DayOptimizationResult({
    required this.suggestions,
    required this.summary,
    required this.focusTimeMinutes,
    required this.breakRecommendation,
  });

  final List<AiSuggestion> suggestions;
  final String summary;
  final int focusTimeMinutes;
  final String breakRecommendation;
}

/// Offline rule-based AI day optimizer.
class DayOptimizer {
  DayOptimizer._();

  /// Analyse [tasks] for today and return an optimised schedule.
  ///
  /// With a Rhythm [profile] the slots come from [RhythmScheduler] (focused
  /// work in your energy peaks, lighter work in the troughs, breaks after
  /// long heavy runs), starting no earlier than [now]. Without one, tasks are
  /// packed in priority order from [AppConfig.optimizerStartHour], as before.
  static DayOptimizationResult optimise(
    List<DzTask> tasks, {
    EnergyProfile? profile,
    DateTime? now,
  }) {
    if (tasks.isNotEmpty && profile != null) {
      return _optimiseWithRhythm(tasks, profile, now ?? DateTime.now());
    }
    if (tasks.isEmpty) {
      return const DayOptimizationResult(
        suggestions: [],
        summary: 'No tasks scheduled for today. Enjoy the breathing room!',
        focusTimeMinutes: 0,
        breakRecommendation: 'Use this time for a mindful, restorative break.',
      );
    }

    // ── Score each task ──────────────────────────────────────────────────────
    // Higher score → schedule earlier.
    //   Priority weight: High=4, Zen=3, Routine=2, Low=1
    //   Incomplete tasks are prioritised over completed ones.
    //   Mindful tasks are shifted toward late morning (natural focus window).
    final sorted = List<DzTask>.from(tasks)
      ..sort((a, b) {
        final pa = _priorityWeight(a.priority);
        final pb = _priorityWeight(b.priority);
        if (!a.isCompleted && b.isCompleted) return -1;
        if (a.isCompleted && !b.isCompleted) return 1;
        return pb.compareTo(pa);
      });

    // ── Slot assignment ──────────────────────────────────────────────────────
    // Start at configured hour; pack tasks sequentially with breaks
    int currentMinute = AppConfig.optimizerStartHour * 60;
    final suggestions = <AiSuggestion>[];

    for (final task in sorted) {
      final durationMinutes = _estimateDuration(task);
      final slotLabel = _slotLabel(currentMinute, currentMinute + durationMinutes);
      final reason = _reason(task, currentMinute);
      suggestions.add(AiSuggestion(
        task: task,
        suggestedSlot: slotLabel,
        reason: reason,
      ));
      final gap = task.priority == TaskPriority.high ||
              task.category == TaskCategory.mindful
          ? AppConfig.highPriorityGapMinutes
          : AppConfig.regularGapMinutes;
      currentMinute += durationMinutes + gap;
    }

    // ── Summary ──────────────────────────────────────────────────────────────
    final totalFocus = sorted
        .where((t) => !t.isCompleted)
        .fold<int>(0, (sum, t) => sum + _estimateDuration(t));

    final incomplete = sorted.where((t) => !t.isCompleted).length;
    final summary = _buildSummary(incomplete, totalFocus, sorted);

    final breakRec = _breakRecommendation(totalFocus);

    return DayOptimizationResult(
      suggestions: suggestions,
      summary: summary,
      focusTimeMinutes: totalFocus,
      breakRecommendation: breakRec,
    );
  }

  /// The Rhythm path. Every active task is a candidate to move (these are
  /// suggestions, not edits); done and let-go tasks keep their own slot and
  /// are listed after the plan.
  static DayOptimizationResult _optimiseWithRhythm(
    List<DzTask> tasks,
    EnergyProfile profile,
    DateTime now,
  ) {
    final active = tasks.where((t) => t.status == TaskStatus.active).toList();
    final finished = tasks.where((t) => t.status != TaskStatus.active).toList();
    final byId = {for (final t in active) t.id: t};

    final result = RhythmScheduler.schedule(
      items: [
        for (final t in active)
          ScheduleItem(
            id: t.id,
            durationMinutes: _estimateDuration(t),
            priority: SlotPriority.values.byName(t.priority.name),
            effort: t.effort ?? 2,
          ),
      ],
      profile: profile,
      dayStartMinute: AppConfig.optimizerStartHour * 60,
      notBeforeMinute: now.hour * 60 + now.minute,
    );

    final window = profile.sharpestWindow();
    final suggestions = <AiSuggestion>[
      for (final p in result.placed)
        AiSuggestion(
          task: byId[p.id]!,
          suggestedSlot: _slotLabel(p.startMinute, p.endMinute),
          reason: _rhythmReason(byId[p.id]!, profile, p.startMinute, window),
        ),
      for (final id in result.unplaceable)
        AiSuggestion(
          task: byId[id]!,
          suggestedSlot: 'Tomorrow',
          reason: 'No free stretch left today. Rolling it over is fine.',
        ),
      for (final t in finished)
        AiSuggestion(
          task: t,
          suggestedSlot: _slotLabel(
            t.startTime.hour * 60 + t.startTime.minute,
            t.startTime.hour * 60 + t.startTime.minute + _estimateDuration(t),
          ),
          reason: t.isCompleted ? 'Already done — great work!' : 'Let go for today.',
        ),
    ];

    final totalFocus = active.fold<int>(0, (s, t) => s + _estimateDuration(t));
    var summary = _buildSummary(active.length, totalFocus, active);
    if (active.isNotEmpty) {
      summary = '${_windowSentence(profile, window)} $summary';
    }
    var breakRec = _breakRecommendation(totalFocus);
    if (result.breaks.isNotEmpty) {
      final b = result.breaks.first;
      breakRec = 'Take a short break around '
          '${_slotLabel(b.startMinute, b.endMinute).split(' – ').first} '
          'after your longest stretch of heavy work.';
    }
    return DayOptimizationResult(
      suggestions: suggestions,
      summary: summary,
      focusTimeMinutes: totalFocus,
      breakRecommendation: breakRec,
    );
  }

  static String _windowSentence(EnergyProfile profile, HourWindow w) {
    final label = '${_hourLabel(w.startHour)}–${_hourLabel(w.endHour)}';
    return profile.isForming
        ? 'Your sharpest window: ~$label · forming.'
        : 'Your sharpest window: ~$label.';
  }

  static String _hourLabel(int hour) {
    final h = hour % 24;
    final suffix = h < 12 ? 'am' : 'pm';
    final display = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$display $suffix';
  }

  static String _rhythmReason(
    DzTask task,
    EnergyProfile profile,
    int startMinute,
    HourWindow window,
  ) {
    final hour = startMinute ~/ 60;
    final inPeak = hour >= window.startHour && hour < window.endHour;
    switch (task.priority) {
      case TaskPriority.high:
        return inPeak
            ? 'Focused work in your sharpest window.'
            : 'Focused work in the best free stretch left today.';
      case TaskPriority.zen:
        return 'A calm block while your energy is good.';
      case TaskPriority.routine:
      case TaskPriority.low:
        return 'Lighter task in a lower-energy stretch, keeping your peak free.';
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static int _priorityWeight(TaskPriority p) => switch (p) {
        TaskPriority.high => 4,
        TaskPriority.zen => 3,
        TaskPriority.routine => 2,
        TaskPriority.low => 1,
      };

  /// Estimate task duration in minutes from its scheduled start/end times,
  /// falling back to priority-based defaults.
  static int _estimateDuration(DzTask task) {
    final startM = task.startTime.hour * 60 + task.startTime.minute;
    final endM = task.endTime.hour * 60 + task.endTime.minute;
    // end < start is a genuine overnight span (e.g. Sleep 10:30 PM → 5:00 AM),
    // not an unscheduled task — only an exact start == end is treated as
    // "not really scheduled" and falls back to the priority default below.
    if (endM < startM) return (1440 - startM) + endM;
    final scheduled = endM - startM;
    if (scheduled > 0) return scheduled;
    return switch (task.priority) {
      TaskPriority.high => AppConfig.highPriorityDurationMinutes,
      TaskPriority.zen => AppConfig.zenDurationMinutes,
      TaskPriority.routine => AppConfig.routineDurationMinutes,
      TaskPriority.low => AppConfig.lowDurationMinutes,
    };
  }

  static String _slotLabel(int startMinute, int endMinute) {
    String fmt(int m) {
      final h = m ~/ 60 % 24;
      final min = m % 60;
      final suffix = h < 12 ? 'AM' : 'PM';
      final displayH = h == 0 ? 12 : h > 12 ? h - 12 : h;
      return '$displayH:${min.toString().padLeft(2, '0')} $suffix';
    }

    return '${fmt(startMinute)} – ${fmt(endMinute)}';
  }

  static String _reason(DzTask task, int startMinute) {
    final hour = startMinute ~/ 60;
    if (task.isCompleted) return 'Already done — great work!';

    if (task.priority == TaskPriority.high) {
      if (hour < 10) {
        return 'High-priority work placed in your peak morning focus window.';
      }
      return 'High-priority item moved as early as possible today.';
    }

    if (task.category == TaskCategory.mindful) {
      return 'Mindful activities are most effective in a calm mid-morning slot.';
    }

    if (task.priority == TaskPriority.zen) {
      return 'Zen tasks suit a relaxed, unhurried time block.';
    }

    if (task.priority == TaskPriority.low) {
      return 'Low-priority task placed after your core focus work.';
    }

    return 'Routine task sequenced to keep momentum flowing.';
  }

  static String _buildSummary(
      int incomplete, int totalFocusMinutes, List<DzTask> tasks) {
    if (incomplete == 0) {
      return 'All tasks are already complete — exceptional focus today!';
    }

    final hours = totalFocusMinutes ~/ 60;
    final mins = totalFocusMinutes % 60;
    final durationText = hours > 0
        ? '$hours h ${mins > 0 ? '$mins min' : ''}' .trim()
        : '$mins min';

    final highCount =
        tasks.where((t) => t.priority == TaskPriority.high && !t.isCompleted).length;

    if (highCount > 2) {
      return 'You have $highCount high-priority items. '
          'I\'ve front-loaded them into your morning peak. '
          'Total focused time: $durationText.';
    }

    if (totalFocusMinutes > AppConfig.heavyWorkloadThresholdMinutes) {
      return 'Heavy day ahead ($durationText of focus). '
          'I\'ve ordered tasks to protect your energy — '
          'high-stakes work first, lighter items after lunch.';
    }

    return 'Balanced day: $durationText of focused work across $incomplete ${incomplete == 1 ? 'task' : 'tasks'}. '
        'I\'ve sequenced them for steady, calm momentum.';
  }

  static String _breakRecommendation(int totalFocusMinutes) {
    if (totalFocusMinutes > AppConfig.breakRecommendationHighThreshold) {
      return AppConfig.breakRecommendationHigh;
    }
    if (totalFocusMinutes > AppConfig.breakRecommendationMediumThreshold) {
      return AppConfig.breakRecommendationMedium;
    }
    return AppConfig.breakRecommendationLight;
  }
}
