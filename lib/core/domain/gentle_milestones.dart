/// Gentle milestones (plan M-1.13): small, cumulative markers that only ever
/// go up. No streaks, no daily targets, nothing that resets on a quiet day.
/// Pure Dart.
library;

class MilestoneStats {
  const MilestoneStats({
    this.tasksPlanned = 0,
    this.tasksDone = 0,
    this.tasksLetGo = 0,
    this.daysClosed = 0,
    this.journalEntries = 0,
    this.checkins = 0,
  });

  final int tasksPlanned;
  final int tasksDone;
  final int tasksLetGo;
  final int daysClosed;
  final int journalEntries;
  final int checkins;
}

class MilestoneDef {
  const MilestoneDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.value,
  });

  final String id;
  final String title;
  final String description;

  /// An emoji (the achievements page renders it as text).
  final String icon;
  final int target;
  final int Function(MilestoneStats s) value;
}

class MilestoneState {
  const MilestoneState(this.def, this.current);
  final MilestoneDef def;

  /// Capped at the target.
  final int current;
  bool get reached => current >= def.target;
}

class GentleMilestones {
  GentleMilestones._();

  static final List<MilestoneDef> all = [
    MilestoneDef(
      id: 'first-plan',
      title: 'First plan',
      description: 'Put one thing on your day.',
      icon: '🌱',
      target: 1,
      value: (s) => s.tasksPlanned,
    ),
    MilestoneDef(
      id: 'first-done',
      title: 'First thing done',
      description: 'Finish a task.',
      icon: '✅',
      target: 1,
      value: (s) => s.tasksDone,
    ),
    MilestoneDef(
      id: 'ten-done',
      title: 'Ten things done',
      description: 'Ten finished tasks, at your own pace.',
      icon: '🌿',
      target: 10,
      value: (s) => s.tasksDone,
    ),
    MilestoneDef(
      id: 'fifty-done',
      title: 'Fifty things done',
      description: 'Fifty finished tasks. No rush to get here.',
      icon: '🌳',
      target: 50,
      value: (s) => s.tasksDone,
    ),
    MilestoneDef(
      id: 'first-let-go',
      title: 'Let it go',
      description: 'Choosing what not to do counts too.',
      icon: '🍃',
      target: 1,
      value: (s) => s.tasksLetGo,
    ),
    MilestoneDef(
      id: 'first-close',
      title: 'First evening close',
      description: 'Close a day and note how it felt.',
      icon: '🌙',
      target: 1,
      value: (s) => s.daysClosed,
    ),
    MilestoneDef(
      id: 'seven-closes',
      title: 'Seven evenings',
      description: 'Close seven days, any seven.',
      icon: '✨',
      target: 7,
      value: (s) => s.daysClosed,
    ),
    MilestoneDef(
      id: 'first-entry',
      title: 'First reflection',
      description: 'Write a journal entry.',
      icon: '📓',
      target: 1,
      value: (s) => s.journalEntries,
    ),
    MilestoneDef(
      id: 'ten-entries',
      title: 'Ten reflections',
      description: 'Ten journal entries to look back on.',
      icon: '📚',
      target: 10,
      value: (s) => s.journalEntries,
    ),
    MilestoneDef(
      id: 'rhythm-shape',
      title: 'Rhythm taking shape',
      description: 'Ten energy check-ins help DayZen learn your day.',
      icon: '🌊',
      target: 10,
      value: (s) => s.checkins,
    ),
  ];

  static List<MilestoneState> evaluate(MilestoneStats stats) => [
        for (final d in all)
          MilestoneState(d, d.value(stats).clamp(0, d.target)),
      ];
}
