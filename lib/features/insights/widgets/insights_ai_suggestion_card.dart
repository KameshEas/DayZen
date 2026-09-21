import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// A tip drawn from the user's own completion history. Shown only once there is
/// a real pattern to point at (see [InsightsData.suggestion]); it never shows
/// invented advice.
class InsightsAiSuggestionCard extends StatelessWidget {
  const InsightsAiSuggestionCard({super.key, required this.suggestion});
  final String suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: DzSpacing.md),
              Expanded(
                child: Text(
                  'Zen suggestion',
                  style: DzTextStyles.heading3.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          Text(
            suggestion,
            style: DzTextStyles.body
                .copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}
