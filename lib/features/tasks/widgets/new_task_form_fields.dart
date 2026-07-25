import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../home/models/task_model.dart';

/// Priority level as selected in the New Task form â€” mapped to the domain
/// [TaskPriority] enum by the page (medium -> routine; the form doesn't
/// expose "zen" as a selectable priority).
enum NewTaskPriorityLevel { low, medium, high }

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Scheduled tile
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ScheduledTile extends StatelessWidget {
  const ScheduledTile({
    super.key,
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
            const Icon(Icons.edit_outlined, color: DzColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Category chips
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Priority segmented control
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class PrioritySegment extends StatelessWidget {
  const PrioritySegment({
    super.key,
    required this.selected,
    required this.primary,
    required this.onSelect,
  });
  final NewTaskPriorityLevel selected;
  final Color primary;
  final ValueChanged<NewTaskPriorityLevel> onSelect;

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
                  color: isSelected ? DzColors.selectedChipBg : Colors.transparent,
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


