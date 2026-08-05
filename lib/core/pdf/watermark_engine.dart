import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Isolate-safe description of a watermark run. Mirrors
/// `WatermarkConfig` but carries resolved bytes rather than a file path,
/// so the isolate never touches the filesystem.
class WatermarkRequest {
  const WatermarkRequest({
    required this.source,
    required this.opacity,
    required this.rotationDegrees,
    required this.scale,
    required this.tiled,
    required this.alignment,
    this.text,
    this.imageBytes,
    this.colorValue = 0xFF808080,
  });

  final Uint8List source;
  final String? text;
  final Uint8List? imageBytes;
  final double opacity;
  final double rotationDegrees;
  final double scale;
  final bool tiled;

  /// Fractional page position (0..1 on each axis) of the watermark's
  /// center. Ignored when [tiled].
  final Offset alignment;
  final int colorValue;
}

/// Stamps a watermark onto every page of a document.
abstract final class WatermarkEngine {
  static Future<Uint8List> apply(WatermarkRequest request) {
    return compute(_applyIsolate, request);
  }
}

Uint8List _applyIsolate(WatermarkRequest request) {
  final document = PdfDocument(inputBytes: request.source);

  try {
    for (var i = 0; i < document.pages.count; i++) {
      final page = document.pages[i];
      final graphics = page.graphics;
      final pageSize = page.size;

      // Saved/restored per page so transparency and rotation never leak
      // into the next page's content stream.
      final state = graphics.save();
      graphics.setTransparency(request.opacity);

      if (request.tiled) {
        _drawTiled(graphics, request, pageSize);
      } else {
        _drawSingle(
          graphics,
          request,
          pageSize,
          Offset(
            pageSize.width * request.alignment.dx,
            pageSize.height * request.alignment.dy,
          ),
        );
      }

      graphics.restore(state);
    }
    return Uint8List.fromList(document.saveSync());
  } finally {
    document.dispose();
  }
}

void _drawTiled(PdfGraphics graphics, WatermarkRequest request, Size pageSize) {
  final size = _watermarkSize(request, pageSize);
  // Spacing leaves a visible gap between stamps rather than a solid wash.
  final stepX = size.width * 1.6;
  final stepY = size.height * 2.4;
  if (stepX <= 0 || stepY <= 0) return;

  for (var y = stepY / 2; y < pageSize.height + stepY; y += stepY) {
    for (var x = stepX / 2; x < pageSize.width + stepX; x += stepX) {
      _drawSingle(graphics, request, pageSize, Offset(x, y));
    }
  }
}

/// Draws one watermark centered on [center], rotated about that point.
void _drawSingle(
  PdfGraphics graphics,
  WatermarkRequest request,
  Size pageSize,
  Offset center,
) {
  final state = graphics.save();

  // Rotation happens about the origin, so move the origin to the target
  // center first, then draw the mark centered on (0, 0).
  graphics
    ..translateTransform(center.dx, center.dy)
    ..rotateTransform(request.rotationDegrees);

  final size = _watermarkSize(request, pageSize);
  final imageBytes = request.imageBytes;

  if (imageBytes != null) {
    graphics.drawImage(
      PdfBitmap(imageBytes),
      Rect.fromLTWH(-size.width / 2, -size.height / 2, size.width, size.height),
    );
  } else {
    final text = request.text ?? '';
    if (text.isNotEmpty) {
      final font = PdfStandardFont(PdfFontFamily.helvetica, _fontSize(request, pageSize));
      final measured = font.measureString(text);
      final color = Color(request.colorValue);
      graphics.drawString(
        text,
        font,
        brush: PdfSolidBrush(
          PdfColor((color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round()),
        ),
        bounds: Rect.fromLTWH(
          -measured.width / 2,
          -measured.height / 2,
          measured.width,
          measured.height,
        ),
      );
    }
  }

  graphics.restore(state);
}

double _fontSize(WatermarkRequest request, Size pageSize) {
  final shortestEdge = pageSize.shortestSide;
  return (shortestEdge * 0.12 * request.scale).clamp(6.0, 400.0);
}

Size _watermarkSize(WatermarkRequest request, Size pageSize) {
  if (request.imageBytes != null) {
    final bitmap = PdfBitmap(request.imageBytes!);
    final target = pageSize.shortestSide * 0.5 * request.scale;
    if (bitmap.width <= 0 || bitmap.height <= 0) return Size(target, target);
    final aspect = bitmap.width / bitmap.height;
    return aspect >= 1 ? Size(target, target / aspect) : Size(target * aspect, target);
  }

  final font = PdfStandardFont(PdfFontFamily.helvetica, _fontSize(request, pageSize));
  final measured = font.measureString(request.text ?? '');
  return Size(measured.width, measured.height);
}
