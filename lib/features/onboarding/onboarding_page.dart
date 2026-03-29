import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingPage
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onDone, this.onEnableSync});

  final VoidCallback? onDone;
  final VoidCallback? onEnableSync;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: DzDuration.normal,
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentPage < _totalPages - 1) _goTo(_currentPage + 1);
  }

  void _back() {
    if (_currentPage > 0) _goTo(_currentPage - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFFDDE8F8),
              Color(0xFFEEF3FA),
              Color(0xFFF4F7FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: DzSpacing.lg),

              // ── Logo ──────────────────────────────────────────
              AnimatedSwitcher(
                duration: DzDuration.normal,
                child: _currentPage == 1
                    ? const DzLogo(key: ValueKey('wordmark'), variant: DzLogoVariant.wordmarkOnly)
                    : const DzLogo(key: ValueKey('logo')),
              ),

              const SizedBox(height: DzSpacing.lg),

              // ── Slides ────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: const [
                    _Slide1Content(),
                    _Slide2Content(),
                    _Slide3Content(),
                  ],
                ),
              ),

              // ── Bottom controls ───────────────────────────────
              if (_currentPage < _totalPages - 1)
                _StandardBottomBar(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onBack: _currentPage > 0 ? _back : null,
                  onNext: _next,
                )
              else
                _FinalBottomBar(
                  totalPages: _totalPages,
                  onOffline: widget.onDone,
                  onSync: widget.onEnableSync,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 1 — "DayZen / Plan simply. Stay focused."
// ─────────────────────────────────────────────────────────────────────────────

class _Slide1Content extends StatelessWidget {
  const _Slide1Content();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Column(
        children: [
          _HeroCardShell(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    _IconTile(
                      color: Color(0xFFDDE4F8),
                      shape: BoxShape.rectangle,
                      radius: 28,
                      icon: Icons.calendar_month_rounded,
                      iconColor: DzColors.primary,
                    ),
                    SizedBox(width: DzSpacing.md),
                    _IconTile(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                      icon: Icons.eco_rounded,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
                const Positioned(
                  top: -20,
                  right: -28,
                  child: _FloatingChip(
                    bgColor: Color(0xFFF59E0B),
                    icon: Icons.done_all_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          const _SlideText(
            title: 'DayZen',
            subtitle: 'Plan simply. Stay focused.',
            accent: 'Live calm.',
          ),
          const SizedBox(height: DzSpacing.lg),
          const _PillBadge(
            icon: Icons.shield_rounded,
            label: '100% OFFLINE AI',
            style: _PillStyle.gray,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 2 — "Your Data Stays With You"
// ─────────────────────────────────────────────────────────────────────────────

class _Slide2Content extends StatelessWidget {
  const _Slide2Content();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Column(
        children: [
          // Hero: two overlapping offset white cards
          SizedBox(
            height: 260,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Back card — slightly rotated left
                Positioned(
                  left: 20,
                  top: 0,
                  child: Transform.rotate(
                    angle: -0.06,
                    child: _WhiteCard(
                      width: 200,
                      height: 230,
                      child: Center(
                        child: Icon(
                          Icons.phone_iphone_rounded,
                          size: 72,
                          color: const Color(0xFFA8BBDB),
                        ),
                      ),
                    ),
                  ),
                ),
                // Front card — bottom-right, lock icon
                Positioned(
                  right: 20,
                  bottom: 0,
                  child: _WhiteCard(
                    width: 160,
                    height: 160,
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: DzColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          const _SlideText(
            title: 'Your Data Stays\nWith You',
            subtitle:
                'Everything is stored locally. No tracking. No cloud by default. Experience productivity with total peace of mind.',
          ),
          const SizedBox(height: DzSpacing.lg),
          const _PillBadge(
            icon: Icons.verified_user_rounded,
            label: 'Offline-First Security',
            style: _PillStyle.green,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 3 — "Ready to Plan Your Day?" (final)
// ─────────────────────────────────────────────────────────────────────────────

class _Slide3Content extends StatelessWidget {
  const _Slide3Content();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Column(
        children: [
          // Hero: task card with floating circular badges
          SizedBox(
            height: 240,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Center(
                  child: _WhiteCard(
                    width: 280,
                    height: 190,
                    child: Padding(
                      padding: const EdgeInsets.all(DzSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _TaskLine(width: 140, color: Color(0xFFCBD5E1)),
                          SizedBox(height: DzSpacing.sm),
                          _TaskLine(width: 180, color: Color(0xFFCBD5E1)),
                          SizedBox(height: DzSpacing.sm),
                          _TaskLine(width: 110, color: Color(0xFFDCFAF0)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Green check — top right
                const Positioned(
                  top: 8,
                  right: 10,
                  child: _BadgeCircle(
                    size: 44,
                    color: Color(0xFF34D399),
                    icon: Icons.check_rounded,
                    iconColor: Colors.white,
                  ),
                ),
                // Blue clock — bottom right of card
                const Positioned(
                  bottom: 14,
                  right: 42,
                  child: _BadgeCircle(
                    size: 52,
                    color: DzColors.primary,
                    icon: Icons.schedule_rounded,
                    iconColor: Colors.white,
                  ),
                ),
                // Small muted circle — left side
                const Positioned(
                  left: 6,
                  bottom: 46,
                  child: _BadgeCircle(
                    size: 34,
                    color: Color(0xFFDDE8F8),
                    icon: Icons.done_all_rounded,
                    iconColor: Color(0xFF93B0D4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          const _SlideText(
            title: 'Ready to Plan\nYour Day?',
            subtitle: 'Start offline instantly or enable sync anytime.',
          ),
          const SizedBox(height: DzSpacing.lg),
          const _PillBadge(
            icon: Icons.shield_rounded,
            label: 'YOUR DATA STAYS ON DEVICE',
            style: _PillStyle.gray,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bars
// ─────────────────────────────────────────────────────────────────────────────

/// Slides 1 & 2: Back | dots | Next
class _StandardBottomBar extends StatelessWidget {
  const _StandardBottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    this.onBack,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DzSpacing.md, DzSpacing.sm, DzSpacing.md, DzSpacing.lg),
      child: Row(
        children: [
          // Back
          SizedBox(
            width: 80,
            child: onBack != null
                ? TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back'),
                    style: TextButton.styleFrom(
                      foregroundColor: DzColors.textSecondary,
                      textStyle:
                          DzTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Dots
          Expanded(
            child: Center(
              child: _PageDots(total: totalPages, current: currentPage),
            ),
          ),
          // Next pill button
          SizedBox(
            width: 110,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DzColors.primary,
                foregroundColor: DzColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DzRadius.fab),
                ),
                textStyle: DzTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide 3: two stacked action buttons + dots
class _FinalBottomBar extends StatelessWidget {
  const _FinalBottomBar({
    required this.totalPages,
    this.onOffline,
    this.onSync,
  });

  final int totalPages;
  final VoidCallback? onOffline;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DzSpacing.md, DzSpacing.md, DzSpacing.md, DzSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DzPrimaryButton(
            label: 'Start Offline',
            icon: const Icon(Icons.arrow_forward_rounded,
                color: DzColors.white, size: 18),
            onPressed: onOffline,
          ),
          const SizedBox(height: DzSpacing.sm),
          DzSecondaryButton(
            label: 'Enable Sync (Optional)',
            onPressed: onSync,
          ),
          const SizedBox(height: DzSpacing.lg),
          _PageDots(total: totalPages, current: totalPages - 1),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Shared micro-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SlideText extends StatelessWidget {
  const _SlideText({
    required this.title,
    required this.subtitle,
    this.accent,
  });

  final String title;
  final String subtitle;
  final String? accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'InterDisplay',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: DzColors.textPrimary,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: DzSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: DzTextStyles.body.copyWith(
            color: DzColors.textSecondary,
            height: 1.6,
          ),
        ),
        if (accent != null) ...[
          const SizedBox(height: DzSpacing.xs),
          Text(
            accent!,
            textAlign: TextAlign.center,
            style: DzTextStyles.body.copyWith(
              color: DzColors.zenGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

enum _PillStyle { gray, green }

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.icon,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final String label;
  final _PillStyle style;

  @override
  Widget build(BuildContext context) {
    final isGreen = style == _PillStyle.green;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: DzSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: isGreen
            ? DzColors.zenGreen.withValues(alpha: 0.15)
            : const Color(0xFFE4EAF4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isGreen ? DzColors.zenGreen : DzColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: DzTextStyles.small.copyWith(
              color: isGreen ? DzColors.zenGreen : DzColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: isGreen ? 0.2 : 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// White elevated card container.
class _WhiteCard extends StatelessWidget {
  const _WhiteCard({
    required this.child,
    required this.width,
    required this.height,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DzRadius.modal + 4),
        boxShadow: DzShadows.elevated,
      ),
      child: child,
    );
  }
}

/// Hero card shell (slide 1).
class _HeroCardShell extends StatelessWidget {
  const _HeroCardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DzSpacing.xl,
        vertical: DzSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DzRadius.modal + 4),
        boxShadow: DzShadows.elevated,
      ),
      child: Center(child: child),
    );
  }
}

/// Square or circle icon tile (slide 1 hero).
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.color,
    required this.shape,
    required this.icon,
    required this.iconColor,
    this.radius = 0,
  });

  final Color color;
  final BoxShape shape;
  final IconData icon;
  final Color iconColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(radius)
            : null,
      ),
      child: Icon(icon, size: 52, color: iconColor),
    );
  }
}

/// Floating chip badge (slide 1, top-right of hero).
class _FloatingChip extends StatelessWidget {
  const _FloatingChip({required this.bgColor, required this.icon});

  final Color bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DzShadows.soft,
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Circular floating badge (slide 3 hero).
class _BadgeCircle extends StatelessWidget {
  const _BadgeCircle({
    required this.size,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final double size;
  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: DzShadows.soft,
      ),
      child: Icon(icon, color: iconColor, size: size * 0.44),
    );
  }
}

/// Task skeleton line (slide 3 hero card).
class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.width, required this.color});
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Animated dot page indicators.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: DzDuration.fast,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? DzColors.primary : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
