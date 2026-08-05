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
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (actionLabel case final label?) TextButton(onPressed: onActionTap, child: Text(label)),
      ],
    );
  }
}
