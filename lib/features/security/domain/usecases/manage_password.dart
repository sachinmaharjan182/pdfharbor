import '../../../../core/error/result.dart';
import '../repositories/security_repository.dart';

class ProtectPdf {
  const ProtectPdf(this._repository);

  final SecurityRepository _repository;

  Future<Result<String>> call({required String sourcePath, required String password}) {
    return _repository.protect(sourcePath: sourcePath, password: password);
  }
}

class RemovePdfPassword {
  const RemovePdfPassword(this._repository);

  final SecurityRepository _repository;

  Future<Result<String>> call({required String sourcePath, required String password}) {
    return _repository.removePassword(sourcePath: sourcePath, password: password);
  }
}

class CheckPdfEncrypted {
  const CheckPdfEncrypted(this._repository);

  final SecurityRepository _repository;

  Future<Result<bool>> call(String path) => _repository.isEncrypted(path);
}
