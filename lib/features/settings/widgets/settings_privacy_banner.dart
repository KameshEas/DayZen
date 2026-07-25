import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Decorative header banner shown at the top of the Settings page.
class SettingsPrivacyBanner extends StatelessWidget {
  const SettingsPrivacyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DzRadius.card),
        gradient: const LinearGradient(
          colors: [DzColors.privacyBannerGradientStart, DzColors.privacyBannerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative plant icon
          const Positioned(
            right: -8,
            bottom: -12,
            child: Opacity(
              opacity: 0.25,
              child: Icon(
                Icons.park_rounded,
                size: 130,
                color: DzColors.forestGreen,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DzSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'System Version 2.4.0',
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.privacyBannerIcon,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Privacy Protected',
                  style: DzTextStyles.heading2.copyWith(
                    color: DzColors.privacyBannerHeading,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
