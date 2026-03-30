import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Guides the user to enroll a fingerprint / face in device settings
/// before they can enable biometric lock in DayZen.
class BiometricSetupGuidePage extends StatelessWidget {
  const BiometricSetupGuidePage({super.key});

  static const _steps = [
    _Step(
      number: '1',
      title: 'Open Device Settings',
      description: 'Go to your phone\'s Settings app from the home screen.',
      icon: Icons.settings_rounded,
    ),
    _Step(
      number: '2',
      title: 'Find Security / Biometrics',
      description:
          'Look for "Security", "Biometrics", or "Face & Fingerprint" '
          'depending on your device.',
      icon: Icons.security_rounded,
    ),
    _Step(
      number: '3',
      title: 'Register Your Fingerprint or Face',
      description:
          'Follow the on-screen instructions to add at least one '
          'fingerprint or facial recognition profile.',
      icon: Icons.fingerprint_rounded,
    ),
    _Step(
      number: '4',
      title: 'Return to DayZen',
      description:
          'Once registered, come back here and enable Biometric Lock '
          'in Settings → Privacy.',
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: DzColors.appBackground,
      appBar: DzAppBar(
        title: 'Set Up Biometrics',
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.lg,
          vertical: DzSpacing.md,
        ),
        children: [
          // ── Hero illustration ───────────────────────────────────
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fingerprint_rounded,
                color: primary,
                size: 52,
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.lg),

          Text(
            'No Biometrics Registered',
            textAlign: TextAlign.center,
            style: DzTextStyles.heading2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: DzSpacing.sm),
          Text(
            'Your device supports biometrics but you haven\'t '
            'registered any fingerprint or face yet.\n'
            'Follow these steps to get started:',
            textAlign: TextAlign.center,
            style: DzTextStyles.body.copyWith(
              color: DzColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: DzSpacing.xl),

          // ── Step cards ─────────────────────────────────────────
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: DzSpacing.md),
              child: DzCard(
                padding: const EdgeInsets.all(DzSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(step.icon, color: primary, size: 22),
                    ),
                    const SizedBox(width: DzSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step ${step.number}',
                            style: DzTextStyles.caption.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.title,
                            style: DzTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.description,
                            style: DzTextStyles.caption.copyWith(
                              color: DzColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: DzSpacing.lg),

          // ── Go back button ─────────────────────────────────────
          DzPrimaryButton(
            label: 'Go to Device Settings',
            icon: const Icon(Icons.open_in_new_rounded,
                color: DzColors.white, size: 18),
            onPressed: () => _openDeviceSettings(context),
          ),
          const SizedBox(height: DzSpacing.sm),
          DzSecondaryButton(
            label: 'Go Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: DzSpacing.xl),
        ],
      ),
    );
  }

  void _openDeviceSettings(BuildContext context) {
    // On Android, Intent.ACTION_SECURITY_SETTINGS isn't directly
    // available from Flutter without a plugin. We inform the user instead.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Open your device Settings → Security → Fingerprint to register.',
        ),
      ),
    );
  }
}

class _Step {
  const _Step({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;
}
