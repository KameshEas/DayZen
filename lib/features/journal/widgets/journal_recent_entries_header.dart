import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/utils/date_formatter.dart';

class JournalRecentEntriesHeader extends StatelessWidget {
  const JournalRecentEntriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormatter.formatMonthYear(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Entries',
          style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          monthYear,
          style: DzTextStyles.caption.copyWith(
            color: DzColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
