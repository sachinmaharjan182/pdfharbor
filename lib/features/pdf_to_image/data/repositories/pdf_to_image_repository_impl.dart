import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/repositories/pdf_to_image_repository.dart';

class PdfToImageRepositoryImpl implements PdfToImageRepository {
  const PdfToImageRepositoryImpl();

  @override
  Future<Result<int>> pageCount(String path) async {
    PdfDocument? document;
    try {
      if (!await File(path).exists()) return ResultFailure(FileNotFoundFailure(path));
      document = await PdfDocument.openFile(path);
      return Success(document.pagesCount);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure(e.toString()));
    } finally {
      await document?.close();
    }
  }

  @override
  Future<Result<List<String>>> exportPages({
    required String sourcePath,
    required List<int> pageNumbers,
    required ImageExportFormat format,
    required ImageExportQuality quality,
    void Function(int done, int total)? onProgress,
  }) async {
    if (pageNumbers.isEmpty) {
      return const ResultFailure(UnexpectedFailure('Select at least one page'));
    }

    PdfDocument? document;
    try {
      if (!await File(sourcePath).exists()) {
        return ResultFailure(FileNotFoundFailure(sourcePath));
      }

      document = await PdfDocument.openFile(sourcePath);
      final baseName = p.basenameWithoutExtension(sourcePath);
      final savedPaths = <String>[];
      final sorted = [...pageNumbers]..sort();

      for (var i = 0; i < sorted.length; i++) {
        final pageNumber = sorted[i];
        if (pageNumber < 1 || pageNumber > document.pagesCount) continue;

        // Android's renderer can't render pages in parallel, so pages are
        // opened, rendered, and closed strictly one at a time.
        final page = await document.getPage(pageNumber);
        try {
          final rendered = await page.render(
            width: page.width * quality.renderScale,
            height: page.height * quality.renderScale,
            format: format == ImageExportFormat.png
                ? PdfPageImageFormat.png
                : PdfPageImageFormat.jpeg,
            quality: quality.jpegQuality,
            backgroundColor: '#FFFFFF',
          );
          if (rendered != null) {
            final saved = await OutputFileService.save(
              rendered.bytes,
              '$baseName page $pageNumber.${format.extension}',
            );
            savedPaths.add(saved.path);
          }
        } finally {
          await page.close();
        }
        onProgress?.call(i + 1, sorted.length);
      }

      if (savedPaths.isEmpty) {
        return const ResultFailure(UnexpectedFailure('No pages could be exported'));
      }
      return Success(savedPaths);
    } on Exception catch (e) {
      return ResultFailure(InvalidPdfFailure('Could not export pages: $e'));
    } finally {
      await document?.close();
    }
  }
}
