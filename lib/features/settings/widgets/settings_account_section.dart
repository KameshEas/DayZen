import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/app_prefs.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/services/account_deletion_service.dart';
import '../../app_data.dart';
import '../settings_controller.dart';
import 'delete_account_dialog.dart';
import '../../../core/data/database/database_provider.dart';
import 'settings_shared_widgets.dart';

/// The "ACCOUNT" card on the Settings page — sign-in status, account sheet,
/// and navigation to the sign-in flow.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key, required this.ctrl});

  final SettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionLabel('ACCOUNT'),
        const SizedBox(height: DzSpacing.sm),
        DzCard(
          padding: EdgeInsets.zero,
          child: SettingsTile(
            icon: ctrl.isSignedIn
                ? Icons.cloud_done_rounded
                : Icons.cloud_off_rounded,
            iconBg: ctrl.isSignedIn
                ? Theme.of(context).colorScheme.primaryContainer
                : DzColors.warning.withValues(alpha: 0.15),
            iconColor: ctrl.isSignedIn
                ? Theme.of(context).colorScheme.primary
                : DzColors.warning,
            title: ctrl.isSignedIn ? 'Account' : 'Sign In & Sync',
            subtitle: ctrl.isSignedIn
                ? ctrl.userEmail ?? 'Signed in'
                : 'Offline mode — tap to sign in',
            onTap: () {
              if (ctrl.isSignedIn) {
                _showAccountSheet(context, ctrl);
              } else {
                _navigateToSignIn(context, ctrl);
              }
            },
          ),
        ),
      ],
    );
  }

  void _navigateToSignIn(BuildContext context, SettingsController ctrl) {
    context.push(RoutePaths.login);
  }

  void _showAccountSheet(BuildContext context, SettingsController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSheetHandle(),
            const SizedBox(height: DzSpacing.md),
            Text('Account',
                style: DzTextStyles.heading3
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DzSpacing.lg),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 26),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctrl.userEmail ?? 'Signed in',
                        style: DzTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sync is active',
                        style: DzTextStyles.caption
                            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DzColors.error,
                  side: const BorderSide(color: DzColors.error),
                  padding:
                      const EdgeInsets.symmetric(vertical: DzSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DzRadius.button),
                  ),
                ),
                onPressed: () {
                  ctrl.signOut();
                  context.pop();
                },
              ),
            ),
            const SizedBox(height: DzSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('delete-account-button'),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  padding:
                      const EdgeInsets.symmetric(vertical: DzSpacing.md),
                ),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _confirmAndDeleteAccount(context, ctrl);
                },
                child: const Text('Delete account'),
              ),
            ),
            const SizedBox(height: DzSpacing.lg),
          ],
        ),
      ),
    );
  }

  /// Confirm, delete on the server, wipe this device, then start fresh at
  /// onboarding. On failure nothing is deleted and a message explains why.
  Future<void> _confirmAndDeleteAccount(
      BuildContext context, SettingsController ctrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );
    if (confirmed != true || !context.mounted) return;

    final tasks = TaskScope.of(context);
    final journal = JournalScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final service = AccountDeletionService(
      api: ApiClient(),
      signOut: ctrl.signOut,
      wipeLocalData: () async {
        await tasks.clearAll(); // also cancels scheduled reminders
        await journal.clearAll();
        // Check-ins, day closes, Rhythm and counters (local only).
        await DatabaseProvider.instance.localOnlyDao.clearAll();
        await AppPrefs.clearPin();
        await AppPrefs.clearAllSecureData();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // settings, onboarding, biometric, sync flags
        await ctrl.load(); // reset in-memory settings to defaults
      },
    );

    try {
      await DzProgress.run<void>(
        context,
        message: 'Deleting your account…',
        successMessage: 'Account deleted',
        alwaysShow: true,
        task: service.deleteAccount,
      );
    } on AccountDeletionException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    router.go(RoutePaths.onboarding);
  }
}



