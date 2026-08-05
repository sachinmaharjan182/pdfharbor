import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/result_success_sheet.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../domain/entities/watermark_config.dart';
import '../providers/watermark_providers.dart';

class WatermarkScreen extends ConsumerStatefulWidget {
  const WatermarkScreen({super.key});

  @override
  ConsumerState<WatermarkScreen> createState() => _WatermarkScreenState();
}

class _WatermarkScreenState extends ConsumerState<WatermarkScreen> {
  late final TextEditingController _textController;
  String? _sourcePath;
  bool _isApplying = false;

  static const List<int> _colorSwatches = [
    0xFF808080,
    0xFFE53935,
    0xFF1E88E5,
    0xFF43A047,
    0xFFFB8C00,
    0xFF000000,
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: ref.read(watermarkConfigProvider).text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _sourcePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watermark'),
        actions: [
          if (path != null && !_isApplying)
            TextButton(onPressed: _pickFile, child: const Text('Change')),
        ],
      ),
      body: path == null ? _buildPicker() : _buildEditor(path),
    );
  }

  Widget _buildPicker() {
    return EmptyState(
      icon: Icons.water_drop_rounded,
      title: 'Choose a PDF',
      message: 'Stamp text or an image across every page, with a live preview.',
      action: FilledButton.icon(
        onPressed: _pickFile,
        icon: const Icon(Icons.folder_open_rounded),
        label: const Text('Select PDF'),
      ),
    );
  }

  Widget _buildEditor(String path) {
    final config = ref.watch(watermarkConfigProvider);
    final notifier = ref.read(watermarkConfigProvider.notifier);

    return Column(
      children: [
        if (_isApplying) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _WatermarkPreview(sourcePath: path),
              const SizedBox(height: AppSpacing.xxl),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Text'), icon: Icon(Icons.title_rounded)),
                  ButtonSegment(
                    value: true,
                    label: Text('Image'),
                    icon: Icon(Icons.image_rounded),
                  ),
                ],
                selected: {config.isImageWatermark},
                onSelectionChanged: (selection) {
                  if (selection.first) {
                    _pickWatermarkImage();
                  } else {
                    notifier.setImagePath(null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              if (config.isImageWatermark)
                _buildImageRow(config)
              else ...[
                TextField(
                  controller: _textController,
                  enabled: !_isApplying,
                  decoration: const InputDecoration(
                    labelText: 'Watermark text',
                    prefixIcon: Icon(Icons.text_fields_rounded),
                  ),
                  onChanged: notifier.setText,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Color', style: context.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  children: [
                    for (final swatch in _colorSwatches)
                      _ColorDot(
                        colorValue: swatch,
                        isSelected: config.colorValue == swatch,
                        onTap: () => notifier.setColor(swatch),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              _buildSlider(
                label: 'Opacity',
                value: config.opacity,
                min: 0.05,
                max: 1,
                displayValue: '${(config.opacity * 100).round()}%',
                onChanged: notifier.setOpacity,
              ),
              _buildSlider(
                label: 'Rotation',
                value: config.rotationDegrees,
                min: -90,
                max: 90,
                displayValue: '${config.rotationDegrees.round()}°',
                onChanged: notifier.setRotation,
              ),
              _buildSlider(
                label: 'Size',
                value: config.scale,
                min: 0.3,
                max: 2.5,
                displayValue: '${(config.scale * 100).round()}%',
                onChanged: notifier.setScale,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Position', style: context.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final position in WatermarkPosition.values)
                    ChoiceChip(
                      label: Text(position.label),
                      selected: config.position == position,
                      onSelected: (_) => notifier.setPosition(position),
                    ),
                ],
              ),
            ],
          ),
        ),
        _buildBottomBar(path, config),
      ],
    );
  }

  Widget _buildImageRow(WatermarkConfig config) {
    return Row(
      children: [
        Icon(Icons.image_rounded, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            config.imagePath == null
                ? 'No image selected'
                : p.basename(config.imagePath!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium,
          ),
        ),
        TextButton(onPressed: _pickWatermarkImage, child: const Text('Choose')),
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
          onChanged: _isApplying ? null : onChanged,
        ),
      ],
    );
  }

  Widget _buildBottomBar(String path, WatermarkConfig config) {
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
            onPressed: config.isValid && !_isApplying ? () => _apply(path) : null,
            icon: const Icon(Icons.water_drop_rounded),
            label: Text(_isApplying ? 'Applying…' : 'Apply watermark'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final path = await PdfPicker.pickSingle();
    if (path == null) return;
    setState(() => _sourcePath = path);
  }

  Future<void> _pickWatermarkImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    ref.read(watermarkConfigProvider.notifier).setImagePath(picked.path);
  }

  Future<void> _apply(String path) async {
    setState(() => _isApplying = true);

    final result = await ref.read(applyWatermarkUseCaseProvider).call(
          sourcePath: path,
          config: ref.read(watermarkConfigProvider),
        );

    if (!mounted) return;
    setState(() => _isApplying = false);

    result.fold(
      (savedPath) {
        invalidateFilesProviders(ref);
        showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => ResultSuccessSheet(
            filePaths: [savedPath],
            title: 'Watermark applied',
          ),
        );
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.colorValue,
    required this.isSelected,
    required this.onTap,
  });

  final int colorValue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class _WatermarkPreview extends ConsumerWidget {
  const _WatermarkPreview({required this.sourcePath});

  final String sourcePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPreview = ref.watch(watermarkPreviewProvider(sourcePath));

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        clipBehavior: Clip.antiAlias,
        child: asyncPreview.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                error is EmptyWatermarkException
                    ? 'Enter watermark text to see a preview'
                    : 'Preview unavailable',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium
                    ?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          data: (bytes) => Image.memory(bytes, fit: BoxFit.contain, width: double.infinity),
        ),
      ),
    );
  }
}
