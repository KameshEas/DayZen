import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets used across multiple settings sections (Phase 5.1 of
// docs/DEVELOPMENT_PLAN.md — extracted from the former monolithic
// settings_page.dart). Kept public (no leading underscore) since they're
// now consumed from other files under features/settings/widgets/.
// ─────────────────────────────────────────────────────────────────────────────

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: DzTextStyles.caption.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          fontSize: 12,
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DzRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.md, vertical: DzSpacing.md),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: DzSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DzTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DzTextStyles.caption.copyWith(
                      color: DzColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: DzColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Divider(height: 1, color: DzColors.borderLight),
    );
  }
}

class SettingsSheetHandle extends StatelessWidget {
  const SettingsSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: DzColors.borderLight,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DzTextStyles.body),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class SettingsOptionListSheet<T> extends StatelessWidget {
  const SettingsOptionListSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsSheetHandle(),
          const SizedBox(height: DzSpacing.md),
          Text(title,
              style:
                  DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: DzSpacing.md),
          ...options.map((opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt, style: DzTextStyles.body),
                trailing: opt == selected
                    ? Icon(Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary, size: 22)
                    : const Icon(Icons.circle_outlined,
                        color: DzColors.borderLight, size: 22),
                onTap: () => onSelect(opt),
              )),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    );
  }
}

/// Shared bottom sheet used by both the Appearance section (font size) and
/// the AI section (personality/tip frequency/analysis depth) — a single
/// choice from a fixed list of string options.
void showSettingsOptionSheet(
  BuildContext context,
  String title,
  List<String> options,
  String current,
  ValueChanged<String> onSelect,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
    ),
    builder: (_) => SettingsOptionListSheet<String>(
      title: title,
      options: options,
      selected: current,
      onSelect: (v) {
        onSelect(v);
        Navigator.pop(context);
      },
    ),
  );
}
