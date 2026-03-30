import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../app_data.dart';
import '../task_controller.dart';
import '../tasks/new_task_page.dart';
import 'models/task_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = AppData.of(context).tasks;
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
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

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
        // ── Date + Greeting ──────────────────────────────────────
        const SizedBox(height: DzSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: DzTextStyles.caption.copyWith(
                      color: DzColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(greeting, style: DzTextStyles.heading1),
                  const SizedBox(height: 4),
                  Text(
                    tasks.isEmpty
                        ? 'Add your first task to get started.'
                        : remaining == 0
                            ? 'All tasks done. Great work!'
                            : 'You have $remaining task${remaining == 1 ? '' : 's'} remaining.',
                    style: DzTextStyles.body.copyWith(
                      color: DzColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              child: Icon(
                Icons.person_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: DzSpacing.lg),

        // ── Focus Score Card ─────────────────────────────────────
        DzCard(
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
                        value: tasks.isEmpty ? 0 : score / 100,
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
                tasks.isEmpty
                    ? 'Add tasks to track your focus score.'
                    : score >= 80
                        ? 'Excellent focus today \u2014 you\'re in the zone!'
                        : score >= 50
                            ? 'Good progress! Keep the momentum going.'
                            : 'Every task completed brings you closer.',
                textAlign: TextAlign.center,
                style: DzTextStyles.caption
                    .copyWith(color: DzColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: DzSpacing.md),

        // ── AI Suggestion Card ───────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3D6FDB), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(DzRadius.card),
          ),
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                remaining > 3
                    ? 'Feeling overwhelmed?'
                    : 'You\'re on a great path!',
                style: DzTextStyles.heading3.copyWith(color: DzColors.white),
              ),
              const SizedBox(height: DzSpacing.sm),
              Text(
                remaining > 3
                    ? 'Let AI balance your schedule for maximum calm.'
                    : 'Keep up the momentum \u2014 mindful progress every day.',
                style: DzTextStyles.body.copyWith(
                  color: DzColors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: DzSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('AI optimizer coming soon.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DzColors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DzSpacing.lg,
                    vertical: DzSpacing.sm + 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DzRadius.button),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Optimize My Day',
                  style: DzTextStyles.button.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DzSpacing.lg),

        // ── Today's Tasks ────────────────────────────────────────
        DzCard(
          padding: const EdgeInsets.all(DzSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: DzColors.zenGreen,
                    size: 20,
                  ),
                  const SizedBox(width: DzSpacing.sm),
                  Text('Today\'s Tasks', style: DzTextStyles.heading3),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DzSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: DzColors.appBackground,
                      borderRadius: BorderRadius.circular(DzRadius.small),
                    ),
                    child: Text(
                      '$remaining Left',
                      style: DzTextStyles.small.copyWith(
                        color: DzColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DzSpacing.md),

              if (tasks.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: DzSpacing.md),
                  child: Text(
                    'No tasks yet. Tap + to add one.',
                    style: DzTextStyles.body
                        .copyWith(color: DzColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...tasks.map((task) => _TaskItem(
                      task: task,
                      onToggle: () =>
                          AppData.of(context).tasks.toggleTask(task.id),
                    )),

              const SizedBox(height: DzSpacing.sm),

              // Quick Add
              GestureDetector(
                onTap: () => _showAddTaskSheet(context),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: DzSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: DzColors.borderLight,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(DzRadius.card),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          size: 16, color: DzColors.textSecondary),
                      const SizedBox(width: DzSpacing.xs),
                      Text(
                        'Quick Add Task',
                        style: DzTextStyles.caption.copyWith(
                          color: DzColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DzSpacing.md),

        // ── Stats Row ────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: DzCard(
                padding: const EdgeInsets.all(DzSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(DzRadius.small),
                      ),
                      child: Icon(Icons.timer_rounded,
                          color: Theme.of(context).colorScheme.primary, size: 20),
                    ),
                    const SizedBox(height: DzSpacing.sm),
                    Text(
                      'Focus Time',
                      style: DzTextStyles.small
                          .copyWith(color: DzColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      focusLabel,
                      style: DzTextStyles.heading2.copyWith(
                        color: DzColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: DzSpacing.md),
            Expanded(
              child: DzCard(
                padding: const EdgeInsets.all(DzSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: DzColors.zenGreen.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(DzRadius.small),
                      ),
                      child: const Icon(Icons.self_improvement_rounded,
                          color: DzColors.zenGreen, size: 20),
                    ),
                    const SizedBox(height: DzSpacing.sm),
                    Text(
                      'Zen Sessions',
                      style: DzTextStyles.small
                          .copyWith(color: DzColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$zenDone',
                      style: DzTextStyles.heading2.copyWith(
                        color: DzColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DzSpacing.md),

        // ── Daily Reflection ─────────────────────────────────────
        DzCard(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: DzSpacing.sm),
                  Text('Daily Reflection', style: DzTextStyles.heading3),
                ],
              ),
              const SizedBox(height: DzSpacing.md),
              Text(
                '"The secret of your future is hidden in your daily routine."',
                style: DzTextStyles.body.copyWith(
                  fontStyle: FontStyle.italic,
                  color: DzColors.textPrimary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: DzSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '\u2014 MIKE MURDOCK',
                  style: DzTextStyles.small.copyWith(
                    color: DzColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DzSpacing.xl),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewTaskPage()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task item row
// ─────────────────────────────────────────────────────────────────────────────

class _TaskItem extends StatelessWidget {
  const _TaskItem({required this.task, required this.onToggle});
  final DzTask task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DzSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.sm, vertical: DzSpacing.sm),
      decoration: BoxDecoration(
        color: DzColors.appBackground,
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: DzColors.borderLight, width: 1.5),
          ),
          const SizedBox(width: DzSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: DzTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted
                        ? DzColors.textSecondary
                        : DzColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.timeRange,
                  style: DzTextStyles.small
                      .copyWith(color: DzColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: DzSpacing.sm),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: task.priority.bg,
              borderRadius: BorderRadius.circular(DzRadius.small),
            ),
            child: Text(
              task.priority.label,
              style: DzTextStyles.small.copyWith(
                color: task.priority.color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
