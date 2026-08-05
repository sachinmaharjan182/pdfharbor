import '../../../../core/error/result.dart';
import '../entities/pdf_file_entry.dart';

/// Source of truth for PDFs on device storage plus their app-side metadata
/// (favorites, last-opened). Implemented by [FilesRepositoryImpl] in the
/// data layer; presentation code depends only on this interface.
abstract interface class FilesRepository {
  Future<Result<List<PdfFileEntry>>> scanDeviceForPdfs({bool forceRescan = false});

  Future<Result<List<PdfFileEntry>>> getRecentFiles({int limit = 10});

  Future<Result<List<PdfFileEntry>>> getFavorites();

  Future<Result<void>> recordOpened(String path);

  Future<Result<void>> toggleFavorite(String path);

  Future<Result<void>> renameFile(String path, String newName);

  Future<Result<void>> deleteFile(String path);
}
