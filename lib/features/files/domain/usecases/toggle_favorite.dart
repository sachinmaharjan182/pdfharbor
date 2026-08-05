import '../../../../core/error/result.dart';
import '../repositories/files_repository.dart';

class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FilesRepository _repository;

  Future<Result<void>> call(String path) => _repository.toggleFavorite(path);
}
