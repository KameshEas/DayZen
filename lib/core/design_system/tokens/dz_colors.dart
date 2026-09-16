import 'package:flutter/material.dart';

/// DayZen Color Tokens
/// All colors follow the DayZen Design System specification.
abstract final class DzColors {
  // ── Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF3B82F6);
  static const Color zenGreen = Color(0xFF10B981);

  // ── Backgrounds ──────────────────────────────────────────
  static const Color appBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFFCBD5F5);

  // ── Status ───────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ── Dark Mode ─────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF1F5F9);

  // ── Utility ──────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // ── Accent palette (Settings > Theme Accent options) ──────
  // zenGreen and primary above double as two of the four selectable
  // accents; these are the other two.
  static const Color sunsetOrange = Color(0xFFF97316);
  static const Color lavender = Color(0xFF8B5CF6);

  // ── Status tints (light backgrounds for icon circles etc.) ─
  // Phase 5.2 of docs/DEVELOPMENT_PLAN.md: extracted from repeated
  // Color(0x...) literals across features/ — see docs/DEVELOPMENT_PLAN.md
  // for the full sweep list. Not simple .withValues(alpha:) derivations of
  // the solid colors above — the original design used distinct hex values
  // for these tints, and this sweep preserves the existing visual design
  // rather than silently changing it.
  static const Color primaryTint = Color(0xFFDDE8F8);
  static const Color errorTint = Color(0xFFFEE2E2);
  static const Color successTint = Color(0xFFD1FAE5);
  static const Color warningTint = Color(0xFFFEF3C7);
  static const Color neutralTint = Color(0xFFF1F5F9);
  static const Color indigoTint = Color(0xFFE0E7FF);
  static const Color skyTint = Color(0xFFDBEAFE);

  // ── Additional solid colors (repeated 2+ times outside tints) ──
  static const Color mutedBorder = Color(0xFFCBD5E1);
  static const Color slateGray = Color(0xFF94A3B8);
  static const Color indigo = Color(0xFF6366F1);
  static const Color brightGreen = Color(0xFF34D399);
  static const Color forestGreen = Color(0xFF2D6A4F);

  // ── Decorative / illustration colors ───────────────────────
  // One-off colors used in a single decorative context (onboarding
  // illustrations, the Settings privacy banner, the Sign Up avatar icon).
  // Still centralized here (rather than left inline) so no Color(0x...)
  // literal exists outside lib/core/design_system/ — but grouped
  // separately from the semantic tokens above since these don't represent
  // a reusable design decision, just a specific illustration's palette.
  static const Color onboardingScaffoldBg = Color(0xFFEEF2FB);
  static const Color onboardingGradientMid = Color(0xFFEEF3FA);
  static const Color onboardingGradientEnd = Color(0xFFF4F7FC);
  static const Color onboardingIconTileBg = Color(0xFFDDE4F8);
  static const Color onboardingCardIcon = Color(0xFFA8BBDB);
  static const Color onboardingTaskLineTeal = Color(0xFFDCFAF0);
  static const Color onboardingBadgeMuted = Color(0xFF93B0D4);
  static const Color onboardingPillBg = Color(0xFFE4EAF4);
  static const Color pinDotUnfilled = Color(0xFFD1DCF0);
  static const Color selectedChipBg = Color(0xFFF0F0F0);
  static const Color chartBarInactive = Color(0xFFBFD7FF);
  static const Color privacyBannerGradientStart = Color(0xFFC7D9C0);
  static const Color privacyBannerGradientEnd = Color(0xFFA3C4A0);
  static const Color privacyBannerIcon = Color(0xFF3D5A3D);
  static const Color privacyBannerHeading = Color(0xFF1A3D1A);
  static const Color reflectionCardGradientStart = Color(0xFF1E3A5F);
  static const Color signUpAvatarBg = Color(0xFF6EE7B7);
  static const Color signUpAvatarIcon = Color(0xFF065F46);
}
