import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Journal mood
// ─────────────────────────────────────────────────────────────────────────────

enum JournalMood { happy, peaceful, inspired, overwhelmed }

extension JournalMoodX on JournalMood {
  IconData get icon => switch (this) {
        JournalMood.happy => Icons.sentiment_very_satisfied_rounded,
        JournalMood.peaceful => Icons.self_improvement_rounded,
        JournalMood.inspired => Icons.lightbulb_outline_rounded,
        JournalMood.overwhelmed => Icons.sentiment_dissatisfied_rounded,
      };

  Color get iconColor => switch (this) {
        JournalMood.happy => const Color(0xFF10B981),
        JournalMood.peaceful => const Color(0xFF3B82F6),
        JournalMood.inspired => const Color(0xFFF59E0B),
        JournalMood.overwhelmed => const Color(0xFFEF4444),
      };

  Color get bg => switch (this) {
        JournalMood.happy => const Color(0xFFD1FAE5),
        JournalMood.peaceful => const Color(0xFFDBEAFE),
        JournalMood.inspired => const Color(0xFFFEF3C7),
        JournalMood.overwhelmed => const Color(0xFFFEE2E2),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Journal entry model
// ─────────────────────────────────────────────────────────────────────────────

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.timestamp,
    this.accentColor,
  });

  final String id;
  final String title;
  final String body;
  final JournalMood mood;
  final DateTime timestamp;
  final Color? accentColor;

  /// Human-friendly label derived from timestamp.
  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(
        timestamp.year, timestamp.month, timestamp.day);
    final diff = today.difference(entryDay).inDays;

    final h = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final m = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$h:$m $period';

    if (diff == 0) return 'Today, $timeStr';
    if (diff == 1) return 'Yesterday, $timeStr';

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[timestamp.month]} ${timestamp.day}, $timeStr';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'mood': mood.name,
        'timestampMs': timestamp.millisecondsSinceEpoch,
        'accentColorValue': accentColor?.toARGB32(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        mood: JournalMood.values.byName(json['mood'] as String),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            json['timestampMs'] as int),
        accentColor: json['accentColorValue'] != null
            ? Color(json['accentColorValue'] as int)
            : null,
      );
}
