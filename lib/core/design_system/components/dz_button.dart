import 'package:flutter/material.dart';
import '../tokens/dz_colors.dart';
import '../tokens/dz_dimensions.dart';
import '../tokens/dz_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzPrimaryButton
// ─────────────────────────────────────────────────────────────────────────────

/// A full-width primary CTA button.
///
/// ```dart
/// DzPrimaryButton(label: 'Get Started', onPressed: () {})
/// ```
class DzPrimaryButton extends StatelessWidget {
  const DzPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: DzSizing.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DzColors.white,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      const SizedBox(width: DzSpacing.sm),
                      Text(label, style: DzTextStyles.button.copyWith(color: DzColors.white)),
                    ],
                  )
                : Text(label, style: DzTextStyles.button.copyWith(color: DzColors.white)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzSecondaryButton
// ─────────────────────────────────────────────────────────────────────────────

/// An outlined secondary button.
class DzSecondaryButton extends StatelessWidget {
  const DzSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: DzSizing.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      const SizedBox(width: DzSpacing.sm),
                      Text(label),
                    ],
                  )
                : Text(label),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzGhostButton
// ─────────────────────────────────────────────────────────────────────────────

/// A text-only ghost button with no background or border.
class DzGhostButton extends StatelessWidget {
  const DzGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.primary;
    return TextButton(
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: DzSpacing.xs),
                Text(label, style: DzTextStyles.button.copyWith(color: textColor)),
              ],
            )
          : Text(label, style: DzTextStyles.button.copyWith(color: textColor)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzIconButton
// ─────────────────────────────────────────────────────────────────────────────

/// A minimal icon button that respects the 44px touch target.
class DzIconButton extends StatelessWidget {
  const DzIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DzRadius.button),
        child: Container(
          width: DzSizing.minTouchTarget,
          height: DzSizing.minTouchTarget,
          alignment: Alignment.center,
          child: IconTheme(
            data: IconThemeData(
              color: color ?? Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
