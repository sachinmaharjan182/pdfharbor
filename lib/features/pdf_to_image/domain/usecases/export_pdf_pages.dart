import '../../../../core/error/result.dart';
import '../entities/export_options.dart';
import '../repositories/pdf_to_image_repository.dart';

class ExportPdfPages {
  const ExportPdfPages(this._repository);

  final PdfToImageRepository _repository;

  Future<Result<List<String>>> call({
    required String sourcePath,
    required List<int> pageNumbers,
    required ImageExportFormat format,
    required ImageExportQuality quality,
    void Function(int done, int total)? onProgress,
  }) {
    return _repository.exportPages(
      sourcePath: sourcePath,
      pageNumbers: pageNumbers,
      format: format,
      quality: quality,
      onProgress: onProgress,
    );
  }
}

class GetPdfToImagePageCount {
  const GetPdfToImagePageCount(this._repository);

  final PdfToImageRepository _repository;

  Future<Result<int>> call(String path) => _repository.pageCount(path);
}
