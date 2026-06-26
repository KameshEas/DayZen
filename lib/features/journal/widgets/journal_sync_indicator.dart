/// Journal sync status indicator with retry button.
library;

import 'package:flutter/material.dart';
import '../../../core/services/journal_sync_manager.dart';
import '../../journal_controller.dart';

/// Widget showing journal sync status and retry button.
class JournalSyncIndicator extends StatelessWidget {
  final JournalController journalController;
  final bool showFullStatus;

  const JournalSyncIndicator({
    super.key,
    required this.journalController,
    this.showFullStatus = false,
  });

  Future<void> _retry(BuildContext context) async {
    try {
      await JournalSyncManager.instance.retrySyncEntries(journalController);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal sync completed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Journal sync failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: JournalSyncManager.instance,
      builder: (context, _) {
        final isSyncing = JournalSyncManager.instance.isSyncing;
        final status = JournalSyncManager.instance.syncStatus;

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
                    icon: const Icon(Icons.cloud_done, size: 16),
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
