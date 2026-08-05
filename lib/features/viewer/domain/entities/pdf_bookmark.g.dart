// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_bookmark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfBookmarkEntryImpl _$$PdfBookmarkEntryImplFromJson(
  Map<String, dynamic> json,
) => _$PdfBookmarkEntryImpl(
  id: json['id'] as String,
  documentPath: json['documentPath'] as String,
  pageNumber: (json['pageNumber'] as num).toInt(),
  label: json['label'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PdfBookmarkEntryImplToJson(
  _$PdfBookmarkEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'documentPath': instance.documentPath,
  'pageNumber': instance.pageNumber,
  'label': instance.label,
  'createdAt': instance.createdAt.toIso8601String(),
};
