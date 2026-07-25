import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';

/// The circular "Focus Score" / ZEN INDEX card on the Home page.
class HomeFocusScoreCard extends StatelessWidget {
  const HomeFocusScoreCard({
    super.key,
    required this.score,
    required this.hasTasks,
  });

  final int score;

  /// Whether the user has any tasks scheduled today — controls both the
  /// progress ring's fill (0 when empty) and the guidance message shown.
  final bool hasTasks;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      padding: const EdgeInsets.all(DzSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Focus Score',
                style: DzTextStyles.caption.copyWith(
                  color: DzColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: hasTasks ? score / 100 : 0,
                    strokeWidth: 10,
                    backgroundColor: DzColors.borderLight,
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontFamily: 'InterDisplay',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: DzColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    Text(
                      'ZEN INDEX',
                      style: DzTextStyles.small.copyWith(
                        letterSpacing: 0.8,
                        color: DzColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.md),
          Text(
            !hasTasks
                ? 'Add tasks to track your focus score.'
                : score >= AppConfig.excellentScoreThreshold
                    ? AppConfig.messageExcellent
                    : score >= AppConfig.goodScoreThreshold
                        ? AppConfig.messageGood
                        : AppConfig.messageNeedImprovement,
            style: DzTextStyles.body.copyWith(
              color: DzColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
