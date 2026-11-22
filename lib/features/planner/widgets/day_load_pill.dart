import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/day_load.dart';

/// "Balanced day" pill (plan M-2.6). Calm colours only: Heavy is amber, never
/// red, because a full day is information, not a failure.
class DayLoadPill extends StatelessWidget {
  const DayLoadPill({super.key, required this.result, this.onTap});

  final DayLoadResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg, IconData icon) = switch (result.level) {
      DayLoadLevel.light => (
          DzColors.zenGreen.withValues(alpha: 0.14),
          scheme.brightness == Brightness.dark ? DzColors.brightGreen : DzColors.forestGreen,
          Icons.spa_outlined,
        ),
      DayLoadLevel.balanced => (
          scheme.primary.withValues(alpha: 0.10),
          scheme.primary,
          Icons.balance_rounded,
        ),
      DayLoadLevel.heavy => (
          DzColors.warning.withValues(alpha: 0.18),
          scheme.brightness == Brightness.dark ? DzColors.warning : const Color(0xFF8A5A0B),
          Icons.layers_outlined,
        ),
    };
    final label = '${result.level.label} day';
    return Semantics(
      label: result.hasHistory
          ? '$label: about ${(result.load / result.baseline! * 100).round()} percent of a usual day'
          : label,
      button: onTap != null,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Text(label,
                    style: DzTextStyles.caption.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
