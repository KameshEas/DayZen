import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import '../journal_controller.dart';
import 'models/journal_entry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// JournalPage
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
      builder: (_) => const _NewEntrySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalCtrl = AppData.of(context).journal;
    return ListenableBuilder(
      listenable: journalCtrl,
      builder: (context, _) => Scaffold(
        backgroundColor: DzColors.appBackground,
        floatingActionButton: FloatingActionButton(
          backgroundColor: DzColors.primary,
          onPressed: _openNewEntry,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: DzSpacing.lg, vertical: DzSpacing.md),
          children: [
            _WeeklyReflectionBanner(count: journalCtrl.thisWeekCount),
            const SizedBox(height: DzSpacing.xl),
            const _RecentEntriesHeader(),
            const SizedBox(height: DzSpacing.md),
            ..._buildEntries(journalCtrl),
            const SizedBox(height: DzSpacing.xl),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEntries(JournalController journalCtrl) {
    final entries = journalCtrl.all;
    if (entries.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DzSpacing.xl),
          child: Center(
            child: Text(
              'No entries yet. Tap + to write your first.',
              style: DzTextStyles.body.copyWith(color: DzColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }
    final widgets = <Widget>[];
    for (final entry in entries) {
      widgets.add(_JournalEntryCard(entry: entry));
      widgets.add(const SizedBox(height: DzSpacing.md));
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly reflection banner
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyReflectionBanner extends StatelessWidget {
  const _WeeklyReflectionBanner({required this.count});
  final int count;

  String get _headline {
    if (count == 0) return 'Start your journey';
    if (count <= 2) return 'Good start!';
    if (count <= 4) return 'Keep it up!';
    return 'You\'re on fire!';
  }

  String get _subtitle {
    if (count == 0) return 'Write your first entry today.';
    return 'You\'ve logged $count entr${count == 1 ? 'y' : 'ies'} this week.\nConsistency is the key to mindfulness.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DzColors.primary,
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 4,
            child: Opacity(
              opacity: 0.18,
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 80),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 4,
            child: Opacity(
              opacity: 0.12,
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Reflection',
                style: DzTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _headline,
                style: DzTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: DzSpacing.sm),
              Text(
                _subtitle,
                style: DzTextStyles.body
                    .copyWith(color: Colors.white.withValues(alpha: 0.88)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Entries header row
// ─────────────────────────────────────────────────────────────────────────────

class _RecentEntriesHeader extends StatelessWidget {
  const _RecentEntriesHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear =
        '${_monthName(now.month).toUpperCase()} ${now.year}';

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

  String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];
}

// ─────────────────────────────────────────────────────────────────────────────
// Journal entry card
// ─────────────────────────────────────────────────────────────────────────────

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});
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

// ─────────────────────────────────────────────────────────────────────────────
// New entry bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _NewEntrySheet extends StatefulWidget {
  const _NewEntrySheet();

  @override
  State<_NewEntrySheet> createState() => _NewEntrySheetState();
}

class _NewEntrySheetState extends State<_NewEntrySheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  JournalMood _selectedMood = JournalMood.happy;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: DzColors.cardBackground,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(DzRadius.modal)),
        ),
        padding: const EdgeInsets.fromLTRB(
            DzSpacing.lg, DzSpacing.lg, DzSpacing.lg, DzSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: DzColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.lg),
            Text('New Entry',
                style: DzTextStyles.heading3
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DzSpacing.md),
            // Mood picker
            Row(
              children: JournalMood.values.map((mood) {
                final selected = _selectedMood == mood;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: AnimatedContainer(
                      duration: DzDuration.fast,
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? mood.bg : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(color: mood.iconColor, width: 1.5)
                            : Border.all(
                                color: DzColors.borderLight, width: 1),
                      ),
                      child: Icon(mood.icon,
                          color: mood.iconColor,
                          size: selected ? 24 : 20),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: DzSpacing.md),
            DzTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'What\'s on your mind?',
            ),
            const SizedBox(height: DzSpacing.md),
            DzTextField(
              controller: _bodyController,
              label: 'Write your thoughts…',
              hint: '',
              maxLines: 4,
            ),
            const SizedBox(height: DzSpacing.lg),
            DzPrimaryButton(
              label: 'Save Entry',
              onPressed: () {
                final title = _titleController.text.trim();
                final body = _bodyController.text.trim();
                if (title.isEmpty) return;
                final entry = JournalEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  body: body.isEmpty ? '' : body,
                  mood: _selectedMood,
                  timestamp: DateTime.now(),
                  accentColor: _selectedMood.iconColor,
                );
                AppData.of(context).journal.addEntry(entry);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
