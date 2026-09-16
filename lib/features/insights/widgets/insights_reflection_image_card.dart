import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/content_service.dart';

class InsightsReflectionImageCard extends StatelessWidget {
  const InsightsReflectionImageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: ContentService.instance.getRandomQuote(),
      builder: (context, snapshot) {
        final quote = snapshot.data ?? AppConfig.defaultDailyReflectionQuote;
        return Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DzRadius.card),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A5F), DzColors.forestGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Text(
            quote,
            style: DzTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }
}


