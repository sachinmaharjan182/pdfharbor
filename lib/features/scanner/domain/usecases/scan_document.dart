import '../../../../core/error/result.dart';
import '../../../image_to_pdf/domain/entities/image_filter_type.dart';
import '../repositories/scanner_repository.dart';

class ScanPages {
  const ScanPages(this._repository);

  final ScannerRepository _repository;

  Future<Result<List<String>>> call() => _repository.scanPages();
}

class SaveScanAsPdf {
  const SaveScanAsPdf(this._repository);

  final ScannerRepository _repository;

  Future<Result<String>> call({
    required List<String> imagePaths,
    required ImageFilterType filter,
    required Map<String, int> rotations,
    required String outputName,
    void Function(int done, int total)? onProgress,
  }) {
    return _repository.saveAsPdf(
      imagePaths: imagePaths,
      filter: filter,
      rotations: rotations,
      outputName: outputName,
      onProgress: onProgress,
    );
  }
}
