import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import 'widgets/insights_ai_suggestion_card.dart';
import 'widgets/insights_data.dart';
import 'widgets/insights_focus_trend_card.dart';
import 'widgets/insights_greeting.dart';
import 'widgets/insights_mindfulness_card.dart';
import 'widgets/insights_productivity_score_card.dart';
import 'widgets/insights_reflection_image_card.dart';
import 'widgets/insights_sync_indicator.dart';
import 'widgets/insights_top_category_card.dart';
import 'widgets/insights_weekly_completion_card.dart';

/// InsightsPage — composes the individual card widgets under
/// features/insights/widgets/. Split from a single 688-line file in
/// Phase 5.1 of docs/DEVELOPMENT_PLAN.md.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final insightsCtrl = InsightsScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge(
          [TaskScope.of(context), JournalScope.of(context), insightsCtrl]),
      builder: (context, _) {
        final d = InsightsData.from(context);
        return ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: DzSpacing.lg, vertical: DzSpacing.md),
          children: [
            const InsightsGreeting(),
            const SizedBox(height: DzSpacing.lg),
            InsightsSyncIndicator(
              insightsController: insightsCtrl,
              showFullStatus: true,
            ),
            const SizedBox(height: DzSpacing.md),
            InsightsProductivityScoreCard(data: d),
            const SizedBox(height: DzSpacing.md),
            InsightsFocusTrendCard(data: d),
            const SizedBox(height: DzSpacing.md),
            InsightsWeeklyCompletionCard(data: d),
            const SizedBox(height: DzSpacing.md),
            const InsightsAiSuggestionCard(),
            const SizedBox(height: DzSpacing.md),
            const InsightsTopCategoryCard(),
            const SizedBox(height: DzSpacing.md),
            const InsightsMindfulnessCard(),
            const SizedBox(height: DzSpacing.md),
            const InsightsReflectionImageCard(),
            const SizedBox(height: DzSpacing.xl),
          ],
        );
      },
    );
  }
}
