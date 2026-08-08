import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/result_success_sheet.dart';
import '../../../../shared/widgets/selection_mark.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../files/presentation/widgets/pdf_thumbnail.dart';
import '../../domain/entities/split_mode.dart';
import '../../domain/usecases/build_page_groups.dart';
import '../providers/split_providers.dart';

class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen({super.key});

  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  final TextEditingController _customController = TextEditingController();

  String? _sourcePath;
  SplitMode _mode = SplitMode.everyPage;
  int _rangeStart = 1;
  int _rangeEnd = 1;
  bool _isSplitting = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _sourcePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
        actions: [
          if (path != null)
            TextButton(
              onPressed: _isSplitting ? null : _pickFile,
              child: const Text('Change'),
            ),
        ],
      ),
      body: path == null ? _buildPicker() : _buildEditor(path),
    );
  }

  Widget _buildPicker() {
    return EmptyState(
      icon: Icons.call_split_rounded,
      title: 'Choose a PDF to split',
      message: 'Split by page range, every page, odd or even pages, or a custom selection.',
      action: FilledButton.icon(
        onPressed: _pickFile,
        icon: const Icon(Icons.folder_open_rounded),
        label: const Text('Select PDF'),
      ),
    );
  }

  Widget _buildEditor(String path) {
    final asyncPageCount = ref.watch(pdfPageCountProvider(path));

    return asyncPageCount.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: 'Could not read this PDF.',
        onRetry: () => ref.invalidate(pdfPageCountProvider(path)),
      ),
      data: (pageCount) {
        final groups = buildPageGroups(
          mode: _mode,
          pageCount: pageCount,
          rangeStart: _rangeStart,
          rangeEnd: _rangeEnd,
          customSelection: _customController.text,
        );
        final isValid = groups != null;

        return Column(
          children: [
            if (_isSplitting) const LinearProgressIndicator(),
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
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Split by', style: context.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  ...SplitMode.values.map((mode) => _buildModeTile(mode, pageCount)),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPreview(groups, pageCount),
                ],
              ),
            ),
            _buildBottomBar(isValid: isValid, groups: groups, path: path),
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
                  '$pageCount pages',
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

  Widget _buildModeTile(SplitMode mode, int pageCount) {
    final scheme = context.colorScheme;
    final isSelected = _mode == mode;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        color: isSelected ? scheme.secondaryContainer : scheme.surfaceContainerHigh,
        borderColor: isSelected ? scheme.primary : null,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        padding: EdgeInsets.zero,
        onTap: _isSplitting ? null : () => setState(() => _mode = mode),
        child: Column(
          children: [
            ListTile(
              title: Text(mode.label),
              subtitle: Text(mode.description),
              trailing: SelectionMark(isSelected: isSelected),
            ),
            if (isSelected && mode == SplitMode.pageRange)
              _buildRangeInputs(pageCount)
            else if (isSelected && mode == SplitMode.customPages)
              _buildCustomInput(pageCount),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeInputs(int pageCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _NumberField(
              label: 'From',
              value: _rangeStart,
              min: 1,
              max: pageCount,
              onChanged: (value) => setState(() => _rangeStart = value),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _NumberField(
              label: 'To',
              value: _rangeEnd,
              min: 1,
              max: pageCount,
              onChanged: (value) => setState(() => _rangeEnd = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInput(int pageCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: TextField(
        controller: _customController,
        onChanged: (_) => setState(() {}),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'Pages',
          hintText: 'e.g. 1,3,5-8',
          helperText: 'Between 1 and $pageCount',
        ),
      ),
    );
  }

  Widget _buildPreview(List<List<int>>? groups, int pageCount) {
    if (groups == null) {
      return Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: context.colorScheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _mode == SplitMode.customPages
                  ? 'Enter valid pages between 1 and $pageCount'
                  : 'Enter a valid range between 1 and $pageCount',
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error),
            ),
          ),
        ],
      );
    }

    final totalPages = groups.fold<int>(0, (sum, group) => sum + group.length);
    final fileCount = groups.length;

    return AppCard(
      color: context.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.preview_rounded, color: context.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Result preview', style: context.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  fileCount == 1
                      ? '1 PDF with $totalPages ${totalPages == 1 ? 'page' : 'pages'}'
                      : '$fileCount PDFs, 1 page each',
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

  Widget _buildBottomBar({
    required bool isValid,
    required List<List<int>>? groups,
    required String path,
  }) {
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
            onPressed: isValid && !_isSplitting ? () => _split(path, groups!) : null,
            icon: const Icon(Icons.call_split_rounded),
            label: Text(_isSplitting ? 'Splitting…' : 'Split PDF'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final path = await PdfPicker.pickSingle();
    if (path == null) return;
    setState(() {
      _sourcePath = path;
      _mode = SplitMode.everyPage;
      _rangeStart = 1;
      _rangeEnd = 1;
      _customController.clear();
    });
  }

  Future<void> _split(String path, List<List<int>> groups) async {
    setState(() => _isSplitting = true);

    final baseName = p.basenameWithoutExtension(path);
    final result = await ref.read(splitPdfUseCaseProvider).call(
          sourcePath: path,
          pageGroups: groups,
          outputBaseName: groups.length > 1 ? '$baseName page' : '$baseName split',
        );

    if (!mounted) return;
    setState(() => _isSplitting = false);

    result.fold(
      (paths) {
        invalidateFilesProviders(ref);
        showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => ResultSuccessSheet(
            filePaths: paths,
            title: paths.length == 1 ? 'PDF split' : '${paths.length} PDFs created',
          ),
        );
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }
}

/// Small stepper-style numeric field used for the page-range bounds.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall
                    ?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
              Text('$value', style: context.textTheme.titleMedium),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
