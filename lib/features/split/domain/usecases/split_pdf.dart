import '../../../../core/error/result.dart';
import '../repositories/split_repository.dart';

class SplitPdf {
  const SplitPdf(this._repository);

  final SplitRepository _repository;

  Future<Result<List<String>>> call({
    required String sourcePath,
    required List<List<int>> pageGroups,
    required String outputBaseName,
  }) {
    return _repository.splitIntoFiles(
      sourcePath: sourcePath,
      pageGroups: pageGroups,
      outputBaseName: outputBaseName,
    );
  }
}

class GetPdfPageCount {
  const GetPdfPageCount(this._repository);

  final SplitRepository _repository;

  Future<Result<int>> call(String path) => _repository.pageCount(path);
}
