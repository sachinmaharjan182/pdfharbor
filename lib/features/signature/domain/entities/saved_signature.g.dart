// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_signature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavedSignatureImpl _$$SavedSignatureImplFromJson(Map<String, dynamic> json) =>
    _$SavedSignatureImpl(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SavedSignatureImplToJson(
  _$SavedSignatureImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'imagePath': instance.imagePath,
  'createdAt': instance.createdAt.toIso8601String(),
};
