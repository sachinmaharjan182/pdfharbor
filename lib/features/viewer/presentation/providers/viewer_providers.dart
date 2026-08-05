import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/hive/hive_service.dart';
import '../../data/repositories/viewer_repository_impl.dart';
import '../../domain/entities/pdf_bookmark.dart';
import '../../domain/entities/pdf_document_info.dart';
import '../../domain/repositories/viewer_repository.dart';
import '../../domain/usecases/manage_bookmarks.dart';
import '../../domain/usecases/read_document_info.dart';

final viewerRepositoryProvider = Provider<ViewerRepository>((ref) {
  return ViewerRepositoryImpl(HiveService.bookmarksBox);
});

final readDocumentInfoUseCaseProvider = Provider(
  (ref) => ReadDocumentInfo(ref.watch(viewerRepositoryProvider)),
);
final getBookmarksUseCaseProvider = Provider(
  (ref) => GetBookmarks(ref.watch(viewerRepositoryProvider)),
);
final addBookmarkUseCaseProvider = Provider(
  (ref) => AddBookmark(ref.watch(viewerRepositoryProvider)),
);
final removeBookmarkUseCaseProvider = Provider(
  (ref) => RemoveBookmark(ref.watch(viewerRepositoryProvider)),
);

/// Document metadata for the "PDF Information" sheet, keyed by file path.
final documentInfoProvider =
    FutureProvider.autoDispose.family<PdfDocumentInfo, String>((ref, path) async {
  final result = await ref.watch(readDocumentInfoUseCaseProvider).call(path);
  return result.fold((info) => info, (failure) => throw failure);
});

/// User bookmarks for one document. Kept as a Notifier so adding/removing
/// updates the viewer's bookmark sheet immediately.
class BookmarksNotifier extends AutoDisposeFamilyNotifier<List<PdfBookmarkEntry>, String> {
  @override
  List<PdfBookmarkEntry> build(String documentPath) {
    return ref.watch(getBookmarksUseCaseProvider).call(documentPath);
  }

  Future<void> add(PdfBookmarkEntry bookmark) async {
    final result = await ref.read(addBookmarkUseCaseProvider).call(bookmark);
    result.fold((_) => _refresh(), (_) {});
  }

  Future<void> remove(String bookmarkId) async {
    final result = await ref.read(removeBookmarkUseCaseProvider).call(bookmarkId);
    result.fold((_) => _refresh(), (_) {});
  }

  void _refresh() {
    state = ref.read(getBookmarksUseCaseProvider).call(arg);
  }
}

final bookmarksProvider = NotifierProvider.autoDispose
    .family<BookmarksNotifier, List<PdfBookmarkEntry>, String>(BookmarksNotifier.new);
