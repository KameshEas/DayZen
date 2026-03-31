import '../../features/home/models/task_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Offline AI Day Optimizer
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
  static DayOptimizationResult optimise(List<DzTask> tasks) {
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
    // Start at 8:00 AM; pack tasks sequentially with 10-min micro-breaks
    // between high-focus items and 5-min gaps between lighter ones.
    int currentMinute = 8 * 60; // 8:00 AM
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
          ? 10
          : 5;
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
    final scheduled = endM - startM;
    if (scheduled > 0) return scheduled;
    return switch (task.priority) {
      TaskPriority.high => 90,
      TaskPriority.zen => 60,
      TaskPriority.routine => 30,
      TaskPriority.low => 20,
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
        ? '$hours h ${mins > 0 ? '${mins} min' : ''}' .trim()
        : '$mins min';

    final highCount =
        tasks.where((t) => t.priority == TaskPriority.high && !t.isCompleted).length;

    if (highCount > 2) {
      return 'You have $highCount high-priority items. '
          'I\'ve front-loaded them into your morning peak. '
          'Total focused time: $durationText.';
    }

    if (totalFocusMinutes > 240) {
      return 'Heavy day ahead ($durationText of focus). '
          'I\'ve ordered tasks to protect your energy — '
          'high-stakes work first, lighter items after lunch.';
    }

    return 'Balanced day: $durationText of focused work across $incomplete tasks. '
        'I\'ve sequenced them for steady, calm momentum.';
  }

  static String _breakRecommendation(int totalFocusMinutes) {
    if (totalFocusMinutes > 300) {
      return 'Schedule a 20-min break every 90 minutes. '
          'A short walk or breathing exercise will restore peak focus.';
    }
    if (totalFocusMinutes > 150) {
      return 'Take a 10-min mindful break around midday to sustain focus.';
    }
    return 'Light day — a short stretch or breathing exercise is enough.';
  }
}
