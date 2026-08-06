import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/file_size_extension.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/selection_mark.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../files/presentation/widgets/pdf_thumbnail.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/compression_preset.dart';
import '../../domain/entities/compression_result.dart';
import '../providers/compress_providers.dart';
import '../widgets/compression_result_card.dart';

class CompressScreen extends ConsumerStatefulWidget {
  const CompressScreen({super.key});

  @override
  ConsumerState<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends ConsumerState<CompressScreen> {
  String? _sourcePath;
  int _sourceBytes = 0;
  late CompressionPreset _preset;

  bool _isCompressing = false;
  int _pagesDone = 0;
  int _pagesTotal = 0;
  CompressionResult? _result;

  @override
  void initState() {
    super.initState();
    _preset = switch (ref.read(settingsProvider).defaultCompression) {
      DefaultCompression.low => CompressionPreset.low,
      DefaultCompression.medium => CompressionPreset.medium,
      DefaultCompression.high => CompressionPreset.high,
    };
  }

  @override
  Widget build(BuildContext context) {
    final path = _sourcePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
        actions: [
          if (path != null && !_isCompressing)
            TextButton(onPressed: _pickFile, child: const Text('Change')),
        ],
      ),
      body: path == null ? _buildPicker() : _buildEditor(path),
    );
  }

  Widget _buildPicker() {
    return EmptyState(
      icon: Icons.compress_rounded,
      title: 'Choose a PDF to compress',
      message: 'Reduce file size so PDFs are easier to share and store.',
      action: FilledButton.icon(
        onPressed: _pickFile,
        icon: const Icon(Icons.folder_open_rounded),
        label: const Text('Select PDF'),
      ),
    );
  }

  Widget _buildEditor(String path) {
    return Column(
      children: [
        if (_isCompressing)
          LinearProgressIndicator(
            value: _pagesTotal == 0 ? null : _pagesDone / _pagesTotal,
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _buildSourceCard(path),
              const SizedBox(height: AppSpacing.xxl),
              if (_result case final result?) ...[
                CompressionResultCard(result: result),
                const SizedBox(height: AppSpacing.xxl),
              ],
              Text('Compression level', style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              ...CompressionPreset.values.map(_buildPresetTile),
              const SizedBox(height: AppSpacing.lg),
              _buildRasterNotice(),
            ],
          ),
        ),
        _buildBottomBar(path),
      ],
    );
  }

  Widget _buildSourceCard(String path) {
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
                  _sourceBytes.readableFileSize,
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

  Widget _buildPresetTile(CompressionPreset preset) {
    final scheme = context.colorScheme;
    final isSelected = _preset == preset;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        color: isSelected ? scheme.secondaryContainer : scheme.surfaceContainerHigh,
        borderColor: isSelected ? scheme.primary : null,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        padding: EdgeInsets.zero,
        onTap: _isCompressing ? null : () => setState(() => _preset = preset),
        child: ListTile(
          title: Text(preset.label),
          subtitle: Text(preset.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                preset.estimatedQuality,
                style: context.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.sm),
              SelectionMark(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRasterNotice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Compression converts pages to images, so text in the compressed '
            'copy is no longer selectable or searchable. Your original file '
            'is kept unchanged.',
            style: context.textTheme.bodySmall
                ?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(String path) {
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
            if (_isCompressing && _pagesTotal > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Compressing page $_pagesDone of $_pagesTotal…',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isCompressing ? null : () => _compress(path),
                icon: const Icon(Icons.compress_rounded),
                label: Text(_isCompressing ? 'Compressing…' : 'Compress PDF'),
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
    final size = await File(path).length();
    setState(() {
      _sourcePath = path;
      _sourceBytes = size;
      _result = null;
      _pagesDone = 0;
      _pagesTotal = 0;
    });
  }

  Future<void> _compress(String path) async {
    setState(() {
      _isCompressing = true;
      _result = null;
      _pagesDone = 0;
      _pagesTotal = 0;
    });

    final result = await ref.read(compressPdfUseCaseProvider).call(
          sourcePath: path,
          preset: _preset,
          onProgress: (done, total) {
            if (!mounted) return;
            setState(() {
              _pagesDone = done;
              _pagesTotal = total;
            });
          },
        );

    if (!mounted) return;
    setState(() => _isCompressing = false);

    result.fold(
      (compression) {
        invalidateFilesProviders(ref);
        setState(() => _result = compression);
        if (!compression.didShrink) {
          context.showSnackBar(
            'This PDF was already well optimized — the copy is not smaller.',
          );
        }
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }
}
