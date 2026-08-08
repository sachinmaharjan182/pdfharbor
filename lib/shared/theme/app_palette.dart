import 'package:flutter/material.dart';

/// The app's fixed brand palette.
///
/// PDFHarbor ships a designed identity (indigo brand, near-white canvas,
/// white cards on a hairline border), so colors are pinned here rather than
/// derived from a seed or from the platform's dynamic palette — a wallpaper
/// on Android 12+ must not be able to repaint the product.
abstract final class AppPalette {
  // Brand
  static const Color brand = Color(0xFF2F5AF0);
  static const Color brandPressed = Color(0xFF2449CC);
  static const Color brandOnDark = Color(0xFF7D9BFF);

  // Light canvas
  static const Color lightCanvas = Color(0xFFF6F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightMuted = Color(0xFFF1F3F7);
  static const Color lightBorder = Color(0xFFE6E9F0);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightTint = Color(0xFFE9EEFF);

  // Dark canvas
  static const Color darkCanvas = Color(0xFF0E1116);
  static const Color darkCard = Color(0xFF171B22);
  static const Color darkMuted = Color(0xFF1E232B);
  static const Color darkBorder = Color(0xFF272D37);
  static const Color darkText = Color(0xFFF3F5F8);
  static const Color darkTextMuted = Color(0xFF98A2B3);
  static const Color darkTint = Color(0xFF1B2540);

  // Status
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
}

/// Per-tool accent colors. Each tool keeps the same hue everywhere it shows
/// up (Home quick action, Tools row, empty state), so the color becomes a
/// recognisable shorthand for the tool.
abstract final class AppAccents {
  static const Color blue = Color(0xFF2F5AF0);
  static const Color green = Color(0xFF16A34A);
  static const Color violet = Color(0xFF7C5CFC);
  static const Color orange = Color(0xFFF97316);
  static const Color red = Color(0xFFE5484D);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF0EA5E9);
  static const Color amber = Color(0xFFF59E0B);
}

extension AccentTint on Color {
  /// The soft background an accent icon sits on. Light mode uses a pale
  /// wash of the hue; dark mode needs more alpha to stay visible against
  /// the card.
  Color tint(Brightness brightness) =>
      withValues(alpha: brightness == Brightness.light ? 0.12 : 0.22);

  /// The accent itself, lightened for dark mode where the saturated light
  /// mode hue reads as muddy on a dark card.
  Color onTint(Brightness brightness) => brightness == Brightness.light
      ? this
      : Color.lerp(this, Colors.white, 0.32) ?? this;
}
