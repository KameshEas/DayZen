import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Small caps section label used throughout the New Task form.
class TaskSectionLabel extends StatelessWidget {
  const TaskSectionLabel(this.text, {super.key});
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
