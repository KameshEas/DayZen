import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../home/models/task_model.dart';

/// Minimal redesigned widgets for NewTask
/// Focus: Clean, subtle improvements without over-design

enum NewTaskPriorityLevel { low, medium, high }

// ──────────────────────────────────────────────────────────────────────────────
// Schedule Card - Clean and refined
// ──────────────────────────────────────────────────────────────────────────────

class ScheduleCardMinimal extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ScheduleCardMinimal({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md, vertical: DzSpacing.sm),
        decoration: BoxDecoration(
          color: DzColors.cardBackground,
          border: Border.all(color: DzColors.borderLight, width: 1),
          borderRadius: BorderRadius.circular(DzRadius.card),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: const Color(0xFF667EEA)),
            const SizedBox(width: DzSpacing.md),
            Expanded(
              child: Text(
                label,
                style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.edit_outlined, size: 16, color: DzColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Category Chips - Icons + text, subtle styling
// ──────────────────────────────────────────────────────────────────────────────

class CategoryChipsMinimal extends StatelessWidget {
  final TaskCategory selected;
  final ValueChanged<TaskCategory> onSelect;

  const CategoryChipsMinimal({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  String _getEmoji(TaskCategory cat) => switch (cat) {
        TaskCategory.work => '💼',
        TaskCategory.personal => '👤',
        TaskCategory.study => '📚',
        TaskCategory.mindful => '🧘',
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DzSpacing.sm,
      runSpacing: DzSpacing.sm,
      children: TaskCategory.values.map((cat) {
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF667EEA) : DzColors.cardBackground,
              border: Border.all(
                color: isSelected ? const Color(0xFF667EEA) : DzColors.borderLight,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getEmoji(cat), style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: DzTextStyles.body.copyWith(
                    fontSize: 0.9,
                    color: isSelected ? DzColors.white : DzColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
// Priority Picker - Color dots with subtle design
// ──────────────────────────────────────────────────────────────────────────────

class PriorityPickerMinimal extends StatelessWidget {
  final NewTaskPriorityLevel selected;
  final ValueChanged<NewTaskPriorityLevel> onSelect;

  const PriorityPickerMinimal({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
        border: Border.all(color: DzColors.borderLight, width: 1),
        borderRadius: BorderRadius.circular(DzRadius.card),
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
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: isSelected ? 1.5 : 0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: DzTextStyles.body.copyWith(
                        fontSize: 0.85,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
// Focus Card - Simple and clean
// ──────────────────────────────────────────────────────────────────────────────

class FocusCardMinimal extends StatelessWidget {
  final String label;
  final String initials;
  final Color color;

  const FocusCardMinimal({
    super.key,
    required this.label,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md, vertical: DzSpacing.sm),
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
        border: Border.all(color: DzColors.borderLight, width: 1),
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                initials,
                style: DzTextStyles.body.copyWith(
                  color: DzColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: DzSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT',
                style: DzTextStyles.caption.copyWith(
                  color: DzColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: DzTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 0.9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
