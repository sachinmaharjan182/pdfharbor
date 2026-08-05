import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/file_size_extension.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/result_success_sheet.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../files/presentation/widgets/pdf_thumbnail.dart';
import '../providers/merge_providers.dart';

class MergeScreen extends ConsumerStatefulWidget {
  const MergeScreen({super.key});

  @override
  ConsumerState<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends ConsumerState<MergeScreen> {
  bool _isMerging = false;

  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(mergeSelectionProvider);
    final canMerge = candidates.length >= 2 && !_isMerging;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDF'),
        actions: [
          if (candidates.isNotEmpty)
            TextButton(
              onPressed: _isMerging
                  ? null
                  : () => ref.read(mergeSelectionProvider.notifier).clear(),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isMerging) const LinearProgressIndicator(),
          Expanded(
            child: candidates.isEmpty
                ? EmptyState(
                    icon: Icons.call_merge_rounded,
                    title: 'No PDFs selected',
                    message: 'Add two or more PDFs, then drag to set the order they merge in.',
                    action: FilledButton.icon(
                      onPressed: _addFiles,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add PDFs'),
                    ),
                  )
                : _buildList(candidates),
          ),
          if (candidates.isNotEmpty) _buildBottomBar(canMerge, candidates.length),
        ],
      ),
      floatingActionButton: candidates.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _isMerging ? null : _addFiles,
              tooltip: 'Add PDFs',
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildList(List<MergeCandidate> candidates) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl * 2,
      ),
      itemCount: candidates.length,
      onReorder: ref.read(mergeSelectionProvider.notifier).reorder,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        return Padding(
          key: ValueKey(candidate.path),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: context.colorScheme.secondaryContainer,
                    child: Text(
                      '${index + 1}',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  PdfThumbnail(path: candidate.path, width: 40, height: 52),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          candidate.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium,
                        ),
                        Text(
                          candidate.sizeBytes.readableFileSize,
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _isMerging
                        ? null
                        : () => ref.read(mergeSelectionProvider.notifier).removeAt(index),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(bool canMerge, int count) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count < 2)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Add at least one more PDF to merge',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canMerge ? _merge : null,
                icon: const Icon(Icons.call_merge_rounded),
                label: Text(_isMerging ? 'Merging…' : 'Merge $count PDFs'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFiles() async {
    final paths = await PdfPicker.pickMultiple();
    if (paths.isEmpty) return;
    await ref.read(mergeSelectionProvider.notifier).addPaths(paths);
  }

  Future<void> _merge() async {
    final candidates = ref.read(mergeSelectionProvider);
    final outputName = await _askOutputName();
    if (outputName == null || !mounted) return;

    setState(() => _isMerging = true);
    final result = await ref.read(mergePdfsUseCaseProvider).call(
          sourcePaths: candidates.map((c) => c.path).toList(),
          outputName: outputName,
        );
    if (!mounted) return;
    setState(() => _isMerging = false);

    result.fold(
      (path) {
        ref.read(mergeSelectionProvider.notifier).clear();
        invalidateFilesProviders(ref);
        showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => ResultSuccessSheet(
            filePaths: [path],
            title: 'PDFs merged',
          ),
        );
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }

  Future<String?> _askOutputName() {
    final controller = TextEditingController(text: 'Merged document');
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save as'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'File name', suffixText: '.pdf'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              Navigator.of(dialogContext).pop(name.isEmpty ? 'Merged document' : name);
            },
            child: const Text('Merge'),
          ),
        ],
      ),
    );
  }
}
