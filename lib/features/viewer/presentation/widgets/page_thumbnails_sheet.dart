import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

/// Grid of page thumbnails for jumping around a document.
///
/// Opens its own [PdfDocument] handle (independent of the Syncfusion
/// viewer's) and renders pages lazily, because Android's PDF renderer
/// cannot render pages in parallel — requests are queued one at a time.
class PageThumbnailsSheet extends StatefulWidget {
  const PageThumbnailsSheet({
    required this.path,
    required this.pageCount,
    required this.currentPage,
    required this.onPageSelected,
    super.key,
  });

  final String path;
  final int pageCount;
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  @override
  State<PageThumbnailsSheet> createState() => _PageThumbnailsSheetState();
}

class _PageThumbnailsSheetState extends State<PageThumbnailsSheet> {
  final Map<int, Uint8List> _thumbnails = {};
  final Set<int> _requested = {};

  PdfDocument? _document;
  Future<void> _renderQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _openDocument();
  }

  Future<void> _openDocument() async {
    try {
      final document = await PdfDocument.openFile(widget.path);
      if (!mounted) {
        await document.close();
        return;
      }
      setState(() => _document = document);
    } on Exception {
      // Leaving _document null renders placeholder tiles rather than
      // failing the whole sheet.
    }
  }

  /// Serializes renders through a single future chain — the Android
  /// renderer rejects concurrent page renders on one document.
  void _requestThumbnail(int pageNumber) {
    if (_requested.contains(pageNumber)) return;
    _requested.add(pageNumber);

    _renderQueue = _renderQueue.then((_) async {
      final document = _document;
      if (document == null || !mounted) return;
      try {
        final page = await document.getPage(pageNumber);
        final image = await page.render(
          width: 160,
          height: 160 * (page.height / page.width),
          format: PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
        );
        await page.close();
        if (image != null && mounted) {
          setState(() => _thumbnails[pageNumber] = image.bytes);
        }
      } on Exception {
        // Skip this page's thumbnail; the tile keeps its placeholder.
      }
    });
  }

  @override
  void dispose() {
    // Close only after any in-flight render settles, so we never close a
    // document mid-render.
    final document = _document;
    if (document != null) {
      _renderQueue.whenComplete(document.close);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.sm,
              AppSpacing.xxl,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Text('Pages', style: context.textTheme.titleLarge),
                const Spacer(),
                Text(
                  '${widget.pageCount} pages',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.62,
              ),
              itemCount: widget.pageCount,
              itemBuilder: (context, index) {
                final pageNumber = index + 1;
                _requestThumbnail(pageNumber);
                return _ThumbnailTile(
                  pageNumber: pageNumber,
                  bytes: _thumbnails[pageNumber],
                  isCurrent: pageNumber == widget.currentPage,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onPageSelected(pageNumber);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailTile extends StatelessWidget {
  const _ThumbnailTile({
    required this.pageNumber,
    required this.bytes,
    required this.isCurrent,
    required this.onTap,
  });

  final int pageNumber;
  final Uint8List? bytes;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: isCurrent ? scheme.primary : scheme.outlineVariant,
                  width: isCurrent ? 2.5 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: bytes == null
                  ? ShimmerLoading(child: ColoredBox(color: scheme.surfaceContainerHighest))
                  : Image.memory(bytes!, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$pageNumber',
            style: context.textTheme.labelSmall?.copyWith(
              color: isCurrent ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
