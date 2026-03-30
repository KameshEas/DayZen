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
    return Scaffold(
      backgroundColor: DzColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: DzSpacing.xl),

            // ── Brand ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded,
                    color: DzColors.primary, size: 22),
                const SizedBox(width: DzSpacing.sm),
                Text(
                  'DayZen',
                  style: DzTextStyles.heading2.copyWith(
                    color: DzColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Fingerprint icon ─────────────────────────────────
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE8F8),
                borderRadius: BorderRadius.circular(DzRadius.card),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: DzColors.primary,
                size: 56,
              ),
            ),

            const SizedBox(height: DzSpacing.lg),

            Text('Unlock DayZen', style: DzTextStyles.heading1),
            const SizedBox(height: DzSpacing.sm),

            Text(
              _isAuthenticating
                  ? 'Waiting for biometric...'
                  : 'Touch the sensor to continue',
              style:
                  DzTextStyles.body.copyWith(color: DzColors.textSecondary),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: DzSpacing.md),
              Text(
                _errorMessage!,
                style: DzTextStyles.caption.copyWith(color: DzColors.error),
              ),
            ],

            const SizedBox(height: DzSpacing.xl),

            // ── Retry button ─────────────────────────────────────
            if (!_isAuthenticating)
              DzPrimaryButton(
                label: 'Try Again',
                onPressed: _authenticate,
              ),

            const Spacer(),

            // ── Fallback to PIN ──────────────────────────────────
            if (widget.onFallbackToPin != null) ...[
              TextButton.icon(
                onPressed: widget.onFallbackToPin,
                icon: const Icon(Icons.dialpad_rounded, size: 18),
                label: const Text('Use PIN instead'),
                style: TextButton.styleFrom(
                  foregroundColor: DzColors.primary,
                ),
              ),
              const SizedBox(height: DzSpacing.md),
            ],

            // ── Footer ──────────────────────────────────────────
            Text(
              'PRIVACY BY DESIGN  •  DATA STAYS LOCAL',
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
