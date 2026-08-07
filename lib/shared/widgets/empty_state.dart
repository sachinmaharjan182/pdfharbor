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
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: Icon(icon, size: 34, color: scheme.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, style: context.textTheme.titleMedium, textAlign: TextAlign.center),
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
