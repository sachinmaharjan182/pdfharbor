import '../../../../core/error/result.dart';
import '../repositories/files_repository.dart';

class RenamePdfFile {
  const RenamePdfFile(this._repository);

  final FilesRepository _repository;

  Future<Result<void>> call(String path, String newName) {
    return _repository.renameFile(path, newName);
  }
}
