import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class DayOptimizerBreakCard extends StatelessWidget {
  const DayOptimizerBreakCard({super.key, required this.recommendation});
  final String recommendation;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      padding: const EdgeInsets.all(DzSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DzColors.zenGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.self_improvement_rounded,
                color: DzColors.zenGreen, size: 20),
          ),
          const SizedBox(width: DzSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Break Strategy',
                    style: DzTextStyles.label
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(recommendation,
                    style: DzTextStyles.body
                        .copyWith(color: DzColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
