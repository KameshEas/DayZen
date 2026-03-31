import 'package:flutter/material.dart';
import '../tokens/dz_colors.dart';
import '../tokens/dz_dimensions.dart';
import '../tokens/dz_shadows.dart';
import '../tokens/dz_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzNavItem model
// ─────────────────────────────────────────────────────────────────────────────

class DzNavItem {
  const DzNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final Widget icon;
  final Widget activeIcon;
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// DzBottomNavBar
// ─────────────────────────────────────────────────────────────────────────────

/// Persistent bottom navigation bar for DayZen.
///
/// The center slot is reserved for the FAB — pass [fabIndex] to mark which
/// index is the FAB slot so it renders as an empty transparent space (FAB overlays this slot).
///
/// ```dart
/// DzBottomNavBar(
///   items: DzNavDefaults.items,
///   currentIndex: _index,
///   fabIndex: 2,
///   onTap: (i) => setState(() => _index = i),
/// )
/// ```
class DzBottomNavBar extends StatelessWidget {
  const DzBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.fabIndex = 2,
  });

  final List<DzNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// The index position occupied by the FAB; rendered as blank space.
  final int fabIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? DzColors.darkCard : DzColors.cardBackground;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: DzSizing.bottomNavHeight,
          child: Row(
            children: List.generate(items.length, (i) {
              if (i == fabIndex) {
                return const Expanded(child: SizedBox.shrink());
              }
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavTile(
                  item: items[i],
                  isActive: isActive,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final DzNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Theme.of(context).colorScheme.primary : DzColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DzRadius.button),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: DzDuration.fast,
            child: IconTheme(
              data: IconThemeData(color: color),
              child: isActive
                  ? KeyedSubtree(key: const ValueKey('active'), child: item.activeIcon)
                  : KeyedSubtree(key: const ValueKey('inactive'), child: item.icon),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: DzTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzFab
// ─────────────────────────────────────────────────────────────────────────────

/// The center FAB for the DayZen bottom bar.
/// Wrap this in [FloatingActionButtonLocation.centerDocked] positioning.
class DzFab extends StatefulWidget {
  const DzFab({
    super.key,
    this.onPressed,
    this.icon = const Icon(Icons.add_rounded, size: 28),
    this.tooltip = 'Add',
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String tooltip;

  @override
  State<DzFab> createState() => _DzFabState();
}

class _DzFabState extends State<DzFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: DzShadows.fab,
      ),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: FloatingActionButton(
              onPressed: _onTap,
              tooltip: widget.tooltip,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzNavDefaults — Default nav items for DayZen
// ─────────────────────────────────────────────────────────────────────────────

abstract final class DzNavDefaults {
  static const List<DzNavItem> items = [
    DzNavItem(
      icon: Icon(Icons.home_outlined, size: 24),
      activeIcon: Icon(Icons.home_rounded, size: 24),
      label: 'Home',
    ),
    DzNavItem(
      icon: Icon(Icons.calendar_today_outlined, size: 24),
      activeIcon: Icon(Icons.calendar_today_rounded, size: 24),
      label: 'Planner',
    ),
    // index 2 → FAB slot (center button overlays here)
    DzNavItem(
      icon: SizedBox.shrink(),
      activeIcon: SizedBox.shrink(),
      label: '',
    ),
    DzNavItem(
      icon: Icon(Icons.bar_chart_outlined, size: 24),
      activeIcon: Icon(Icons.bar_chart_rounded, size: 24),
      label: 'Insights',
    ),
    DzNavItem(
      icon: Icon(Icons.book_outlined, size: 24),
      activeIcon: Icon(Icons.book_rounded, size: 24),
      label: 'Journal',
    ),
  ];
}
