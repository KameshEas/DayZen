import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Which logo lockup to show. Pick by context (see assets/branding/README.md):
///
/// | Layout       | Use for                                             |
/// |--------------|-----------------------------------------------------|
/// | [primary]    | Splash, About — mark + wordmark + tagline           |
/// | [stacked]    | Login/sign-up, onboarding, empty states             |
/// | [horizontal] | App bars, headers                                   |
/// | [wordmark]   | Only where the mark already appears nearby          |
/// | [mark]       | Small UI, PIN/biometric screens, loaders, watermarks|
enum DzLogoLayout {
  primary('primary', 991, 630),
  stacked('stacked', 991, 569),
  horizontal('horizontal', 1473, 342),
  wordmark('wordmark', 991, 342),
  mark('mark', 432, 248);

  const DzLogoLayout(this.file, this.artWidth, this.artHeight);

  final String file;
  final double artWidth;
  final double artHeight;

  double get aspectRatio => artWidth / artHeight;
}

/// Which colorway to use. [auto] follows the theme: color on light surfaces,
/// reversed (white + Sunrise) on dark ones.
enum DzLogoTone {
  auto('color'),
  color('color'),
  reversed('reversed'),
  monoDark('mono-dark'),
  monoLight('mono-light');

  const DzLogoTone(this.suffix);

  final String suffix;
}

/// The DayZen logo, rendered from the vector kit in assets/branding/logo/.
///
/// ```dart
/// DzLogo(layout: DzLogoLayout.stacked, width: 200)
/// DzLogo(layout: DzLogoLayout.mark, width: 56)
/// ```
///
/// Give [width] (or [height]); the other side follows the artwork's aspect
/// ratio. Kit minimum widths in physical px: primary 240, horizontal 220,
/// stacked 140, wordmark 120, mark 32.
class DzLogo extends StatelessWidget {
  const DzLogo({
    super.key,
    this.layout = DzLogoLayout.horizontal,
    this.tone = DzLogoTone.auto,
    this.width,
    this.height,
  });

  final DzLogoLayout layout;
  final DzLogoTone tone;
  final double? width;
  final double? height;

  static String assetPath(DzLogoLayout layout, DzLogoTone tone) =>
      'assets/branding/logo/dayzen-${layout.file}-${tone.suffix}.svg';

  @override
  Widget build(BuildContext context) {
    final resolved = tone == DzLogoTone.auto
        ? (Theme.of(context).brightness == Brightness.dark
            ? DzLogoTone.reversed
            : DzLogoTone.color)
        : tone;

    final w = width ??
        (height != null ? height! * layout.aspectRatio : _defaultWidth);
    final h = w / layout.aspectRatio;

    return SvgPicture.asset(
      assetPath(layout, resolved),
      width: w,
      height: h,
      semanticsLabel: 'DayZen',
    );
  }

  double get _defaultWidth => switch (layout) {
        DzLogoLayout.primary => 260,
        DzLogoLayout.stacked => 180,
        DzLogoLayout.horizontal => 170,
        DzLogoLayout.wordmark => 140,
        DzLogoLayout.mark => 56,
      };
}
