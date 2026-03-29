import 'package:flutter/material.dart';
import '../tokens/dz_text_styles.dart';
import '../tokens/dz_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzText — Semantic text widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Main page/section heading. (28px Bold)
class DzHeading1 extends StatelessWidget {
  const DzHeading1(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DzTextStyles.heading1.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Sub-section heading. (22px SemiBold)
class DzHeading2 extends StatelessWidget {
  const DzHeading2(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DzTextStyles.heading2.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Card / widget title. (18px Medium)
class DzHeading3 extends StatelessWidget {
  const DzHeading3(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DzTextStyles.heading3.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Standard body text. (16px Regular)
class DzBodyText extends StatelessWidget {
  const DzBodyText(this.text, {super.key, this.color, this.maxLines, this.overflow});
  final String text;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: DzTextStyles.body.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Helper / subtext label. (14px Regular, secondary color)
class DzCaption extends StatelessWidget {
  const DzCaption(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DzTextStyles.caption.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Micro / metadata text. (12px Light)
class DzSmallText extends StatelessWidget {
  const DzSmallText(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DzTextStyles.small.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzGreeting
// ─────────────────────────────────────────────────────────────────────────────

/// The home page contextual greeting widget.
///
/// ```dart
/// DzGreeting(name: 'Alex')
/// ```
class DzGreeting extends StatelessWidget {
  const DzGreeting({super.key, this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DzCaption(greeting),
        const SizedBox(height: 2),
        DzHeading1(name != null ? '$greeting, $name 👋' : greeting),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzPrivacyBadge
// ─────────────────────────────────────────────────────────────────────────────

/// Privacy trust indicator — "Your data stays on device".
class DzPrivacyBadge extends StatelessWidget {
  const DzPrivacyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DzColors.zenGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 12, color: DzColors.zenGreen),
          const SizedBox(width: 4),
          Text(
            'Your data stays on device',
            style: DzTextStyles.small.copyWith(
              color: DzColors.zenGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzSectionHeader
// ─────────────────────────────────────────────────────────────────────────────

/// A labeled section separator with an optional action button.
class DzSectionHeader extends StatelessWidget {
  const DzSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DzHeading3(title),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: DzCaption(
              actionLabel!,
              color: DzColors.primary,
            ),
          ),
      ],
    );
  }
}
