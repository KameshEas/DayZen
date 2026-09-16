import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import 'onboarding_decoration_widgets.dart';

/// Slides 1 & 2: Back | dots | Next
class OnboardingStandardBottomBar extends StatelessWidget {
  const OnboardingStandardBottomBar({
    super.key,
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
          // Dots + step label
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OnboardingPageDots(total: totalPages, current: currentPage),
                const SizedBox(height: 4),
                Semantics(
                  label: 'Step ${currentPage + 1} of $totalPages',
                  child: ExcludeSemantics(
                    child: Text(
                      '${currentPage + 1} of $totalPages',
                      style: DzTextStyles.small,
                    ),
                  ),
                ),
              ],
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
                backgroundColor: Theme.of(context).colorScheme.primary,
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
class OnboardingFinalBottomBar extends StatelessWidget {
  const OnboardingFinalBottomBar({
    super.key,
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
          _GlowPulse(
            child: DzPrimaryButton(
              label: AppConfig.onboardingPrimaryCta,
              icon: const Icon(Icons.arrow_forward_rounded,
                  color: DzColors.white, size: 18),
              onPressed: onOffline,
            ),
          ),
          const SizedBox(height: DzSpacing.sm),
          DzSecondaryButton(
            label: AppConfig.onboardingSecondaryCta,
            onPressed: onSync,
          ),
          const SizedBox(height: DzSpacing.lg),
          OnboardingPageDots(total: totalPages, current: totalPages - 1),
          const SizedBox(height: 4),
          Semantics(
            label: 'Step $totalPages of $totalPages',
            child: ExcludeSemantics(
              child: Text('$totalPages of $totalPages', style: DzTextStyles.small),
            ),
          ),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    );
  }
}

/// Soft looping glow behind the final slide's primary CTA, to draw the
/// eye toward the one action most users should take.
class _GlowPulse extends StatefulWidget {
  const _GlowPulse({required this.child});
  final Widget child;

  @override
  State<_GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<_GlowPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);
  late final Animation<double> _glow =
      Tween<double>(begin: 0.15, end: 0.4).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DzRadius.fab),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: _glow.value),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
