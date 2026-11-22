import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/app_prefs.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import 'widgets/pin_pad.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PinUnlockPage  — "Unlock DayZen"
// ─────────────────────────────────────────────────────────────────────────────

class PinUnlockPage extends StatefulWidget {
  /// Called when the correct PIN is entered.
  final VoidCallback onUnlocked;

  /// Called when the user taps CANCEL (optional — e.g. to allow biometric skip).
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

  final _auth = LocalAuthentication();
  String _pin = '';
  String? _errorMessage;
  bool _biometricAvailable = false;

  /// Set while the persisted lockout is active (see AppPrefs.attemptPin).
  DateTime? _lockedUntil;
  Timer? _lockTicker;
  bool _verifying = false;

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
    _restoreLockout();
  }

  /// A lockout survives app restarts, so pick it up on open.
  Future<void> _restoreLockout() async {
    final until = await AppPrefs.pinLockedUntil();
    if (until != null && mounted) _startLockout(until);
  }

  void _startLockout(DateTime until) {
    _lockTicker?.cancel();
    setState(() {
      _lockedUntil = until;
      _errorMessage = _lockMessage(until);
    });
    _lockTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (!DateTime.now().isBefore(until)) {
        t.cancel();
        setState(() {
          _lockedUntil = null;
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = _lockMessage(until));
      }
    });
  }

  static String _lockMessage(DateTime until) {
    final left = until.difference(DateTime.now());
    final secs = left.inSeconds + 1;
    final text = secs >= 60 ? '${(secs / 60).ceil()} min' : '$secs s';
    return 'Too many attempts. Try again in $text.';
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
    _lockTicker?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength || _lockedUntil != null || _verifying) return;
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
    _verifying = true;
    final result = await AppPrefs.attemptPin(entered);
    _verifying = false;
    if (!mounted) return;
    if (result.ok) {
      widget.onUnlocked();
      return;
    }
    HapticFeedback.mediumImpact();
    _shakeCtrl.forward(from: 0);
    setState(() => _pin = '');
    final lockedUntil = result.lockedUntil;
    if (lockedUntil != null) {
      _startLockout(lockedUntil);
    } else {
      final remaining = result.remainingBeforeLock;
      setState(() => _errorMessage =
          'Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining.');
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
    final scheme = Theme.of(context).colorScheme;
    final showBiometrics =
        _biometricAvailable && SettingsScope.of(context).biometricEnabled;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: DzSpacing.lg),
                    const DzLogo(layout: DzLogoLayout.stacked, width: 128),
                    const SizedBox(height: DzSpacing.lg),
                    const Text(
                      AppConfig.pinUnlockTitle,
                      textAlign: TextAlign.center,
                      style: DzTextStyles.heading1,
                    ),
                    const SizedBox(height: DzSpacing.sm),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
                      child: Text(
                        AppConfig.pinUnlockSubtitle,
                        textAlign: TextAlign.center,
                        style: DzTextStyles.body
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: DzSpacing.lg),
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
                    SizedBox(
                      height: 28,
                      child: _errorMessage != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: DzSpacing.sm),
                              child: Text(
                                _errorMessage!,
                                style: DzTextStyles.caption
                                    .copyWith(color: DzColors.error),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: DzSpacing.md),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
                      child: DzPinPad(
                        onDigit: _onDigit,
                        onBackspace: _onBackspace,
                        leftLabel: widget.onCancel != null ? 'CANCEL' : null,
                        onLeftAction: widget.onCancel,
                      ),
                    ),
                    const Spacer(),
                    if (showBiometrics) ...[
                      const SizedBox(height: DzSpacing.md),
                      GestureDetector(
                        onTap: _triggerBiometric,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(DzRadius.card),
                          ),
                          child: Icon(
                            Icons.fingerprint_rounded,
                            color: scheme.primary,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: DzSpacing.xs),
                      Text(
                        'Use biometrics',
                        style: DzTextStyles.caption.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: DzSpacing.md),
                    Text(
                  'PRIVACY BY DESIGN  •  DATA STAYS LOCAL',
                  textAlign: TextAlign.center,
                  style: DzTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
                    const SizedBox(height: DzSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
