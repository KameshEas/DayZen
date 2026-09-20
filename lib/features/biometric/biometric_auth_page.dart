import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/design_system/design_system.dart';

/// Full-screen biometric authentication page.
///
/// Automatically triggers the system biometric prompt on mount.
/// On success, calls [onAuthenticated]. On repeated failure, the user
/// can tap a retry button or fall back to PIN via [onFallbackToPin].
class BiometricAuthPage extends StatefulWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback? onFallbackToPin;

  const BiometricAuthPage({
    super.key,
    required this.onAuthenticated,
    this.onFallbackToPin,
  });

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Trigger biometric immediately after frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      // Verify hardware is still available at auth time
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        if (!mounted) return;
        // Device doesn't support biometrics — fall back to PIN
        if (widget.onFallbackToPin != null) {
          widget.onFallbackToPin!();
        } else {
          setState(() {
            _isAuthenticating = false;
            _errorMessage = 'Biometrics not available on this device.';
          });
        }
        return;
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to unlock DayZen',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!mounted) return;

      if (didAuthenticate) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'Authentication failed. Try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'Biometric error. Use PIN instead.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
                  child: Column(
                    children: [
                      const SizedBox(height: DzSpacing.xl),
                      const DzLogo(layout: DzLogoLayout.stacked, width: 150),
                      const Spacer(),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(DzRadius.card),
                        ),
                        child: Icon(
                          Icons.fingerprint_rounded,
                          color: scheme.primary,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: DzSpacing.lg),
                      const Text(
                        'Unlock DayZen',
                        textAlign: TextAlign.center,
                        style: DzTextStyles.heading1,
                      ),
                      const SizedBox(height: DzSpacing.sm),
                      Text(
                        _isAuthenticating
                            ? 'Waiting for biometric...'
                            : 'Touch the sensor to continue',
                        textAlign: TextAlign.center,
                        style: DzTextStyles.body
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: DzSpacing.md),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: DzTextStyles.caption
                              .copyWith(color: DzColors.error),
                        ),
                      ],
                      const SizedBox(height: DzSpacing.xl),
                      // Keeps its slot while the system prompt is showing so
                      // the content behind the prompt stays put.
                      Visibility(
                        visible: !_isAuthenticating,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: DzPrimaryButton(
                            label: 'Try Again',
                            onPressed: _authenticate,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.onFallbackToPin != null) ...[
                        TextButton.icon(
                          onPressed: widget.onFallbackToPin,
                          icon: const Icon(Icons.dialpad_rounded, size: 18),
                          label: const Text('Use PIN instead'),
                        ),
                        const SizedBox(height: DzSpacing.md),
                      ],
                      Text(
                  'PRIVACY BY DESIGN  •  DATA STAYS LOCAL',
                  textAlign: TextAlign.center,
                  style: DzTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
                      const SizedBox(height: DzSpacing.xl),
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
}
