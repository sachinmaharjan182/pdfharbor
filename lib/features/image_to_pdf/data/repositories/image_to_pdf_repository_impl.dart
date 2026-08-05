import 'dart:io';
import 'dart:ui';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/image/image_processor.dart';
import '../../../../core/pdf/pdf_engine.dart';
import '../../../../core/utils/output_file_service.dart';
import '../../domain/entities/image_page_item.dart';
import '../../domain/entities/page_layout.dart';
import '../../domain/repositories/image_to_pdf_repository.dart';

class ImageToPdfRepositoryImpl implements ImageToPdfRepository {
  const ImageToPdfRepositoryImpl();

  @override
  Future<Result<String>> buildPdf({
    required List<ImagePageItem> items,
    required PdfPageSizeOption pageSize,
    required PageOrientation orientation,
    required PageMargin margin,
    required String outputName,
    void Function(int done, int total)? onProgress,
  }) async {
    if (items.isEmpty) {
      return const ResultFailure(UnexpectedFailure('Add at least one image'));
    }

    try {
      final pages = <PdfImagePage>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final file = File(item.path);
        if (!await file.exists()) return ResultFailure(FileNotFoundFailure(item.path));

        final processed = await ImageProcessor.process(
          ImageProcessRequest(
            bytes: await file.readAsBytes(),
            filter: item.filter,
            rotationDegrees: item.normalizedRotation,
          ),
        );

        // Measured after processing so rotation is reflected in the
        // "fit to image" page shape.
        final size = await ImageProcessor.dimensions(processed);
        pages.add(
          PdfImagePage(
            bytes: processed,
            pageSize: resolvePageSize(
              sizeOption: pageSize,
              orientation: orientation,
              imagePixelSize: size == null
                  ? Size.zero
                  : Size(size.width.toDouble(), size.height.toDouble()),
            ),
            margin: margin.points,
          ),
        );
        onProgress?.call(i + 1, items.length);
      }

      final bytes = await PdfEngine.buildFromImages(BuildFromImagesRequest(pages));
      final name = outputName.toLowerCase().endsWith('.pdf') ? outputName : '$outputName.pdf';
      final saved = await OutputFileService.save(bytes, name);
      return Success(saved.path);
    } on Exception catch (e) {
      return ResultFailure(UnexpectedFailure('Could not create the PDF: $e'));
    }
  }
}
