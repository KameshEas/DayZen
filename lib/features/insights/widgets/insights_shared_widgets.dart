import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Small shared widgets used by multiple insights cards (Phase 5.1 of
// docs/DEVELOPMENT_PLAN.md â€” extracted from the former monolithic
// insights_page.dart).
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// A single bar in a week-bar-chart (used by both the Focus Trend and
/// Weekly Completion cards).
class InsightsBar extends StatelessWidget {
  const InsightsBar({
    super.key,
    required this.fraction,
    required this.label,
    this.highlight = false,
  });
  final double fraction;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: FractionallySizedBox(
            heightFactor: fraction,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: highlight ? Theme.of(context).colorScheme.primary : DzColors.chartBarInactive,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: DzTextStyles.caption.copyWith(
              fontSize: 9,
              color: DzColors.textSecondary,
            )),
      ],
    );
  }
}

/// Thin rounded progress bar (used by both the Top Category and
/// Mindfulness cards).
class InsightsProgressBar extends StatelessWidget {
  const InsightsProgressBar({super.key, required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: DzColors.borderLight,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}



