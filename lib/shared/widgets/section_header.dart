import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

/// Title + optional trailing action, used above every horizontal list or
/// grid section (Recent Files, Quick Actions, ...).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (actionLabel case final label?)
          GestureDetector(
            onTap: onActionTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                label,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
