import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// "Add to My Day" save button + "Press Enter to save quickly" hint, shown
/// as the New Task page's bottomNavigationBar.
class NewTaskBottomBar extends StatelessWidget {
  const NewTaskBottomBar({
    super.key,
    required this.primary,
    required this.onSave,
  });

  final Color primary;
  final VoidCallback onSave;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Add to My Day ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: DzSizing.buttonHeight + 4,
              child: ElevatedButton.icon(
                onPressed: onSave,
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
    );
  }
}
