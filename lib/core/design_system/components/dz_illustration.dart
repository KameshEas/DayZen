import 'package:flutter/material.dart';

/// Enumeration of available onboarding illustrations
enum DzIllustration {
  /// Slide 1: Focus & Planning illustration
  focusPlanning,

  /// Slide 2: Privacy & Security illustration
  privacySecurity,

  /// Slide 3: Habit Building & Streaks illustration
  habitStreaks,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
