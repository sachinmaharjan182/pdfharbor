import 'dart:io';
import 'dart:ui';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/image/image_processor.dart';
import '../../../../core/pdf/pdf_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../../image_to_pdf/domain/entities/image_filter_type.dart';
import '../../domain/repositories/scanner_repository.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  const ScannerRepositoryImpl();

  @override
  Future<Result<List<String>>> scanPages() async {
    try {
      final pictures = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
      );
      // The plugin returns null when the user backs out of the scanner.
      return Success(pictures ?? const []);
    } on Exception catch (e) {
      // The plugin throws a plain Exception with this message when camera
      // permission is refused, rather than surfacing a typed error.
      if (e.toString().contains('Permission not granted')) {
        return const ResultFailure(PermissionDeniedFailure('Camera'));
      }
      return ResultFailure(UnexpectedFailure('Could not start the scanner: $e'));
    }
  }

  @override
  Future<Result<String>> saveAsPdf({
    required List<String> imagePaths,
    required ImageFilterType filter,
    required Map<String, int> rotations,
    required String outputName,
    void Function(int done, int total)? onProgress,
  }) async {
    if (imagePaths.isEmpty) {
      return const ResultFailure(UnexpectedFailure('Scan at least one page'));
    }

    try {
      final pages = <PdfImagePage>[];
      for (var i = 0; i < imagePaths.length; i++) {
        final path = imagePaths[i];
        final file = File(path);
        if (!await file.exists()) return ResultFailure(FileNotFoundFailure(path));

        final processed = await ImageProcessor.process(
          ImageProcessRequest(
            bytes: await file.readAsBytes(),
            filter: filter,
            rotationDegrees: rotations[path] ?? 0,
          ),
        );

        // Scanned pages keep their own aspect ratio — the native scanner
        // has already cropped to the document's edges, so forcing A4 here
        // would reintroduce borders it just removed.
        final size = await ImageProcessor.dimensions(processed);
        pages.add(
          PdfImagePage(
            bytes: processed,
            pageSize: size == null
                ? const Size(595, 842)
                : Size(size.width.toDouble(), size.height.toDouble()),
          ),
        );
        onProgress?.call(i + 1, imagePaths.length);
      }

      final bytes = await PdfEngine.buildFromImages(BuildFromImagesRequest(pages));
      final name = outputName.toLowerCase().endsWith('.pdf') ? outputName : '$outputName.pdf';
      final saved = await OutputFileService.save(bytes, name);
      return Success(saved.path);
    } on Exception catch (e) {
      return ResultFailure(UnexpectedFailure('Could not save the scan: $e'));
    }
  }
}
