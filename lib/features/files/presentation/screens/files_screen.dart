import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../domain/entities/pdf_file_entry.dart';
import '../providers/files_providers.dart';
import '../providers/files_ui_state.dart';
import '../widgets/pdf_file_grid_card.dart';
import '../widgets/pdf_file_list_tile.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  AppPermissionResult? _permissionResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermission());
  }

  Future<void> _ensurePermission() async {
    final result = await ref.read(permissionServiceProvider).requestManageExternalStorage();
    if (mounted) setState(() => _permissionResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(fileViewModeProvider);
    final sortOrder = ref.watch(fileSortOrderProvider);
    final filter = ref.watch(fileFilterProvider);
    final query = ref.watch(fileSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
            tooltip: viewMode == FileViewMode.list ? 'Grid view' : 'List view',
            icon: Icon(
              viewMode == FileViewMode.list ? Icons.grid_view_rounded : Icons.view_list_rounded,
            ),
            onPressed: () {
              ref.read(fileViewModeProvider.notifier).state =
                  viewMode == FileViewMode.list ? FileViewMode.grid : FileViewMode.list;
            },
          ),
          PopupMenuButton<FileSortOrder>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (order) => ref.read(fileSortOrderProvider.notifier).state = order,
            itemBuilder: (context) => [
              _sortMenuItem(FileSortOrder.name, 'Name', sortOrder),
              _sortMenuItem(FileSortOrder.date, 'Date', sortOrder),
              _sortMenuItem(FileSortOrder.size, 'Size', sortOrder),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              onChanged: (value) => ref.read(fileSearchQueryProvider.notifier).state = value,
              decoration: const InputDecoration(
                hintText: 'Search PDFs',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<FileFilter>(
                segments: const [
                  ButtonSegment(value: FileFilter.all, label: Text('All')),
                  ButtonSegment(value: FileFilter.recent, label: Text('Recent')),
                  ButtonSegment(value: FileFilter.favorites, label: Text('Favorites')),
                ],
                selected: {filter},
                onSelectionChanged: (selection) =>
                    ref.read(fileFilterProvider.notifier).state = selection.first,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: _buildBody(context, filter: filter, sortOrder: sortOrder, query: query)),
        ],
      ),
    );
  }

  PopupMenuItem<FileSortOrder> _sortMenuItem(
    FileSortOrder value,
    String label,
    FileSortOrder current,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (value == current)
            const Icon(Icons.check_rounded, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required FileFilter filter,
    required FileSortOrder sortOrder,
    required String query,
  }) {
    if (_permissionResult == AppPermissionResult.permanentlyDenied) {
      return EmptyState(
        icon: Icons.folder_off_rounded,
        title: 'Storage access needed',
        message: 'PDFverse needs storage access to find PDFs on your device.',
        action: FilledButton(
          onPressed: () => ref.read(permissionServiceProvider).openSettings(),
          child: const Text('Open Settings'),
        ),
      );
    }
    if (_permissionResult == AppPermissionResult.denied) {
      return EmptyState(
        icon: Icons.folder_off_rounded,
        title: 'Storage access needed',
        message: 'Grant storage access so PDFverse can list PDFs on your device.',
        action: FilledButton(onPressed: _ensurePermission, child: const Text('Grant Access')),
      );
    }

    final provider = switch (filter) {
      FileFilter.all => allPdfFilesProvider,
      FileFilter.recent => recentFilesProvider,
      FileFilter.favorites => favoriteFilesProvider,
    };
    final asyncFiles = ref.watch(provider);

    return asyncFiles.when(
      loading: () => const _LoadingSkeleton(),
      error: (error, stackTrace) => ErrorView(
        message: 'Could not load your PDFs.',
        onRetry: () => ref.invalidate(provider),
      ),
      data: (files) {
        var filtered = files;
        if (query.trim().isNotEmpty) {
          final lower = query.toLowerCase();
          filtered = filtered.where((f) => f.name.toLowerCase().contains(lower)).toList();
        }
        filtered = _sorted(filtered, sortOrder);

        if (filtered.isEmpty) {
          return EmptyState(
            icon: filter == FileFilter.favorites
                ? Icons.favorite_border_rounded
                : Icons.picture_as_pdf_outlined,
            title: query.isNotEmpty ? 'No matches' : 'No PDFs found',
            message: query.isNotEmpty
                ? 'Try a different search term.'
                : switch (filter) {
                    FileFilter.favorites => 'Mark PDFs as favorite to see them here.',
                    FileFilter.recent => 'Files you open will show up here.',
                    FileFilter.all => 'No PDF files were found on this device.',
                  },
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(allPdfFilesProvider),
          child: ref.watch(fileViewModeProvider) == FileViewMode.list
              ? ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => _buildListTile(context, filtered[index]),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => PdfFileGridCard(
                    entry: filtered[index],
                    onTap: () => _openFile(context, filtered[index]),
                    onFavoriteToggle: () => _toggleFavorite(filtered[index]),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context, PdfFileEntry entry) {
    return PdfFileListTile(
      entry: entry,
      onTap: () => _openFile(context, entry),
      onFavoriteToggle: () => _toggleFavorite(entry),
      onAction: (action) => _handleAction(context, entry, action),
    );
  }

  List<PdfFileEntry> _sorted(List<PdfFileEntry> files, FileSortOrder order) {
    final sorted = [...files];
    switch (order) {
      case FileSortOrder.name:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case FileSortOrder.date:
        sorted.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      case FileSortOrder.size:
        sorted.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    }
    return sorted;
  }

  void _openFile(BuildContext context, PdfFileEntry entry) {
    context.showComingSoon('The PDF Viewer');
  }

  Future<void> _toggleFavorite(PdfFileEntry entry) async {
    final result = await ref.read(toggleFavoriteUseCaseProvider).call(entry.path);
    result.fold((_) => invalidateFilesProviders(ref), (failure) {
      if (mounted) context.showSnackBar(failure.message, isError: true);
    });
  }

  Future<void> _handleAction(BuildContext context, PdfFileEntry entry, PdfFileAction action) async {
    switch (action) {
      case PdfFileAction.share:
        await Share.shareXFiles([XFile(entry.path)]);
      case PdfFileAction.rename:
        await _renameFile(context, entry);
      case PdfFileAction.delete:
        await _deleteFile(context, entry);
    }
  }

  Future<void> _renameFile(BuildContext context, PdfFileEntry entry) async {
    final controller = TextEditingController(
      text: entry.name.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), ''),
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename file'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(suffixText: '.pdf'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || !mounted) return;

    final result = await ref.read(renamePdfFileUseCaseProvider).call(entry.path, newName);
    result.fold((_) => invalidateFilesProviders(ref), (failure) {
      if (mounted) context.showSnackBar(failure.message, isError: true);
    });
  }

  Future<void> _deleteFile(BuildContext context, PdfFileEntry entry) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete "${entry.name}"?',
      message: 'This will permanently delete the file from your device.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    final result = await ref.read(deletePdfFileUseCaseProvider).call(entry.path);
    result.fold((_) => invalidateFilesProviders(ref), (failure) {
      if (mounted) context.showSnackBar(failure.message, isError: true);
    });
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => const SkeletonListTile(),
      ),
    );
  }
}
