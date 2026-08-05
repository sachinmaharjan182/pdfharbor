import 'package:freezed_annotation/freezed_annotation.dart';

part 'pdf_bookmark.freezed.dart';
part 'pdf_bookmark.g.dart';

/// A user-created bookmark pinning a page of a specific document.
/// Distinct from the PDF's own embedded outline/table-of-contents.
@freezed
class PdfBookmarkEntry with _$PdfBookmarkEntry {
  const factory PdfBookmarkEntry({
    required String id,
    required String documentPath,
    required int pageNumber,
    required String label,
    required DateTime createdAt,
  }) = _PdfBookmarkEntry;

  factory PdfBookmarkEntry.fromJson(Map<String, dynamic> json) =>
      _$PdfBookmarkEntryFromJson(json);
}
