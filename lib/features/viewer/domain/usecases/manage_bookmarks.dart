import '../../../../core/error/result.dart';
import '../entities/pdf_bookmark.dart';
import '../repositories/viewer_repository.dart';

class GetBookmarks {
  const GetBookmarks(this._repository);

  final ViewerRepository _repository;

  List<PdfBookmarkEntry> call(String documentPath) => _repository.bookmarksFor(documentPath);
}

class AddBookmark {
  const AddBookmark(this._repository);

  final ViewerRepository _repository;

  Future<Result<void>> call(PdfBookmarkEntry bookmark) => _repository.addBookmark(bookmark);
}

class RemoveBookmark {
  const RemoveBookmark(this._repository);

  final ViewerRepository _repository;

  Future<Result<void>> call(String bookmarkId) => _repository.removeBookmark(bookmarkId);
}
