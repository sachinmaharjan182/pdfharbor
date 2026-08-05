// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_file_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PdfFileEntry {
  String get path => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  DateTime get lastModified => throw _privateConstructorUsedError;
  DateTime? get lastOpened => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Create a copy of PdfFileEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfFileEntryCopyWith<PdfFileEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfFileEntryCopyWith<$Res> {
  factory $PdfFileEntryCopyWith(
    PdfFileEntry value,
    $Res Function(PdfFileEntry) then,
  ) = _$PdfFileEntryCopyWithImpl<$Res, PdfFileEntry>;
  @useResult
  $Res call({
    String path,
    String name,
    int sizeBytes,
    DateTime lastModified,
    DateTime? lastOpened,
    bool isFavorite,
  });
}

/// @nodoc
class _$PdfFileEntryCopyWithImpl<$Res, $Val extends PdfFileEntry>
    implements $PdfFileEntryCopyWith<$Res> {
  _$PdfFileEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfFileEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? name = null,
    Object? sizeBytes = null,
    Object? lastModified = null,
    Object? lastOpened = freezed,
    Object? isFavorite = null,
  }) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sizeBytes: null == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            lastModified: null == lastModified
                ? _value.lastModified
                : lastModified // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastOpened: freezed == lastOpened
                ? _value.lastOpened
                : lastOpened // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfFileEntryImplCopyWith<$Res>
    implements $PdfFileEntryCopyWith<$Res> {
  factory _$$PdfFileEntryImplCopyWith(
    _$PdfFileEntryImpl value,
    $Res Function(_$PdfFileEntryImpl) then,
  ) = __$$PdfFileEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String path,
    String name,
    int sizeBytes,
    DateTime lastModified,
    DateTime? lastOpened,
    bool isFavorite,
  });
}

/// @nodoc
class __$$PdfFileEntryImplCopyWithImpl<$Res>
    extends _$PdfFileEntryCopyWithImpl<$Res, _$PdfFileEntryImpl>
    implements _$$PdfFileEntryImplCopyWith<$Res> {
  __$$PdfFileEntryImplCopyWithImpl(
    _$PdfFileEntryImpl _value,
    $Res Function(_$PdfFileEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfFileEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? name = null,
    Object? sizeBytes = null,
    Object? lastModified = null,
    Object? lastOpened = freezed,
    Object? isFavorite = null,
  }) {
    return _then(
      _$PdfFileEntryImpl(
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sizeBytes: null == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        lastModified: null == lastModified
            ? _value.lastModified
            : lastModified // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastOpened: freezed == lastOpened
            ? _value.lastOpened
            : lastOpened // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PdfFileEntryImpl extends _PdfFileEntry {
  const _$PdfFileEntryImpl({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.lastModified,
    this.lastOpened,
    this.isFavorite = false,
  }) : super._();

  @override
  final String path;
  @override
  final String name;
  @override
  final int sizeBytes;
  @override
  final DateTime lastModified;
  @override
  final DateTime? lastOpened;
  @override
  @JsonKey()
  final bool isFavorite;

  @override
  String toString() {
    return 'PdfFileEntry(path: $path, name: $name, sizeBytes: $sizeBytes, lastModified: $lastModified, lastOpened: $lastOpened, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfFileEntryImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.lastModified, lastModified) ||
                other.lastModified == lastModified) &&
            (identical(other.lastOpened, lastOpened) ||
                other.lastOpened == lastOpened) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    path,
    name,
    sizeBytes,
    lastModified,
    lastOpened,
    isFavorite,
  );

  /// Create a copy of PdfFileEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfFileEntryImplCopyWith<_$PdfFileEntryImpl> get copyWith =>
      __$$PdfFileEntryImplCopyWithImpl<_$PdfFileEntryImpl>(this, _$identity);
}

abstract class _PdfFileEntry extends PdfFileEntry {
  const factory _PdfFileEntry({
    required final String path,
    required final String name,
    required final int sizeBytes,
    required final DateTime lastModified,
    final DateTime? lastOpened,
    final bool isFavorite,
  }) = _$PdfFileEntryImpl;
  const _PdfFileEntry._() : super._();

  @override
  String get path;
  @override
  String get name;
  @override
  int get sizeBytes;
  @override
  DateTime get lastModified;
  @override
  DateTime? get lastOpened;
  @override
  bool get isFavorite;

  /// Create a copy of PdfFileEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfFileEntryImplCopyWith<_$PdfFileEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
