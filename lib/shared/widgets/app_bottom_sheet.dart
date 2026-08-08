import 'package:flutter/material.dart';

/// Shows a modal bottom sheet with the app's rounded-top styling (configured
/// globally in [BottomSheetThemeData]) and safe-area handling, so every
/// feature gets consistent bottom-sheet behavior for free.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    // Root navigator, so the sheet covers the shell's bottom bar and its
    // docked action button instead of being painted over by them.
    useRootNavigator: true,
    builder: builder,
  );
}
