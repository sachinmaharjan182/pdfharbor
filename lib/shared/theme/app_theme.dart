import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'app_palette.dart';

/// Builds the app's Material 3 [ThemeData] from the fixed brand palette in
/// [AppPalette].
///
/// The `dynamicScheme` parameter is accepted so existing callers keep
/// compiling, but it is deliberately ignored: PDFHarbor has a designed
/// identity, and letting the platform's wallpaper palette repaint it broke
/// the intended look (and, on some palettes, card/background contrast).
abstract final class AppTheme {
  static ThemeData light([ColorScheme? dynamicScheme]) => _themeFrom(lightScheme);

  static ThemeData dark([ColorScheme? dynamicScheme]) => _themeFrom(darkScheme);

  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.brand,
  ).copyWith(
    primary: AppPalette.brand,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.lightTint,
    onPrimaryContainer: AppPalette.brandPressed,
    secondary: AppPalette.brand,
    onSecondary: Colors.white,
    // Selected option cards / nav indicators across the app read this pair.
    secondaryContainer: AppPalette.lightTint,
    onSecondaryContainer: AppPalette.brandPressed,
    tertiary: AppAccents.violet,
    onTertiary: Colors.white,
    error: AppPalette.danger,
    onError: Colors.white,
    errorContainer: const Color(0xFFFDE7E7),
    onErrorContainer: const Color(0xFF7F1D1D),
    surface: AppPalette.lightCanvas,
    onSurface: AppPalette.lightText,
    onSurfaceVariant: AppPalette.lightTextMuted,
    surfaceContainerLowest: AppPalette.lightCard,
    surfaceContainerLow: AppPalette.lightCard,
    surfaceContainer: AppPalette.lightMuted,
    surfaceContainerHigh: AppPalette.lightCard,
    surfaceContainerHighest: AppPalette.lightMuted,
    outline: const Color(0xFFCBD2DE),
    outlineVariant: AppPalette.lightBorder,
    inverseSurface: const Color(0xFF1B212B),
    onInverseSurface: Colors.white,
  );

  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.brand,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppPalette.brandOnDark,
    onPrimary: const Color(0xFF0A1330),
    primaryContainer: AppPalette.darkTint,
    onPrimaryContainer: AppPalette.brandOnDark,
    secondary: AppPalette.brandOnDark,
    onSecondary: const Color(0xFF0A1330),
    secondaryContainer: AppPalette.darkTint,
    onSecondaryContainer: AppPalette.brandOnDark,
    tertiary: AppAccents.violet,
    onTertiary: Colors.white,
    error: const Color(0xFFFF6B6F),
    onError: const Color(0xFF3B0708),
    errorContainer: const Color(0xFF3A1516),
    onErrorContainer: const Color(0xFFFFD5D6),
    surface: AppPalette.darkCanvas,
    onSurface: AppPalette.darkText,
    onSurfaceVariant: AppPalette.darkTextMuted,
    surfaceContainerLowest: AppPalette.darkCard,
    surfaceContainerLow: AppPalette.darkCard,
    surfaceContainer: AppPalette.darkMuted,
    surfaceContainerHigh: AppPalette.darkCard,
    surfaceContainerHighest: AppPalette.darkMuted,
    outline: const Color(0xFF3A4250),
    outlineVariant: AppPalette.darkBorder,
    inverseSurface: AppPalette.darkText,
    onInverseSurface: AppPalette.darkCanvas,
  );

  static ThemeData _themeFrom(ColorScheme scheme) {
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
    );
    final textTheme = _buildTextTheme(base.textTheme);
    final isLight = scheme.brightness == Brightness.light;

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        // Flat headers: the design separates the bar from content with
        // whitespace, not with a tonal overlay on scroll.
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: AppSpacing.sm,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),
          side: BorderSide(color: scheme.outlineVariant),
          foregroundColor: scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: isLight ? AppPalette.lightMuted : AppPalette.darkMuted,
        hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        modalBackgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
        ),
        showDragHandle: true,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: isLight ? AppPalette.lightMuted : AppPalette.darkMuted,
        selectedColor: scheme.secondaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide.none,
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: isLight ? AppPalette.lightMuted : AppPalette.darkMuted,
          selectedBackgroundColor: scheme.secondaryContainer,
          selectedForegroundColor: scheme.onSecondaryContainer,
          foregroundColor: scheme.onSurfaceVariant,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant,
        thumbColor: scheme.primary,
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
        circularTrackColor: scheme.outlineVariant,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        elevation: 0,
        height: 68,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        indicatorColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }

  /// The design uses a slightly larger, tighter type ramp than Material's
  /// default — big bold headings, quiet secondary text.
  ///
  /// This scales each style individually rather than via
  /// `TextTheme.apply(fontSizeFactor:)`, which asserts that *every* style
  /// has a non-null `fontSize` — not guaranteed for a Material 3 base
  /// theme, and it crashes at first build when one is null.
  static TextTheme _buildTextTheme(TextTheme base) {
    return TextTheme(
      displayLarge: _scale(base.displayLarge)?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displayMedium: _scale(base.displayMedium)?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      displaySmall: _scale(base.displaySmall)?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineLarge: _scale(base.headlineLarge)?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: _scale(base.headlineMedium)?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineSmall: _scale(base.headlineSmall)?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: _scale(base.titleLarge)?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: _scale(base.titleMedium)?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: _scale(base.titleSmall)?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: _scale(base.bodyLarge)?.copyWith(height: 1.4),
      bodyMedium: _scale(base.bodyMedium)?.copyWith(height: 1.4),
      bodySmall: _scale(base.bodySmall)?.copyWith(height: 1.3),
      labelLarge: _scale(base.labelLarge)?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: _scale(base.labelMedium)?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: _scale(base.labelSmall)?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static const double _fontSizeFactor = 1.05;

  /// Scales a style's size when it has one, and leaves it untouched when it
  /// doesn't — a null `fontSize` means "inherit", which must be preserved.
  static TextStyle? _scale(TextStyle? style) {
    if (style == null) return null;
    final size = style.fontSize;
    if (size == null) return style;
    return style.copyWith(fontSize: size * _fontSizeFactor);
  }
}

/// The single soft shadow every raised surface in the design uses. Dark
/// mode drops it — on a near-black canvas a shadow reads as smudge, so the
/// hairline border does the separating instead.
abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return [
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
