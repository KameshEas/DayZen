import 'package:flutter/material.dart';
import '../tokens/dz_colors.dart';
import '../tokens/dz_dimensions.dart';
import '../tokens/dz_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzPrimaryButton
// ─────────────────────────────────────────────────────────────────────────────

/// A full-width primary CTA button with 3D tap depth effect.
///
/// ```dart
/// DzPrimaryButton(label: 'Get Started', onPressed: () {})
/// ```
class DzPrimaryButton extends StatefulWidget {
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
  State<DzPrimaryButton> createState() => _DzPrimaryButtonState();
}

class _DzPrimaryButtonState extends State<DzPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown() => _pressController.forward();
  void _onTapUp() => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: DzSizing.buttonHeight,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DzColors.white,
                      ),
                    )
                  : widget.icon != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.icon!,
                            const SizedBox(width: DzSpacing.sm),
                            Text(widget.label,
                                style: DzTextStyles.button
                                    .copyWith(color: DzColors.white)),
                          ],
                        )
                      : Text(widget.label,
                          style: DzTextStyles.button
                              .copyWith(color: DzColors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzSecondaryButton
// ─────────────────────────────────────────────────────────────────────────────

/// An outlined secondary button with 3D tap depth effect.
class DzSecondaryButton extends StatefulWidget {
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
  State<DzSecondaryButton> createState() => _DzSecondaryButtonState();
}

class _DzSecondaryButtonState extends State<DzSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown() => _pressController.forward();
  void _onTapUp() => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: DzSizing.buttonHeight,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: OutlinedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : widget.icon != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.icon!,
                            const SizedBox(width: DzSpacing.sm),
                            Text(widget.label),
                          ],
                        )
                      : Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzGhostButton
// ─────────────────────────────────────────────────────────────────────────────

/// A text-only ghost button with no background or border and 3D tap depth effect.
class DzGhostButton extends StatefulWidget {
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
  State<DzGhostButton> createState() => _DzGhostButtonState();
}

class _DzGhostButtonState extends State<DzGhostButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown() => _pressController.forward();
  void _onTapUp() => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final textColor = widget.color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: TextButton(
            onPressed: widget.onPressed,
            child: widget.icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.icon!,
                      const SizedBox(width: DzSpacing.xs),
                      Text(widget.label,
                          style: DzTextStyles.button.copyWith(color: textColor)),
                    ],
                  )
                : Text(widget.label,
                    style: DzTextStyles.button.copyWith(color: textColor)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzIconButton
// ─────────────────────────────────────────────────────────────────────────────

/// A minimal icon button that respects the 44px touch target with 3D tap depth.
class DzIconButton extends StatefulWidget {
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
  State<DzIconButton> createState() => _DzIconButtonState();
}

class _DzIconButtonState extends State<DzIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown() => _pressController.forward();
  void _onTapUp() => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.tooltip,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(DzRadius.button),
          child: AnimatedBuilder(
            animation: _scale,
            builder: (context, child) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: DzSizing.minTouchTarget,
                height: DzSizing.minTouchTarget,
                alignment: Alignment.center,
                child: IconTheme(
                  data: IconThemeData(
                    color: widget.color ??
                        Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                  child: widget.icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
