import '../../../../core/error/result.dart';
import '../entities/export_options.dart';

abstract interface class PdfToImageRepository {
  Future<Result<int>> pageCount(String path);

  /// Exports [pageNumbers] (1-based) as separate image files.
  /// Returns the saved paths in page order.
  Future<Result<List<String>>> exportPages({
    required String sourcePath,
    required List<int> pageNumbers,
    required ImageExportFormat format,
    required ImageExportQuality quality,
    void Function(int done, int total)? onProgress,
  });
}
