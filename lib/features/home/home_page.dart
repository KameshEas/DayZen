import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../app_data.dart';
import '../task_controller.dart';
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
                        value: tasks.isEmpty ? 0 : score / 100,
                        strokeWidth: 10,
                        backgroundColor: DzColors.borderLight,
                        valueColor:
                            const AlwaysStoppedAnimation(DzColors.primary),
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
                        color: DzColors.primary.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(DzRadius.small),
                      ),
                      child: const Icon(Icons.timer_rounded,
                          color: DzColors.primary, size: 20),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(taskCtrl: AppData.of(context).tasks),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Task bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.taskCtrl});
  final TaskController taskCtrl;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.routine;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _startTime = now;
    _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final task = DzTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      startTime: _startTime,
      endTime: _endTime,
      priority: _priority,
      icon: Icons.circle_outlined,
    );
    await widget.taskCtrl.addTask(task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: DzColors.cardBackground,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
        ),
        padding: const EdgeInsets.fromLTRB(
            DzSpacing.lg, DzSpacing.lg, DzSpacing.lg, DzSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: DzColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.lg),
            Text('Add Task',
                style: DzTextStyles.heading3
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DzSpacing.md),
            DzTextField(
              controller: _titleCtrl,
              label: 'Task name',
              hint: 'What do you need to do?',
              autofocus: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: DzSpacing.md),
            Text('Priority',
                style: DzTextStyles.caption
                    .copyWith(color: DzColors.textSecondary)),
            const SizedBox(height: DzSpacing.sm),
            Row(
              children: TaskPriority.values.map((p) {
                final selected = _priority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: DzDuration.fast,
                      margin: const EdgeInsets.only(right: 6),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? p.bg : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: selected
                            ? Border.all(color: p.color, width: 1.5)
                            : Border.all(
                                color: DzColors.borderLight, width: 1),
                      ),
                      child: Text(
                        p.label,
                        textAlign: TextAlign.center,
                        style: DzTextStyles.small.copyWith(
                          color:
                              selected ? p.color : DzColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: DzSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: 'Start',
                    time: _startTime,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: _TimeTile(
                    label: 'End',
                    time: _endTime,
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            DzPrimaryButton(label: 'Save Task', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile(
      {required this.label, required this.time, required this.onTap});
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final p = time.period == DayPeriod.am ? 'AM' : 'PM';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.md, vertical: DzSpacing.sm + 2),
        decoration: BoxDecoration(
          color: DzColors.appBackground,
          borderRadius: BorderRadius.circular(DzRadius.card),
          border: Border.all(color: DzColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: DzTextStyles.small
                    .copyWith(color: DzColors.textSecondary)),
            const SizedBox(height: 2),
            Text('$h:$m $p',
                style:
                    DzTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
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
