import '../../../../core/error/result.dart';
import '../entities/pdf_document_info.dart';
import '../repositories/viewer_repository.dart';

class ReadDocumentInfo {
  const ReadDocumentInfo(this._repository);

  final ViewerRepository _repository;

  Future<Result<PdfDocumentInfo>> call(String path, {String? password}) {
    return _repository.readDocumentInfo(path, password: password);
  }
}
