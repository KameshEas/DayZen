import 'package:flutter/material.dart';
import '../design_system.dart';

/// Empty state UI when no data is available.
/// Shows an icon (or an [illustration], when given), a title, and an optional
/// action button.
class DzEmptyState extends StatelessWidget {
  final IconData icon;

  /// Shown in place of [icon] when set.
  final DzIllustration? illustration;

  /// Height of the [illustration].
  final double illustrationHeight;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const DzEmptyState({
    super.key,
    required this.icon,
    this.illustration,
    this.illustrationHeight = 170,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconCol = iconColor ?? theme.colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (illustration != null)
                // Decorative: the title says everything the picture does.
                ExcludeSemantics(
                  child: DzIllustrationWidget(
                    illustration: illustration!,
                    height: illustrationHeight,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 64,
                  color: iconCol,
                ),
              const SizedBox(height: DzSpacing.lg),
              Text(
                title,
                style: DzTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: DzSpacing.md),
                Text(
                  subtitle!,
                  style: DzTextStyles.body.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: DzSpacing.lg),
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
