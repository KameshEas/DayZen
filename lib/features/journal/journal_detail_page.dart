import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';

class JournalDetailPage extends StatelessWidget {
  const JournalDetailPage({
    super.key,
    required this.journalId,
  });

  final String journalId;

  @override
  Widget build(BuildContext context) {
    final journalCtrl = JournalScope.of(context);
    final entries = journalCtrl.all;
    final entry = entries.isEmpty ? null : entries.cast<dynamic>().fold(
      null,
      (prev, e) => (e.id as String) == journalId ? e : prev,
    );

    return DzAuthScaffold(
      appBar: const DzAppBar(
        title: 'Journal Entry',
      ),
      body: entry == null
          ? DzEmptyState(
              icon: Icons.book_outlined,
              title: AppConfig.journalEntryNotFound,
              subtitle: 'Entry no longer exists.',
              actionLabel: 'Back',
              onAction: () => Navigator.of(context).pop(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(DzSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood indicator
                    DzCard(
                      child: Padding(
                        padding: const EdgeInsets.all(DzSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              (entry.mood as dynamic).icon as IconData,
                              color: (entry.mood as dynamic).iconColor as Color,
                              size: 32,
                            ),
                            const SizedBox(width: DzSpacing.md),
                            Text(
                              (entry.mood as dynamic).name as String,
                              style: DzTextStyles.heading3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: DzSpacing.md),

                    // Title
                    Text(
                      entry.title as String,
                      style: DzTextStyles.heading2,
                    ),
                    const SizedBox(height: DzSpacing.sm),

                    // Timestamp
                    Text(
                      '${entry.timestamp}',
                      style: DzTextStyles.caption,
                    ),
                    const SizedBox(height: DzSpacing.md),

                    // Body in a card for visual separation
                    DzCard(
                      child: Padding(
                        padding: const EdgeInsets.all(DzSpacing.md),
                        child: Text(
                          entry.body as String,
                          style: DzTextStyles.body,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
