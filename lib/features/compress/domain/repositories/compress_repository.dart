import '../../../../core/error/result.dart';
import '../entities/compression_preset.dart';
import '../entities/compression_result.dart';

abstract interface class CompressRepository {
  /// Rasterizes and re-encodes [sourcePath] at [preset]'s quality.
  ///
  /// [onProgress] reports completed pages out of the total so the UI can
  /// show real progress on long documents.
  Future<Result<CompressionResult>> compress({
    required String sourcePath,
    required CompressionPreset preset,
    void Function(int done, int total)? onProgress,
  });
}
