import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/app_prefs.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import 'widgets/pin_pad.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// PinUnlockPage  â€” "Unlock DayZen"
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class PinUnlockPage extends StatefulWidget {
  /// Called when the correct PIN is entered.
  final VoidCallback onUnlocked;

  /// Called when the user taps CANCEL (optional â€” e.g. to allow biometric skip).
  final VoidCallback? onCancel;

  const PinUnlockPage({
    super.key,
    required this.onUnlocked,
    this.onCancel,
  });

  @override
  State<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends State<PinUnlockPage>
    with SingleTickerProviderStateMixin {
  static const _pinLength = 4;
  static const _maxAttempts = 5;

  final _auth = LocalAuthentication();
  String _pin = '';
  String? _errorMessage;
  int _attempts = 0;
  bool _biometricAvailable = false;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (mounted) {
        setState(() => _biometricAvailable = canCheck && isSupported);
      }
    } catch (_) {
      // Leave _biometricAvailable as false
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    final newPin = _pin + digit;
    setState(() {
      _pin = newPin;
      _errorMessage = null;
    });
    if (newPin.length == _pinLength) _verify(newPin);
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify(String entered) async {
    final isValid = await AppPrefs.verifyPin(entered);
    if (isValid) {
      widget.onUnlocked();
    } else {
      _attempts++;
      HapticFeedback.mediumImpact();
      _shakeCtrl.forward(from: 0);
      final remaining = _maxAttempts - _attempts;
      setState(() {
        _pin = '';
        _errorMessage = remaining > 0
            ? 'Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining.'
            : 'Too many attempts. Please try again later.';
      });
    }
  }

  Future<void> _triggerBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometrics not available.')),
          );
        }
        return;
      }
      final didAuth = await _auth.authenticate(
        localizedReason: 'Authenticate to unlock DayZen',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (didAuth && mounted) {
        widget.onUnlocked();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DzColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: DzSpacing.xl),

            // â”€â”€ Brand â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: DzSpacing.sm),
                Text(
                  'DayZen',
                  style: DzTextStyles.heading2.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DzSpacing.xl),

            // â”€â”€ Heading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Text(AppConfig.pinUnlockTitle, style: DzTextStyles.heading1),
            const SizedBox(height: DzSpacing.sm),
            Text(
              AppConfig.pinUnlockSubtitle,
              style: DzTextStyles.body.copyWith(color: DzColors.textSecondary),
            ),

            const SizedBox(height: DzSpacing.xl),

            // â”€â”€ PIN dots with shake animation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) {
                final offset = _shakeCtrl.isAnimating
                    ? 8 * (0.5 - _shakeAnim.value).abs() * 2
                    : 0.0;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: DzPinDots(filled: _pin.length),
            ),

            // â”€â”€ Error â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SizedBox(
              height: 28,
              child: _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: DzSpacing.sm),
                      child: Text(
                        _errorMessage!,
                        style: DzTextStyles.caption
                            .copyWith(color: DzColors.error),
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: DzSpacing.xl),

            // â”€â”€ PIN pad â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
              child: DzPinPad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                leftLabel: widget.onCancel != null ? 'CANCEL' : null,
                onLeftAction: widget.onCancel,
              ),
            ),

            const Spacer(),

            // â”€â”€ Biometrics button (only shown if hardware available AND user opted in) â”€
            if (_biometricAvailable && SettingsScope.of(context).biometricEnabled)
              Column(
                children: [
                  GestureDetector(
                    onTap: _triggerBiometric,
                    child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: DzColors.primaryTint,
                      borderRadius: BorderRadius.circular(DzRadius.card),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: DzSpacing.sm),
                Text(
                  'Use biometrics',
                  style: DzTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.xl),

            // â”€â”€ Footer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Text(
              'PRIVACY BY DESIGN  â€¢  DATA STAYS LOCAL',
              style: DzTextStyles.caption.copyWith(
                color: DzColors.textSecondary,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),

            const SizedBox(height: DzSpacing.xl),
          ],
        ),
      ),
    );
  }
}



