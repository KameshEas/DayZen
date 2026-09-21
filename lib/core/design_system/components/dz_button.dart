import 'package:flutter/material.dart';
import 'dz_progress.dart';
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
    this.loadingLabel,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Shown next to the loader while [isLoading] (e.g. 'Signing in…').
  final String? loadingLabel;
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
              // Stay fully colored while busy instead of turning disabled-gray.
              style: widget.isLoading
                  ? ElevatedButton.styleFrom(
                      disabledBackgroundColor:
                          Theme.of(context).colorScheme.primary,
                      disabledForegroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
              child: widget.isLoading
                  ? _LoadingContent(
                      label: widget.loadingLabel,
                      color: Theme.of(context).colorScheme.onPrimary,
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
// DzSecondaryButton
// ─────────────────────────────────────────────────────────────────────────────

/// An outlined secondary button with 3D tap depth effect.
class DzSecondaryButton extends StatefulWidget {
  const DzSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Shown next to the loader while [isLoading] (e.g. 'Signing in…').
  final String? loadingLabel;
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
              style: widget.isLoading
                  ? OutlinedButton.styleFrom(
                      disabledForegroundColor:
                          Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    )
                  : null,
              child: widget.isLoading
                  ? _LoadingContent(
                      label: widget.loadingLabel,
                      color: Theme.of(context).colorScheme.primary,
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

/// Loader (plus optional message) shown inside a button while it is busy.
class _LoadingContent extends StatelessWidget {
  const _LoadingContent({required this.color, this.label});

  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DzSunLoader.mono(width: 40, color: color),
        if (label != null) ...[
          const SizedBox(width: DzSpacing.sm),
          Text(label!),
        ],
      ],
    );
  }
}
