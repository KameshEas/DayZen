import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../home/home_page.dart';
import '../insights/insights_page.dart';
import '../journal/journal_page.dart';
import '../planner/planner_page.dart';
import '../settings/settings_page.dart';
import '../tasks/new_task_page.dart';

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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewTaskPage()),
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
