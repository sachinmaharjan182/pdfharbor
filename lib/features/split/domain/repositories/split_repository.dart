import '../../../../core/error/result.dart';

abstract interface class SplitRepository {
  /// Reads how many pages [path] contains.
  Future<Result<int>> pageCount(String path);

  /// Writes one output PDF per entry in [pageGroups] (each a list of
  /// zero-based page indices). Returns the saved file paths in order.
  Future<Result<List<String>>> splitIntoFiles({
    required String sourcePath,
    required List<List<int>> pageGroups,
    required String outputBaseName,
  });
}
