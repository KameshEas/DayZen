import 'package:flutter/material.dart';
import 'dz_colors.dart';

/// DayZen Typography Tokens
///
/// Three font families:
/// - [_brand]   → Bodoni Moda — the logo's wordmark face; page titles only
/// - [_body]    → Inter 18pt   — body, caption, label, small (≤16px)
/// - [_display] → InterDisplay 28pt — headings and large display text (≥18px)
abstract final class DzTextStyles {
  static const String _body = 'Inter';
  static const String _display = 'InterDisplay';
  static const String _brand = 'BodoniModa';
  // Optical size 6 keeps Bodoni's hairlines sturdy at UI sizes (24–30px);
  // higher values (the logo uses 28) make thin strokes vanish on phones.
  static const List<FontVariation> _brandVariations = [
    FontVariation('wght', 600),
    FontVariation('opsz', 6),
  ];

  // ── Display / Headings (InterDisplay 28pt) ─────────────────

  static const TextStyle heading1 = TextStyle(
    fontFamily: _brand,
    fontVariations: _brandVariations,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _brand,
    fontVariations: _brandVariations,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _display,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // ── Body / UI text (Inter 18pt) ───────────────────────────────

  static const TextStyle body = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DzColors.slate,
    height: 1.4,
  );

  static const TextStyle small = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: DzColors.slate,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );
}
