import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

/// Renders a PDF's first page as a thumbnail image. Used by Recent Files,
/// the File Manager, and later by Merge/Split page pickers — kept here
/// since `files` is the most foundational feature that owns the PDF-file
/// concept.
///
/// [width]/[height] are the *layout* size (null lets the parent decide, e.g.
/// via `Expanded`/`AspectRatio`); the bitmap itself is always rasterized at
/// a fixed resolution independent of layout size.
class PdfThumbnail extends StatefulWidget {
  const PdfThumbnail({
    required this.path,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String path;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<PdfThumbnail> createState() => _PdfThumbnailState();
}

class _PdfThumbnailState extends State<PdfThumbnail> {
  static final Map<String, Uint8List> _cache = {};
  static const double _renderLongSide = 320;

  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = _cache[widget.path];
    if (cached != null) {
      setState(() => _bytes = cached);
      return;
    }
    PdfDocument? document;
    try {
      document = await PdfDocument.openFile(widget.path);
      final page = await document.getPage(1);
      final aspect = page.width / page.height;
      final targetWidth = aspect >= 1 ? _renderLongSide : _renderLongSide * aspect;
      final targetHeight = aspect >= 1 ? _renderLongSide / aspect : _renderLongSide;
      final image = await page.render(
        width: targetWidth,
        height: targetHeight,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
      );
      await page.close();
      if (image == null) throw StateError('render returned null');
      _cache[widget.path] = image.bytes;
      if (mounted) setState(() => _bytes = image.bytes);
    } on Exception {
      if (mounted) setState(() => _failed = true);
    } finally {
      await document?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadius.small);

    Widget content;
    if (_failed) {
      content = ColoredBox(
        color: context.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.picture_as_pdf_rounded, color: context.colorScheme.onSurfaceVariant),
        ),
      );
    } else if (_bytes case final bytes?) {
      content = Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    } else {
      content = ShimmerLoading(
        child: ColoredBox(color: context.colorScheme.surfaceContainerHighest),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: widget.width, height: widget.height, child: content),
    );
  }
}
