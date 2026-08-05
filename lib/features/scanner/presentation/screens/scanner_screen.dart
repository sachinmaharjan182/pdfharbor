import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/result_success_sheet.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../image_to_pdf/domain/entities/image_filter_type.dart';
import '../providers/scanner_providers.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _isSaving = false;
  int _done = 0;
  int _total = 0;

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(scannedPagesProvider);
    final filter = ref.watch(scanFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        actions: [
          if (pages.isNotEmpty && !_isSaving)
            TextButton(
              onPressed: () {
                ref.read(scannedPagesProvider.notifier).clear();
                ref.read(scanRotationsProvider.notifier).state = const {};
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isSaving) LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
          Expanded(
            child: pages.isEmpty ? _buildEmpty() : _buildPages(pages, filter),
          ),
          if (pages.isNotEmpty) _buildBottomBar(pages.length),
        ],
      ),
      floatingActionButton: pages.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _isSaving ? null : _scan,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Scan more'),
            ),
    );
  }

  Widget _buildEmpty() {
    return EmptyState(
      icon: Icons.document_scanner_rounded,
      title: 'Scan a document',
      message: 'Your camera detects page edges automatically and straightens the result.',
      action: FilledButton.icon(
        onPressed: _scan,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Start scanning'),
      ),
    );
  }

  Widget _buildPages(List<String> pages, ImageFilterType filter) {
    final rotations = ref.watch(scanRotationsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(child: Text('Filter', style: context.textTheme.labelLarge)),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              for (final value in ImageFilterType.values)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(value.label),
                    selected: filter == value,
                    onSelected: _isSaving
                        ? null
                        : (_) => ref.read(scanFilterProvider.notifier).state = value,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl * 2,
            ),
            itemCount: pages.length,
            onReorder: ref.read(scannedPagesProvider.notifier).reorder,
            itemBuilder: (context, index) {
              final path = pages[index];
              final rotation = rotations[path] ?? 0;
              return Padding(
                key: ValueKey(path),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          child: Image.file(
                            File(path),
                            width: 52,
                            height: 66,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 52,
                              height: 66,
                              color: context.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image_rounded, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Page ${index + 1}', style: context.textTheme.bodyMedium),
                              Text(
                                '$rotation°',
                                style: context.textTheme.bodySmall
                                    ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Rotate',
                          icon: const Icon(Icons.rotate_right_rounded),
                          onPressed: _isSaving ? null : () => _rotate(path),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _isSaving
                              ? null
                              : () => ref.read(scannedPagesProvider.notifier).removeAt(index),
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
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(int count) {
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
            if (_isSaving && _total > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Processing page $_done of $_total…',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(
                  _isSaving
                      ? 'Saving…'
                      : 'Save $count ${count == 1 ? 'page' : 'pages'} as PDF',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rotate(String path) {
    final rotations = {...ref.read(scanRotationsProvider)};
    rotations[path] = ((rotations[path] ?? 0) + 90) % 360;
    ref.read(scanRotationsProvider.notifier).state = rotations;
  }

  Future<void> _scan() async {
    final permission = await ref.read(permissionServiceProvider).requestCamera();
    if (!mounted) return;
    if (permission == AppPermissionResult.permanentlyDenied) {
      context.showSnackBar(
        'Camera access is blocked. Enable it in Settings.',
        isError: true,
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => ref.read(permissionServiceProvider).openSettings(),
        ),
      );
      return;
    }

    final result = await ref.read(scanPagesUseCaseProvider).call();
    if (!mounted) return;

    result.fold(
      (paths) {
        if (paths.isEmpty) return;
        ref.read(scannedPagesProvider.notifier).addAll(paths);
      },
      (failure) => context.showSnackBar(
        failure is PermissionDeniedFailure
            ? 'Camera access is needed to scan documents.'
            : failure.message,
        isError: true,
      ),
    );
  }

  Future<void> _save() async {
    final pages = ref.read(scannedPagesProvider);
    final name = await _askOutputName();
    if (name == null || !mounted) return;

    setState(() {
      _isSaving = true;
      _done = 0;
      _total = pages.length;
    });

    final result = await ref.read(saveScanAsPdfUseCaseProvider).call(
          imagePaths: pages,
          filter: ref.read(scanFilterProvider),
          rotations: ref.read(scanRotationsProvider),
          outputName: name,
          onProgress: (done, total) {
            if (!mounted) return;
            setState(() {
              _done = done;
              _total = total;
            });
          },
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (path) {
        ref.read(scannedPagesProvider.notifier).clear();
        ref.read(scanRotationsProvider.notifier).state = const {};
        invalidateFilesProviders(ref);
        showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => ResultSuccessSheet(
            filePaths: [path],
            title: 'Scan saved',
          ),
        );
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }

  Future<String?> _askOutputName() {
    final controller = TextEditingController(
      text: 'Scan ${DateTime.now().toIso8601String().substring(0, 10)}',
    );
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
              final value = controller.text.trim();
              Navigator.of(dialogContext).pop(value.isEmpty ? 'Scan' : value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
