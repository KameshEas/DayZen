import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/jwt_auth_service.dart';

class InsightsGreeting extends StatelessWidget {
  const InsightsGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = JwtAuthService();
    final user = authService.currentUser;
    final rawName = user?.name ?? user?.email ?? 'there';
    final name = rawName.contains('@') ? rawName.split('@').first : rawName.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $name',
            style: DzTextStyles.heading2
                .copyWith(fontWeight: FontWeight.w700, fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          'You\'ve maintained a calm focus for 4 days straight. Take a deep breath.',
          style: DzTextStyles.body.copyWith(color: DzColors.textSecondary),
        ),
      ],
    );
  }
}
