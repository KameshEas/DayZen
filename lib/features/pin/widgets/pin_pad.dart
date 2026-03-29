import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared PIN pad widget — used by both Setup and Unlock pages
// ─────────────────────────────────────────────────────────────────────────────

/// A full numeric PIN-pad that emits a 4-character PIN string via [onPinChanged]
/// and fires [onBackspace] / individual digit callbacks internally.
class DzPinPad extends StatelessWidget {
  const DzPinPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometrics,
    this.leftLabel,
    this.onLeftAction,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// If provided, the bottom-left cell shows a fingerprint icon button.
  final VoidCallback? onBiometrics;

  /// Text label for the bottom-left action (e.g. "CANCEL"). Ignored when
  /// [onBiometrics] is set.
  final String? leftLabel;
  final VoidCallback? onLeftAction;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['_left', '0', '_back'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Row(
          children: row.map((key) {
            return Expanded(child: _PadKey(
              keyValue: key,
              onDigit: onDigit,
              onBackspace: onBackspace,
              onBiometrics: onBiometrics,
              leftLabel: leftLabel,
              onLeftAction: onLeftAction,
            ));
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({
    required this.keyValue,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometrics,
    this.leftLabel,
    this.onLeftAction,
  });

  final String keyValue;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometrics;
  final String? leftLabel;
  final VoidCallback? onLeftAction;

  @override
  Widget build(BuildContext context) {
    if (keyValue == '_back') {
      return _ActionCell(
        onTap: onBackspace,
        child: const Icon(
          Icons.backspace_rounded,
          color: DzColors.textPrimary,
          size: 22,
        ),
      );
    }

    if (keyValue == '_left') {
      if (onBiometrics != null) {
        return _ActionCell(
          onTap: onBiometrics!,
          child: Icon(
            Icons.fingerprint_rounded,
            color: DzColors.textSecondary,
            size: 28,
          ),
        );
      }
      if (leftLabel != null && onLeftAction != null) {
        return _ActionCell(
          onTap: onLeftAction!,
          child: Text(
            leftLabel!,
            style: DzTextStyles.caption.copyWith(
              color: DzColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        );
      }
      return const SizedBox.expand();
    }

    // Digit key
    return _ActionCell(
      onTap: () => onDigit(keyValue),
      child: Text(
        keyValue,
        style: const TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 26,
          fontWeight: FontWeight.w400,
          color: DzColors.textPrimary,
        ),
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 76,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: DzColors.cardBackground,
          borderRadius: BorderRadius.circular(DzRadius.card),
          boxShadow: DzShadows.soft,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIN dot indicator row
// ─────────────────────────────────────────────────────────────────────────────

class DzPinDots extends StatelessWidget {
  const DzPinDots({super.key, required this.filled, this.length = 4});
  final int filled;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: DzDuration.fast,
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? DzColors.primary : const Color(0xFFD1DCF0),
          ),
        );
      }),
    );
  }
}
