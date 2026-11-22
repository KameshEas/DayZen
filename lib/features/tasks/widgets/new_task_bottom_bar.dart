import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// "Add to My Day" save button, shown as the New Task page's
/// bottomNavigationBar.
class NewTaskBottomBar extends StatelessWidget {
  const NewTaskBottomBar({
    super.key,
    required this.primary,
    required this.onSave,
    this.label = 'Add to My Day',
  });

  final Color primary;
  final VoidCallback onSave;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          DzSpacing.lg,
          DzSpacing.sm,
          DzSpacing.lg,
          DzSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          width: double.infinity,
          height: DzSizing.buttonHeight + 4,
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.check_circle_outline_rounded,
                color: DzColors.white, size: 20),
            label: Text(
              label,
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
      ),
    );
  }
}
