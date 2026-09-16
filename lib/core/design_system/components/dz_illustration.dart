import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Enumeration of available onboarding illustrations
enum DzIllustration {
  /// Legacy: Slide 1: Focus & Planning illustration
  focusPlanning,

  /// Legacy: Slide 2: Privacy & Security illustration
  privacySecurity,

  /// Legacy: Slide 3: Habit Building & Streaks illustration
  habitStreaks,

  /// New animated flow: Welcome slide
  welcome,

  /// New animated flow: Plan slide
  plan,

  /// New animated flow: Reflect slide
  reflect,

  /// New animated flow: Grow slide
  grow,

  /// New animated flow: Privacy slide
  privacy,

  /// New animated flow: Ready/All Set slide
  ready,
}

/// DzIllustration widget — displays vector or raster illustrations
/// for onboarding and other editorial contexts.
///
/// Illustrations are stored in assets/illustrations/ and are referenced
/// by enum. This allows for easy swapping and version management.
class DzIllustrationWidget extends StatelessWidget {
  const DzIllustrationWidget({
    super.key,
    required this.illustration,
    this.height = 240,
    this.width,
    this.fit = BoxFit.contain,
  });

  final DzIllustration illustration;
  final double height;
  final double? width;
  final BoxFit fit;

  /// Map enum to asset path
  String get _assetPath {
    switch (illustration) {
      case DzIllustration.focusPlanning:
        return 'assets/illustrations/onboarding_slide_1_focus_planning.png';
      case DzIllustration.privacySecurity:
        return 'assets/illustrations/onboarding_slide_2_privacy_security.png';
      case DzIllustration.habitStreaks:
        return 'assets/illustrations/onboarding_slide_3_habit_streaks.png';
      case DzIllustration.welcome:
        return 'assets/illustrations/dayzen_welcome_onboarding.svg';
      case DzIllustration.plan:
        return 'assets/illustrations/dayzen_plan_onboarding.svg';
      case DzIllustration.reflect:
        return 'assets/illustrations/dayzen_reflect_onboarding.svg';
      case DzIllustration.grow:
        return 'assets/illustrations/dayzen_grow_onboarding.svg';
      case DzIllustration.privacy:
        return 'assets/illustrations/dayzen_privacy_onboarding.svg';
      case DzIllustration.ready:
        return 'assets/illustrations/dayzen_ready_onboarding.svg';
    }
  }

  /// Check if this is an SVG illustration
  bool get _isSvg => _assetPath.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        _assetPath,
        height: height,
        width: width,
        fit: fit,
      );
    }
    return Image.asset(
      _assetPath,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
