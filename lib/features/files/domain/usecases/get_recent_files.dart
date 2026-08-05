import '../../../../core/error/result.dart';
import '../entities/pdf_file_entry.dart';
import '../repositories/files_repository.dart';

class GetRecentFiles {
  const GetRecentFiles(this._repository);

  final FilesRepository _repository;

  Future<Result<List<PdfFileEntry>>> call({int limit = 10}) {
    return _repository.getRecentFiles(limit: limit);
  }
}
