import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/context_extensions.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// The base surface used everywhere in the app: a white (or dark-mode
/// elevated) panel on a hairline border with one soft shadow, so every card
/// in the product shares the same corner radius, depth, and ripple.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.borderRadius,
    this.borderColor,
    this.showShadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;

  /// Overrides the hairline outline — used for selected states, which the
  /// design marks with a brand-colored border rather than a fill alone.
  final Color? borderColor;

  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.large);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showShadow ? AppShadows.card(scheme.brightness) : const [],
      ),
      child: Material(
        color: color ?? scheme.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        // A hairline outline, not elevation: under a near-white canvas the
        // card fill alone is not enough separation, and the shadow above is
        // deliberately faint.
        // Note: Material asserts that `shape` and `borderRadius` are never
        // both set, so the radius lives inside the shape.
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor ?? scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The rounded, tinted square an accent icon sits in — the single most
/// repeated element in the design (tool cards, file rows, settings, empty
/// states).
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    required this.icon,
    super.key,
    this.accent,
    this.size = 44,
    this.iconSize = 22,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  final IconData icon;
  final Color? accent;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final brightness = context.colorScheme.brightness;
    final tone = accent ?? context.colorScheme.primary;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? tone.tint(brightness),
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.small),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: foregroundColor ?? tone.onTint(brightness),
      ),
    );
  }
}

/// A compact icon+label tile for the Home quick-actions grid: accent icon
/// on a tinted square, label centered underneath.
class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// The tool's brand hue. Each tool keeps one hue everywhere it appears.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconTile(
            icon: icon,
            accent: accent,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Flexible, not a plain Text: the tile is deliberately small, so a
          // long tool name or a large system text scale must ellipsize
          // rather than overflow the card.
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width tool row — accent icon, title, one line of description —
/// used by the Tools catalogue and anywhere a list of destinations needs
/// more explanation than a grid tile can carry.
class ToolRowCard extends StatelessWidget {
  const ToolRowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Row(
        children: [
          AppIconTile(icon: icon, accent: accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
