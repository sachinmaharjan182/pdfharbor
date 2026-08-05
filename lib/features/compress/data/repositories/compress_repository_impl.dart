import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/pdf/pdf_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/entities/compression_preset.dart';
import '../../domain/entities/compression_result.dart';
import '../../domain/repositories/compress_repository.dart';

class CompressRepositoryImpl implements CompressRepository {
  const CompressRepositoryImpl();

  @override
  Future<Result<CompressionResult>> compress({
    required String sourcePath,
    required CompressionPreset preset,
    void Function(int done, int total)? onProgress,
  }) async {
    PdfDocument? document;
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return ResultFailure(FileNotFoundFailure(sourcePath));

      final originalBytes = await file.length();
      final sourceBytes = await file.readAsBytes();

      // Page geometry comes from Syncfusion so output pages keep the
      // original point dimensions, independent of raster pixel size.
      final pageSizes = await PdfEngine.pageSizes(sourceBytes);

      // pdfx renders through a platform channel, so this must stay on the
      // main isolate; only the PDF assembly is offloaded.
      document = await PdfDocument.openFile(sourcePath);
      final total = document.pagesCount;
      final imagePages = <PdfImagePage>[];

      for (var pageNumber = 1; pageNumber <= total; pageNumber++) {
        final page = await document.getPage(pageNumber);
        try {
          final rendered = await page.render(
            width: page.width * preset.renderScale,
            height: page.height * preset.renderScale,
            format: PdfPageImageFormat.jpeg,
            quality: preset.jpegQuality,
            backgroundColor: '#FFFFFF',
          );
          if (rendered != null) {
            imagePages.add(
              PdfImagePage(
                bytes: rendered.bytes,
                pageSize: pageSizes.elementAtOrNull(pageNumber - 1) ??
                    Size(page.width, page.height),
              ),
            );
          }
        } finally {
          await page.close();
        }
        onProgress?.call(pageNumber, total);
      }

      if (imagePages.isEmpty) {
        return const ResultFailure(InvalidPdfFailure('This PDF has no renderable pages'));
      }

      final compressed = await PdfEngine.buildFromImages(BuildFromImagesRequest(imagePages));
      final outputName = '${p.basenameWithoutExtension(sourcePath)} compressed.pdf';
      final saved = await OutputFileService.save(compressed, outputName);

      return Success(
        CompressionResult(
          outputPath: saved.path,
          originalBytes: originalBytes,
          compressedBytes: compressed.lengthInBytes,
        ),
      );
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not compress this PDF: $e'));
    } finally {
      await document?.close();
    }
  }
}
