import '../../../../core/error/result.dart';
import '../repositories/merge_repository.dart';

class MergePdfs {
  const MergePdfs(this._repository);

  final MergeRepository _repository;

  Future<Result<String>> call({
    required List<String> sourcePaths,
    required String outputName,
  }) {
    return _repository.mergePdfs(sourcePaths: sourcePaths, outputName: outputName);
  }
}
