import 'package:flutter/material.dart';
import '../../core/app_prefs.dart';
import '../../core/design_system/design_system.dart';
import 'widgets/pin_pad.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// PinSetupPage  â€” "Secure Your Space"
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class PinSetupPage extends StatefulWidget {
  /// Called with the page's own [BuildContext] after the PIN has been saved.
  final void Function(BuildContext context) onPinSet;

  const PinSetupPage({super.key, required this.onPinSet});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  static const _pinLength = 4;

  String _pin = '';
  String? _errorMessage;

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _errorMessage = null;
    });
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _confirm() async {
    if (_pin.length < _pinLength) {
      setState(() => _errorMessage = 'Please enter all 4 digits.');
      return;
    }
    await AppPrefs.savePin(_pin);
    if (mounted) widget.onPinSet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DzColors.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
          children: [
            // â”€â”€ App bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DzSpacing.sm,
                vertical: DzSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Text(
                    'Secure Your Space',
                    style: DzTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: DzColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DzSpacing.lg),

            // â”€â”€ Lock icon â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: DzColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_clock_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 34,
              ),
            ),

            const SizedBox(height: DzSpacing.lg),

            // â”€â”€ Heading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const Text('Create your PIN', style: DzTextStyles.heading1),
            const SizedBox(height: DzSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DzSpacing.xl),
              child: Text(
                'Choose a 4-digit code to keep your personal data and daily journal private.',
                style: DzTextStyles.body.copyWith(color: DzColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: DzSpacing.xl),

            // â”€â”€ PIN dots â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            DzPinDots(filled: _pin.length),

            // â”€â”€ Error â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_errorMessage != null) ...[
              const SizedBox(height: DzSpacing.sm),
              Text(
                _errorMessage!,
                style: DzTextStyles.caption.copyWith(color: DzColors.error),
              ),
            ],

            const SizedBox(height: DzSpacing.xl),

            // â”€â”€ PIN pad â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
              child: DzPinPad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                // biometrics slot shows fingerprint icon (decorative for setup)
                onBiometrics: () {},
              ),
            ),

            const Spacer(),

            // â”€â”€ Confirm button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
              child: DzPrimaryButton(
                label: 'Confirm PIN',
                onPressed: _pin.length == _pinLength ? _confirm : null,
              ),
            ),

            const SizedBox(height: DzSpacing.md),

            // â”€â”€ Privacy note â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_rounded,
                    size: 14, color: DzColors.textSecondary),
                const SizedBox(width: DzSpacing.xs),
                Text(
                  'Your data stays encrypted on device',
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DzSpacing.xl),
          ],
        ),
            ),
          ),
        ),
      ),
    );
  }
}


