import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../../core/routing/route_paths.dart';

/// Persistent shell that hosts Home, Planner, Insights, Journal tabs.
/// Index 2 is the FAB slot – tapping the FAB opens the New Task page.
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

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
    context.push(RoutePaths.newTask);
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
