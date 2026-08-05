import '../../../../core/error/result.dart';

abstract interface class MergeRepository {
  /// Merges [sourcePaths] in order into a new PDF named [outputName].
  /// Returns the saved file's path.
  Future<Result<String>> mergePdfs({
    required List<String> sourcePaths,
    required String outputName,
  });
}
