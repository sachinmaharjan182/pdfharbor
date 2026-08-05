import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart' as pdfx;

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/pdf/watermark_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/entities/watermark_config.dart';
import '../../domain/repositories/watermark_repository.dart';

class WatermarkRepositoryImpl implements WatermarkRepository {
  const WatermarkRepositoryImpl();

  @override
  Future<Result<String>> applyWatermark({
    required String sourcePath,
    required WatermarkConfig config,
  }) async {
    try {
      final request = await _buildRequest(sourcePath, config);
      if (request == null) return ResultFailure(FileNotFoundFailure(sourcePath));

      final bytes = await WatermarkEngine.apply(request);
      final name = '${p.basenameWithoutExtension(sourcePath)} watermarked.pdf';
      final saved = await OutputFileService.save(bytes, name);
      return Success(saved.path);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not apply the watermark: $e'));
    }
  }

  @override
  Future<Result<Uint8List>> renderPreview({
    required String sourcePath,
    required WatermarkConfig config,
  }) async {
    pdfx.PdfDocument? document;
    try {
      final request = await _buildRequest(sourcePath, config);
      if (request == null) return ResultFailure(FileNotFoundFailure(sourcePath));

      final watermarked = await WatermarkEngine.apply(request);

      // Rendering from memory avoids writing a temp file for every slider
      // tick while the user is tuning the watermark.
      document = await pdfx.PdfDocument.openData(watermarked);
      final page = await document.getPage(1);
      try {
        final image = await page.render(
          width: 700,
          height: 700 * (page.height / page.width),
          format: pdfx.PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
        );
        if (image == null) {
          return const ResultFailure(UnexpectedFailure('Could not render a preview'));
        }
        return Success(image.bytes);
      } finally {
        await page.close();
      }
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not render a preview: $e'));
    } finally {
      await document?.close();
    }
  }

  Future<WatermarkRequest?> _buildRequest(String sourcePath, WatermarkConfig config) async {
    final file = File(sourcePath);
    if (!await file.exists()) return null;

    Uint8List? imageBytes;
    if (config.imagePath case final imagePath?) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) imageBytes = await imageFile.readAsBytes();
    }

    return WatermarkRequest(
      source: await file.readAsBytes(),
      text: config.text,
      imageBytes: imageBytes,
      opacity: config.opacity,
      rotationDegrees: config.rotationDegrees,
      scale: config.scale,
      tiled: config.position == WatermarkPosition.tiled,
      alignment: _alignmentFor(config.position),
      colorValue: config.colorValue,
    );
  }

  /// Fractional page position of the watermark's center. Corners are
  /// inset so the mark isn't clipped by the page edge.
  static Offset _alignmentFor(WatermarkPosition position) => switch (position) {
        WatermarkPosition.center || WatermarkPosition.tiled => const Offset(0.5, 0.5),
        WatermarkPosition.topLeft => const Offset(0.25, 0.18),
        WatermarkPosition.topRight => const Offset(0.75, 0.18),
        WatermarkPosition.bottomLeft => const Offset(0.25, 0.82),
        WatermarkPosition.bottomRight => const Offset(0.75, 0.82),
      };
}
