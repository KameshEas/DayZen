/// AI-powered task recommendations card.
library;

import 'package:flutter/material.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../ai_optimization_controller.dart';

/// Display AI task recommendations for today.
class AIRecommendationsCard extends StatelessWidget {
  final AIOptimizationController aiController;

  const AIRecommendationsCard({
    super.key,
    required this.aiController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: aiController,
      builder: (context, _) {
        final recommendations = aiController.recommendations ?? [];

        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return DzCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Recommendations',
                    style: DzTextStyles.heading3.copyWith(
                      color: DzColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DzSpacing.md),
              ...recommendations.take(3).map((rec) => _RecommendationTile(
                    recommendation: rec,
                  )),
              if (recommendations.length > 3) ...[
                const SizedBox(height: DzSpacing.sm),
                Text(
                  '+${recommendations.length - 3} more',
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Individual recommendation tile.
class _RecommendationTile extends StatelessWidget {
  final TaskRecommendation recommendation;

  const _RecommendationTile({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: DzTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.reason,
                      style: DzTextStyles.caption.copyWith(
                        color: DzColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ConfidenceBadge(
                score: recommendation.confidenceScore,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SuggestedTimeChip(recommendation: recommendation),
        ],
      ),
    );
  }
}

/// Confidence score badge.
class _ConfidenceBadge extends StatelessWidget {
  final double score; // 0-1.0

  const _ConfidenceBadge({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).toInt();
    final color = score > 0.8
        ? const Color(0xFF10B981) // green
        : score > 0.6
            ? const Color(0xFFF59E0B) // orange
            : const Color(0xFFEF4444); // red

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$percentage%',
        style: DzTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Suggested time chip.
class _SuggestedTimeChip extends StatelessWidget {
  final TaskRecommendation recommendation;

  const _SuggestedTimeChip({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final hour = recommendation.suggestedStartHour;
    final minute = recommendation.suggestedStartMinute;
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DzColors.appBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: DzColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 14),
          const SizedBox(width: 4),
          Text(
            'Suggested: $timeStr',
            style: DzTextStyles.caption.copyWith(
              color: DzColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
