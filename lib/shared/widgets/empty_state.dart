import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/context_extensions.dart';

/// Standard empty-state layout: soft icon badge, title, optional message and
/// action. Used instead of a bare "No items" text anywhere a list can be
/// empty.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: scheme.onSecondaryContainer),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(title, style: context.textTheme.titleLarge, textAlign: TextAlign.center),
            if (message case final msg?) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                msg,
                style: context.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (action case final actionWidget?) ...[
              const SizedBox(height: AppSpacing.xxl),
              actionWidget,
            ],
          ],
        ),
      ),
    );
  }
}
