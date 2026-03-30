import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../app_data.dart';
import '../home/home_page.dart';
import '../home/models/task_model.dart';
import '../insights/insights_page.dart';
import '../journal/journal_page.dart';
import '../planner/planner_page.dart';
import '../settings/settings_page.dart';

/// Persistent shell that hosts Home, Planner, Insights, Journal tabs.
/// Index 2 is the FAB placeholder – tapping it opens a quick-add bottom sheet.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pageTitles = ['DayZen', 'Planner', '', 'Insights', 'Journal'];

  final _pages = const [
    HomePage(),
    PlannerPage(),
    SizedBox.shrink(), // FAB slot – never shown
    const InsightsPage(),
    const JournalPage(),
  ];

  void _onNavTap(int index) {
    if (index == 2) return; // FAB slot
    setState(() => _currentIndex = index);
  }

  void _onFabPressed() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => const _QuickAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DzScaffold(
      currentIndex: _currentIndex,
      onNavTap: _onNavTap,
      onFabPressed: _onFabPressed,
      appBar: DzAppBar(
        titleWidget: _currentIndex == 0
            ? const DzLogo()
            : Text(
                _pageTitles[_currentIndex],
                style: DzTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder pages for Insights / Journal (to be built later)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Quick-add bottom sheet (stub)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet();

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  final _titleCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.routine;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final now = TimeOfDay.now();
    final task = DzTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      startTime: now,
      endTime: TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute),
      priority: _priority,
      icon: Icons.circle_outlined,
    );
    await AppData.of(context).tasks.addTask(task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DzSpacing.lg,
        DzSpacing.lg,
        DzSpacing.lg,
        DzSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Add Task', style: DzTextStyles.heading3),
          const SizedBox(height: DzSpacing.md),
          DzTextField(
            controller: _titleCtrl,
            hint: 'What do you need to do?',
            autofocus: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: DzSpacing.md),
          Row(
            children: TaskPriority.values.map((p) {
              final selected = _priority == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: DzDuration.fast,
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? p.bg : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? Border.all(color: p.color, width: 1.5)
                          : Border.all(color: DzColors.borderLight, width: 1),
                    ),
                    child: Text(
                      p.label,
                      textAlign: TextAlign.center,
                      style: DzTextStyles.small.copyWith(
                        color: selected ? p.color : DzColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DzSpacing.md),
          DzPrimaryButton(label: 'Add Task', onPressed: _save),
        ],
      ),
    );
  }
}
