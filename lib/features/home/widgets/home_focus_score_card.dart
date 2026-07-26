import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';

/// The circular "Focus Score" / ZEN INDEX card on the Home page.
class HomeFocusScoreCard extends StatefulWidget {
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
  State<HomeFocusScoreCard> createState() => _HomeFocusScoreCardState();
}

class _HomeFocusScoreCardState extends State<HomeFocusScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(HomeFocusScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = IntTween(begin: oldWidget.score, end: widget.score)
          .animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut),
      );
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
                    value: widget.hasTasks ? _scoreAnimation.value / 100 : 0,
                    strokeWidth: 10,
                    backgroundColor: DzColors.borderLight,
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_scoreAnimation.value}',
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
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.md),
          Text(
            !widget.hasTasks
                ? 'Add tasks to track your focus score.'
                : _scoreAnimation.value >= AppConfig.excellentScoreThreshold
                    ? AppConfig.messageExcellent
                    : _scoreAnimation.value >= AppConfig.goodScoreThreshold
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
