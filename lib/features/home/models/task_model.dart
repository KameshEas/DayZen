import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Task model
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

class DzTask {
  DzTask({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.priority = TaskPriority.routine,
    this.icon,
    this.subtitle,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TaskPriority priority;
  final IconData? icon;
  final String? subtitle;
  bool isCompleted;

  String get timeRange {
    String fmt(TimeOfDay t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final m = t.minute.toString().padLeft(2, '0');
      final period = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$h:$m $period';
    }

    return '${fmt(startTime)} — ${fmt(endTime)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Planner event model
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
    this.isEmpty = false,
  });

  final String title;
  final String subtitle;
  final int hour;
  final int minute;
  final int durationMinutes;
  final Color accentColor;
  final IconData icon;
  final bool isCompleted;
  final bool isEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────────────────────

class DzMockData {
  static final todayTasks = [
    DzTask(
      id: '1',
      title: 'Deep Work: Design Review',
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 30),
      priority: TaskPriority.high,
      icon: Icons.work_outline_rounded,
    ),
    DzTask(
      id: '2',
      title: 'Mindful Walk',
      startTime: const TimeOfDay(hour: 12, minute: 0),
      endTime: const TimeOfDay(hour: 12, minute: 30),
      priority: TaskPriority.zen,
      icon: Icons.directions_walk_rounded,
    ),
    DzTask(
      id: '3',
      title: 'Email Batching',
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 14, minute: 45),
      priority: TaskPriority.routine,
      icon: Icons.mail_outline_rounded,
    ),
  ];

  static const plannerEvents = [
    PlannerEvent(
      title: 'Morning Stretch',
      subtitle: 'Done at 8:15 AM',
      hour: 8,
      minute: 0,
      durationMinutes: 30,
      accentColor: Color(0xFF10B981),
      icon: Icons.wb_sunny_outlined,
      isCompleted: true,
    ),
    PlannerEvent(
      title: 'Deep Work: UI System',
      subtitle: 'Focus Session • 9:00 - 11:30',
      hour: 9,
      minute: 0,
      durationMinutes: 150,
      accentColor: Color(0xFF3B82F6),
      icon: Icons.work_outline_rounded,
    ),
    PlannerEvent(
      title: 'Coffee & Reflection',
      subtitle: '15 min mindful break',
      hour: 11,
      minute: 0,
      durationMinutes: 15,
      accentColor: Color(0xFFF59E0B),
      icon: Icons.coffee_rounded,
    ),
    PlannerEvent(
      title: 'Schedule Lunch',
      subtitle: '',
      hour: 12,
      minute: 0,
      durationMinutes: 60,
      accentColor: Color(0xFFCBD5E1),
      icon: Icons.add_circle_outline_rounded,
      isEmpty: true,
    ),
    PlannerEvent(
      title: 'Sync Meeting',
      subtitle: 'Project Phoenix Update',
      hour: 13,
      minute: 0,
      durationMinutes: 60,
      accentColor: Color(0xFF3B82F6),
      icon: Icons.group_outlined,
    ),
    PlannerEvent(
      title: 'Meditation',
      subtitle: 'Offline Session',
      hour: 14,
      minute: 0,
      durationMinutes: 30,
      accentColor: Color(0xFF10B981),
      icon: Icons.self_improvement_rounded,
    ),
  ];
}
