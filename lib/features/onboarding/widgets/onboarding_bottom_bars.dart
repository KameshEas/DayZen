import 'package:flutter/material.dart';
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
          // Dots
          Expanded(
            child: Center(
              child: OnboardingPageDots(total: totalPages, current: currentPage),
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
          OnboardingPageDots(total: totalPages, current: totalPages - 1),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    );
  }
}
