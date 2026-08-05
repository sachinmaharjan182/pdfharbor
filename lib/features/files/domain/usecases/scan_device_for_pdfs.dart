import '../../../../core/error/result.dart';
import '../entities/pdf_file_entry.dart';
import '../repositories/files_repository.dart';

class ScanDeviceForPdfs {
  const ScanDeviceForPdfs(this._repository);

  final FilesRepository _repository;

  Future<Result<List<PdfFileEntry>>> call({bool forceRescan = false}) {
    return _repository.scanDeviceForPdfs(forceRescan: forceRescan);
  }
}
