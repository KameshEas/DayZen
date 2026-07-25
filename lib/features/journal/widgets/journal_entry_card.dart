import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../models/journal_entry.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({super.key, required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final accent = entry.accentColor;

    return Container(
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
        borderRadius: BorderRadius.circular(DzRadius.card),
        boxShadow: DzShadows.soft,
        border: accent != null
            ? Border(left: BorderSide(color: accent, width: 3))
            : null,
      ),
      padding: const EdgeInsets.all(DzSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: entry.mood.bg,
              shape: BoxShape.circle,
            ),
            child: Icon(entry.mood.icon,
                color: entry.mood.iconColor, size: 22),
          ),
          const SizedBox(width: DzSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.dateLabel,
                      style: DzTextStyles.caption.copyWith(
                          color: DzColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.body,
                  style: DzTextStyles.body.copyWith(
                      color: DzColors.textSecondary, height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
