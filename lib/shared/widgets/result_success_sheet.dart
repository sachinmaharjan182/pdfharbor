import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/context_extensions.dart';
import '../../core/utils/file_size_extension.dart';
import '../navigation/app_router.dart';

/// Shown after a tool produces a file: confirms where it was saved and
/// offers open/share. Shared by merge, split, compress, and the converters
/// so every tool ends the same way.
class ResultSuccessSheet extends StatelessWidget {
  const ResultSuccessSheet({
    required this.filePaths,
    super.key,
    this.title = 'Done!',
  });

  final List<String> filePaths;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isSingle = filePaths.length == 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.sm,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle_rounded, color: scheme.primary, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: context.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isSingle
                  ? 'Saved to Documents/PDFHarbor'
                  : '${filePaths.length} files saved to Documents/PDFHarbor',
              style: context.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filePaths.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _FileRow(path: filePaths[index]),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles(
                      filePaths.map(XFile.new).toList(),
                    ),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.viewerFor(filePaths.first));
                    },
                    icon: const Icon(Icons.visibility_rounded),
                    label: Text(isSingle ? 'Open' : 'Open first'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final size = File(path).existsSync() ? File(path).lengthSync() : 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf_rounded, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.basename(path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  size.readableFileSize,
                  style: context.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
