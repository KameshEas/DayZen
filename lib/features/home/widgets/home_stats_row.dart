import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// "Focus Time" + "Zen Sessions" stat cards, shown side by side on the
/// Home page.
class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({
    super.key,
    required this.focusLabel,
    required this.zenSessionsCount,
  });

  final String focusLabel;
  final int zenSessionsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DzCard(
            padding: const EdgeInsets.all(DzSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(DzRadius.small),
                  ),
                  child: Icon(Icons.timer_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                const SizedBox(height: DzSpacing.sm),
                Text(
                  'Focus Time',
                  style: DzTextStyles.small
                      .copyWith(color: DzColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  focusLabel,
                  style: DzTextStyles.heading2.copyWith(
                    color: DzColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: DzSpacing.md),
        Expanded(
          child: DzCard(
            padding: const EdgeInsets.all(DzSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DzColors.zenGreen.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(DzRadius.small),
                  ),
                  child: const Icon(Icons.self_improvement_rounded,
                      color: DzColors.zenGreen, size: 20),
                ),
                const SizedBox(height: DzSpacing.sm),
                Text(
                  'Zen Sessions',
                  style: DzTextStyles.small
                      .copyWith(color: DzColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '$zenSessionsCount',
                  style: DzTextStyles.heading2.copyWith(
                    color: DzColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
