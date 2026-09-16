import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'widgets/onboarding_bottom_bars.dart';
import 'widgets/onboarding_slide_1.dart';
import 'widgets/onboarding_slide_2.dart';
import 'widgets/onboarding_slide_3.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// OnboardingPage â€” composes the 3 slide widgets + bottom bars under
// features/onboarding/widgets/. Split from a single 758-line file in
// Phase 5.1 of docs/DEVELOPMENT_PLAN.md.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
      backgroundColor: DzColors.onboardingScaffoldBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              DzColors.primaryTint,
              DzColors.onboardingGradientMid,
              DzColors.onboardingGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: DzSpacing.lg),

              // â”€â”€ Logo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
                child: Row(
                  children: [
                    const SizedBox(width: 56),
                    Expanded(
                      child: Center(
                        child: DzLogo(
                          variant: DzLogoVariant.wordmarkOnly,
                          size: DzLogoSize.large,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: _currentPage < _totalPages - 1
                          ? TextButton(
                              onPressed: () => _goTo(_totalPages - 1),
                              style: TextButton.styleFrom(
                                foregroundColor: DzColors.textSecondary,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Skip',
                                style: DzTextStyles.caption
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DzSpacing.lg),

              // â”€â”€ Slides â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    OnboardingSlide1(controller: _controller, index: 0),
                    OnboardingSlide2(controller: _controller, index: 1),
                    OnboardingSlide3(controller: _controller, index: 2),
                  ],
                ),
              ),

              // â”€â”€ Bottom controls â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (_currentPage < _totalPages - 1)
                OnboardingStandardBottomBar(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onBack: _currentPage > 0 ? _back : null,
                  onNext: _next,
                )
              else
                OnboardingFinalBottomBar(
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



