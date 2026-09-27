import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/design_system/design_system.dart';

/// Decorative header banner shown at the top of the Settings page.
class SettingsPrivacyBanner extends StatelessWidget {
  const SettingsPrivacyBanner({super.key});

  // Cached at module scope: the installed version never changes at runtime,
  // so there's no reason to re-fetch it (and re-show a loading gap) on
  // every rebuild of this widget.
  static Future<PackageInfo>? _packageInfo;
  static Future<PackageInfo> get _version => _packageInfo ??= PackageInfo.fromPlatform();

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
                FutureBuilder<PackageInfo>(
                  future: _version,
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    return Text(
                      info == null ? 'App Version' : 'App Version ${info.version}',
                      style: DzTextStyles.caption.copyWith(
                        color: DzColors.privacyBannerIcon,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
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
