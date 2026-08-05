import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../domain/entities/page_layout.dart';
import '../providers/image_to_pdf_providers.dart';

/// Page size / orientation / margin controls for Image→PDF.
class PageOptionsSheet extends ConsumerWidget {
  const PageOptionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageSize = ref.watch(pageSizeOptionProvider);
    final orientation = ref.watch(pageOrientationProvider);
    final margin = ref.watch(pageMarginProvider);
    // Orientation is meaningless when each page matches its own image.
    final orientationEnabled = pageSize != PdfPageSizeOption.fitImage;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.sm,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Page options', style: context.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            const _Label('Page size'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final option in PdfPageSizeOption.values)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: pageSize == option,
                    onSelected: (_) =>
                        ref.read(pageSizeOptionProvider.notifier).state = option,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const _Label('Orientation'),
            const SizedBox(height: AppSpacing.sm),
            Opacity(
              opacity: orientationEnabled ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !orientationEnabled,
                child: SegmentedButton<PageOrientation>(
                  segments: [
                    for (final value in PageOrientation.values)
                      ButtonSegment(value: value, label: Text(value.label)),
                  ],
                  selected: {orientation},
                  onSelectionChanged: (selection) =>
                      ref.read(pageOrientationProvider.notifier).state = selection.first,
                ),
              ),
            ),
            if (!orientationEnabled)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Each page matches its own image',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            const _Label('Margins'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final value in PageMargin.values)
                  ChoiceChip(
                    label: Text(value.label),
                    selected: margin == value,
                    onSelected: (_) => ref.read(pageMarginProvider.notifier).state = value,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.primary),
    );
  }
}
