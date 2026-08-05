import 'package:flutter/material.dart';

/// Shorthand accessors and common UI actions kept off the widget tree's
/// business logic (e.g. showing a themed snackbar from anywhere with a
/// `BuildContext`).
extension BuildContextX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isTablet => screenSize.shortestSide >= 600;

  void showSnackBar(
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? colorScheme.errorContainer : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          action: action,
        ),
      );
  }
}
