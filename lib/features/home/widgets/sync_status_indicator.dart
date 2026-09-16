/// Sync status indicator with manual retry button.
library;

import 'package:flutter/material.dart';
import '../../../core/services/sync_manager.dart';
import '../../task_controller.dart';

/// Widget showing sync status and retry button.
class SyncStatusIndicator extends StatelessWidget {
  final TaskController taskController;
  final bool showFullStatus;

  const SyncStatusIndicator({
    super.key,
    required this.taskController,
    this.showFullStatus = false,
  });

  Future<void> _retry(BuildContext context) async {
    try {
      await SyncManager.instance.retrySyncTasks(taskController);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SyncManager.instance,
      builder: (context, _) {
        final isSyncing = SyncManager.instance.isSyncing;
        final status = SyncManager.instance.syncStatus;

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
                        'Sync Status',
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
                              Icons.cloud_done,
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
                  Semantics(
                    label: 'Retry sync',
                    button: true,
                    enabled: true,
                    onTap: () => _retry(context),
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _retry(context),
                      tooltip: 'Retry sync',
                    ),
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
                : Semantics(
                    label: 'Retry sync',
                    button: true,
                    enabled: true,
                    onTap: () => _retry(context),
                    child: IconButton(
                      icon: const Icon(Icons.cloud_done, size: 16),
                      onPressed: () => _retry(context),
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                      tooltip: 'Retry sync',
                    ),
                  ),
          ),
        );
      },
    );
  }
}
