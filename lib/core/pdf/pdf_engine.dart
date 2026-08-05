import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Arguments for [PdfEngine.merge], shaped for `compute` (must be a single
/// value that can cross an isolate boundary).
class MergeRequest {
  const MergeRequest(this.documents);

  /// Raw bytes of each source PDF, in output order.
  final List<Uint8List> documents;
}

/// Arguments for [PdfEngine.extractPages].
class ExtractPagesRequest {
  const ExtractPagesRequest(this.source, this.pageIndices);

  final Uint8List source;

  /// Zero-based page indices to keep, in output order.
  final List<int> pageIndices;
}

/// Pure-Dart PDF operations built on Syncfusion, run off the UI thread.
///
/// Syncfusion has no page-import API in this version, so pages are copied
/// by rendering each source page as a [PdfTemplate] onto a destination page
/// sized to match the original — this preserves page dimensions and
/// orientation instead of forcing everything to A4.
abstract final class PdfEngine {
  static Future<Uint8List> merge(MergeRequest request) {
    return compute(_mergeIsolate, request);
  }

  static Future<Uint8List> extractPages(ExtractPagesRequest request) {
    return compute(_extractPagesIsolate, request);
  }

  /// Reads a document's page count without rendering anything.
  static Future<int> pageCount(Uint8List bytes) => compute(_pageCountIsolate, bytes);
}

Uint8List _mergeIsolate(MergeRequest request) {
  final output = PdfDocument();
  // Margins would otherwise inset every copied page.
  output.pageSettings.setMargins(0);

  final sources = <PdfDocument>[];
  try {
    for (final bytes in request.documents) {
      final source = PdfDocument(inputBytes: bytes);
      sources.add(source);
      for (var i = 0; i < source.pages.count; i++) {
        _copyPage(source.pages[i], output);
      }
    }
    return Uint8List.fromList(output.saveSync());
  } finally {
    for (final source in sources) {
      source.dispose();
    }
    output.dispose();
  }
}

Uint8List _extractPagesIsolate(ExtractPagesRequest request) {
  final source = PdfDocument(inputBytes: request.source);
  final output = PdfDocument();
  output.pageSettings.setMargins(0);

  try {
    for (final index in request.pageIndices) {
      if (index < 0 || index >= source.pages.count) continue;
      _copyPage(source.pages[index], output);
    }
    return Uint8List.fromList(output.saveSync());
  } finally {
    source.dispose();
    output.dispose();
  }
}

int _pageCountIsolate(Uint8List bytes) {
  final document = PdfDocument(inputBytes: bytes);
  try {
    return document.pages.count;
  } finally {
    document.dispose();
  }
}

/// Copies one page into [output], preserving its original size.
void _copyPage(PdfPage sourcePage, PdfDocument output) {
  final template = sourcePage.createTemplate();
  output.pageSettings.size = sourcePage.size;
  final page = output.pages.add();
  page.graphics.drawPdfTemplate(template, Offset.zero, sourcePage.size);
}
