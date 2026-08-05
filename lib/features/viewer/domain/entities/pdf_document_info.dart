import 'package:freezed_annotation/freezed_annotation.dart';

part 'pdf_document_info.freezed.dart';

/// Metadata read out of a PDF's document-information dictionary, shown in
/// the viewer's "PDF Information" sheet.
@freezed
class PdfDocumentInfo with _$PdfDocumentInfo {
  const factory PdfDocumentInfo({
    required String fileName,
    required int sizeBytes,
    required int pageCount,
    required bool isEncrypted,
    String? title,
    String? author,
    String? subject,
    String? keywords,
    String? creator,
    String? producer,
    DateTime? creationDate,
    DateTime? modificationDate,
  }) = _PdfDocumentInfo;
}
