import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../files/presentation/widgets/pdf_thumbnail.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/pdf_bookmark.dart';
import '../providers/viewer_providers.dart';
import '../widgets/bookmarks_sheet.dart';
import '../widgets/page_thumbnails_sheet.dart';
import '../widgets/pdf_info_sheet.dart';

class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({required this.path, super.key});

  final String path;

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();
  final TextEditingController _searchController = TextEditingController();

  PdfTextSearchResult? _searchResult;
  bool _isSearching = false;
  bool _isHorizontal = false;
  bool _documentLoaded = false;
  int _pageCount = 0;
  String? _password;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    // Reflect the user's saved default scroll direction.
    final defaultView = ref.read(settingsProvider).defaultPageView;
    _isHorizontal = defaultView == DefaultPageView.horizontal;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchResult?.removeListener(_onSearchResultChanged);
    _controller.dispose();
    super.dispose();
  }

  String get _fileName => p.basename(widget.path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildDefaultAppBar(),
      body: _loadError != null ? _buildErrorBody() : _buildBody(),
      bottomNavigationBar: _documentLoaded && !_isSearching ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildViewer(),
        // Gives the incoming Hero somewhere to land: the file's thumbnail
        // fills the screen while the real viewer parses the document, then
        // fades out. Without it the flight would end on empty space.
        if (!_documentLoaded)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: context.colorScheme.surface,
                child: Center(
                  child: PdfThumbnail(
                    path: widget.path,
                    heroTag: 'file-${widget.path}',
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      title: Text(_fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded),
          onPressed: _documentLoaded ? () => setState(() => _isSearching = true) : null,
        ),
        IconButton(
          tooltip: 'Bookmark this page',
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: _documentLoaded ? _addBookmarkForCurrentPage : null,
        ),
        PopupMenuButton<_ViewerMenuAction>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            _menuItem(_ViewerMenuAction.bookmarks, Icons.bookmarks_rounded, 'Bookmarks'),
            _menuItem(_ViewerMenuAction.thumbnails, Icons.grid_view_rounded, 'Page thumbnails'),
            _menuItem(_ViewerMenuAction.jumpToPage, Icons.numbers_rounded, 'Jump to page'),
            PopupMenuItem(
              value: _ViewerMenuAction.toggleScrollDirection,
              child: ListTile(
                leading: Icon(_isHorizontal ? Icons.swap_vert_rounded : Icons.swap_horiz_rounded),
                title: Text(_isHorizontal ? 'Continuous scroll' : 'Horizontal pages'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            _menuItem(_ViewerMenuAction.share, Icons.share_rounded, 'Share'),
            _menuItem(_ViewerMenuAction.print, Icons.print_rounded, 'Print'),
            _menuItem(_ViewerMenuAction.info, Icons.info_outline_rounded, 'PDF information'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<_ViewerMenuAction> _menuItem(
    _ViewerMenuAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    final result = _searchResult;
    final hasMatches = result != null && result.hasResult;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: _exitSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Search in document',
          border: InputBorder.none,
          filled: false,
        ),
        onSubmitted: _performSearch,
      ),
      actions: [
        if (hasMatches)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '${result.currentInstanceIndex}/${result.totalInstanceCount}',
                style: context.textTheme.labelLarge,
              ),
            ),
          ),
        IconButton(
          tooltip: 'Previous match',
          icon: const Icon(Icons.keyboard_arrow_up_rounded),
          onPressed: hasMatches ? result.previousInstance : null,
        ),
        IconButton(
          tooltip: 'Next match',
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: hasMatches ? result.nextInstance : null,
        ),
      ],
    );
  }

  Widget _buildViewer() {
    return SfPdfViewer.file(
      File(widget.path),
      // Keying on the password forces a fresh viewer once the user supplies
      // one; without this the failed load would never be retried.
      key: ValueKey('pdf-viewer-${widget.path}-${_password ?? ''}'),
      controller: _controller,
      password: _password,
      canShowPasswordDialog: false,
      scrollDirection: _isHorizontal ? PdfScrollDirection.horizontal : PdfScrollDirection.vertical,
      pageLayoutMode: _isHorizontal ? PdfPageLayoutMode.single : PdfPageLayoutMode.continuous,
      onPageChanged: (details) => setState(() {}),
      onDocumentLoaded: (details) {
        setState(() {
          _documentLoaded = true;
          _pageCount = details.document.pages.count;
          _loadError = null;
        });
        // Recording the open here (rather than on navigation) means the
        // Recent Files list only contains documents that actually opened.
        ref.read(recordOpenedUseCaseProvider).call(widget.path).then((_) {
          if (mounted) invalidateFilesProviders(ref);
        });
      },
      onDocumentLoadFailed: (details) {
        final needsPassword = details.description.toLowerCase().contains('password');
        if (needsPassword) {
          _promptForPassword();
        } else {
          setState(() => _loadError = details.description);
        }
      },
    );
  }

  Widget _buildErrorBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, size: 56, color: context.colorScheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Could not open this PDF',
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _loadError ?? '',
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: _controller.previousPage,
          ),
          TextButton(
            onPressed: _showJumpToPageDialog,
            child: Text('${_controller.pageNumber} / $_pageCount'),
          ),
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _controller.nextPage,
          ),
          IconButton(
            tooltip: 'Zoom out',
            icon: const Icon(Icons.zoom_out_rounded),
            onPressed: () => _changeZoom(-0.25),
          ),
          IconButton(
            tooltip: 'Zoom in',
            icon: const Icon(Icons.zoom_in_rounded),
            onPressed: () => _changeZoom(0.25),
          ),
        ],
      ),
    );
  }

  void _changeZoom(double delta) {
    // maxZoomLevel defaults to 3; clamp so the control can't drive the
    // viewer outside its supported range.
    _controller.zoomLevel = (_controller.zoomLevel + delta).clamp(1.0, 3.0);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    _searchResult?.removeListener(_onSearchResultChanged);
    final result = _controller.searchText(query);
    result.addListener(_onSearchResultChanged);
    setState(() => _searchResult = result);
  }

  void _onSearchResultChanged() {
    if (mounted) setState(() {});
  }

  void _exitSearch() {
    _searchResult?.removeListener(_onSearchResultChanged);
    _searchResult?.clear();
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResult = null;
    });
  }

  Future<void> _handleMenuAction(_ViewerMenuAction action) async {
    switch (action) {
      case _ViewerMenuAction.bookmarks:
        await showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => BookmarksSheet(
            documentPath: widget.path,
            onJumpToPage: _controller.jumpToPage,
          ),
        );
      case _ViewerMenuAction.thumbnails:
        await showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => PageThumbnailsSheet(
            path: widget.path,
            pageCount: _pageCount,
            currentPage: _controller.pageNumber,
            onPageSelected: _controller.jumpToPage,
          ),
        );
      case _ViewerMenuAction.jumpToPage:
        await _showJumpToPageDialog();
      case _ViewerMenuAction.toggleScrollDirection:
        setState(() => _isHorizontal = !_isHorizontal);
      case _ViewerMenuAction.share:
        await Share.shareXFiles([XFile(widget.path)]);
      case _ViewerMenuAction.print:
        await _printDocument();
      case _ViewerMenuAction.info:
        await showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => PdfInfoSheet(path: widget.path),
        );
    }
  }

  Future<void> _printDocument() async {
    try {
      final bytes = await File(widget.path).readAsBytes();
      await Printing.layoutPdf(onLayout: (format) async => bytes, name: _fileName);
    } on Exception catch (e) {
      if (mounted) context.showSnackBar('Could not print: $e', isError: true);
    }
  }

  Future<void> _showJumpToPageDialog() async {
    final controller = TextEditingController();
    final page = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Jump to page'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '1 - $_pageCount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.of(dialogContext).pop(value);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );

    if (page == null || !mounted) return;
    if (page < 1 || page > _pageCount) {
      context.showSnackBar('Enter a page between 1 and $_pageCount', isError: true);
      return;
    }
    _controller.jumpToPage(page);
  }

  Future<void> _addBookmarkForCurrentPage() async {
    final pageNumber = _controller.pageNumber;
    final controller = TextEditingController(text: 'Page $pageNumber');
    final label = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add bookmark'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (label == null || label.isEmpty || !mounted) return;

    await ref.read(bookmarksProvider(widget.path).notifier).add(
          PdfBookmarkEntry(
            id: const Uuid().v4(),
            documentPath: widget.path,
            pageNumber: pageNumber,
            label: label,
            createdAt: DateTime.now(),
          ),
        );
    if (mounted) context.showSnackBar('Bookmark added');
  }

  Future<void> _promptForPassword() async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Password required'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Open'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (password == null || password.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    // Rebuilding with a new password re-instantiates the viewer via the key.
    setState(() => _password = password);
  }
}

enum _ViewerMenuAction {
  bookmarks,
  thumbnails,
  jumpToPage,
  toggleScrollDirection,
  share,
  print,
  info,
}
