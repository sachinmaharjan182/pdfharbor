import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/selection_mark.dart';
import '../../../files/presentation/widgets/pdf_thumbnail.dart';
import '../../domain/entities/export_options.dart';
import '../providers/pdf_to_image_providers.dart';

class PdfToImageScreen extends ConsumerStatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  ConsumerState<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends ConsumerState<PdfToImageScreen> {
  String? _sourcePath;
  final Set<int> _selectedPages = {};
  ImageExportFormat _format = ImageExportFormat.jpeg;
  ImageExportQuality _quality = ImageExportQuality.medium;

  bool _isExporting = false;
  int _done = 0;
  int _total = 0;
  List<String>? _exportedPaths;

  @override
  Widget build(BuildContext context) {
    final path = _sourcePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Images'),
        actions: [
          if (path != null && !_isExporting)
            TextButton(onPressed: _pickFile, child: const Text('Change')),
        ],
      ),
      body: path == null ? _buildPicker() : _buildEditor(path),
    );
  }

  Widget _buildPicker() {
    return EmptyState(
      icon: Icons.collections_rounded,
      title: 'Choose a PDF to export',
      message: 'Turn selected pages into JPEG or PNG image files.',
      action: FilledButton.icon(
        onPressed: _pickFile,
        icon: const Icon(Icons.folder_open_rounded),
        label: const Text('Select PDF'),
      ),
    );
  }

  Widget _buildEditor(String path) {
    final asyncCount = ref.watch(exportPageCountProvider(path));

    return asyncCount.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: 'Could not read this PDF.',
        onRetry: () => ref.invalidate(exportPageCountProvider(path)),
      ),
      data: (pageCount) {
        final allSelected = _selectedPages.length == pageCount;

        return Column(
          children: [
            if (_isExporting)
              LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  _buildSourceCard(path, pageCount),
                  if (_exportedPaths case final paths?) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildExportedCard(paths),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Expanded(child: Text('Pages', style: context.textTheme.titleMedium)),
                      TextButton(
                        onPressed: _isExporting
                            ? null
                            : () => setState(() {
                                  if (allSelected) {
                                    _selectedPages.clear();
                                  } else {
                                    _selectedPages
                                      ..clear()
                                      ..addAll(List.generate(pageCount, (i) => i + 1));
                                  }
                                }),
                        child: Text(allSelected ? 'Clear all' : 'Select all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPageChips(pageCount),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Format', style: context.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ...ImageExportFormat.values.map(_buildFormatTile),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Quality', style: context.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<ImageExportQuality>(
                    segments: [
                      for (final value in ImageExportQuality.values)
                        ButtonSegment(value: value, label: Text(value.label)),
                    ],
                    selected: {_quality},
                    onSelectionChanged: _isExporting
                        ? null
                        : (selection) => setState(() => _quality = selection.first),
                  ),
                  if (_format == ImageExportFormat.png)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'PNG is lossless — quality only affects resolution.',
                        style: context.textTheme.bodySmall
                            ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
            _buildBottomBar(path),
          ],
        );
      },
    );
  }

  Widget _buildSourceCard(String path, int pageCount) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          PdfThumbnail(path: path, width: 44, height: 56),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.basename(path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall,
                ),
                Text(
                  '$pageCount pages • ${_selectedPages.length} selected',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportedCard(List<String> paths) {
    return AppCard(
      color: context.colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: context.colorScheme.onPrimaryContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${paths.length} ${paths.length == 1 ? 'image' : 'images'} saved to '
              'Documents/PDFverse',
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.onPrimaryContainer),
            ),
          ),
          IconButton(
            tooltip: 'Share',
            icon: Icon(Icons.share_rounded, color: context.colorScheme.onPrimaryContainer),
            onPressed: () => Share.shareXFiles(paths.map(XFile.new).toList()),
          ),
        ],
      ),
    );
  }

  Widget _buildPageChips(int pageCount) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var page = 1; page <= pageCount; page++)
          FilterChip(
            label: Text('$page'),
            selected: _selectedPages.contains(page),
            onSelected: _isExporting
                ? null
                : (selected) => setState(() {
                      if (selected) {
                        _selectedPages.add(page);
                      } else {
                        _selectedPages.remove(page);
                      }
                    }),
          ),
      ],
    );
  }

  Widget _buildFormatTile(ImageExportFormat format) {
    final scheme = context.colorScheme;
    final isSelected = _format == format;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        color: isSelected ? scheme.secondaryContainer : scheme.surfaceContainerHigh,
        borderColor: isSelected ? scheme.primary : null,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        padding: EdgeInsets.zero,
        onTap: _isExporting ? null : () => setState(() => _format = format),
        child: ListTile(
          title: Text(format.label),
          subtitle: Text(format.description),
          trailing: SelectionMark(isSelected: isSelected),
        ),
      ),
    );
  }

  Widget _buildBottomBar(String path) {
    final canExport = _selectedPages.isNotEmpty && !_isExporting;
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
            if (_isExporting && _total > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Exporting page $_done of $_total…',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              )
            else if (_selectedPages.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Select at least one page',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canExport ? () => _export(path) : null,
                icon: const Icon(Icons.image_rounded),
                label: Text(
                  _isExporting
                      ? 'Exporting…'
                      : 'Export ${_selectedPages.length} '
                          '${_selectedPages.length == 1 ? 'image' : 'images'}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final path = await PdfPicker.pickSingle();
    if (path == null) return;
    if (!await File(path).exists()) return;
    setState(() {
      _sourcePath = path;
      _selectedPages.clear();
      _exportedPaths = null;
      _done = 0;
      _total = 0;
    });
  }

  Future<void> _export(String path) async {
    setState(() {
      _isExporting = true;
      _exportedPaths = null;
      _done = 0;
      _total = _selectedPages.length;
    });

    final result = await ref.read(exportPdfPagesUseCaseProvider).call(
          sourcePath: path,
          pageNumbers: _selectedPages.toList(),
          format: _format,
          quality: _quality,
          onProgress: (done, total) {
            if (!mounted) return;
            setState(() {
              _done = done;
              _total = total;
            });
          },
        );

    if (!mounted) return;
    setState(() => _isExporting = false);

    result.fold(
      (paths) => setState(() => _exportedPaths = paths),
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }
}
