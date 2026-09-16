import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class InsightsAiSuggestionCard extends StatelessWidget {
  const InsightsAiSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                'Zen AI Suggestion',
                style: DzTextStyles.heading3.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          Text(
            'Based on your peak performance hours, we suggest moving your '
            '"Deep Work" block to 9:00 AM instead of 2:00 PM for optimal focus.',
            style: DzTextStyles.body
                .copyWith(color: Colors.white.withValues(alpha: 0.88)),
          ),
          const SizedBox(height: DzSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DzRadius.button),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {},
              child: const Text('Adjust My Planner',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
