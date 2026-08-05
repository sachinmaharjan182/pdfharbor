import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

/// Confirmation dialog for destructive/irreversible actions (delete, remove
/// password, overwrite). Returns `true` only if the user tapped confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final scheme = context.colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: isDestructive
              ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Success dialog shown after a completed operation (merge, split, compress,
/// export, ...).
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  String? message,
  String actionLabel = 'Done',
  VoidCallback? onAction,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(Icons.check_circle_rounded, color: context.colorScheme.primary, size: 40),
      title: Text(title, textAlign: TextAlign.center),
      content: message != null ? Text(message, textAlign: TextAlign.center) : null,
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onAction?.call();
          },
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

/// Error dialog for failures that need more than a snackbar (e.g. blocking
/// the rest of a flow until acknowledged).
Future<void> showErrorDialog(
  BuildContext context, {
  required String message,
  String title = 'Something went wrong',
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(Icons.error_rounded, color: context.colorScheme.error, size: 40),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK')),
      ],
    ),
  );
}

/// Non-dismissible processing dialog for operations without a granular
/// progress value (e.g. a quick merge). Pop it with
/// `Navigator.of(context).pop()` once the operation finishes.
Future<void> showProcessingDialog(BuildContext context, {required String message}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    ),
  );
}
