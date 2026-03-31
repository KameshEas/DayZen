import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../app_data.dart';
import '../home/models/task_model.dart';


// ─────────────────────────────────────────────────────────────────────────────
// New Task Page — full-screen design matching the DayZen UI spec
// ─────────────────────────────────────────────────────────────────────────────

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
  _PriorityLevel _priority = _PriorityLevel.medium;

  @override
  void initState() {
    super.initState();
    _scheduledDate = widget.initialDate ?? DateTime.now();
    final now = TimeOfDay.now();
    // Round up to next full hour for a clean default
    final nextHour = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    _startTime = nextHour;
    _endTime = TimeOfDay(hour: (nextHour.hour + 1) % 24, minute: 0);
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_scheduledDate.year, _scheduledDate.month, _scheduledDate.day);

    final diff = selected.difference(today).inDays;
    final dayLabel = diff == 0
        ? 'Today'
        : diff == 1
            ? 'Tomorrow'
            : '${_weekday(_scheduledDate)}, ${_scheduledDate.day} ${_monthAbbr(_scheduledDate.month)}';

    final h = _startTime.hourOfPeriod == 0 ? 12 : _startTime.hourOfPeriod;
    final m = _startTime.minute.toString().padLeft(2, '0');
    final period = _startTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$dayLabel at $h:$m $period';
  }

  String _weekday(DateTime d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

  String _monthAbbr(int m) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];

  String _focusLabel() => switch (_category) {
        TaskCategory.work => 'Deep Work Session',
        TaskCategory.personal => 'Personal Time',
        TaskCategory.mindful => 'Mindful Afternoon',
        TaskCategory.study => 'Focus Study Block',
      };

  String _focusInitials() => switch (_category) {
        TaskCategory.work => 'DW',
        TaskCategory.personal => 'PT',
        TaskCategory.mindful => 'MA',
        TaskCategory.study => 'FS',
      };

  Color _focusColor() => switch (_category) {
        TaskCategory.work => const Color(0xFF3B82F6),
        TaskCategory.personal => const Color(0xFF8B5CF6),
        TaskCategory.mindful => const Color(0xFF10B981),
        TaskCategory.study => const Color(0xFFF59E0B),
      };

  TaskPriority _toDzPriority() => switch (_priority) {
        _PriorityLevel.low => TaskPriority.low,
        _PriorityLevel.medium => TaskPriority.routine,
        _PriorityLevel.high => TaskPriority.high,
      };

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickSchedule() async {
    // Pick date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      _endTime = TimeOfDay(
        hour: (pickedTime.hour + 1) % 24,
        minute: pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _titleFocus.requestFocus();
      return;
    }

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

    final tasks = AppData.of(context).tasks;
    await tasks.addTask(task);

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
      backgroundColor: DzColors.appBackground,
      appBar: AppBar(
        backgroundColor: DzColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          color: DzColors.textPrimary,
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
                      color: DzColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: DzTextStyles.heading1.copyWith(
                        fontSize: 28,
                        color: DzColors.textPrimary.withValues(alpha: 0.25),
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
                  _SectionLabel('SCHEDULED FOR'),
                  const SizedBox(height: DzSpacing.sm),
                  _ScheduledTile(
                    label: _formatScheduled(),
                    onTap: _pickSchedule,
                    primary: primary,
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── CATEGORY ─────────────────────────────────────
                  _SectionLabel('CATEGORY'),
                  const SizedBox(height: DzSpacing.sm),
                  _CategoryChips(
                    selected: _category,
                    primary: primary,
                    onSelect: (c) => setState(() => _category = c),
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── PRIORITY ─────────────────────────────────────
                  _SectionLabel('PRIORITY'),
                  const SizedBox(height: DzSpacing.sm),
                  _PrioritySegment(
                    selected: _priority,
                    primary: primary,
                    onSelect: (p) => setState(() => _priority = p),
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── CURRENT FOCUS card ───────────────────────────
                  _CurrentFocusCard(
                    label: _focusLabel(),
                    initials: _focusInitials(),
                    color: _focusColor(),
                  ),
                  const SizedBox(height: DzSpacing.md),

                  // ── Privacy note ─────────────────────────────────
                  _PrivacyNote(primary: primary),
                  const SizedBox(height: DzSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            DzSpacing.lg,
            DzSpacing.sm,
            DzSpacing.lg,
            DzSpacing.md + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Add to My Day ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: DzSizing.buttonHeight + 4,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      color: DzColors.white, size: 20),
                  label: Text(
                    'Add to My Day',
                    style: DzTextStyles.body.copyWith(
                      color: DzColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: DzColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DzRadius.button + 2),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: DzSpacing.sm),
              // ── Enter hint ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Press ', style: DzTextStyles.caption.copyWith(color: DzColors.textSecondary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: DzColors.cardBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: DzColors.borderLight),
                      boxShadow: DzShadows.soft,
                    ),
                    child: Text('Enter',
                        style: DzTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DzColors.textPrimary,
                        )),
                  ),
                  Text(' to save quickly',
                      style: DzTextStyles.caption.copyWith(color: DzColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DzTextStyles.caption.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: DzColors.textSecondary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scheduled tile
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduledTile extends StatelessWidget {
  const _ScheduledTile({
    required this.label,
    required this.onTap,
    required this.primary,
  });
  final String label;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.md,
          vertical: DzSpacing.md,
        ),
        decoration: BoxDecoration(
          color: DzColors.cardBackground,
          borderRadius: BorderRadius.circular(DzRadius.card),
          boxShadow: DzShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.access_time_rounded, color: primary, size: 17),
            ),
            const SizedBox(width: DzSpacing.md),
            Expanded(
              child: Text(
                label,
                style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.edit_outlined, color: DzColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category chips
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.primary,
    required this.onSelect,
  });
  final TaskCategory selected;
  final Color primary;
  final ValueChanged<TaskCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DzSpacing.sm,
      runSpacing: DzSpacing.sm,
      children: TaskCategory.values.map((cat) {
        final isSelected = cat == selected;
        return AnimatedContainer(
          duration: DzDuration.fast,
          child: GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: DzDuration.fast,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primary : DzColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? primary : DzColors.borderLight,
                  width: 1.5,
                ),
                boxShadow: isSelected ? null : DzShadows.soft,
              ),
              child: Text(
                cat.label,
                style: DzTextStyles.body.copyWith(
                  color: isSelected ? DzColors.white : DzColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Priority segmented control
// ─────────────────────────────────────────────────────────────────────────────

enum _PriorityLevel { low, medium, high }

class _PrioritySegment extends StatelessWidget {
  const _PrioritySegment({
    required this.selected,
    required this.primary,
    required this.onSelect,
  });
  final _PriorityLevel selected;
  final Color primary;
  final ValueChanged<_PriorityLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
        borderRadius: BorderRadius.circular(DzRadius.card),
        boxShadow: DzShadows.soft,
      ),
      child: Row(
        children: _PriorityLevel.values.map((level) {
          final isSelected = level == selected;
          final label = switch (level) {
            _PriorityLevel.low => 'Low',
            _PriorityLevel.medium => 'Medium',
            _PriorityLevel.high => 'High',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(level),
              child: AnimatedContainer(
                duration: DzDuration.fast,
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F0F0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(DzRadius.card - 4),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: DzTextStyles.body.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? DzColors.textPrimary : DzColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Current Focus card
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentFocusCard extends StatelessWidget {
  const _CurrentFocusCard({
    required this.label,
    required this.initials,
    required this.color,
  });
  final String label;
  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DzDuration.normal,
      padding: const EdgeInsets.all(DzSpacing.md),
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
        borderRadius: BorderRadius.circular(DzRadius.card),
        boxShadow: DzShadows.soft,
      ),
      child: Row(
        children: [
          // Avatar with initials
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: DzTextStyles.body.copyWith(
                  color: DzColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: DzSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT FOCUS',
                style: DzTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: DzTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: DzColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Privacy note
// ─────────────────────────────────────────────────────────────────────────────

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DzSpacing.md,
        vertical: DzSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: primary, size: 18),
          const SizedBox(width: DzSpacing.sm),
          Expanded(
            child: Text(
              'Your data is stored locally and stays private.',
              style: DzTextStyles.caption.copyWith(
                color: primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
