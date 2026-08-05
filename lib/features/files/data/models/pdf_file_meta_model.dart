import 'package:freezed_annotation/freezed_annotation.dart';

part 'pdf_file_meta_model.freezed.dart';
part 'pdf_file_meta_model.g.dart';

/// The subset of [PdfFileEntry] that actually needs persisting in Hive —
/// everything else (size, last-modified) is read live from the filesystem
/// on each scan.
@freezed
class PdfFileMetaModel with _$PdfFileMetaModel {
  const factory PdfFileMetaModel({
    required String path,
    DateTime? lastOpened,
    @Default(false) bool isFavorite,
  }) = _PdfFileMetaModel;

  factory PdfFileMetaModel.fromJson(Map<String, dynamic> json) =>
      _$PdfFileMetaModelFromJson(json);
}
