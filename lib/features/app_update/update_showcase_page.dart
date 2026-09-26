import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/design_system/components/dz_button.dart';
import '../../core/design_system/components/dz_card.dart';
import '../../core/design_system/components/dz_scaffold.dart';
import '../../core/design_system/components/dz_typography.dart';
import '../../core/design_system/tokens/dz_dimensions.dart';
import '../../core/models/app_version_model.dart';
import '../../core/services/app_version_service.dart';
import '../../core/services/store_redirect_service.dart';

/// Full-screen, non-dismissible "update showcase" shown in place of a
/// plain update popup — driven by [AppVersionController.config].
class UpdateShowcasePage extends StatefulWidget {
  const UpdateShowcasePage({
    super.key,
    required this.versionConfig,
    required this.versionService,
  });

  final AppVersionModel versionConfig;
  final AppVersionService versionService;

  @override
  State<UpdateShowcasePage> createState() => _UpdateShowcasePageState();
}

class _UpdateShowcasePageState extends State<UpdateShowcasePage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _currentVersion;

  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _currentVersion = info.version);
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    Future.wait([
      _fadeController.forward(),
      _slideController.forward(),
      Future.delayed(const Duration(milliseconds: 300), _scaleController.forward),
    ]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: DzAuthScaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _UpdateBadge(colorScheme: colorScheme),
                      const SizedBox(height: DzSpacing.xl),
                      const DzHeading1('Update Required'),
                      const SizedBox(height: DzSpacing.sm),
                      DzBodyText(
                        'A newer version of DayZen is available',
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: DzSpacing.lg),
                      _VersionCompareCard(
                        currentVersion: _currentVersion,
                        newVersion: widget.versionConfig.currentVersion,
                      ),
                      const SizedBox(height: DzSpacing.lg),
                      DzSectionCard(
                        title: "What's New",
                        child: DzBodyText(
                          widget.versionConfig.releaseNotes,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: DzSpacing.xl),
                      DzPrimaryButton(
                        label: 'Update Now',
                        isLoading: _isLoading,
                        icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                        onPressed: _handleUpdate,
                      ),
                      const SizedBox(height: DzSpacing.md),
                      DzCaption(
                        "It's recommended to update for better performance and security",
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    try {
      await widget.versionService.logUpdateInitiated(widget.versionConfig.minimumVersion);
      await widget.versionService.logRedirectedToStore();

      final success = await StoreRedirectService.openStoreFromUrl(widget.versionConfig.storeUrl);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open the app store. Please update manually.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _UpdateBadge extends StatelessWidget {
  const _UpdateBadge({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.2),
            colorScheme.secondary.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Icon(Icons.system_update_alt_rounded, size: 60, color: colorScheme.primary),
    );
  }
}

class _VersionCompareCard extends StatelessWidget {
  const _VersionCompareCard({required this.currentVersion, required this.newVersion});

  final String? currentVersion;
  final String newVersion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DzCard(
      elevated: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const DzCaption('Current'),
              const SizedBox(height: DzSpacing.xs),
              DzHeading3(currentVersion ?? '—'),
            ],
          ),
          Icon(Icons.arrow_forward_rounded, color: colorScheme.primary),
          Column(
            children: [
              const DzCaption('New'),
              const SizedBox(height: DzSpacing.xs),
              DzHeading3(newVersion, color: colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}
