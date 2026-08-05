import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/context_extensions.dart';

/// The base rounded, elevation-free card used everywhere in the app so
/// every surface shares the same corner radius and ripple behavior.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.large);
    return Material(
      color: color ?? scheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      // A hairline outline, not elevation: under some dynamic-color
      // palettes `surfaceContainerHigh` is nearly identical to the
      // scaffold background, which left cards invisible on device.
      // Note: Material asserts that `shape` and `borderRadius` are never
      // both set, so the radius lives inside the shape.
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A square icon+label card for the Home quick-actions grid and the Tools
/// screen. Both features reuse this instead of duplicating card markup.
class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.iconBackgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      // Icon pinned top, label pinned bottom — packing both to the top
      // left a dead band across the lower half of every card.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: iconColor ?? scheme.onSecondaryContainer, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
