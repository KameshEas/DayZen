import 'package:flutter/material.dart';
import '../../../core/design_system/tokens/dz_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Task priority
// ─────────────────────────────────────────────────────────────────────────────

enum TaskPriority { high, zen, routine, low }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.high => 'HIGH',
        TaskPriority.zen => 'ZEN',
        TaskPriority.routine => 'ROUTINE',
        TaskPriority.low => 'LOW',
      };

  Color get color => switch (this) {
        TaskPriority.high => DzColors.error,
        TaskPriority.zen => DzColors.zenGreen,
        TaskPriority.routine => DzColors.slateGray,
        TaskPriority.low => DzColors.primary,
      };

  Color get bg => switch (this) {
        TaskPriority.high => DzColors.errorTint,
        TaskPriority.zen => DzColors.successTint,
        TaskPriority.routine => DzColors.neutralTint,
        TaskPriority.low => DzColors.skyTint,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Task category
// ─────────────────────────────────────────────────────────────────────────────

enum TaskCategory { work, personal, mindful, study }

extension TaskCategoryX on TaskCategory {
  String get label => switch (this) {
        TaskCategory.work => 'Work',
        TaskCategory.personal => 'Personal',
        TaskCategory.mindful => 'Mindful',
        TaskCategory.study => 'Study',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Task status
// ─────────────────────────────────────────────────────────────────────────────

/// `released` = let go on purpose (Close the Day). Neither done nor carried.
enum TaskStatus { active, done, released }

// ─────────────────────────────────────────────────────────────────────────────
// Task model
// ─────────────────────────────────────────────────────────────────────────────

class DzTask {
  DzTask({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.priority = TaskPriority.routine,
    TaskCategory? category,
    this.icon,
    this.subtitle,
    TaskStatus? status,
    bool isCompleted = false,
    this.completedAt,
    this.rolloverCount = 0,
    this.effort,
    DateTime? originalDate,
    DateTime? date,
  })  : _category = category ?? TaskCategory.work,
        status = status ?? (isCompleted ? TaskStatus.done : TaskStatus.active),
        originalDate = originalDate == null ? null : _midnight(originalDate),
        date = _midnight(date ?? DateTime.now());

  final String id;
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TaskPriority priority;
  // Backed by a nullable field so old persisted tasks (without this field)
  // and hot-reload binary mismatches never cause a null-dereference crash.
  final TaskCategory? _category;
  TaskCategory get category => _category ?? TaskCategory.work;
  final IconData? icon;
  final String? subtitle;

  final TaskStatus status;
  bool get isCompleted => status == TaskStatus.done;

  /// Set when the task becomes done, cleared when it leaves done.
  final DateTime? completedAt;

  /// Days Gentle Rollover has carried this task forward.
  final int rolloverCount;

  /// 1 (light) to 3 (heavy); null = not set.
  final int? effort;

  /// The date first planned for, set on the first rollover. Midnight.
  final DateTime? originalDate;

  /// Normalised to midnight (date only, no time component).
  final DateTime date;

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  bool isSameDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;

  String get timeRange {
    String fmt(TimeOfDay t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final m = t.minute.toString().padLeft(2, '0');
      final period = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$h:$m $period';
    }
    return '${fmt(startTime)} — ${fmt(endTime)}';
  }

  /// [isCompleted] is shorthand for done/active; un-completing a released
  /// task leaves it released. Entering done stamps [completedAt] with [now]
  /// (default: the current time); leaving done clears it.
  DzTask copyWith({
    String? title,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    TaskPriority? priority,
    TaskCategory? category,
    IconData? icon,
    bool? isCompleted,
    TaskStatus? status,
    DateTime? date,
    int? rolloverCount,
    DateTime? originalDate,
    DateTime? now,
  }) {
    final next = status ??
        switch (isCompleted) {
          null => this.status,
          true => TaskStatus.done,
          false =>
            this.status == TaskStatus.done ? TaskStatus.active : this.status,
        };
    final DateTime? nextCompletedAt;
    if (next != TaskStatus.done) {
      nextCompletedAt = null;
    } else if (this.status != TaskStatus.done) {
      nextCompletedAt = now ?? DateTime.now();
    } else {
      nextCompletedAt = completedAt;
    }
    return DzTask(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      category: category ?? _category,
      icon: icon ?? this.icon,
      subtitle: subtitle,
      status: next,
      completedAt: nextCompletedAt,
      rolloverCount: rolloverCount ?? this.rolloverCount,
      effort: effort,
      originalDate: originalDate ?? this.originalDate,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'endHour': endTime.hour,
        'endMinute': endTime.minute,
        'priority': priority.name,
        'category': category.name,
        'iconCode': icon?.codePoint,
        'subtitle': subtitle,
        'isCompleted': isCompleted,
        'status': status.name,
        'completedAtMs': completedAt?.millisecondsSinceEpoch,
        'rolloverCount': rolloverCount,
        'effort': effort,
        'originalDateMs': originalDate?.millisecondsSinceEpoch,
        'dateMs': date.millisecondsSinceEpoch,
      };

  static DateTime? _dateFromMs(Object? ms) =>
      ms is int ? DateTime.fromMillisecondsSinceEpoch(ms) : null;

  factory DzTask.fromJson(Map<String, dynamic> json) {
    try {
      final priorityStr = json['priority'] as String? ?? 'routine';
      final categoryStr = json['category'] as String? ?? 'work';

      TaskPriority priority;
      try {
        priority = TaskPriority.values.byName(priorityStr);
      } catch (_) {
        priority = TaskPriority.routine;
      }

      TaskCategory category;
      try {
        category = TaskCategory.values.byName(categoryStr);
      } catch (_) {
        category = TaskCategory.work;
      }

      return DzTask(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Untitled Task',
        startTime: TimeOfDay(
          hour: (json['startHour'] as int?) ?? 9,
          minute: (json['startMinute'] as int?) ?? 0,
        ),
        endTime: TimeOfDay(
          hour: (json['endHour'] as int?) ?? 10,
          minute: (json['endMinute'] as int?) ?? 0,
        ),
        priority: priority,
        category: category,
        icon: json['iconCode'] != null && json['iconCode'] is int
            ? IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons')
            : null,
        subtitle: json['subtitle'] as String?,
        status: TaskStatus.values.asNameMap()[json['status']],
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: _dateFromMs(json['completedAtMs']),
        rolloverCount: json['rolloverCount'] as int? ?? 0,
        effort: json['effort'] as int?,
        originalDate: _dateFromMs(json['originalDateMs']),
        date: json['dateMs'] != null && json['dateMs'] is int
            ? DateTime.fromMillisecondsSinceEpoch(json['dateMs'] as int)
            : DateTime.now(),
      );
    } catch (e) {
      return DzTask(
        id: json['id'] as String? ?? '',
        title: 'Error loading task',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        priority: TaskPriority.routine,
        category: TaskCategory.work,
        icon: null,
        subtitle: 'Failed to parse task',
        isCompleted: false,
        date: DateTime.now(),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Planner event — lightweight view model derived from DzTask
// ─────────────────────────────────────────────────────────────────────────────

class PlannerEvent {
  const PlannerEvent({
    required this.title,
    required this.subtitle,
    required this.hour,
    required this.minute,
    required this.durationMinutes,
    required this.accentColor,
    required this.icon,
    this.isCompleted = false,
    this.isReleased = false,
    this.taskIds = const [],
  });

  final String title;
  final String subtitle;
  final int hour;
  final int minute;
  final int durationMinutes;
  final Color accentColor;
  final IconData icon;
  final bool isCompleted;

  /// Let go on purpose: drawn faded, never as a failure.
  final bool isReleased;

  /// The tasks this card stands for (more than one when identical tasks were
  /// merged into one card by the timeline layout).
  final List<String> taskIds;

  PlannerEvent copyWith({
    bool? isCompleted,
    bool? isReleased,
    List<String>? taskIds,
  }) =>
      PlannerEvent(
        title: title,
        subtitle: subtitle,
        hour: hour,
        minute: minute,
        durationMinutes: durationMinutes,
        accentColor: accentColor,
        icon: icon,
        isCompleted: isCompleted ?? this.isCompleted,
        isReleased: isReleased ?? this.isReleased,
        taskIds: taskIds ?? this.taskIds,
      );

  factory PlannerEvent.fromTask(DzTask task) {
    final startMins = task.startTime.hour * 60 + task.startTime.minute;
    final endMins = task.endTime.hour * 60 + task.endTime.minute;
    return PlannerEvent(
      title: task.title,
      subtitle: task.timeRange,
      hour: task.startTime.hour,
      minute: task.startTime.minute,
      durationMinutes: (endMins - startMins).clamp(15, 480),
      accentColor: task.priority.color,
      icon: task.icon ?? Icons.circle_outlined,
      isCompleted: task.isCompleted,
      isReleased: task.status == TaskStatus.released,
      taskIds: [task.id],
    );
  }
}
