import '../../../../core/error/result.dart';
import '../entities/compression_preset.dart';
import '../entities/compression_result.dart';
import '../repositories/compress_repository.dart';

class CompressPdf {
  const CompressPdf(this._repository);

  final CompressRepository _repository;

  Future<Result<CompressionResult>> call({
    required String sourcePath,
    required CompressionPreset preset,
    void Function(int done, int total)? onProgress,
  }) {
    return _repository.compress(
      sourcePath: sourcePath,
      preset: preset,
      onProgress: onProgress,
    );
  }
}
