import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Isolate-safe description of stamping one signature image onto a page.
class StampSignatureRequest {
  const StampSignatureRequest({
    required this.source,
    required this.signaturePng,
    required this.pageNumber,
    required this.centerX,
    required this.centerY,
    required this.widthFraction,
    required this.rotationDegrees,
  });

  final Uint8List source;
  final Uint8List signaturePng;

  /// 1-based page to stamp.
  final int pageNumber;

  /// Center position as a fraction of page width/height (0..1).
  final double centerX;
  final double centerY;

  /// Signature width as a fraction of the page width.
  final double widthFraction;

  final double rotationDegrees;
}

abstract final class SignatureEngine {
  static Future<Uint8List> stamp(StampSignatureRequest request) {
    return compute(_stampIsolate, request);
  }
}

Uint8List _stampIsolate(StampSignatureRequest request) {
  final document = PdfDocument(inputBytes: request.source);

  try {
    final index = request.pageNumber - 1;
    if (index < 0 || index >= document.pages.count) {
      throw RangeError('Page ${request.pageNumber} is outside this document');
    }

    final page = document.pages[index];
    final pageSize = page.size;
    final bitmap = PdfBitmap(request.signaturePng);

    final drawWidth = pageSize.width * request.widthFraction;
    final aspect = bitmap.height / bitmap.width;
    final drawHeight = drawWidth * aspect;

    final graphics = page.graphics;
    final state = graphics.save();

    // Rotate about the signature's own center rather than the page origin.
    graphics
      ..translateTransform(pageSize.width * request.centerX, pageSize.height * request.centerY)
      ..rotateTransform(request.rotationDegrees)
      ..drawImage(
        bitmap,
        Rect.fromLTWH(-drawWidth / 2, -drawHeight / 2, drawWidth, drawHeight),
      )
      ..restore(state);

    return Uint8List.fromList(document.saveSync());
  } finally {
    document.dispose();
  }
}
