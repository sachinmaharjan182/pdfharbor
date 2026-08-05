import 'package:freezed_annotation/freezed_annotation.dart';

part 'pdf_file_entry.freezed.dart';

/// A PDF file on device storage, combining live filesystem stats with
/// persisted metadata (favorite flag, last-opened time).
@freezed
class PdfFileEntry with _$PdfFileEntry {
  const factory PdfFileEntry({
    required String path,
    required String name,
    required int sizeBytes,
    required DateTime lastModified,
    DateTime? lastOpened,
    @Default(false) bool isFavorite,
  }) = _PdfFileEntry;

  const PdfFileEntry._();

  /// The file path uniquely identifies an entry; used as list/map keys.
  String get id => path;
}
