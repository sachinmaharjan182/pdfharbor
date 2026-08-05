// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_signature.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SavedSignature _$SavedSignatureFromJson(Map<String, dynamic> json) {
  return _SavedSignature.fromJson(json);
}

/// @nodoc
mixin _$SavedSignature {
  String get id => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SavedSignature to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedSignature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedSignatureCopyWith<SavedSignature> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedSignatureCopyWith<$Res> {
  factory $SavedSignatureCopyWith(
    SavedSignature value,
    $Res Function(SavedSignature) then,
  ) = _$SavedSignatureCopyWithImpl<$Res, SavedSignature>;
  @useResult
  $Res call({String id, String imagePath, DateTime createdAt});
}

/// @nodoc
class _$SavedSignatureCopyWithImpl<$Res, $Val extends SavedSignature>
    implements $SavedSignatureCopyWith<$Res> {
  _$SavedSignatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedSignature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imagePath = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SavedSignatureImplCopyWith<$Res>
    implements $SavedSignatureCopyWith<$Res> {
  factory _$$SavedSignatureImplCopyWith(
    _$SavedSignatureImpl value,
    $Res Function(_$SavedSignatureImpl) then,
  ) = __$$SavedSignatureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String imagePath, DateTime createdAt});
}

/// @nodoc
class __$$SavedSignatureImplCopyWithImpl<$Res>
    extends _$SavedSignatureCopyWithImpl<$Res, _$SavedSignatureImpl>
    implements _$$SavedSignatureImplCopyWith<$Res> {
  __$$SavedSignatureImplCopyWithImpl(
    _$SavedSignatureImpl _value,
    $Res Function(_$SavedSignatureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedSignature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imagePath = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SavedSignatureImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
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
class _$SavedSignatureImpl implements _SavedSignature {
  const _$SavedSignatureImpl({
    required this.id,
    required this.imagePath,
    required this.createdAt,
  });

  factory _$SavedSignatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedSignatureImplFromJson(json);

  @override
  final String id;
  @override
  final String imagePath;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SavedSignature(id: $id, imagePath: $imagePath, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedSignatureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, imagePath, createdAt);

  /// Create a copy of SavedSignature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedSignatureImplCopyWith<_$SavedSignatureImpl> get copyWith =>
      __$$SavedSignatureImplCopyWithImpl<_$SavedSignatureImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedSignatureImplToJson(this);
  }
}

abstract class _SavedSignature implements SavedSignature {
  const factory _SavedSignature({
    required final String id,
    required final String imagePath,
    required final DateTime createdAt,
  }) = _$SavedSignatureImpl;

  factory _SavedSignature.fromJson(Map<String, dynamic> json) =
      _$SavedSignatureImpl.fromJson;

  @override
  String get id;
  @override
  String get imagePath;
  @override
  DateTime get createdAt;

  /// Create a copy of SavedSignature
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedSignatureImplCopyWith<_$SavedSignatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SignaturePlacement {
  int get pageNumber => throw _privateConstructorUsedError;
  double get centerX => throw _privateConstructorUsedError;
  double get centerY => throw _privateConstructorUsedError;

  /// Width as a fraction of the page width.
  double get widthFraction => throw _privateConstructorUsedError;
  double get rotationDegrees => throw _privateConstructorUsedError;

  /// Create a copy of SignaturePlacement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignaturePlacementCopyWith<SignaturePlacement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignaturePlacementCopyWith<$Res> {
  factory $SignaturePlacementCopyWith(
    SignaturePlacement value,
    $Res Function(SignaturePlacement) then,
  ) = _$SignaturePlacementCopyWithImpl<$Res, SignaturePlacement>;
  @useResult
  $Res call({
    int pageNumber,
    double centerX,
    double centerY,
    double widthFraction,
    double rotationDegrees,
  });
}

/// @nodoc
class _$SignaturePlacementCopyWithImpl<$Res, $Val extends SignaturePlacement>
    implements $SignaturePlacementCopyWith<$Res> {
  _$SignaturePlacementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignaturePlacement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageNumber = null,
    Object? centerX = null,
    Object? centerY = null,
    Object? widthFraction = null,
    Object? rotationDegrees = null,
  }) {
    return _then(
      _value.copyWith(
            pageNumber: null == pageNumber
                ? _value.pageNumber
                : pageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            centerX: null == centerX
                ? _value.centerX
                : centerX // ignore: cast_nullable_to_non_nullable
                      as double,
            centerY: null == centerY
                ? _value.centerY
                : centerY // ignore: cast_nullable_to_non_nullable
                      as double,
            widthFraction: null == widthFraction
                ? _value.widthFraction
                : widthFraction // ignore: cast_nullable_to_non_nullable
                      as double,
            rotationDegrees: null == rotationDegrees
                ? _value.rotationDegrees
                : rotationDegrees // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SignaturePlacementImplCopyWith<$Res>
    implements $SignaturePlacementCopyWith<$Res> {
  factory _$$SignaturePlacementImplCopyWith(
    _$SignaturePlacementImpl value,
    $Res Function(_$SignaturePlacementImpl) then,
  ) = __$$SignaturePlacementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int pageNumber,
    double centerX,
    double centerY,
    double widthFraction,
    double rotationDegrees,
  });
}

/// @nodoc
class __$$SignaturePlacementImplCopyWithImpl<$Res>
    extends _$SignaturePlacementCopyWithImpl<$Res, _$SignaturePlacementImpl>
    implements _$$SignaturePlacementImplCopyWith<$Res> {
  __$$SignaturePlacementImplCopyWithImpl(
    _$SignaturePlacementImpl _value,
    $Res Function(_$SignaturePlacementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignaturePlacement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageNumber = null,
    Object? centerX = null,
    Object? centerY = null,
    Object? widthFraction = null,
    Object? rotationDegrees = null,
  }) {
    return _then(
      _$SignaturePlacementImpl(
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        centerX: null == centerX
            ? _value.centerX
            : centerX // ignore: cast_nullable_to_non_nullable
                  as double,
        centerY: null == centerY
            ? _value.centerY
            : centerY // ignore: cast_nullable_to_non_nullable
                  as double,
        widthFraction: null == widthFraction
            ? _value.widthFraction
            : widthFraction // ignore: cast_nullable_to_non_nullable
                  as double,
        rotationDegrees: null == rotationDegrees
            ? _value.rotationDegrees
            : rotationDegrees // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$SignaturePlacementImpl implements _SignaturePlacement {
  const _$SignaturePlacementImpl({
    required this.pageNumber,
    this.centerX = 0.5,
    this.centerY = 0.8,
    this.widthFraction = 0.3,
    this.rotationDegrees = 0.0,
  });

  @override
  final int pageNumber;
  @override
  @JsonKey()
  final double centerX;
  @override
  @JsonKey()
  final double centerY;

  /// Width as a fraction of the page width.
  @override
  @JsonKey()
  final double widthFraction;
  @override
  @JsonKey()
  final double rotationDegrees;

  @override
  String toString() {
    return 'SignaturePlacement(pageNumber: $pageNumber, centerX: $centerX, centerY: $centerY, widthFraction: $widthFraction, rotationDegrees: $rotationDegrees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignaturePlacementImpl &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.centerX, centerX) || other.centerX == centerX) &&
            (identical(other.centerY, centerY) || other.centerY == centerY) &&
            (identical(other.widthFraction, widthFraction) ||
                other.widthFraction == widthFraction) &&
            (identical(other.rotationDegrees, rotationDegrees) ||
                other.rotationDegrees == rotationDegrees));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    pageNumber,
    centerX,
    centerY,
    widthFraction,
    rotationDegrees,
  );

  /// Create a copy of SignaturePlacement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignaturePlacementImplCopyWith<_$SignaturePlacementImpl> get copyWith =>
      __$$SignaturePlacementImplCopyWithImpl<_$SignaturePlacementImpl>(
        this,
        _$identity,
      );
}

abstract class _SignaturePlacement implements SignaturePlacement {
  const factory _SignaturePlacement({
    required final int pageNumber,
    final double centerX,
    final double centerY,
    final double widthFraction,
    final double rotationDegrees,
  }) = _$SignaturePlacementImpl;

  @override
  int get pageNumber;
  @override
  double get centerX;
  @override
  double get centerY;

  /// Width as a fraction of the page width.
  @override
  double get widthFraction;
  @override
  double get rotationDegrees;

  /// Create a copy of SignaturePlacement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignaturePlacementImplCopyWith<_$SignaturePlacementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
