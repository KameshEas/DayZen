import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../home/home_page.dart';
import '../planner/planner_page.dart';

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
    _PlaceholderPage(icon: Icons.bar_chart_rounded, label: 'Insights'),
    _PlaceholderPage(icon: Icons.book_rounded, label: 'Journal'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon.')),
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

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: DzColors.borderLight),
          const SizedBox(height: DzSpacing.md),
          Text(
            '$label coming soon.',
            style: DzTextStyles.body.copyWith(color: DzColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick-add bottom sheet (stub)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

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
          const DzTextField(hint: 'What do you need to do?'),
          const SizedBox(height: DzSpacing.md),
          DzPrimaryButton(
            label: 'Add Task',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
