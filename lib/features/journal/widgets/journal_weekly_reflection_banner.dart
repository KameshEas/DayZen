import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';

class JournalWeeklyReflectionBanner extends StatelessWidget {
  const JournalWeeklyReflectionBanner({super.key, required this.count});
  final int count;

  String get _headline {
    if (count == 0) {
      return AppConfig.journalReflectionMessages[0] ?? AppConfig.journalReflectionDefault;
    } else if (count <= 2) {
      return AppConfig.journalReflectionMessages[2] ?? AppConfig.journalReflectionDefault;
    } else if (count <= 4) {
      return AppConfig.journalReflectionMessages[4] ?? AppConfig.journalReflectionDefault;
    }
    return AppConfig.journalReflectionDefault;
  }

  String get _subtitle {
    if (count == 0) {
      return AppConfig.journalSubtitleMessages[0] ?? 'Write your first entry today.';
    }
    return 'You\'ve logged $count entr${count == 1 ? 'y' : 'ies'} this week.\nConsistency is the key to mindfulness.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Stack(
        children: [
          const Positioned(
            right: 8,
            top: 4,
            child: Opacity(
              opacity: 0.18,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 80),
            ),
          ),
          const Positioned(
            right: 40,
            bottom: 4,
            child: Opacity(
              opacity: 0.12,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 48),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Reflection',
                style: DzTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _headline,
                style: DzTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: DzSpacing.sm),
              Text(
                _subtitle,
                style: DzTextStyles.body
                    .copyWith(color: Colors.white.withValues(alpha: 0.88)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
