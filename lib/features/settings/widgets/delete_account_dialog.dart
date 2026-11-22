import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

/// Final confirmation before permanently deleting the account. The delete
/// button stays disabled until the user types [confirmWord], so the action
/// can't happen from a stray tap.
///
/// Pops `true` when confirmed, `false`/`null` otherwise.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  static const String confirmWord = 'DELETE';

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final matches =
          _controller.text.trim().toUpperCase() == DeleteAccountDialog.confirmWord;
      if (matches != _confirmed) setState(() => _confirmed = matches);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      title: const Text('Delete account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your DayZen account and everything '
              'in it: your tasks, journal entries and settings, from our '
              'server and from this phone.',
            ),
            const SizedBox(height: DzSpacing.sm),
            Text(
              "This can't be undone. Other phones signed in to this account "
              'will be signed out.',
              style: DzTextStyles.caption.copyWith(color: muted),
            ),
            const SizedBox(height: DzSpacing.lg),
            TextField(
              key: const Key('delete-account-confirm-field'),
              controller: _controller,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Type ${DeleteAccountDialog.confirmWord} to confirm',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (_confirmed) Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('delete-account-confirm-button'),
          onPressed: _confirmed ? () => Navigator.of(context).pop(true) : null,
          style: TextButton.styleFrom(foregroundColor: DzColors.error),
          child: const Text('Delete account'),
        ),
      ],
    );
  }
}
