import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import '../journal_controller.dart';
import 'widgets/journal_entry_card.dart';
import 'widgets/journal_new_entry_sheet.dart';
import 'widgets/journal_recent_entries_header.dart';
import 'widgets/journal_sync_indicator.dart';
import 'widgets/journal_weekly_reflection_banner.dart';

// ─────────────────────────────────────────────────────────────────────────────
// JournalPage — composes the individual card/sheet widgets under
// features/journal/widgets/. Split from a single 417-line file (grown from
// the Phase 4 CustomScrollView conversion) in Phase 5.1 of
// docs/DEVELOPMENT_PLAN.md.
// ─────────────────────────────────────────────────────────────────────────────

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  void _openNewEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JournalNewEntrySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalCtrl = JournalScope.of(context);
    return ListenableBuilder(
      listenable: journalCtrl,
      builder: (context, _) => Scaffold(
        backgroundColor: DzColors.appBackground,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: _openNewEntry,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        // CustomScrollView + SliverList.separated so the (unbounded-growth)
        // entry list is lazily built — only visible entries (plus a small
        // buffer) are constructed, rather than every entry a user has ever
        // written. See docs/PERFORMANCE_TESTING.md (Phase 4 of
        // docs/DEVELOPMENT_PLAN.md). The header content above the list
        // stays as a plain sliver since it's fixed-size regardless of
        // entry count.
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  DzSpacing.lg, DzSpacing.md, DzSpacing.lg, 0),
              sliver: SliverList.list(
                children: [
                  JournalWeeklyReflectionBanner(count: journalCtrl.thisWeekCount),
                  const SizedBox(height: DzSpacing.xl),
                  JournalSyncIndicator(
                    journalController: journalCtrl,
                    showFullStatus: true,
                  ),
                  const SizedBox(height: DzSpacing.md),
                  const JournalRecentEntriesHeader(),
                  const SizedBox(height: DzSpacing.md),
                ],
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
              sliver: _buildEntriesSliver(journalCtrl),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: DzSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesSliver(JournalController journalCtrl) {
    final entries = journalCtrl.all;
    if (entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DzSpacing.xl),
          child: DzEmptyState(
            icon: Icons.edit_note_outlined,
            title: 'No entries yet',
            subtitle: 'Start journaling to reflect on your day',
            actionLabel: 'Write your first entry',
            onAction: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const JournalNewEntrySheet(),
            ),
          ),
        ),
      );
    }
    return SliverList.separated(
      itemCount: entries.length,
      itemBuilder: (context, i) => JournalEntryCard(entry: entries[i]),
      separatorBuilder: (context, i) => const SizedBox(height: DzSpacing.md),
    );
  }
}
