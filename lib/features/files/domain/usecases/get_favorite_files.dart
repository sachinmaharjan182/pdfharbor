import '../../../../core/error/result.dart';
import '../entities/pdf_file_entry.dart';
import '../repositories/files_repository.dart';

class GetFavoriteFiles {
  const GetFavoriteFiles(this._repository);

  final FilesRepository _repository;

  Future<Result<List<PdfFileEntry>>> call() => _repository.getFavorites();
}
