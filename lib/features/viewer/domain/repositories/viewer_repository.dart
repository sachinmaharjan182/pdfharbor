import '../../../../core/error/result.dart';
import '../entities/pdf_bookmark.dart';
import '../entities/pdf_document_info.dart';

abstract interface class ViewerRepository {
  /// Reads document metadata. [password] is required for encrypted files.
  Future<Result<PdfDocumentInfo>> readDocumentInfo(String path, {String? password});

  /// True when the PDF requires a password to open.
  Future<Result<bool>> isEncrypted(String path);

  List<PdfBookmarkEntry> bookmarksFor(String documentPath);

  Future<Result<void>> addBookmark(PdfBookmarkEntry bookmark);

  Future<Result<void>> removeBookmark(String bookmarkId);
}
