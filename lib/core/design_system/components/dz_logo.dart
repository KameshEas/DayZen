import 'package:flutter/material.dart';
import '../tokens/dz_colors.dart';
import '../tokens/dz_dimensions.dart';
import '../tokens/dz_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzLogo
// ─────────────────────────────────────────────────────────────────────────────

/// DayZen brand logo — gradient droplet icon + wordmark.
///
/// Use [DzLogoVariant.full] for light surfaces (default),
/// [DzLogoVariant.wordmarkOnly] for slide 2 / muted contexts.
///
/// ```dart
/// DzLogo()                                   // full, default size
/// DzLogo(size: DzLogoSize.large)             // larger
/// DzLogo(variant: DzLogoVariant.wordmarkOnly)
/// ```
enum DzLogoVariant { full, wordmarkOnly }

enum DzLogoSize { small, medium, large }

class DzLogo extends StatelessWidget {
  const DzLogo({
    super.key,
    this.variant = DzLogoVariant.full,
    this.size = DzLogoSize.medium,
    this.color,
  });

  final DzLogoVariant variant;
  final DzLogoSize size;

  /// Override the wordmark text colour. Defaults to [DzColors.primary] for
  /// [DzLogoVariant.full] and [DzColors.textSecondary] for wordmarkOnly.
  final Color? color;

  double get _iconBox {
    return switch (size) {
      DzLogoSize.small => 24,
      DzLogoSize.medium => 32,
      DzLogoSize.large => 44,
    };
  }

  double get _iconSize {
    return switch (size) {
      DzLogoSize.small => 13,
      DzLogoSize.medium => 18,
      DzLogoSize.large => 24,
    };
  }

  TextStyle get _textStyle {
    final base = switch (size) {
      DzLogoSize.small => DzTextStyles.heading3.copyWith(fontSize: 16),
      DzLogoSize.medium => DzTextStyles.heading3,
      DzLogoSize.large => DzTextStyles.heading2,
    };
    final resolvedColor = color ??
        (variant == DzLogoVariant.full
            ? DzColors.primary
            : DzColors.textSecondary);
    return base.copyWith(
      fontWeight: FontWeight.w700,
      color: resolvedColor,
      letterSpacing: -0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == DzLogoVariant.wordmarkOnly) {
      return Text('DayZen', style: _textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _iconBox,
          height: _iconBox,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF60A5FA), DzColors.primary],
            ),
            borderRadius: BorderRadius.circular(_iconBox * 0.31),
          ),
          child: Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: _iconSize,
          ),
        ),
        const SizedBox(width: DzSpacing.sm),
        Text('DayZen', style: _textStyle),
      ],
    );
  }
}
