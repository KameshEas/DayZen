import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/journal_analytics.dart';
import '../../app_data.dart';

/// "What lifts you" (plan M-4.1). Shows only real patterns (8+ days per
/// category) and only in positive terms; until then it isn't shown at all.
class LiftsYouCard extends StatelessWidget {
  const LiftsYouCard({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = JournalAnalytics.liftsYou(
      JournalScope.of(context).all,
      TaskScope.of(context).all,
    );
    if (insights.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.md),
      child: DzCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, size: 18, color: scheme.primary),
                const SizedBox(width: DzSpacing.sm),
                Semantics(
                  header: true,
                  child: Text('What lifts you',
                      style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.sm),
            for (final i in insights.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: DzSpacing.xs),
                child: Text(i.sentence, style: DzTextStyles.body),
              ),
            Text(
              'From the moods you noted on days you finished these.',
              style: DzTextStyles.small.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
