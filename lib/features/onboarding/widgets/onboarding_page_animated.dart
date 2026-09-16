import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'onboarding_slide_animated.dart';
import 'onboarding_bottom_bars.dart';

/// Enhanced animated onboarding page using new SVG illustrations
/// with smooth transitions and animations.
class AnimatedOnboardingPage extends StatefulWidget {
  const AnimatedOnboardingPage({
    super.key,
    this.onDone,
    this.onEnableSync,
  });

  final VoidCallback? onDone;
  final VoidCallback? onEnableSync;

  @override
  State<AnimatedOnboardingPage> createState() => _AnimatedOnboardingPageState();
}

class _AnimatedOnboardingPageState extends State<AnimatedOnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  static const int _totalPages = 6;

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

              // Logo + Skip button
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

              // Slides PageView
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    AnimatedOnboardingSlideWelcome(
                      controller: _controller,
                      index: 0,
                    ),
                    AnimatedOnboardingSlidePlan(
                      controller: _controller,
                      index: 1,
                    ),
                    AnimatedOnboardingSlideReflect(
                      controller: _controller,
                      index: 2,
                    ),
                    AnimatedOnboardingSlideGrow(
                      controller: _controller,
                      index: 3,
                    ),
                    AnimatedOnboardingSlidePrivacy(
                      controller: _controller,
                      index: 4,
                    ),
                    AnimatedOnboardingSlideReady(
                      controller: _controller,
                      index: 5,
                    ),
                  ],
                ),
              ),

              // Bottom controls
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
