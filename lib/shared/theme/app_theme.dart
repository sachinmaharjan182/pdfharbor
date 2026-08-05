import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Builds the app's Material 3 [ThemeData]. Pass the platform's dynamic
/// [ColorScheme] (from `DynamicColorBuilder`, Android 12+) when available;
/// otherwise a seeded scheme is used so light/dark mode still look
/// deliberate rather than default Material blue.
abstract final class AppTheme {
  static const Color _seedColor = Color(0xFF3457D5);

  static ThemeData light([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme?.harmonized() ??
        ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);
    return _themeFrom(scheme);
  }

  static ThemeData dark([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme?.harmonized() ??
        ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);
    return _themeFrom(scheme);
  }

  static ThemeData _themeFrom(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: scheme.brightness);
    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shadowColor: scheme.shadow.withValues(alpha: 0.08),
        // Outlined rather than elevated — see the note in AppCard: some
        // dynamic-color palettes make container surfaces indistinguishable
        // from the background.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        backgroundColor: scheme.surfaceContainerHigh,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        modalBackgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
        ),
        showDragHandle: true,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
        indicatorColor: scheme.secondaryContainer,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
      ),
    );
  }

  /// The spec asks for a slightly larger type scale than Material's default.
  ///
  /// This scales each style individually rather than via
  /// `TextTheme.apply(fontSizeFactor:)`, which asserts that *every* style
  /// has a non-null `fontSize` — not guaranteed for a Material 3 base
  /// theme, and it crashes at first build when one is null.
  static TextTheme _buildTextTheme(TextTheme base) {
    return TextTheme(
      displayLarge: _scale(base.displayLarge)?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      displayMedium: _scale(base.displayMedium)?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: _scale(base.displaySmall),
      headlineLarge: _scale(base.headlineLarge)?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: _scale(base.headlineMedium)?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: _scale(base.headlineSmall)?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: _scale(base.titleLarge)?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: _scale(base.titleMedium)?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: _scale(base.titleSmall),
      bodyLarge: _scale(base.bodyLarge)?.copyWith(height: 1.4),
      bodyMedium: _scale(base.bodyMedium)?.copyWith(height: 1.4),
      bodySmall: _scale(base.bodySmall),
      labelLarge: _scale(base.labelLarge),
      labelMedium: _scale(base.labelMedium),
      labelSmall: _scale(base.labelSmall),
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
