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
  static ThemeData light({Color accent = const Color(0xFF10B981)}) =>
      _buildTheme(brightness: Brightness.light, accent: accent);

  // ── Dark Theme ─────────────────────────────────────────────
  static ThemeData dark({Color accent = const Color(0xFF10B981)}) =>
      _buildTheme(brightness: Brightness.dark, accent: accent);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color accent,
  }) {
    final bool isDark = brightness == Brightness.dark;

    final Color bg = isDark ? DzColors.darkBackground : DzColors.appBackground;
    final Color card = isDark ? DzColors.darkCard : DzColors.cardBackground;
    final Color textPrimary = isDark ? DzColors.darkText : DzColors.textPrimary;
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : DzColors.textSecondary;
    final Color primaryContainer = isDark
        ? Color.lerp(accent, const Color(0xFF000000), 0.6)!
        : Color.lerp(accent, const Color(0xFFFFFFFF), 0.85)!;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: DzColors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: isDark ? DzColors.white : DzColors.textPrimary,
      secondary: DzColors.zenGreen,
      onSecondary: DzColors.white,
      secondaryContainer: isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5),
      onSecondaryContainer: isDark ? DzColors.white : DzColors.textPrimary,
      error: DzColors.error,
      onError: DzColors.white,
      errorContainer: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
      onErrorContainer: isDark ? DzColors.white : DzColors.textPrimary,
      surface: card,
      onSurface: textPrimary,
      surfaceContainerHighest: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      onSurfaceVariant: textSecondary,
      outline: isDark ? const Color(0xFF475569) : DzColors.borderLight,
      outlineVariant: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      scrim: Colors.black,
      inverseSurface: isDark ? DzColors.appBackground : DzColors.darkBackground,
      onInverseSurface: isDark ? DzColors.textPrimary : DzColors.darkText,
      inversePrimary: accent,
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
          foregroundColor: DzColors.white,
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
        backgroundColor: accent,
        foregroundColor: DzColors.white,
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
        fillColor: isDark ? const Color(0xFF334155) : DzColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.md,
          vertical: 14,
        ),
        hintStyle: DzTextStyles.body.copyWith(color: textSecondary),
        labelStyle: DzTextStyles.caption.copyWith(color: textSecondary),
        floatingLabelStyle: DzTextStyles.caption.copyWith(color: accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DzRadius.input),
          borderSide: BorderSide(color: DzColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DzRadius.input),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF475569) : DzColors.borderLight,
          ),
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
        color: isDark ? const Color(0xFF334155) : DzColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
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
          if (states.contains(WidgetState.selected)) return DzColors.white;
          return isDark ? const Color(0xFF94A3B8) : DzColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return isDark ? const Color(0xFF334155) : DzColors.borderLight;
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
