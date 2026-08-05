// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_bookmark.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PdfBookmarkEntry _$PdfBookmarkEntryFromJson(Map<String, dynamic> json) {
  return _PdfBookmarkEntry.fromJson(json);
}

/// @nodoc
mixin _$PdfBookmarkEntry {
  String get id => throw _privateConstructorUsedError;
  String get documentPath => throw _privateConstructorUsedError;
  int get pageNumber => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PdfBookmarkEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfBookmarkEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfBookmarkEntryCopyWith<PdfBookmarkEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfBookmarkEntryCopyWith<$Res> {
  factory $PdfBookmarkEntryCopyWith(
    PdfBookmarkEntry value,
    $Res Function(PdfBookmarkEntry) then,
  ) = _$PdfBookmarkEntryCopyWithImpl<$Res, PdfBookmarkEntry>;
  @useResult
  $Res call({
    String id,
    String documentPath,
    int pageNumber,
    String label,
    DateTime createdAt,
  });
}

/// @nodoc
class _$PdfBookmarkEntryCopyWithImpl<$Res, $Val extends PdfBookmarkEntry>
    implements $PdfBookmarkEntryCopyWith<$Res> {
  _$PdfBookmarkEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfBookmarkEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentPath = null,
    Object? pageNumber = null,
    Object? label = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            documentPath: null == documentPath
                ? _value.documentPath
                : documentPath // ignore: cast_nullable_to_non_nullable
                      as String,
            pageNumber: null == pageNumber
                ? _value.pageNumber
                : pageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfBookmarkEntryImplCopyWith<$Res>
    implements $PdfBookmarkEntryCopyWith<$Res> {
  factory _$$PdfBookmarkEntryImplCopyWith(
    _$PdfBookmarkEntryImpl value,
    $Res Function(_$PdfBookmarkEntryImpl) then,
  ) = __$$PdfBookmarkEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String documentPath,
    int pageNumber,
    String label,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$PdfBookmarkEntryImplCopyWithImpl<$Res>
    extends _$PdfBookmarkEntryCopyWithImpl<$Res, _$PdfBookmarkEntryImpl>
    implements _$$PdfBookmarkEntryImplCopyWith<$Res> {
  __$$PdfBookmarkEntryImplCopyWithImpl(
    _$PdfBookmarkEntryImpl _value,
    $Res Function(_$PdfBookmarkEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfBookmarkEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentPath = null,
    Object? pageNumber = null,
    Object? label = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PdfBookmarkEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        documentPath: null == documentPath
            ? _value.documentPath
            : documentPath // ignore: cast_nullable_to_non_nullable
                  as String,
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfBookmarkEntryImpl implements _PdfBookmarkEntry {
  const _$PdfBookmarkEntryImpl({
    required this.id,
    required this.documentPath,
    required this.pageNumber,
    required this.label,
    required this.createdAt,
  });

  factory _$PdfBookmarkEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfBookmarkEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String documentPath;
  @override
  final int pageNumber;
  @override
  final String label;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PdfBookmarkEntry(id: $id, documentPath: $documentPath, pageNumber: $pageNumber, label: $label, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfBookmarkEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentPath, documentPath) ||
                other.documentPath == documentPath) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, documentPath, pageNumber, label, createdAt);

  /// Create a copy of PdfBookmarkEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfBookmarkEntryImplCopyWith<_$PdfBookmarkEntryImpl> get copyWith =>
      __$$PdfBookmarkEntryImplCopyWithImpl<_$PdfBookmarkEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfBookmarkEntryImplToJson(this);
  }
}

abstract class _PdfBookmarkEntry implements PdfBookmarkEntry {
  const factory _PdfBookmarkEntry({
    required final String id,
    required final String documentPath,
    required final int pageNumber,
    required final String label,
    required final DateTime createdAt,
  }) = _$PdfBookmarkEntryImpl;

  factory _PdfBookmarkEntry.fromJson(Map<String, dynamic> json) =
      _$PdfBookmarkEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get documentPath;
  @override
  int get pageNumber;
  @override
  String get label;
  @override
  DateTime get createdAt;

  /// Create a copy of PdfBookmarkEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfBookmarkEntryImplCopyWith<_$PdfBookmarkEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
