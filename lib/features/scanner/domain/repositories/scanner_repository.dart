import '../../../../core/error/result.dart';
import '../../../image_to_pdf/domain/entities/image_filter_type.dart';

abstract interface class ScannerRepository {
  /// Launches the platform document scanner (edge detection, perspective
  /// correction, and cropping happen natively). Returns the captured page
  /// image paths, or an empty list if the user cancelled.
  Future<Result<List<String>>> scanPages();

  /// Builds a PDF from scanned page images, applying [filter] and each
  /// page's rotation.
  Future<Result<String>> saveAsPdf({
    required List<String> imagePaths,
    required ImageFilterType filter,
    required Map<String, int> rotations,
    required String outputName,
    void Function(int done, int total)? onProgress,
  });
}
