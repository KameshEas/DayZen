import 'package:flutter/material.dart';
import '../tokens/dz_dimensions.dart';
import '../tokens/dz_colors.dart';
import 'dz_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzScaffold
// ─────────────────────────────────────────────────────────────────────────────

/// The base scaffold for all DayZen main pages.
///
/// Wires up the persistent [DzBottomNavBar] and center [DzFab] automatically.
///
/// ```dart
/// DzScaffold(
///   currentIndex: _tabIndex,
///   onNavTap: (i) => setState(() => _tabIndex = i),
///   onFabPressed: _openAddTask,
///   body: _pages[_tabIndex],
/// )
/// ```
class DzScaffold extends StatelessWidget {
  const DzScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavTap,
    this.onFabPressed,
    this.appBar,
    this.showNav = true,
    this.showFab = true,
    this.resizeToAvoidBottomInset = true,
    this.navItems,
    this.fabIndex = 2,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onFabPressed;
  final PreferredSizeWidget? appBar;

  /// Set to [false] on auth screens.
  final bool showNav;
  final bool showFab;
  final bool resizeToAvoidBottomInset;
  final List<DzNavItem>? navItems;
  final int fabIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
      bottomNavigationBar: showNav
          ? DzBottomNavBar(
              items: navItems ?? DzNavDefaults.items,
              currentIndex: currentIndex,
              onTap: onNavTap,
              fabIndex: fabIndex,
            )
          : null,
      floatingActionButton: showFab && showNav
          ? DzFab(onPressed: onFabPressed)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzAuthScaffold
// ─────────────────────────────────────────────────────────────────────────────

/// Scaffold for auth / onboarding screens: no nav bar, centered content.
class DzAuthScaffold extends StatelessWidget {
  const DzAuthScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(child: body),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzAppBar
// ─────────────────────────────────────────────────────────────────────────────

/// DayZen-branded [AppBar].
///
/// Elevation is always 0; uses the DayZen background color and
/// standard title styling.
class DzAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DzAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.centerTitle = false,
  }) : assert(
          title == null || titleWidget == null,
          'Provide either title or titleWidget, not both.',
        );

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(
        DzSizing.appBarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: DzSpacing.sm),
            ]
          : null,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      bottom: bottom,
      toolbarHeight: DzSizing.appBarHeight,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzPagePadding
// ─────────────────────────────────────────────────────────────────────────────

/// Standard horizontal page padding (16px).
class DzPagePadding extends StatelessWidget {
  const DzPagePadding({super.key, required this.child, this.vertical = true});

  final Widget child;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DzSpacing.md,
        vertical: vertical ? DzSpacing.md : 0,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzDrawer
// ─────────────────────────────────────────────────────────────────────────────

/// DayZen sidebar navigation drawer.
class DzDrawer extends StatelessWidget {
  const DzDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.header,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final Widget? header;

  static const List<_DrawerItem> _items = [
    _DrawerItem(icon: Icons.home_rounded, label: 'Home', route: '/home'),
    _DrawerItem(icon: Icons.calendar_today_rounded, label: 'Planner', route: '/planner'),
    _DrawerItem(icon: Icons.bar_chart_rounded, label: 'Insights', route: '/insights'),
    _DrawerItem(icon: Icons.book_rounded, label: 'Journal', route: '/journal'),
    _DrawerItem(icon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
    _DrawerItem(icon: Icons.shield_outlined, label: 'Privacy', route: '/privacy'),
    _DrawerItem(icon: Icons.info_outline_rounded, label: 'About', route: '/about'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              header!,
              const Divider(height: 1),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DzSpacing.md, DzSpacing.lg, DzSpacing.md, DzSpacing.md,
                ),
                child: Text('DayZen', style: theme.textTheme.headlineMedium),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: DzSpacing.sm),
                children: _items.map((item) {
                  final isActive = currentRoute == item.route;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: isActive
                          ? DzColors.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      item.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isActive ? DzColors.primary : null,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isActive,
                    selectedTileColor:
                        DzColors.primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DzRadius.small),
                    ),
                    onTap: () => onNavigate(item.route),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
