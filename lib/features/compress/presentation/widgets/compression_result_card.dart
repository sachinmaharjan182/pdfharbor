import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/file_size_extension.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/compression_result.dart';

/// Before/after summary shown once a compression run finishes.
class CompressionResultCard extends StatelessWidget {
  const CompressionResultCard({required this.result, super.key});

  final CompressionResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppCard(
      color: scheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: scheme.onPrimaryContainer),
              const SizedBox(width: AppSpacing.sm),
              Text(
                result.didShrink ? 'Compressed' : 'Finished',
                style: context.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
              ),
              const Spacer(),
              if (result.didShrink)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Text(
                    '-${result.savingsPercent}%',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SizeColumn(
                  label: 'Original',
                  value: result.originalBytes.readableFileSize,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: scheme.onPrimaryContainer),
              Expanded(
                child: _SizeColumn(
                  label: 'Compressed',
                  value: result.compressedBytes.readableFileSize,
                  color: scheme.onPrimaryContainer,
                  emphasize: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Share.shareXFiles([XFile(result.outputPath)]),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.viewerFor(result.outputPath)),
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Open'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppDurations.medium).slideY(begin: -0.05, end: 0);
  }
}

class _SizeColumn extends StatelessWidget {
  const _SizeColumn({
    required this.label,
    required this.value,
    required this.color,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(color: color.withValues(alpha: 0.75)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: (emphasize ? context.textTheme.titleLarge : context.textTheme.titleMedium)
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
