/// Notification delivery history card.
library;

import 'package:flutter/material.dart';
import '../../../core/services/notification_sync_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../notification_controller.dart';

/// Display notification delivery history.
class NotificationHistoryCard extends StatefulWidget {
  final NotificationController notificationController;

  const NotificationHistoryCard({
    super.key,
    required this.notificationController,
  });

  @override
  State<NotificationHistoryCard> createState() =>
      _NotificationHistoryCardState();
}

class _NotificationHistoryCardState extends State<NotificationHistoryCard> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await widget.notificationController.loadDeliveryHistory(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notificationController,
      builder: (context, _) {
        final history = widget.notificationController.deliveryHistory ?? [];
        final delivered = history.where((n) => n.status == 'delivered').length;
        final failed = history.where((n) => n.status == 'failed').length;

        return DzCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Notification History',
                    style: DzTextStyles.heading3.copyWith(
                      color: DzColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DzSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatTile(
                    label: 'Total',
                    value: history.length.toString(),
                  ),
                  _StatTile(
                    label: 'Delivered',
                    value: delivered.toString(),
                    color: DzColors.success,
                  ),
                  _StatTile(
                    label: 'Failed',
                    value: failed.toString(),
                    color: DzColors.error,
                  ),
                ],
              ),
              if (history.isNotEmpty) ...[
                const SizedBox(height: DzSpacing.md),
                const Divider(),
                const SizedBox(height: DzSpacing.sm),
                Text(
                  'Recent Notifications',
                  style: DzTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DzColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DzSpacing.sm),
                ...history.take(5).map((notif) => _HistoryTile(
                      notification: notif,
                      onMarkRead: () =>
                          widget.notificationController.markAsRead(notif.id),
                    )),
                if (history.length > 5) ...[
                  const SizedBox(height: DzSpacing.sm),
                  Text(
                    '+${history.length - 5} more notifications',
                    style: DzTextStyles.caption.copyWith(
                      color: DzColors.textSecondary,
                    ),
                  ),
                ],
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DzSpacing.md),
                  child: Text(
                    'No notifications yet',
                    style: DzTextStyles.body.copyWith(
                      color: DzColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Stat tile showing a metric.
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatTile({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: DzTextStyles.heading2.copyWith(
            color: color ?? DzColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: DzTextStyles.caption.copyWith(
            color: DzColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Individual notification history tile.
class _HistoryTile extends StatelessWidget {
  final NotificationDelivery notification;
  final VoidCallback onMarkRead;

  const _HistoryTile({
    required this.notification,
    required this.onMarkRead,
  });

  Color _getStatusColor() {
    return switch (notification.status) {
      'delivered' => DzColors.success,
      'failed' => DzColors.error,
      'read' => DzColors.primary,
      _ => DzColors.textSecondary,
    };
  }

  IconData _getStatusIcon() {
    return switch (notification.status) {
      'delivered' => Icons.check_circle_outline,
      'failed' => Icons.error_outline,
      'read' => Icons.done_all,
      _ => Icons.schedule,
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = notification.deliveredTime?.toString().split('.')[0] ??
        notification.scheduledTime.toString().split('.')[0];

    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: DzTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeStr.split(' ').last,
            style: DzTextStyles.small.copyWith(
              color: DzColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
