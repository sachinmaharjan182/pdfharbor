// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_file_meta_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfFileMetaModelImpl _$$PdfFileMetaModelImplFromJson(
  Map<String, dynamic> json,
) => _$PdfFileMetaModelImpl(
  path: json['path'] as String,
  lastOpened: json['lastOpened'] == null
      ? null
      : DateTime.parse(json['lastOpened'] as String),
  isFavorite: json['isFavorite'] as bool? ?? false,
);

Map<String, dynamic> _$$PdfFileMetaModelImplToJson(
  _$PdfFileMetaModelImpl instance,
) => <String, dynamic>{
  'path': instance.path,
  'lastOpened': instance.lastOpened?.toIso8601String(),
  'isFavorite': instance.isFavorite,
};
