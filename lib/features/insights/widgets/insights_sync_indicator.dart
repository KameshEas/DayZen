/// Insights sync status indicator with retry button.
library;

import 'package:flutter/material.dart';
import '../../../core/services/insights_sync_manager.dart';
import '../../insights_controller.dart';

/// Widget showing insights sync status and retry button.
class InsightsSyncIndicator extends StatelessWidget {
  final InsightsController insightsController;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showFullStatus;

  const InsightsSyncIndicator({
    super.key,
    required this.insightsController,
    this.startDate,
    this.endDate,
    this.showFullStatus = false,
  });

  Future<void> _retry(BuildContext context) async {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = endDate ?? now;

    try {
      await insightsController.retrySyncInsights(
        startDate: start,
        endDate: end,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insights sync completed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insights sync failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: insightsController,
      builder: (context, _) {
        final isSyncing = insightsController.isSyncing;
        final status = InsightsSyncManager.instance.syncStatus;

        if (showFullStatus) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insights Status',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (isSyncing)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.analytics,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              status,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isSyncing)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _retry(context),
                    tooltip: 'Retry sync',
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          );
        }

        // Compact indicator
        return Tooltip(
          message: status,
          child: SizedBox(
            width: 24,
            height: 24,
            child: isSyncing
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).primaryColor,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.analytics, size: 16),
                    onPressed: () => _retry(context),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    tooltip: 'Retry sync',
                  ),
          ),
        );
      },
    );
  }
}
