import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/result_success_sheet.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../domain/entities/image_filter_type.dart';
import '../../domain/entities/image_page_item.dart';
import '../providers/image_to_pdf_providers.dart';
import '../widgets/page_options_sheet.dart';

class ImageToPdfScreen extends ConsumerStatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  ConsumerState<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends ConsumerState<ImageToPdfScreen> {
  bool _isBuilding = false;
  int _done = 0;
  int _total = 0;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(imageSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
        actions: [
          if (items.isNotEmpty) ...[
            IconButton(
              tooltip: 'Page options',
              icon: const Icon(Icons.tune_rounded),
              onPressed: _isBuilding ? null : _showPageOptions,
            ),
            PopupMenuButton<ImageFilterType>(
              tooltip: 'Apply filter to all',
              icon: const Icon(Icons.filter_b_and_w_rounded),
              onSelected: (filter) =>
                  ref.read(imageSelectionProvider.notifier).setFilterForAll(filter),
              itemBuilder: (context) => [
                for (final filter in ImageFilterType.values)
                  PopupMenuItem(value: filter, child: Text('All: ${filter.label}')),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_isBuilding)
            LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
          Expanded(
            child: items.isEmpty ? _buildEmpty() : _buildGrid(items),
          ),
          if (items.isNotEmpty) _buildBottomBar(items.length),
        ],
      ),
      floatingActionButton: items.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _isBuilding ? null : _pickImages,
              tooltip: 'Add images',
              child: const Icon(Icons.add_photo_alternate_rounded),
            ),
    );
  }

  Widget _buildEmpty() {
    return EmptyState(
      icon: Icons.image_rounded,
      title: 'No images yet',
      message: 'Pick photos or scans, arrange them, then export as a single PDF.',
      action: FilledButton.icon(
        onPressed: _pickImages,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Add images'),
      ),
    );
  }

  Widget _buildGrid(List<ImagePageItem> items) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl * 2,
      ),
      itemCount: items.length,
      onReorder: ref.read(imageSelectionProvider.notifier).reorder,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          key: ValueKey(item.id),
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
                      File(item.path),
                      width: 52,
                      height: 66,
                      fit: BoxFit.cover,
                      // Keyed by rotation so the preview reflects edits.
                      key: ValueKey('${item.id}-${item.normalizedRotation}'),
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
                          '${item.filter.label} • ${item.normalizedRotation}°',
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Rotate',
                    icon: const Icon(Icons.rotate_right_rounded),
                    onPressed: _isBuilding
                        ? null
                        : () => ref.read(imageSelectionProvider.notifier).rotate(item.id),
                  ),
                  IconButton(
                    tooltip: 'Crop',
                    icon: const Icon(Icons.crop_rounded),
                    onPressed: _isBuilding ? null : () => _cropImage(item),
                  ),
                  PopupMenuButton<_ItemAction>(
                    onSelected: (action) => _handleItemAction(action, item),
                    itemBuilder: (context) => [
                      for (final filter in ImageFilterType.values)
                        PopupMenuItem(
                          value: _ItemAction.filter(filter),
                          child: Row(
                            children: [
                              if (item.filter == filter)
                                const Icon(Icons.check_rounded, size: 18)
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Text(filter.label),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: _ItemAction.remove(),
                        child: ListTile(
                          leading: Icon(Icons.delete_outline_rounded),
                          title: Text('Remove'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
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
            if (_isBuilding && _total > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Processing image $_done of $_total…',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isBuilding ? null : _export,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(
                  _isBuilding ? 'Creating PDF…' : 'Create PDF from $count '
                      '${count == 1 ? 'image' : 'images'}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPageOptions() {
    return showAppBottomSheet<void>(context, builder: (context) => const PageOptionsSheet());
  }

  Future<void> _pickImages() async {
    final permission = await ref.read(permissionServiceProvider).requestPhotos();
    if (!mounted) return;
    if (permission == AppPermissionResult.permanentlyDenied) {
      context.showSnackBar(
        'Photo access is blocked. Enable it in Settings.',
        isError: true,
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => ref.read(permissionServiceProvider).openSettings(),
        ),
      );
      return;
    }

    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty) return;
    ref.read(imageSelectionProvider.notifier).addPaths(picked.map((x) => x.path));
  }

  Future<void> _cropImage(ImagePageItem item) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: item.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: context.colorScheme.surface,
          toolbarWidgetColor: context.colorScheme.onSurface,
          backgroundColor: context.colorScheme.surface,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );
    if (cropped == null) return;
    ref.read(imageSelectionProvider.notifier).replacePath(item.id, cropped.path);
  }

  void _handleItemAction(_ItemAction action, ImagePageItem item) {
    final notifier = ref.read(imageSelectionProvider.notifier);
    if (action.filter case final filter?) {
      notifier.setFilter(item.id, filter);
    } else {
      notifier.removeById(item.id);
    }
  }

  Future<void> _export() async {
    final items = ref.read(imageSelectionProvider);
    final name = await _askOutputName();
    if (name == null || !mounted) return;

    setState(() {
      _isBuilding = true;
      _done = 0;
      _total = items.length;
    });

    final result = await ref.read(buildPdfFromImagesUseCaseProvider).call(
          items: items,
          pageSize: ref.read(pageSizeOptionProvider),
          orientation: ref.read(pageOrientationProvider),
          margin: ref.read(pageMarginProvider),
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
    setState(() => _isBuilding = false);

    result.fold(
      (path) {
        ref.read(imageSelectionProvider.notifier).clear();
        invalidateFilesProviders(ref);
        showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => ResultSuccessSheet(
            filePaths: [path],
            title: 'PDF created',
          ),
        );
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }

  Future<String?> _askOutputName() {
    final controller = TextEditingController(text: 'Images to PDF');
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
              Navigator.of(dialogContext).pop(value.isEmpty ? 'Images to PDF' : value);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// Either "apply this filter" or "remove this page" from the item menu.
class _ItemAction {
  const _ItemAction.filter(this.filter);

  const _ItemAction.remove() : filter = null;

  final ImageFilterType? filter;
}
