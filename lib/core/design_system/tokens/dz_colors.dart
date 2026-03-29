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
}
