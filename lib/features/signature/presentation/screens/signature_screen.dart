import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/result_success_sheet.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../domain/entities/saved_signature.dart';
import '../providers/signature_providers.dart';
import '../widgets/draw_signature_sheet.dart';

class SignatureScreen extends ConsumerStatefulWidget {
  const SignatureScreen({super.key});

  @override
  ConsumerState<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends ConsumerState<SignatureScreen> {
  String? _sourcePath;
  SavedSignature? _selected;
  SignaturePlacement _placement = const SignaturePlacement(pageNumber: 1);

  bool _isPlacing = false;
  Uint8List? _preview;
  bool _isPreviewLoading = false;

  @override
  Widget build(BuildContext context) {
    final path = _sourcePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
        actions: [
          if (path != null && !_isPlacing)
            TextButton(onPressed: _pickPdf, child: const Text('Change')),
        ],
      ),
      body: path == null ? _buildPicker() : _buildEditor(path),
    );
  }

  Widget _buildPicker() {
    return EmptyState(
      icon: Icons.draw_rounded,
      title: 'Choose a PDF to sign',
      message: 'Draw a signature or reuse a saved one, then place it on any page.',
      action: FilledButton.icon(
        onPressed: _pickPdf,
        icon: const Icon(Icons.folder_open_rounded),
        label: const Text('Select PDF'),
      ),
    );
  }

  Widget _buildEditor(String path) {
    final asyncPageCount = ref.watch(signaturePageCountProvider(path));

    return asyncPageCount.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: 'Could not read this PDF.',
        onRetry: () => ref.invalidate(signaturePageCountProvider(path)),
      ),
      data: (pageCount) => Column(
        children: [
          if (_isPlacing) const LinearProgressIndicator(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                _buildPreview(),
                const SizedBox(height: AppSpacing.xxl),
                _buildSignaturePicker(),
                const SizedBox(height: AppSpacing.xxl),
                if (_selected != null) ...[
                  Text('Placement', style: context.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  _buildPageSelector(pageCount),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSlider(
                    label: 'Horizontal',
                    value: _placement.centerX,
                    min: 0.1,
                    max: 0.9,
                    displayValue: '${(_placement.centerX * 100).round()}%',
                    onChanged: (v) => _updatePlacement(_placement.copyWith(centerX: v)),
                  ),
                  _buildSlider(
                    label: 'Vertical',
                    value: _placement.centerY,
                    min: 0.1,
                    max: 0.9,
                    displayValue: '${(_placement.centerY * 100).round()}%',
                    onChanged: (v) => _updatePlacement(_placement.copyWith(centerY: v)),
                  ),
                  _buildSlider(
                    label: 'Size',
                    value: _placement.widthFraction,
                    min: 0.1,
                    max: 0.8,
                    displayValue: '${(_placement.widthFraction * 100).round()}%',
                    onChanged: (v) => _updatePlacement(_placement.copyWith(widthFraction: v)),
                  ),
                  _buildSlider(
                    label: 'Rotation',
                    value: _placement.rotationDegrees,
                    min: -45,
                    max: 45,
                    displayValue: '${_placement.rotationDegrees.round()}°',
                    onChanged: (v) => _updatePlacement(_placement.copyWith(rotationDegrees: v)),
                  ),
                ],
              ],
            ),
          ),
          _buildBottomBar(path),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_selected == null) {
      return AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Center(
            child: Text(
              'Choose a signature to preview',
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_preview case final bytes?)
              Image.memory(bytes, fit: BoxFit.contain, width: double.infinity)
            else
              const SizedBox.shrink(),
            if (_isPreviewLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildSignaturePicker() {
    final signatures = ref.watch(savedSignaturesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Signature', style: context.textTheme.titleMedium)),
            TextButton.icon(
              onPressed: _isPlacing ? null : _importSignature,
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: const Text('Import'),
            ),
            TextButton.icon(
              onPressed: _isPlacing ? null : _drawSignature,
              icon: const Icon(Icons.draw_rounded, size: 18),
              label: const Text('Draw'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (signatures.isEmpty)
          AppCard(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: context.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'No saved signatures yet — draw or import one.',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: signatures.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final signature = signatures[index];
                final isSelected = _selected?.id == signature.id;
                return InkWell(
                  onTap: _isPlacing ? null : () => _selectSignature(signature),
                  onLongPress: () => _confirmDelete(signature),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: Container(
                    width: 132,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.outlineVariant,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Image.file(
                      File(signature.imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image_rounded),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPageSelector(int pageCount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Page ${_placement.pageNumber} of $pageCount',
            style: context.textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded),
          onPressed: _placement.pageNumber > 1
              ? () => _updatePlacement(
                    _placement.copyWith(pageNumber: _placement.pageNumber - 1),
                  )
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded),
          onPressed: _placement.pageNumber < pageCount
              ? () => _updatePlacement(
                    _placement.copyWith(pageNumber: _placement.pageNumber + 1),
                  )
              : null,
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: context.textTheme.labelLarge)),
            Text(
              displayValue,
              style: context.textTheme.labelMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: _isPlacing ? null : onChanged,
          onChangeEnd: (_) => _refreshPreview(),
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
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selected != null && !_isPlacing ? () => _place(path) : null,
            icon: const Icon(Icons.check_rounded),
            label: Text(_isPlacing ? 'Signing…' : 'Sign PDF'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final path = await PdfPicker.pickSingle();
    if (path == null) return;
    setState(() {
      _sourcePath = path;
      _placement = const SignaturePlacement(pageNumber: 1);
      _preview = null;
    });
    await _refreshPreview();
  }

  Future<void> _drawSignature() async {
    final bytes = await showAppBottomSheet<Uint8List>(
      context,
      builder: (sheetContext) => const DrawSignatureSheet(),
    );
    if (bytes == null || !mounted) return;

    final saved = await ref.read(savedSignaturesProvider.notifier).save(bytes);
    if (!mounted) return;
    if (saved == null) {
      context.showSnackBar('Could not save the signature', isError: true);
      return;
    }
    await _selectSignature(saved);
  }

  Future<void> _importSignature() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    final bytes = await File(picked.path).readAsBytes();
    final saved = await ref.read(savedSignaturesProvider.notifier).save(bytes);
    if (!mounted) return;
    if (saved == null) {
      context.showSnackBar('Could not import that image', isError: true);
      return;
    }
    await _selectSignature(saved);
  }

  Future<void> _confirmDelete(SavedSignature signature) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete signature?',
      message: 'This removes the saved signature from PDFverse.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    await ref.read(savedSignaturesProvider.notifier).delete(signature.id);
    if (_selected?.id == signature.id && mounted) {
      setState(() {
        _selected = null;
        _preview = null;
      });
    }
  }

  Future<void> _selectSignature(SavedSignature signature) async {
    setState(() => _selected = signature);
    await _refreshPreview();
  }

  void _updatePlacement(SignaturePlacement placement) {
    // Captured before the state swap — comparing after would always be equal.
    final pageChanged = placement.pageNumber != _placement.pageNumber;
    setState(() => _placement = placement);
    // A page change has no drag gesture to end, so refresh immediately;
    // slider drags refresh from onChangeEnd instead.
    if (pageChanged) unawaited(_refreshPreview());
  }

  Future<void> _refreshPreview() async {
    final path = _sourcePath;
    final signature = _selected;
    if (path == null || signature == null) return;

    setState(() => _isPreviewLoading = true);
    final result = await ref.read(renderSignaturePreviewUseCaseProvider).call(
          sourcePath: path,
          signatureImagePath: signature.imagePath,
          placement: _placement,
        );
    if (!mounted) return;

    setState(() => _isPreviewLoading = false);
    result.fold(
      (bytes) => setState(() => _preview = bytes),
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }

  Future<void> _place(String path) async {
    final signature = _selected;
    if (signature == null) return;

    setState(() => _isPlacing = true);
    final result = await ref.read(placeSignatureUseCaseProvider).call(
          sourcePath: path,
          signatureImagePath: signature.imagePath,
          placement: _placement,
        );

    if (!mounted) return;
    setState(() => _isPlacing = false);

    result.fold(
      (savedPath) {
        invalidateFilesProviders(ref);
        showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => ResultSuccessSheet(
            filePaths: [savedPath],
            title: 'PDF signed',
          ),
        );
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }
}
