import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../home/models/task_model.dart';

// ──────────────────────────────────────────────────────────────────────────────
// REDESIGNED WIDGETS - Award-winning NewTask UI
// Modern UX with gradients, animations, and micro-interactions
// ──────────────────────────────────────────────────────────────────────────────

// ──────────────────────────────────────────────────────────────────────────────
// Quick Action Button
// ──────────────────────────────────────────────────────────────────────────────

class QuickActionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DzDuration.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : DzColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : DzColors.borderLight,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : DzShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: DzTextStyles.body.copyWith(
                fontSize: 0.85,
                color: isActive ? DzColors.white : DzColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Enhanced Schedule Card with Gradient
// ──────────────────────────────────────────────────────────────────────────────

class ScheduledCardWidget extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const ScheduledCardWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<ScheduledCardWidget> createState() => _ScheduledCardWidgetState();
}

class _ScheduledCardWidgetState extends State<ScheduledCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: DzDuration.fast,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.02).animate(_hoverController),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DzSpacing.md,
              vertical: DzSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DzRadius.card),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DzColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.access_time_rounded,
                      color: DzColors.white, size: 18),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Text(
                    widget.label,
                    style: DzTextStyles.body.copyWith(
                      color: DzColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.edit_outlined, color: DzColors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Category Grid Widget with Icons
// ──────────────────────────────────────────────────────────────────────────────

class CategoryGridWidget extends StatelessWidget {
  final TaskCategory selected;
  final ValueChanged<TaskCategory> onSelect;

  const CategoryGridWidget({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  IconData _getIcon(TaskCategory cat) => switch (cat) {
        TaskCategory.work => Icons.work_outline_rounded,
        TaskCategory.personal => Icons.person_outline_rounded,
        TaskCategory.mindful => Icons.self_improvement_rounded,
        TaskCategory.study => Icons.menu_book_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: DzSpacing.sm,
      crossAxisSpacing: DzSpacing.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: TaskCategory.values.map((cat) {
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: DzDuration.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: DzSpacing.sm,
              vertical: DzSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF667EEA),
                        const Color(0xFF764BA2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : DzColors.cardBackground,
              borderRadius: BorderRadius.circular(DzRadius.card),
              border: Border.all(
                color: isSelected ? Colors.transparent : DzColors.borderLight,
                width: 1.5,
              ),
              boxShadow: isSelected ? DzShadows.soft : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIcon(cat),
                  size: 28,
                  color: isSelected ? DzColors.white : DzColors.textPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  cat.label,
                  style: DzTextStyles.body.copyWith(
                    fontSize: 0.85,
                    color: isSelected ? DzColors.white : DzColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Priority Picker Widget with Color Dots
// ──────────────────────────────────────────────────────────────────────────────

class PriorityPickerWidget extends StatelessWidget {
  final NewTaskPriorityLevel selected;
  final ValueChanged<NewTaskPriorityLevel> onSelect;

  const PriorityPickerWidget({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
        borderRadius: BorderRadius.circular(DzRadius.card),
        boxShadow: DzShadows.soft,
      ),
      child: Row(
        children: NewTaskPriorityLevel.values.map((level) {
          final isSelected = level == selected;
          final color = switch (level) {
            NewTaskPriorityLevel.low => const Color(0xFF4CAF50),
            NewTaskPriorityLevel.medium => const Color(0xFFFFA726),
            NewTaskPriorityLevel.high => const Color(0xFFEF5350),
          };
          final label = switch (level) {
            NewTaskPriorityLevel.low => 'Low',
            NewTaskPriorityLevel.medium => 'Medium',
            NewTaskPriorityLevel.high => 'High',
          };

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(level),
              child: AnimatedContainer(
                duration: DzDuration.fast,
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DzRadius.card - 4),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: DzTextStyles.body.copyWith(
                        fontSize: 0.85,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? color : DzColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Enhanced Focus Card with Gradient Background
// ──────────────────────────────────────────────────────────────────────────────

class EnhancedFocusCard extends StatelessWidget {
  final String label;
  final String initials;
  final Color color;

  const EnhancedFocusCard({
    super.key,
    required this.label,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DzSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DzRadius.card),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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

// ──────────────────────────────────────────────────────────────────────────────
// Priority Level Enum
// ──────────────────────────────────────────────────────────────────────────────

enum NewTaskPriorityLevel { low, medium, high }
