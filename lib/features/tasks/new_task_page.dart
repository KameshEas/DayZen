import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/app_config.dart';
import '../../core/domain/planner_dates.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../../core/utils/date_formatter.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
import 'widgets/new_task_bottom_bar.dart';
import 'widgets/new_task_focus_privacy.dart';
import 'widgets/new_task_form_fields.dart';
import 'widgets/new_task_shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// New Task Page — full-screen design matching the DayZen UI spec. Split
// from a single 624-line file into features/tasks/widgets/ subcomponents
// in Phase 5.1 of docs/DEVELOPMENT_PLAN.md.
// ─────────────────────────────────────────────────────────────────────────────

/// Start and end for a new task on [date]: the next full hour when it is today
/// (never wrapping past midnight into the early hours of the same day), and
/// 9-10 AM on any other day.
(TimeOfDay start, TimeOfDay end) defaultTaskTimes(DateTime date, DateTime now) {
  if (!isSameDay(date, now)) {
    return (const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 10, minute: 0));
  }
  final startHour = (now.hour + 1).clamp(0, 23);
  final endsAtMidnight = startHour >= 23;
  return (
    TimeOfDay(hour: startHour, minute: 0),
    endsAtMidnight
        ? const TimeOfDay(hour: 23, minute: 59)
        : TimeOfDay(hour: startHour + 1, minute: 0),
  );
}

class NewTaskPage extends StatefulWidget {
  /// Optional initial date (defaults to today).
  final DateTime? initialDate;

  const NewTaskPage({super.key, this.initialDate});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _titleFocus = FocusNode();
  final _titleCtrl = TextEditingController();

  late DateTime _scheduledDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  TaskCategory _category = TaskCategory.work;
  NewTaskPriorityLevel _priority = NewTaskPriorityLevel.medium;

  @override
  void initState() {
    super.initState();
    _scheduledDate = dayOnly(widget.initialDate ?? DateTime.now());
    final times = defaultTaskTimes(_scheduledDate, DateTime.now());
    _startTime = times.$1;
    _endTime = times.$2;
    // Auto-focus the title field
    WidgetsBinding.instance.addPostFrameCallback((_) => _titleFocus.requestFocus());
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatScheduled() {
    return DateFormatter.formatTaskSchedule(_scheduledDate, _startTime.hour, _startTime.minute);
  }

  String _focusLabel() {
    final categoryName = _category.name;
    return AppConfig.categoryFocusLabels[categoryName] ?? 'Focus Session';
  }

  String _focusInitials() {
    final categoryName = _category.name;
    return AppConfig.categoryInitials[categoryName] ?? 'FS';
  }

  Color _focusColor() {
    final categoryName = _category.name;
    final colorValue = AppConfig.categoryColors[categoryName] ?? 0xFF3B82F6;
    return Color(colorValue);
  }

  TaskPriority _toDzPriority() => switch (_priority) {
        NewTaskPriorityLevel.low => TaskPriority.low,
        NewTaskPriorityLevel.medium => TaskPriority.routine,
        NewTaskPriorityLevel.high => TaskPriority.high,
      };

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickSchedule() async {
    // Pick date
    // Any day the Planner can show is a valid choice: a year back (to log a past
    // day) and two years ahead. The picker asserts that the initial date is in
    // range, so the range is widened to include the day already chosen.
    final today = dayOnly(DateTime.now());
    var first = DateTime(today.year - 1, today.month, today.day);
    var last = DateTime(today.year + plannerYearsAhead, today.month, today.day);
    if (_scheduledDate.isBefore(first)) first = _scheduledDate;
    if (_scheduledDate.isAfter(last)) last = _scheduledDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: first,
      lastDate: last,
    );
    if (!mounted || pickedDate == null) return;

    // Pick time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (!mounted || pickedTime == null) return;

    setState(() {
      _scheduledDate = pickedDate;
      _startTime = pickedTime;
      _endTime = pickedTime.hour >= 23
          ? const TimeOfDay(hour: 23, minute: 59)
          : TimeOfDay(hour: pickedTime.hour + 1, minute: pickedTime.minute);
    });
  }

  /// True from the first save until the page closes. Saving is triggered from
  /// the button, the keyboard's Done and the Enter key, and takes a moment: a
  /// second trigger during it used to save the task twice.
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _titleFocus.requestFocus();
      return;
    }
    _saving = true;

    final task = DzTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      startTime: _startTime,
      endTime: _endTime,
      priority: _toDzPriority(),
      category: _category,
      icon: _categoryIcon(_category),
      date: _scheduledDate,
    );

    final tasks = TaskScope.of(context);
    try {
      await tasks.addTask(task);
    } catch (_) {
      // Let the user try again instead of leaving the button dead.
      _saving = false;
      rethrow;
    }

    if (mounted) Navigator.of(context).pop(task);
  }

  IconData _categoryIcon(TaskCategory cat) => switch (cat) {
        TaskCategory.work => Icons.work_outline_rounded,
        TaskCategory.personal => Icons.person_outline_rounded,
        TaskCategory.mindful => Icons.self_improvement_rounded,
        TaskCategory.study => Icons.menu_book_rounded,
      };

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          'New Task',
          style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            _save();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: DzSpacing.lg,
                vertical: DzSpacing.md,
              ),
              sliver: SliverList.list(
                children: [
                  // ── Giant title field ────────────────────────────
                  TextField(
                    controller: _titleCtrl,
                    focusNode: _titleFocus,
                    style: DzTextStyles.heading1.copyWith(
                      fontSize: 28,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: DzTextStyles.heading1.copyWith(
                        fontSize: 28,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: DzSpacing.xl),

                  // ── SCHEDULED FOR ────────────────────────────────
                  const TaskSectionLabel('SCHEDULED FOR'),
                  const SizedBox(height: DzSpacing.sm),
                  ScheduledTile(
                    label: _formatScheduled(),
                    onTap: _pickSchedule,
                    primary: primary,
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── CATEGORY ─────────────────────────────────────
                  const TaskSectionLabel('CATEGORY'),
                  const SizedBox(height: DzSpacing.sm),
                  CategoryChips(
                    selected: _category,
                    primary: primary,
                    onSelect: (c) => setState(() => _category = c),
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── PRIORITY ─────────────────────────────────────
                  const TaskSectionLabel('PRIORITY'),
                  const SizedBox(height: DzSpacing.sm),
                  PrioritySegment(
                    selected: _priority,
                    primary: primary,
                    onSelect: (p) => setState(() => _priority = p),
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── CURRENT FOCUS card ───────────────────────────
                  CurrentFocusCard(
                    label: _focusLabel(),
                    initials: _focusInitials(),
                    color: _focusColor(),
                  ),
                  const SizedBox(height: DzSpacing.md),

                  // ── Privacy note ─────────────────────────────────
                  PrivacyNote(primary: primary),
                  const SizedBox(height: DzSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NewTaskBottomBar(primary: primary, onSave: _save),
    );
  }
}
