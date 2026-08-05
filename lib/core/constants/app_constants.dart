/// Static, cross-feature constants. Feature-specific constants belong in
/// that feature's own folder instead of here.
abstract final class AppConstants {
  static const String appName = 'PDFverse';
}

/// Corner radii used across cards, sheets, and dialogs (spec calls for 20-28).
abstract final class AppRadius {
  static const double small = 12;
  static const double medium = 20;
  static const double large = 24;
  static const double extraLarge = 28;
}

/// Spacing scale used instead of magic numbers in layout code.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Shared animation durations/curves.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
}

/// Hive box names. Centralized so a typo can't silently open two boxes.
abstract final class HiveBoxes {
  static const String settings = 'settings_box';
  static const String recentFiles = 'recent_files_box';
  static const String favorites = 'favorites_box';
  static const String bookmarks = 'bookmarks_box';
  static const String signatures = 'signatures_box';
}
