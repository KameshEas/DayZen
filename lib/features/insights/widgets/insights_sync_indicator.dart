/// Insights sync status indicator with retry button.
library;

import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/insights_sync_manager.dart';
import '../../../core/services/jwt_auth_service.dart';
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
          const SnackBar(content: Text('Insights synced')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't sync insights. Try again in a moment.")),
        );
      }
    }
  }

  /// "Synced 5 min ago" / "Not synced yet" — the manager's raw status reworded.
  static String describe(String status, {required bool isSyncing}) {
    if (isSyncing) return 'Syncing…';
    switch (status) {
      case 'Sync error':
        return "Couldn't sync";
      case 'Never synced':
        return 'Not synced yet';
      case 'Just now':
        return 'Synced just now';
      default:
        return 'Synced $status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([insightsController, JwtAuthService.instance]),
      builder: (context, _) {
        final isSyncing = insightsController.isSyncing;
        final status = InsightsSyncManager.instance.syncStatus;

        if (showFullStatus) {
          // Syncing only means something for a signed-in account; offline, the
          // insights are simply calculated on this device.
          if (!JwtAuthService.instance.isAuthenticated) {
            return const SizedBox.shrink();
          }
          // The gap below belongs to the pill: signed out, nothing shows and no space is left.
          return Padding(
            padding: const EdgeInsets.only(bottom: DzSpacing.md),
            child: _SyncStatusPill(
              label: describe(status, isSyncing: isSyncing),
              isSyncing: isSyncing,
              failed: status == 'Sync error',
              onRetry: () => _retry(context),
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
                ? const DzSunLoader(width: 24)
                : Semantics(
                    label: 'Retry sync',
                    button: true,
                    enabled: true,
                    onTap: () => _retry(context),
                    child: IconButton(
                      icon: const Icon(Icons.analytics, size: 16),
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

class _SyncStatusPill extends StatelessWidget {
  const _SyncStatusPill({
    required this.label,
    required this.isSyncing,
    required this.failed,
    required this.onRetry,
  });

  final String label;
  final bool isSyncing;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone = failed ? DzColors.error : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.only(left: DzSpacing.md, right: DzSpacing.xs),
      constraints: const BoxConstraints(minHeight: DzSizing.minTouchTarget),
      decoration: BoxDecoration(
        color: failed ? DzColors.errorTint : scheme.surface,
        borderRadius: BorderRadius.circular(DzRadius.button),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          if (isSyncing)
            const DzSunLoader(width: 28)
          else
            Icon(
              failed ? Icons.cloud_off_rounded : Icons.cloud_done_outlined,
              size: 18,
              color: tone,
            ),
          const SizedBox(width: DzSpacing.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DzTextStyles.caption.copyWith(
                color: failed ? DzColors.error : scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isSyncing)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                minimumSize: const Size(DzSizing.minTouchTarget, DzSizing.minTouchTarget),
                padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
              ),
              child: Text(
                failed ? 'Retry' : 'Sync now',
                style: DzTextStyles.caption.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
