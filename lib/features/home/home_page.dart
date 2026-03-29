import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<DzTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.of(DzMockData.todayTasks);
  }

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
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    final remaining = _tasks.where((t) => !t.isCompleted).length;

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
                    'It\'s a beautiful day for focus.',
                    style: DzTextStyles.body.copyWith(
                      color: DzColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Avatar placeholder
            CircleAvatar(
              radius: 26,
              backgroundColor: DzColors.primary.withValues(alpha: 0.15),
              child: const Icon(
                Icons.person_rounded,
                color: DzColors.primary,
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
                  const Icon(
                    Icons.trending_up_rounded,
                    color: DzColors.primary,
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
                        value: 0.75,
                        strokeWidth: 10,
                        backgroundColor: DzColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation(DzColors.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '75',
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
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                  ),
                  children: const [
                    TextSpan(text: 'You\'re more '),
                    TextSpan(
                      text: 'focused',
                      style: TextStyle(
                        color: DzColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' than 80% of your mornings.'),
                  ],
                ),
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
                'Feeling overwhelmed?',
                style: DzTextStyles.heading3.copyWith(color: DzColors.white),
              ),
              const SizedBox(height: DzSpacing.sm),
              Text(
                'Let AI balance your schedule for maximum calm.',
                style: DzTextStyles.body.copyWith(
                  color: DzColors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: DzSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI optimizer coming soon.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DzColors.white,
                  foregroundColor: DzColors.primary,
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
                  style: DzTextStyles.button.copyWith(color: DzColors.primary),
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
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: DzColors.zenGreen,
                    size: 20,
                  ),
                  const SizedBox(width: DzSpacing.sm),
                  Text(
                    'Today\'s Tasks',
                    style: DzTextStyles.heading3,
                  ),
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

              // Task items
              ..._tasks.map((task) => _TaskItem(
                    task: task,
                    onToggle: (val) =>
                        setState(() => task.isCompleted = val ?? false),
                  )),

              const SizedBox(height: DzSpacing.sm),

              // Quick Add
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quick add coming soon.')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: DzSpacing.md),
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
                        color: DzColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(DzRadius.small),
                      ),
                      child: const Icon(Icons.timer_rounded,
                          color: DzColors.primary, size: 20),
                    ),
                    const SizedBox(height: DzSpacing.sm),
                    Text(
                      'Focus Time',
                      style: DzTextStyles.small.copyWith(
                          color: DzColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '4.2h',
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
                        borderRadius: BorderRadius.circular(DzRadius.small),
                      ),
                      child: const Icon(Icons.self_improvement_rounded,
                          color: DzColors.zenGreen, size: 20),
                    ),
                    const SizedBox(height: DzSpacing.sm),
                    Text(
                      'Breaks Taken',
                      style: DzTextStyles.small.copyWith(
                          color: DzColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '3/5',
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
                  const Icon(
                    Icons.format_quote_rounded,
                    color: DzColors.primary,
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
                  '— MIKE MURDOCK',
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Task item row
// ─────────────────────────────────────────────────────────────────────────────

class _TaskItem extends StatelessWidget {
  const _TaskItem({required this.task, required this.onToggle});
  final DzTask task;
  final ValueChanged<bool?> onToggle;

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
            onChanged: onToggle,
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
                  style:
                      DzTextStyles.small.copyWith(color: DzColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: DzSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
