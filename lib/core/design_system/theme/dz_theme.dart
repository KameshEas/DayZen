import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/dz_colors.dart';
import '../tokens/dz_text_styles.dart';
import '../tokens/dz_dimensions.dart';

/// DayZen App Theme
/// Provides both light and dark [ThemeData] conforming to the DayZen
/// Design System specification.
abstract final class DzTheme {
  // ── Light Theme ────────────────────────────────────────────
  static ThemeData light({Color accent = DzColors.navy}) =>
      _buildTheme(brightness: Brightness.light, accent: accent);

  // ── Dark Theme ─────────────────────────────────────────────
  static ThemeData dark({Color accent = DzColors.navy}) =>
      _buildTheme(brightness: Brightness.dark, accent: accent);

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Text/icon-safe version of [color] on [surface]: brand Navy flips to
  /// Sunrise on dark, and any other accent is nudged toward Navy (light) or
  /// white (dark) until it reaches 3.5:1 against the surface.
  static Color _readable(Color color, Color surface, bool isDark) {
    if (isDark && color == DzColors.navy) return DzColors.sunrise;
    final toward = isDark ? DzColors.white : DzColors.navy;
    var out = color;
    for (var t = 0.0; t <= 1.0 && _contrast(out, surface) < 3.5; t += 0.05) {
      out = Color.lerp(color, toward, t)!;
    }
    return out;
  }

  static Color _onColor(Color background) =>
      background.computeLuminance() > 0.35 ? DzColors.navy : DzColors.white;

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color accent,
  }) {
    final bool isDark = brightness == Brightness.dark;

    final Color bg = isDark ? DzColors.darkBackground : DzColors.appBackground;
    final Color card = isDark ? DzColors.darkCard : DzColors.cardBackground;
    final Color textPrimary = isDark ? DzColors.darkText : DzColors.textPrimary;
    final Color textSecondary =
        isDark ? DzColors.darkTextSecondary : DzColors.textSecondary;
    final Color outline = isDark ? DzColors.darkBorder : DzColors.borderLight;
    final Color fieldFill = isDark ? DzColors.darkSurfaceHigh : DzColors.white;

    // Everything below that used the raw accent now uses the readable primary.
    final Color primary = _readable(accent, card, isDark);
    final Color onPrimary = _onColor(primary);
    accent = primary;
    final Color primaryContainer = isDark
        ? Color.lerp(primary, DzColors.navyDeep, 0.75)!
        : Color.lerp(primary, DzColors.white, 0.88)!;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: isDark ? DzColors.darkText : DzColors.textPrimary,
      secondary: DzColors.sunrise,
      onSecondary: DzColors.navy,
      secondaryContainer: isDark ? DzColors.darkSurfaceHigh : DzColors.sunriseTint,
      onSecondaryContainer: isDark ? DzColors.darkText : DzColors.textPrimary,
      error: DzColors.error,
      onError: DzColors.white,
      errorContainer: isDark ? const Color(0xFF5A2A2A) : DzColors.errorTint,
      onErrorContainer: isDark ? DzColors.white : DzColors.textPrimary,
      surface: card,
      onSurface: textPrimary,
      surfaceContainerHighest:
          isDark ? DzColors.darkSurfaceHigh : DzColors.borderLight,
      onSurfaceVariant: textSecondary,
      outline: outline,
      outlineVariant: isDark ? DzColors.darkSurfaceHigh : DzColors.neutralTint,
      scrim: Colors.black,
      inverseSurface: isDark ? DzColors.appBackground : DzColors.darkBackground,
      onInverseSurface: isDark ? DzColors.textPrimary : DzColors.darkText,
      inversePrimary: isDark ? DzColors.navy : DzColors.sunrise,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: DzTextStyles.heading3.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: DzColors.darkBackground,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: DzColors.appBackground,
              ),
      ),

      // ── Bottom Navigation ────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: DzTextStyles.label.copyWith(color: accent),
        unselectedLabelStyle: DzTextStyles.label.copyWith(color: textSecondary),
      ),

      // ── Cards ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DzRadius.card),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Elevated Button ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, DzSizing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DzRadius.button),
          ),
          textStyle: DzTextStyles.button,
          animationDuration: DzDuration.fast,
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1.5),
          minimumSize: const Size(double.infinity, DzSizing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DzRadius.button),
          ),
          textStyle: DzTextStyles.button.copyWith(color: accent),
          animationDuration: DzDuration.fast,
        ),
      ),

      // ── Text Button ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(0, DzSizing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.sm,
            vertical: DzSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DzRadius.button),
          ),
          textStyle: DzTextStyles.button,
          animationDuration: DzDuration.fast,
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DzColors.sunrise,
        foregroundColor: DzColors.navy,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DzRadius.fab),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: DzSizing.fabSize,
          height: DzSizing.fabSize,
        ),
      ),

      // ── Input Decoration ─────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.md,
          vertical: 14,
        ),
        hintStyle: DzTextStyles.body.copyWith(color: textSecondary),
        labelStyle: DzTextStyles.caption.copyWith(color: textSecondary),
        floatingLabelStyle: DzTextStyles.caption.copyWith(color: accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DzRadius.input),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DzRadius.input),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DzRadius.input),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DzRadius.input),
          borderSide: const BorderSide(color: DzColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DzRadius.input),
          borderSide: const BorderSide(color: DzColors.error, width: 1.5),
        ),
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? DzColors.darkSurfaceHigh : DzColors.neutralTint,
        labelStyle: DzTextStyles.caption.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DzRadius.small),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.sm,
          vertical: DzSpacing.xs,
        ),
      ),

      // ── List Tile ────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.md,
          vertical: DzSpacing.xs,
        ),
        minVerticalPadding: DzSpacing.sm,
        titleTextStyle: DzTextStyles.body.copyWith(color: textPrimary),
        subtitleTextStyle: DzTextStyles.caption.copyWith(color: textSecondary),
        iconColor: textSecondary,
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onPrimary;
          return isDark ? DzColors.mist : DzColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return isDark ? DzColors.darkSurfaceHigh : DzColors.borderLight;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Page Transitions ─────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ── Text Theme ───────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: DzTextStyles.heading1.copyWith(color: textPrimary),
        displayMedium: DzTextStyles.heading2.copyWith(color: textPrimary),
        displaySmall: DzTextStyles.heading3.copyWith(color: textPrimary),
        headlineLarge: DzTextStyles.heading1.copyWith(color: textPrimary),
        headlineMedium: DzTextStyles.heading2.copyWith(color: textPrimary),
        headlineSmall: DzTextStyles.heading3.copyWith(color: textPrimary),
        titleLarge: DzTextStyles.heading3.copyWith(color: textPrimary),
        titleMedium: DzTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: DzTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: DzTextStyles.body.copyWith(color: textPrimary),
        bodyMedium: DzTextStyles.caption.copyWith(color: textPrimary),
        bodySmall: DzTextStyles.small.copyWith(color: textSecondary),
        labelLarge: DzTextStyles.button,
        labelMedium: DzTextStyles.label.copyWith(color: textPrimary),
        labelSmall: DzTextStyles.small,
      ),
    );
  }
}
