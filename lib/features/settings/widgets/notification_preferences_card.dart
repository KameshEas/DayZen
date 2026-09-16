/// Notification preferences card for settings.
library;

import 'package:flutter/material.dart';
import '../../../core/services/notification_sync_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../notification_controller.dart';

/// Display and manage notification preferences.
class NotificationPreferencesCard extends StatefulWidget {
  final NotificationController notificationController;

  const NotificationPreferencesCard({
    super.key,
    required this.notificationController,
  });

  @override
  State<NotificationPreferencesCard> createState() =>
      _NotificationPreferencesCardState();
}

class _NotificationPreferencesCardState
    extends State<NotificationPreferencesCard> {
  @override
  void initState() {
    super.initState();
    widget.notificationController.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notificationController,
      builder: (context, _) {
        final prefs = widget.notificationController.preferences ?? [];

        return DzCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Notification Settings',
                    style: DzTextStyles.heading3.copyWith(
                      color: DzColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DzSpacing.md),
              if (prefs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DzSpacing.md),
                  child: Text(
                    'Loading notification settings...',
                    style: DzTextStyles.body.copyWith(
                      color: DzColors.textSecondary,
                    ),
                  ),
                )
              else
                ...prefs.map((pref) => _PreferenceToggle(
                      preference: pref,
                      onChanged: (enabled) =>
                          _updatePreference(pref, enabled),
                    )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updatePreference(
    NotificationPreference pref,
    bool enabled,
  ) async {
    final updated = NotificationPreference(
      id: pref.id,
      type: pref.type,
      enabled: enabled,
      minHour: pref.minHour,
      maxHour: pref.maxHour,
      channel: pref.channel,
      advanceMinutes: pref.advanceMinutes,
      updatedAt: pref.updatedAt,
    );

    final result = await widget.notificationController.updatePreference(
      pref.type,
      updated,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${pref.type} notifications')),
      );
    }
  }
}

/// Individual preference toggle.
class _PreferenceToggle extends StatelessWidget {
  final NotificationPreference preference;
  final Function(bool) onChanged;

  const _PreferenceToggle({
    required this.preference,
    required this.onChanged,
  });

  String _getLabel(String type) {
    return switch (type) {
      'task_reminder' => 'Task Reminders',
      'journal_prompt' => 'Journal Prompts',
      'ai_suggestion' => 'AI Suggestions',
      'deadline_alert' => 'Deadline Alerts',
      _ => type.replaceAll('_', ' ').toUpperCase(),
    };
  }

  String _getDescription(String type) {
    return switch (type) {
      'task_reminder' => 'Get reminded before tasks start',
      'journal_prompt' => 'Prompts to write in your journal',
      'ai_suggestion' => 'AI-powered recommendations',
      'deadline_alert' => 'Alerts for approaching deadlines',
      _ => 'Notification type: $type',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLabel(preference.type),
                  style: DzTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDescription(preference.type),
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: preference.enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
