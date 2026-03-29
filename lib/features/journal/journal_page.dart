import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

enum JournalMood { happy, peaceful, inspired, overwhelmed }

extension JournalMoodX on JournalMood {
  IconData get icon => switch (this) {
        JournalMood.happy => Icons.sentiment_very_satisfied_rounded,
        JournalMood.peaceful => Icons.self_improvement_rounded,
        JournalMood.inspired => Icons.lightbulb_outline_rounded,
        JournalMood.overwhelmed => Icons.sentiment_dissatisfied_rounded,
      };

  Color get iconColor => switch (this) {
        JournalMood.happy => const Color(0xFF10B981),
        JournalMood.peaceful => const Color(0xFF3B82F6),
        JournalMood.inspired => const Color(0xFFF59E0B),
        JournalMood.overwhelmed => const Color(0xFFEF4444),
      };

  Color get bg => switch (this) {
        JournalMood.happy => const Color(0xFFD1FAE5),
        JournalMood.peaceful => const Color(0xFFDBEAFE),
        JournalMood.inspired => const Color(0xFFFEF3C7),
        JournalMood.overwhelmed => const Color(0xFFFEE2E2),
      };
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.dateLabel,
    this.isPhotoEntry = false,
    this.accentColor,
  });

  final String id;
  final String title;
  final String body;
  final JournalMood mood;
  final String dateLabel;
  final bool isPhotoEntry;
  final Color? accentColor;
}

class _JournalMockData {
  static const entries = [
    JournalEntry(
      id: '1',
      title: 'Feeling productive',
      body: 'Feeling productive today after my morning meditation. '
          'The focus exercises are really helping me stay on track with my work goals.',
      mood: JournalMood.happy,
      dateLabel: 'Today, 9:30 AM',
    ),
    JournalEntry(
      id: '2',
      title: 'Quiet Moment',
      body: 'Spent some time by the park. It\'s amazing how much a little nature can '
          'reset your mood. No screens, just peace.',
      mood: JournalMood.peaceful,
      dateLabel: 'Yesterday, 8:45 PM',
    ),
    JournalEntry(
      id: '3',
      title: 'New Perspective',
      body: 'Had a breakthrough regarding the new project. Journaling my thoughts helped clear the fog.',
      mood: JournalMood.inspired,
      dateLabel: 'Jun 12, 2:15 PM',
      accentColor: Color(0xFFF59E0B),
    ),
    JournalEntry(
      id: '5',
      title: 'A bit overwhelmed',
      body: 'Too many tasks today. Need to prioritize and breathe. '
          'Writing it down makes it feel more manageable.',
      mood: JournalMood.overwhelmed,
      dateLabel: 'Jun 10, 10:00 AM',
    ),
  ];
}

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
    return Scaffold(
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
          const _WeeklyReflectionBanner(),
          const SizedBox(height: DzSpacing.xl),
          const _RecentEntriesHeader(),
          const SizedBox(height: DzSpacing.md),
          ..._buildEntries(),
          const SizedBox(height: DzSpacing.xl),
        ],
      ),
    );
  }

  List<Widget> _buildEntries() {
    final widgets = <Widget>[];
    for (int i = 0; i < _JournalMockData.entries.length; i++) {
      final entry = _JournalMockData.entries[i];
      widgets.add(_JournalEntryCard(entry: entry));
      widgets.add(const SizedBox(height: DzSpacing.md));
      // Insert photo card between index 2 and 3 (after 'New Perspective')
      if (i == 2) {
        widgets.add(const _PhotoCard());
        widgets.add(const SizedBox(height: DzSpacing.md));
      }
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly reflection banner
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyReflectionBanner extends StatelessWidget {
  const _WeeklyReflectionBanner();

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
          // decorative stars
          Positioned(
            right: 8,
            top: 4,
            child: Opacity(
              opacity: 0.18,
              child: Icon(Icons.auto_awesome,
                  color: Colors.white, size: 80),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 4,
            child: Opacity(
              opacity: 0.12,
              child: Icon(Icons.auto_awesome,
                  color: Colors.white, size: 48),
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
                'Keep it up!',
                style: DzTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: DzSpacing.sm),
              Text(
                'You\'ve logged 5 entries this week.\nConsistency is the key to mindfulness.',
                style: DzTextStyles.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
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
// Photo / Captured Moments card
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  const _PhotoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DzRadius.card),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D4A3E), Color(0xFF4A7C59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(DzSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.photo_camera_outlined,
              color: Colors.white60, size: 18),
          const SizedBox(width: 6),
          Text(
            'Captured Moments',
            style: DzTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
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
                // TODO: persist entry
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry saved!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
