import '../../../../core/error/result.dart';
import '../entities/image_page_item.dart';
import '../entities/page_layout.dart';
import '../repositories/image_to_pdf_repository.dart';

class BuildPdfFromImages {
  const BuildPdfFromImages(this._repository);

  final ImageToPdfRepository _repository;

  Future<Result<String>> call({
    required List<ImagePageItem> items,
    required PdfPageSizeOption pageSize,
    required PageOrientation orientation,
    required PageMargin margin,
    required String outputName,
    void Function(int done, int total)? onProgress,
  }) {
    return _repository.buildPdf(
      items: items,
      pageSize: pageSize,
      orientation: orientation,
      margin: margin,
      outputName: outputName,
      onProgress: onProgress,
    );
  }
}
