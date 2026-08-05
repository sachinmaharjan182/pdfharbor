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

/// One image destined to become a PDF page.
class PdfImagePage {
  const PdfImagePage({
    required this.bytes,
    required this.pageSize,
    this.margin = 0,
  });

  /// Encoded image bytes (JPEG or PNG).
  final Uint8List bytes;

  /// Destination page size in PDF points.
  final Size pageSize;

  /// Uniform margin in points; the image is fitted inside what's left.
  final double margin;
}

/// Arguments for [PdfEngine.buildFromImages].
class BuildFromImagesRequest {
  const BuildFromImagesRequest(this.pages);

  final List<PdfImagePage> pages;
}

/// Arguments for [PdfEngine.setPassword].
class SetPasswordRequest {
  const SetPasswordRequest({
    required this.source,
    required this.newPassword,
    this.currentPassword,
  });

  final Uint8List source;

  /// Empty string removes protection.
  final String newPassword;

  /// Required when [source] is already encrypted.
  final String? currentPassword;
}

/// Raised by the password isolate when the supplied password is rejected,
/// so the caller can distinguish it from a corrupt file.
class WrongPasswordException implements Exception {
  const WrongPasswordException();
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

  /// Assembles a PDF whose pages are the supplied images. Backs both
  /// Image→PDF and compression (which rasterizes pages first).
  static Future<Uint8List> buildFromImages(BuildFromImagesRequest request) {
    return compute(_buildFromImagesIsolate, request);
  }

  /// Page dimensions in points for every page, used to size rasterized
  /// output so a compressed document keeps its original page geometry.
  static Future<List<Size>> pageSizes(Uint8List bytes) => compute(_pageSizesIsolate, bytes);

  /// Adds, changes, or (with an empty `newPassword`) removes encryption.
  /// Throws [WrongPasswordException] if `currentPassword` is rejected.
  static Future<Uint8List> setPassword(SetPasswordRequest request) {
    return compute(_setPasswordIsolate, request);
  }

  /// Whether the document requires a password to open.
  static Future<bool> isEncrypted(Uint8List bytes) => compute(_isEncryptedIsolate, bytes);
}

Uint8List _setPasswordIsolate(SetPasswordRequest request) {
  final PdfDocument document;
  try {
    document = PdfDocument(
      inputBytes: request.source,
      password: request.currentPassword,
    );
  } on Exception catch (e) {
    if (_isPasswordError(e)) throw const WrongPasswordException();
    rethrow;
  }

  try {
    final security = document.security;
    if (request.newPassword.isEmpty) {
      // Clearing both passwords drops encryption from the saved copy.
      security.userPassword = '';
      security.ownerPassword = '';
    } else {
      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;
      security.userPassword = request.newPassword;
      security.ownerPassword = request.newPassword;
    }
    return Uint8List.fromList(document.saveSync());
  } finally {
    document.dispose();
  }
}

bool _isEncryptedIsolate(Uint8List bytes) {
  PdfDocument? document;
  try {
    document = PdfDocument(inputBytes: bytes);
    return false;
  } on Exception catch (e) {
    if (_isPasswordError(e)) return true;
    rethrow;
  } finally {
    document?.dispose();
  }
}

/// Syncfusion reports a wrong/missing password by throwing with a message
/// mentioning it, rather than via a typed exception.
bool _isPasswordError(Exception e) => e.toString().toLowerCase().contains('password');

Uint8List _buildFromImagesIsolate(BuildFromImagesRequest request) {
  final document = PdfDocument();
  document.compressionLevel = PdfCompressionLevel.best;
  document.pageSettings.setMargins(0);

  try {
    for (final imagePage in request.pages) {
      document.pageSettings.size = imagePage.pageSize;
      final page = document.pages.add();
      final bitmap = PdfBitmap(imagePage.bytes);

      final available = Size(
        imagePage.pageSize.width - imagePage.margin * 2,
        imagePage.pageSize.height - imagePage.margin * 2,
      );
      if (available.width <= 0 || available.height <= 0) continue;

      // Contain-fit so images are never stretched or cropped.
      final scale = (available.width / bitmap.width) < (available.height / bitmap.height)
          ? available.width / bitmap.width
          : available.height / bitmap.height;
      final drawWidth = bitmap.width * scale;
      final drawHeight = bitmap.height * scale;
      final left = imagePage.margin + (available.width - drawWidth) / 2;
      final top = imagePage.margin + (available.height - drawHeight) / 2;

      page.graphics.drawImage(bitmap, Rect.fromLTWH(left, top, drawWidth, drawHeight));
    }
    return Uint8List.fromList(document.saveSync());
  } finally {
    document.dispose();
  }
}

List<Size> _pageSizesIsolate(Uint8List bytes) {
  final document = PdfDocument(inputBytes: bytes);
  try {
    return [for (var i = 0; i < document.pages.count; i++) document.pages[i].size];
  } finally {
    document.dispose();
  }
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
