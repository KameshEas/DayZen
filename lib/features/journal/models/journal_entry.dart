import 'package:flutter/material.dart';
import '../../../core/design_system/tokens/dz_colors.dart';

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
        JournalMood.happy => DzColors.zenGreen,
        JournalMood.peaceful => DzColors.primary,
        JournalMood.inspired => DzColors.warning,
        JournalMood.overwhelmed => DzColors.error,
      };

  Color get bg => switch (this) {
        JournalMood.happy => DzColors.successTint,
        JournalMood.peaceful => DzColors.skyTint,
        JournalMood.inspired => DzColors.warningTint,
        JournalMood.overwhelmed => DzColors.errorTint,
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

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    try {
      final moodStr = json['mood'] as String? ?? 'peaceful';
      JournalMood mood;
      try {
        mood = JournalMood.values.byName(moodStr);
      } catch (_) {
        mood = JournalMood.peaceful;
      }

      return JournalEntry(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Untitled Entry',
        body: json['body'] as String? ?? '',
        mood: mood,
        timestamp: json['timestampMs'] != null && json['timestampMs'] is int
            ? DateTime.fromMillisecondsSinceEpoch(json['timestampMs'] as int)
            : DateTime.now(),
        accentColor: json['accentColorValue'] != null && json['accentColorValue'] is int
            ? Color(json['accentColorValue'] as int)
            : null,
      );
    } catch (e) {
      return JournalEntry(
        id: json['id'] as String? ?? '',
        title: 'Error loading entry',
        body: 'Failed to parse journal entry',
        mood: JournalMood.peaceful,
        timestamp: DateTime.now(),
        accentColor: null,
      );
    }
  }
}
