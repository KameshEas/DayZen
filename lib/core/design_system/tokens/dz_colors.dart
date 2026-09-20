import 'package:flutter/material.dart';

/// DayZen Color Tokens
///
/// Built on the four brand colors from the DayZen logo kit
/// (assets/branding/README.md): Navy, Sunrise, Slate and Mist.
///
/// Usage rules:
/// - Navy is the ink: text, primary buttons and icons on light surfaces.
/// - Sunrise is the light: highlights, the FAB, progress, streaks and every
///   accent on dark surfaces. It is only ~2:1 on white, so never use it for
///   small text on light backgrounds — use [sunriseDeep] there.
/// - Slate/Mist carry secondary text and quiet UI.
abstract final class DzColors {
  // ── Brand (from the logo kit) ────────────────────────────
  static const Color navy = Color(0xFF1E2A38);
  static const Color sunrise = Color(0xFFF49A70);
  static const Color slate = Color(0xFF6D7C88);
  static const Color mist = Color(0xFFA9B7C3);

  // ── Brand derivatives ────────────────────────────────────
  /// Sunrise darkened to 4.5:1 on white — for text/icons on light surfaces.
  static const Color sunriseDeep = Color(0xFFB85A2A);
  static const Color sunriseTint = Color(0xFFFDEBE1);
  static const Color navyDeep = Color(0xFF141C26);

  // ── Primary ──────────────────────────────────────────────
  static const Color primary = navy;
  static const Color zenGreen = Color(0xFF4A9C84);

  // ── Backgrounds ──────────────────────────────────────────
  static const Color appBackground = Color(0xFFFAF8F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary = navy;
  // Slate darkened slightly to reach 4.5:1 on white/paper for small text.
  static const Color textSecondary = Color(0xFF5A6875);
  static const Color textDisabled = mist;

  // ── Status ───────────────────────────────────────────────
  static const Color success = zenGreen;
  static const Color warning = Color(0xFFE3A03A);
  static const Color error = Color(0xFFD64F4F);

  // ── Dark Mode ─────────────────────────────────────────────
  static const Color darkBackground = navyDeep;
  static const Color darkCard = navy;
  static const Color darkText = Color(0xFFF4F1EE);
  static const Color darkTextSecondary = mist;
  static const Color darkSurfaceHigh = Color(0xFF2B3A4B);
  static const Color darkBorder = Color(0xFF34455A);

  // ── Utility ──────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE9E4DE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // ── Accent palette (Settings > Theme Accent options) ──────
  // Brand Navy is the default (navy in light mode, Sunrise in dark mode);
  // the others are alternates that sit comfortably beside the logo colors.
  static const Color lavender = Color(0xFF7B72C9);

  // ── Status tints (light backgrounds for icon circles etc.) ─
  static const Color primaryTint = Color(0xFFE6EBF0);
  static const Color errorTint = Color(0xFFFBE4E4);
  static const Color successTint = Color(0xFFDDF0E9);
  static const Color warningTint = Color(0xFFFBEFD5);
  static const Color neutralTint = Color(0xFFF1EEEA);
  static const Color indigoTint = Color(0xFFE7E5F5);
  static const Color skyTint = Color(0xFFE6EBF0);

  // ── Additional solid colors ───────────────────────────────
  static const Color mutedBorder = Color(0xFFD8D3CC);
  static const Color slateGray = Color(0xFF8A98A5);
  static const Color indigo = Color(0xFF7B72C9);
  static const Color brightGreen = Color(0xFF6CC0A5);
  static const Color forestGreen = Color(0xFF2F6B58);

  // ── Decorative / illustration colors ───────────────────────
  static const Color onboardingScaffoldBg = Color(0xFFF6F1EC);
  static const Color onboardingGradientMid = Color(0xFFF9F5F0);
  static const Color onboardingGradientEnd = Color(0xFFFCFAF7);
  static const Color onboardingIconTileBg = Color(0xFFFBE3D6);
  static const Color onboardingCardIcon = mist;
  static const Color onboardingTaskLineTeal = successTint;
  static const Color onboardingBadgeMuted = slateGray;
  static const Color onboardingPillBg = Color(0xFFEFE9E3);
  static const Color pinDotUnfilled = Color(0xFFDDD7D0);
  static const Color selectedChipBg = Color(0xFFF1EEEA);
  static const Color chartBarInactive = Color(0xFFD5DDE4);
  static const Color privacyBannerGradientStart = Color(0xFFC7D9C0);
  static const Color privacyBannerGradientEnd = Color(0xFFA3C4A0);
  static const Color privacyBannerIcon = Color(0xFF3D5A3D);
  static const Color privacyBannerHeading = Color(0xFF1A3D1A);
  static const Color reflectionCardGradientStart = Color(0xFF2B3A4B);
  static const Color signUpAvatarBg = Color(0xFFFBE3D6);
  static const Color signUpAvatarIcon = sunriseDeep;

  // ── Task priority (shared by task creation UIs) ────────────
  static const Color priorityLow = zenGreen;
  static const Color priorityMedium = warning;
  static const Color priorityHigh = error;
}
