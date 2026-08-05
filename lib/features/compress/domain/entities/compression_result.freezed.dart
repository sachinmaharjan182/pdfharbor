// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compression_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CompressionResult {
  String get outputPath => throw _privateConstructorUsedError;
  int get originalBytes => throw _privateConstructorUsedError;
  int get compressedBytes => throw _privateConstructorUsedError;

  /// Create a copy of CompressionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompressionResultCopyWith<CompressionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompressionResultCopyWith<$Res> {
  factory $CompressionResultCopyWith(
    CompressionResult value,
    $Res Function(CompressionResult) then,
  ) = _$CompressionResultCopyWithImpl<$Res, CompressionResult>;
  @useResult
  $Res call({String outputPath, int originalBytes, int compressedBytes});
}

/// @nodoc
class _$CompressionResultCopyWithImpl<$Res, $Val extends CompressionResult>
    implements $CompressionResultCopyWith<$Res> {
  _$CompressionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompressionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? originalBytes = null,
    Object? compressedBytes = null,
  }) {
    return _then(
      _value.copyWith(
            outputPath: null == outputPath
                ? _value.outputPath
                : outputPath // ignore: cast_nullable_to_non_nullable
                      as String,
            originalBytes: null == originalBytes
                ? _value.originalBytes
                : originalBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            compressedBytes: null == compressedBytes
                ? _value.compressedBytes
                : compressedBytes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompressionResultImplCopyWith<$Res>
    implements $CompressionResultCopyWith<$Res> {
  factory _$$CompressionResultImplCopyWith(
    _$CompressionResultImpl value,
    $Res Function(_$CompressionResultImpl) then,
  ) = __$$CompressionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String outputPath, int originalBytes, int compressedBytes});
}

/// @nodoc
class __$$CompressionResultImplCopyWithImpl<$Res>
    extends _$CompressionResultCopyWithImpl<$Res, _$CompressionResultImpl>
    implements _$$CompressionResultImplCopyWith<$Res> {
  __$$CompressionResultImplCopyWithImpl(
    _$CompressionResultImpl _value,
    $Res Function(_$CompressionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompressionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? originalBytes = null,
    Object? compressedBytes = null,
  }) {
    return _then(
      _$CompressionResultImpl(
        outputPath: null == outputPath
            ? _value.outputPath
            : outputPath // ignore: cast_nullable_to_non_nullable
                  as String,
        originalBytes: null == originalBytes
            ? _value.originalBytes
            : originalBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        compressedBytes: null == compressedBytes
            ? _value.compressedBytes
            : compressedBytes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CompressionResultImpl extends _CompressionResult {
  const _$CompressionResultImpl({
    required this.outputPath,
    required this.originalBytes,
    required this.compressedBytes,
  }) : super._();

  @override
  final String outputPath;
  @override
  final int originalBytes;
  @override
  final int compressedBytes;

  @override
  String toString() {
    return 'CompressionResult(outputPath: $outputPath, originalBytes: $originalBytes, compressedBytes: $compressedBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompressionResultImpl &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            (identical(other.originalBytes, originalBytes) ||
                other.originalBytes == originalBytes) &&
            (identical(other.compressedBytes, compressedBytes) ||
                other.compressedBytes == compressedBytes));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, outputPath, originalBytes, compressedBytes);

  /// Create a copy of CompressionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompressionResultImplCopyWith<_$CompressionResultImpl> get copyWith =>
      __$$CompressionResultImplCopyWithImpl<_$CompressionResultImpl>(
        this,
        _$identity,
      );
}

abstract class _CompressionResult extends CompressionResult {
  const factory _CompressionResult({
    required final String outputPath,
    required final int originalBytes,
    required final int compressedBytes,
  }) = _$CompressionResultImpl;
  const _CompressionResult._() : super._();

  @override
  String get outputPath;
  @override
  int get originalBytes;
  @override
  int get compressedBytes;

  /// Create a copy of CompressionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompressionResultImplCopyWith<_$CompressionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
