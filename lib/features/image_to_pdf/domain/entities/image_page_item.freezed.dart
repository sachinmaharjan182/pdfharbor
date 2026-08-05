// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_page_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ImagePageItem {
  String get id => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  int get rotationDegrees => throw _privateConstructorUsedError;
  ImageFilterType get filter => throw _privateConstructorUsedError;

  /// Create a copy of ImagePageItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImagePageItemCopyWith<ImagePageItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImagePageItemCopyWith<$Res> {
  factory $ImagePageItemCopyWith(
    ImagePageItem value,
    $Res Function(ImagePageItem) then,
  ) = _$ImagePageItemCopyWithImpl<$Res, ImagePageItem>;
  @useResult
  $Res call({
    String id,
    String path,
    int rotationDegrees,
    ImageFilterType filter,
  });
}

/// @nodoc
class _$ImagePageItemCopyWithImpl<$Res, $Val extends ImagePageItem>
    implements $ImagePageItemCopyWith<$Res> {
  _$ImagePageItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImagePageItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? rotationDegrees = null,
    Object? filter = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            rotationDegrees: null == rotationDegrees
                ? _value.rotationDegrees
                : rotationDegrees // ignore: cast_nullable_to_non_nullable
                      as int,
            filter: null == filter
                ? _value.filter
                : filter // ignore: cast_nullable_to_non_nullable
                      as ImageFilterType,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImagePageItemImplCopyWith<$Res>
    implements $ImagePageItemCopyWith<$Res> {
  factory _$$ImagePageItemImplCopyWith(
    _$ImagePageItemImpl value,
    $Res Function(_$ImagePageItemImpl) then,
  ) = __$$ImagePageItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String path,
    int rotationDegrees,
    ImageFilterType filter,
  });
}

/// @nodoc
class __$$ImagePageItemImplCopyWithImpl<$Res>
    extends _$ImagePageItemCopyWithImpl<$Res, _$ImagePageItemImpl>
    implements _$$ImagePageItemImplCopyWith<$Res> {
  __$$ImagePageItemImplCopyWithImpl(
    _$ImagePageItemImpl _value,
    $Res Function(_$ImagePageItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImagePageItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? rotationDegrees = null,
    Object? filter = null,
  }) {
    return _then(
      _$ImagePageItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        rotationDegrees: null == rotationDegrees
            ? _value.rotationDegrees
            : rotationDegrees // ignore: cast_nullable_to_non_nullable
                  as int,
        filter: null == filter
            ? _value.filter
            : filter // ignore: cast_nullable_to_non_nullable
                  as ImageFilterType,
      ),
    );
  }
}

/// @nodoc

class _$ImagePageItemImpl extends _ImagePageItem {
  const _$ImagePageItemImpl({
    required this.id,
    required this.path,
    this.rotationDegrees = 0,
    this.filter = ImageFilterType.original,
  }) : super._();

  @override
  final String id;
  @override
  final String path;
  @override
  @JsonKey()
  final int rotationDegrees;
  @override
  @JsonKey()
  final ImageFilterType filter;

  @override
  String toString() {
    return 'ImagePageItem(id: $id, path: $path, rotationDegrees: $rotationDegrees, filter: $filter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImagePageItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.rotationDegrees, rotationDegrees) ||
                other.rotationDegrees == rotationDegrees) &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, path, rotationDegrees, filter);

  /// Create a copy of ImagePageItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImagePageItemImplCopyWith<_$ImagePageItemImpl> get copyWith =>
      __$$ImagePageItemImplCopyWithImpl<_$ImagePageItemImpl>(this, _$identity);
}

abstract class _ImagePageItem extends ImagePageItem {
  const factory _ImagePageItem({
    required final String id,
    required final String path,
    final int rotationDegrees,
    final ImageFilterType filter,
  }) = _$ImagePageItemImpl;
  const _ImagePageItem._() : super._();

  @override
  String get id;
  @override
  String get path;
  @override
  int get rotationDegrees;
  @override
  ImageFilterType get filter;

  /// Create a copy of ImagePageItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImagePageItemImplCopyWith<_$ImagePageItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
