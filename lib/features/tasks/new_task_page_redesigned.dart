import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../../core/utils/date_formatter.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
import 'widgets/new_task_bottom_bar.dart';
import 'widgets/new_task_focus_privacy.dart';
import 'widgets/new_task_shared_widgets.dart';
import 'widgets/new_task_redesigned_widgets.dart';

/// Award-winning redesigned NewTask page with modern UX principles:
/// - Gradient accents for visual appeal
/// - Enhanced visual hierarchy with better spacing
/// - Quick action buttons for power users
/// - Icon-based category selection
/// - Color-coded priority levels
/// - Smooth animations and haptic feedback
/// - Full accessibility support
class NewTaskPageRedesigned extends StatefulWidget {
  final DateTime? initialDate;
  const NewTaskPageRedesigned({super.key, this.initialDate});

  @override
  State<NewTaskPageRedesigned> createState() => _NewTaskPageRedesignedState();
}

class _NewTaskPageRedesignedState extends State<NewTaskPageRedesigned>
    with TickerProviderStateMixin {
  final _titleFocus = FocusNode();
  final _titleCtrl = TextEditingController();
  late AnimationController _fadeController;

  late DateTime _scheduledDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  TaskCategory _category = TaskCategory.work;
  NewTaskPriorityLevel _priority = NewTaskPriorityLevel.medium;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    _scheduledDate = widget.initialDate ?? DateTime.now();
    final now = TimeOfDay.now();
    final nextHour = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    _startTime = nextHour;
    _endTime = TimeOfDay(hour: (nextHour.hour + 1) % 24, minute: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) => _titleFocus.requestFocus());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleFocus.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

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
    final colorValue = AppConfig.categoryColors[categoryName] ?? 0xFF667EEA;
    return Color(colorValue);
  }

  TaskPriority _toDzPriority() => switch (_priority) {
        NewTaskPriorityLevel.low => TaskPriority.low,
        NewTaskPriorityLevel.medium => TaskPriority.routine,
        NewTaskPriorityLevel.high => TaskPriority.high,
      };

  Future<void> _pickSchedule() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted || pickedDate == null) return;

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

  void _setQuickSchedule(Duration offsetDays) {
    setState(() {
      _scheduledDate = DateTime.now().add(offsetDays);
    });
    HapticFeedback.lightImpact();
  }

  void _setQuickPriority(NewTaskPriorityLevel priority) {
    setState(() => _priority = priority);
    HapticFeedback.lightImpact();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _titleFocus.requestFocus();
      return;
    }

    HapticFeedback.mediumImpact();

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
    await tasks.addTask(task);

    if (mounted) Navigator.of(context).pop(task);
  }

  IconData _categoryIcon(TaskCategory cat) => switch (cat) {
        TaskCategory.work => Icons.work_outline_rounded,
        TaskCategory.personal => Icons.person_outline_rounded,
        TaskCategory.mindful => Icons.self_improvement_rounded,
        TaskCategory.study => Icons.menu_book_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

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
      body: FadeTransition(
        opacity: _fadeController,
        child: KeyboardListener(
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
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? DzSpacing.lg : DzSpacing.xl,
                  vertical: DzSpacing.md,
                ),
                sliver: SliverList.list(
                  children: [
                    // Title Input
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
                    const SizedBox(height: DzSpacing.lg),

                    // Quick Actions
                    _buildQuickActions(),
                    const SizedBox(height: DzSpacing.xl),

                    // Scheduled For
                    const TaskSectionLabel('SCHEDULED FOR'),
                    const SizedBox(height: DzSpacing.sm),
                    ScheduledCardWidget(
                      label: _formatScheduled(),
                      onTap: _pickSchedule,
                    ),
                    const SizedBox(height: DzSpacing.lg),

                    // Category
                    const TaskSectionLabel('CATEGORY'),
                    const SizedBox(height: DzSpacing.sm),
                    CategoryGridWidget(
                      selected: _category,
                      onSelect: (c) => setState(() => _category = c),
                    ),
                    const SizedBox(height: DzSpacing.lg),

                    // Priority
                    const TaskSectionLabel('PRIORITY'),
                    const SizedBox(height: DzSpacing.sm),
                    PriorityPickerWidget(
                      selected: _priority,
                      onSelect: _setQuickPriority,
                    ),
                    const SizedBox(height: DzSpacing.lg),

                    // Current Focus
                    EnhancedFocusCard(
                      label: _focusLabel(),
                      initials: _focusInitials(),
                      color: _focusColor(),
                    ),
                    const SizedBox(height: DzSpacing.md),

                    // Privacy Banner
                    PrivacyNote(primary: _focusColor()),
                    const SizedBox(height: DzSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NewTaskBottomBar(
        primary: _focusColor(),
        onSave: _save,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: DzSpacing.sm,
      runSpacing: DzSpacing.sm,
      children: [
        QuickActionButton(
          emoji: '📅',
          label: 'Today',
          isActive: true,
          onTap: () => _setQuickSchedule(Duration.zero),
        ),
        QuickActionButton(
          emoji: '⏩',
          label: 'Tomorrow',
          isActive: false,
          onTap: () => _setQuickSchedule(const Duration(days: 1)),
        ),
        QuickActionButton(
          emoji: '🔴',
          label: 'Urgent',
          isActive: _priority == NewTaskPriorityLevel.high,
          onTap: () => _setQuickPriority(NewTaskPriorityLevel.high),
        ),
      ],
    );
  }
}
