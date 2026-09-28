import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../../core/routing/route_paths.dart';
import '../app_data.dart';
import '../home/widgets/overdue_tasks_popup.dart';
import '../journal/widgets/journal_new_entry_sheet.dart';
import '../planner/planner_selection.dart';

/// Persistent shell that hosts Home, Planner, Insights, Journal tabs.
/// Index 2 is the FAB slot – tapping the FAB opens the New Task page.
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Once per app session, regardless of which tab the router lands on
    // first — mirrors AppVersionController's "check once, after first
    // frame" pattern.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      PlannerSelection.instance.catchUpToToday();
      maybeShowOverdueTasksPopup(context, TaskScope.of(context));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding the app doesn't kill the process, so PlannerSelection's
    // singleton survives across midnight if the app is just left open —
    // catch it up to the real "today" whenever the app comes back.
    if (state == AppLifecycleState.resumed) {
      PlannerSelection.instance.catchUpToToday();
    }
  }

  static const _pageTitles = ['DayZen', 'Planner', '', 'Insights', 'Journal'];
  static const _routePaths = [
    RoutePaths.home,
    RoutePaths.planner,
    '',
    RoutePaths.insights,
    RoutePaths.journal,
  ];

  void _onNavTap(int index) {
    if (index == 2) return; // FAB slot (handled by FAB button)
    setState(() => _currentIndex = index);
    if (_routePaths[index].isNotEmpty) {
      context.go(_routePaths[index]);
    }
  }

  void _onFabPressed() {
    // The centre "+" means "add" for whatever tab is showing: a task
    // everywhere except the Journal tab, where it means a journal entry
    // instead — Journal has no separate FAB of its own for that reason.
    if (_currentIndex == 4) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const JournalNewEntrySheet(),
      );
      return;
    }
    // On the Planner, the new task belongs to the day being viewed.
    final onPlanner = _currentIndex == 1;
    if (onPlanner) PlannerSelection.instance.catchUpToToday();
    context.push(
      RoutePaths.newTask,
      extra: onPlanner ? PlannerSelection.instance.value : null,
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
            ? const DzLogo(width: 150)
            : Text(
                _pageTitles[_currentIndex],
                style: DzTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: [
          // The notification test page is a developer tool: debug builds only.
          if (kDebugMode)
            Semantics(
              label: 'Debug',
              button: true,
              enabled: true,
              onTap: () => context.push('/debug/test-notification'),
              child: IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                tooltip: 'Debug',
                onPressed: () {
                  context.push('/debug/test-notification');
                },
              ),
            ),
          Semantics(
            label: 'Settings',
            button: true,
            enabled: true,
            onTap: () => context.push(RoutePaths.settings),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () {
                context.push(RoutePaths.settings);
              },
            ),
          ),
        ],
      ),
      // The router animates the change of tab itself. Wrapping `child` in an
      // AnimatedSwitcher kept the old and new copies of the same page alive at
      // once, which is a "Duplicate GlobalKey" error on every tab switch.
      body: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
