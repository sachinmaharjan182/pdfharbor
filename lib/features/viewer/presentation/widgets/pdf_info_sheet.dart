import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/file_size_extension.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/viewer_providers.dart';

/// "PDF Information" bottom sheet listing document metadata.
class PdfInfoSheet extends ConsumerWidget {
  const PdfInfoSheet({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInfo = ref.watch(documentInfoProvider(path));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => asyncInfo.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxxl),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => ErrorView(
          message: 'Could not read document information.',
          onRetry: () => ref.invalidate(documentInfoProvider(path)),
        ),
        data: (info) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.sm,
            AppSpacing.xxl,
            AppSpacing.xxxl,
          ),
          children: [
            Text('PDF Information', style: context.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            _InfoRow(label: 'File name', value: info.fileName),
            _InfoRow(label: 'File size', value: info.sizeBytes.readableFileSize),
            _InfoRow(label: 'Pages', value: '${info.pageCount}'),
            _InfoRow(label: 'Encrypted', value: info.isEncrypted ? 'Yes' : 'No'),
            if (info.title case final value?) _InfoRow(label: 'Title', value: value),
            if (info.author case final value?) _InfoRow(label: 'Author', value: value),
            if (info.subject case final value?) _InfoRow(label: 'Subject', value: value),
            if (info.keywords case final value?) _InfoRow(label: 'Keywords', value: value),
            if (info.creator case final value?) _InfoRow(label: 'Creator', value: value),
            if (info.producer case final value?) _InfoRow(label: 'Producer', value: value),
            if (info.creationDate case final value?)
              _InfoRow(label: 'Created', value: _formatDate(value)),
            if (info.modificationDate case final value?)
              _InfoRow(label: 'Modified', value: _formatDate(value)),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: Text(value, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
