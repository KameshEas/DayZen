import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/jwt_auth_service.dart';

/// "Hello, Kamesh" plus one honest line about today (see
/// [InsightsData.greetingSubtitle]). Reads the shared auth service, so the name
/// appears as soon as someone signs in.
class InsightsGreeting extends StatelessWidget {
  const InsightsGreeting({super.key, required this.subtitle, this.auth});

  final String subtitle;

  /// Only for tests; the app always uses [JwtAuthService.instance].
  final JwtAuthService? auth;

  /// First name to greet, or "there" when nobody is signed in.
  static String nameFor(AuthUser? user) {
    final raw = (user?.name?.trim().isNotEmpty ?? false)
        ? user!.name!.trim()
        : (user?.email ?? '');
    if (raw.isEmpty) return 'there';
    return raw.contains('@') ? raw.split('@').first : raw.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final service = auth ?? JwtAuthService.instance;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${nameFor(service.currentUser)}',
            style: DzTextStyles.heading1.copyWith(fontSize: 28),
          ),
          const SizedBox(height: DzSpacing.xs),
          Text(
            subtitle,
            style: DzTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
