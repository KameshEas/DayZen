import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_prefs.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/moments_service.dart';

/// After the first journal entry, offer a PIN once (plan M-3.4 / M-1.7: the
/// PIN is no longer asked for at sign-up). [context] must stay mounted after
/// the entry sheet closes, e.g. the Navigator's own context.
Future<void> maybeOfferPin(BuildContext context, {required int journalEntries}) async {
  final offer = MomentsService.shouldOfferPin(
    journalEntries: journalEntries,
    hasPin: await AppPrefs.hasPin(),
    pinOptedOut: await AppPrefs.isPinOptedOut(),
    fired: await MomentsService.fired(),
  );
  if (!offer || !context.mounted) return;
  await MomentsService.markFired(Moment.pinOffer);
  if (!context.mounted) return;
  final setUp = await showModalBottomSheet<bool>(
    useRootNavigator: true, // above the tab bar, not inside the shell
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Theme.of(ctx).colorScheme.primary),
                const SizedBox(width: DzSpacing.sm),
                const Text('Protect your journal?', style: DzTextStyles.heading3),
              ],
            ),
            const SizedBox(height: DzSpacing.sm),
            const Text(
              'Add a PIN so only you can open DayZen. It stays on this phone.',
              style: DzTextStyles.body,
            ),
            const SizedBox(height: DzSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: DzSecondaryButton(
                    label: 'Not now',
                    onPressed: () => Navigator.pop(ctx, false),
                  ),
                ),
                const SizedBox(width: DzSpacing.sm),
                Expanded(
                  child: DzPrimaryButton(
                    label: 'Set a PIN',
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (setUp == true && context.mounted) context.push('/pin-setup');
}
