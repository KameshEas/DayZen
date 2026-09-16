import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/content_service.dart';

/// Quote-of-the-day card shown on the Home page.
class HomeDailyReflectionCard extends StatelessWidget {
  const HomeDailyReflectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: ContentService.instance.getDailyReflectionQuote(),
      builder: (context, snapshot) {
        final quote = snapshot.data ?? AppConfig.defaultDailyReflectionQuote;
        return DzCard(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: DzSpacing.sm),
                  const Text('Daily Reflection', style: DzTextStyles.heading3),
                ],
              ),
              const SizedBox(height: DzSpacing.md),
              Text(
                quote,
                style: DzTextStyles.body.copyWith(
                  fontStyle: FontStyle.italic,
                  color: DzColors.textPrimary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: DzSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '— ${AppConfig.defaultDailyReflectionAuthor}',
                  style: DzTextStyles.small.copyWith(
                    color: DzColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
