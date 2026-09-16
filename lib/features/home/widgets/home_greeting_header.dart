import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Date + greeting text + avatar, shown at the top of the Home page.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.dateLabel,
    required this.greeting,
    required this.subtitle,
  });

  final String dateLabel;
  final String greeting;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: DzTextStyles.caption.copyWith(
                  color: DzColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(greeting, style: DzTextStyles.heading1),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: DzTextStyles.body.copyWith(
                  color: DzColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          child: Icon(
            Icons.person_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
      ],
    );
  }
}
