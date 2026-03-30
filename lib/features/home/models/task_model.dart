import 'package:flutter/material.dart';

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
        TaskPriority.high => const Color(0xFFEF4444),
        TaskPriority.zen => const Color(0xFF10B981),
        TaskPriority.routine => const Color(0xFF94A3B8),
        TaskPriority.low => const Color(0xFF3B82F6),
      };

  Color get bg => switch (this) {
        TaskPriority.high => const Color(0xFFFEE2E2),
        TaskPriority.zen => const Color(0xFFD1FAE5),
        TaskPriority.routine => const Color(0xFFF1F5F9),
        TaskPriority.low => const Color(0xFFDBEAFE),
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
    this.isCompleted = false,
    DateTime? date,
  })  : _category = category ?? TaskCategory.work,
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
  bool isCompleted;
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

  DzTask copyWith({bool? isCompleted}) => DzTask(
        id: id,
        title: title,
        startTime: startTime,
        endTime: endTime,
        priority: priority,
        category: _category,
        icon: icon,
        subtitle: subtitle,
        isCompleted: isCompleted ?? this.isCompleted,
        date: date,
      );

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
        'dateMs': date.millisecondsSinceEpoch,
      };

  factory DzTask.fromJson(Map<String, dynamic> json) => DzTask(
        id: json['id'] as String,
        title: json['title'] as String,
        startTime: TimeOfDay(
            hour: json['startHour'] as int,
            minute: json['startMinute'] as int),
        endTime: TimeOfDay(
            hour: json['endHour'] as int, minute: json['endMinute'] as int),
        priority: TaskPriority.values.byName(json['priority'] as String),
        category: json['category'] != null
            ? TaskCategory.values.byName(json['category'] as String)
            : TaskCategory.work,
        icon: json['iconCode'] != null
            ? IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons')
            : null,
        subtitle: json['subtitle'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        date: json['dateMs'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['dateMs'] as int)
            : DateTime.now(),
      );
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
  });

  final String title;
  final String subtitle;
  final int hour;
  final int minute;
  final int durationMinutes;
  final Color accentColor;
  final IconData icon;
  final bool isCompleted;

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
    );
  }
}
