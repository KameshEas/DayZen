import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Small shared widgets used by multiple insights cards (Phase 5.1 of
// docs/DEVELOPMENT_PLAN.md — extracted from the former monolithic
// insights_page.dart).
// ─────────────────────────────────────────────────────────────────────────────

/// Section label used at the top of every Insights card.
class InsightsCardLabel extends StatelessWidget {
  const InsightsCardLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DzTextStyles.caption.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Background for small neutral chips and icon tiles: the light tint in light
/// mode, a raised dark surface in dark mode (the light tint glows on dark cards).
Color insightsNeutralTint(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DzColors.darkSurfaceHigh
        : DzColors.neutralTint;

/// A single bar in a week-bar-chart (used by both the Focus Trend and
/// Weekly Completion cards).
///
/// An empty day still draws a short, faint stub, so a week with no data reads
/// as "nothing yet" instead of a blank hole where the chart should be.
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

  static const double _emptyStub = 0.06;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = fraction <= 0;
    final color = highlight
        ? scheme.primary
        : (empty ? scheme.outline.withValues(alpha: 0.6) : DzColors.chartBarInactive);
    return Semantics(
      label: '$label, ${(fraction * 100).round()} percent',
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: empty ? _emptyStub : fraction.clamp(_emptyStub, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Text(
              label,
              style: DzTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
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
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
