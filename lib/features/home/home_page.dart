import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../../core/routing/route_paths.dart';
import '../../core/utils/date_formatter.dart';
import '../app_data.dart';
import '../task_controller.dart';
import 'models/task_model.dart';
import 'widgets/ai_recommendations_card.dart';
import 'widgets/home_daily_reflection_card.dart';
import 'widgets/home_focus_score_card.dart';
import 'widgets/home_greeting_header.dart';
import 'widgets/home_stats_row.dart';
import 'widgets/sync_status_indicator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage — composes the individual card widgets under
// features/home/widgets/. Split from a single 409-line file in Phase 5.1
// of docs/DEVELOPMENT_PLAN.md. Also removed `_showAddTaskSheet`/`_TaskItem`
// here — confirmed genuinely dead code (zero references anywhere in the
// codebase) flagged since the docs/BASELINE_METRICS.md Phase 0 audit and
// explicitly deferred to this phase rather than fixed opportunistically.
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = TaskScope.of(context);
    return ListenableBuilder(
      listenable: taskCtrl,
      builder: (context, _) => _HomeBody(taskCtrl: taskCtrl),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.taskCtrl});
  final TaskController taskCtrl;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < AppConfig.morningHourThreshold
        ? AppConfig.greetingMorning
        : hour < AppConfig.afternoonHourThreshold
            ? AppConfig.greetingAfternoon
            : AppConfig.greetingEvening;

    final dateLabel = DateFormatter.formatDate(now);

    final tasks = taskCtrl.forDate(now);
    final remaining = tasks.where((t) => !t.isCompleted).length;
    final score = taskCtrl.todayScore;
    final focusLabel = taskCtrl.todayFocusLabel;
    final zenDone = tasks
        .where((t) => t.priority == TaskPriority.zen && t.isCompleted)
        .length;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: DzSpacing.md,
        vertical: DzSpacing.md,
      ),
      children: [
        const SizedBox(height: DzSpacing.sm),
        HomeGreetingHeader(
          dateLabel: dateLabel,
          greeting: greeting,
          subtitle: remaining == 0 && tasks.isNotEmpty
              ? 'All tasks done. Great work!'
              : 'You have $remaining task${remaining == 1 ? '' : 's'} remaining.',
        ),
        const SizedBox(height: DzSpacing.lg),
        if (tasks.isEmpty)
          DzEmptyState(
            icon: Icons.task_alt_outlined,
            title: "You're all set for today",
            subtitle: 'No tasks scheduled. Create one to get started.',
            actionLabel: 'Add a task',
            onAction: () => context.push(RoutePaths.newTask),
          )
        else ...[
          SyncStatusIndicator(
            taskController: taskCtrl,
            showFullStatus: true,
          ),
          const SizedBox(height: DzSpacing.md),
          AIRecommendationsCard(
            aiController: AIOptimizationScope.of(context),
          ),
          const SizedBox(height: DzSpacing.md),
          HomeFocusScoreCard(score: score, hasTasks: tasks.isNotEmpty),
          const SizedBox(height: DzSpacing.md),
          HomeStatsRow(focusLabel: focusLabel, zenSessionsCount: zenDone),
          const SizedBox(height: DzSpacing.md),
          const HomeDailyReflectionCard(),
        ],
        const SizedBox(height: DzSpacing.xl),
      ],
    );
  }
}
