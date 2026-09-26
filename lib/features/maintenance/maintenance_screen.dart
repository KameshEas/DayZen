import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design_system/components/dz_button.dart';
import '../../core/design_system/components/dz_scaffold.dart';
import '../../core/design_system/components/dz_typography.dart';
import '../../core/design_system/tokens/dz_dimensions.dart';
import '../../core/models/app_version_model.dart';
import '../../core/utils/date_formatter.dart';

/// Full-screen, non-dismissible notice shown when the backend has flagged
/// DayZen as under (block-type) maintenance. Re-checks on its own every
/// [MaintenanceInfo.retryAfterSeconds] via [onRetry], so a user just sits on
/// the screen and it clears itself once the backend lifts the flag.
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key, required this.info, required this.onRetry});

  final MaintenanceInfo info;
  final VoidCallback onRetry;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(seconds: widget.info.retryAfterSeconds),
      (_) => widget.onRetry(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _openStatusPage(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final info = widget.info;
    final title = (info.title?.isNotEmpty ?? false) ? info.title! : 'Taking a Mindful Pause';
    final message = (info.message?.isNotEmpty ?? false)
        ? info.message!
        : "We're tuning things up — you'll be back to your flow shortly.";
    final endsAt = info.endsAt;
    final statusUrl = info.statusUrl;

    return PopScope(
      canPop: false,
      child: DzAuthScaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                  ),
                  child: Icon(Icons.build_rounded, size: 48, color: colorScheme.secondary),
                ),
                const SizedBox(height: DzSpacing.xl),
                DzHeading1(title),
                const SizedBox(height: DzSpacing.sm),
                DzBodyText(
                  message,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                if (endsAt != null) ...[
                  const SizedBox(height: DzSpacing.md),
                  DzCaption(
                    'Expected back ${DateFormatter.formatDate(endsAt.toLocal())} '
                    'at ${DateFormatter.formatTime(endsAt.toLocal().hour, endsAt.toLocal().minute)}',
                  ),
                ],
                const SizedBox(height: DzSpacing.xl),
                DzPrimaryButton(label: 'Try Again', onPressed: widget.onRetry),
                if (statusUrl != null && statusUrl.isNotEmpty) ...[
                  const SizedBox(height: DzSpacing.sm),
                  DzGhostButton(
                    label: 'View status page',
                    onPressed: () => _openStatusPage(statusUrl),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
