// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watermark_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WatermarkConfig {
  String get text => throw _privateConstructorUsedError;

  /// Set for an image watermark; when present it replaces [text].
  String? get imagePath => throw _privateConstructorUsedError;
  double get opacity => throw _privateConstructorUsedError;
  double get rotationDegrees => throw _privateConstructorUsedError;

  /// Relative size: 1.0 spans roughly half the page's shorter edge.
  double get scale => throw _privateConstructorUsedError;
  WatermarkPosition get position => throw _privateConstructorUsedError;
  int get colorValue => throw _privateConstructorUsedError;

  /// Create a copy of WatermarkConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatermarkConfigCopyWith<WatermarkConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatermarkConfigCopyWith<$Res> {
  factory $WatermarkConfigCopyWith(
    WatermarkConfig value,
    $Res Function(WatermarkConfig) then,
  ) = _$WatermarkConfigCopyWithImpl<$Res, WatermarkConfig>;
  @useResult
  $Res call({
    String text,
    String? imagePath,
    double opacity,
    double rotationDegrees,
    double scale,
    WatermarkPosition position,
    int colorValue,
  });
}

/// @nodoc
class _$WatermarkConfigCopyWithImpl<$Res, $Val extends WatermarkConfig>
    implements $WatermarkConfigCopyWith<$Res> {
  _$WatermarkConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatermarkConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? imagePath = freezed,
    Object? opacity = null,
    Object? rotationDegrees = null,
    Object? scale = null,
    Object? position = null,
    Object? colorValue = null,
  }) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            opacity: null == opacity
                ? _value.opacity
                : opacity // ignore: cast_nullable_to_non_nullable
                      as double,
            rotationDegrees: null == rotationDegrees
                ? _value.rotationDegrees
                : rotationDegrees // ignore: cast_nullable_to_non_nullable
                      as double,
            scale: null == scale
                ? _value.scale
                : scale // ignore: cast_nullable_to_non_nullable
                      as double,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as WatermarkPosition,
            colorValue: null == colorValue
                ? _value.colorValue
                : colorValue // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WatermarkConfigImplCopyWith<$Res>
    implements $WatermarkConfigCopyWith<$Res> {
  factory _$$WatermarkConfigImplCopyWith(
    _$WatermarkConfigImpl value,
    $Res Function(_$WatermarkConfigImpl) then,
  ) = __$$WatermarkConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String text,
    String? imagePath,
    double opacity,
    double rotationDegrees,
    double scale,
    WatermarkPosition position,
    int colorValue,
  });
}

/// @nodoc
class __$$WatermarkConfigImplCopyWithImpl<$Res>
    extends _$WatermarkConfigCopyWithImpl<$Res, _$WatermarkConfigImpl>
    implements _$$WatermarkConfigImplCopyWith<$Res> {
  __$$WatermarkConfigImplCopyWithImpl(
    _$WatermarkConfigImpl _value,
    $Res Function(_$WatermarkConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WatermarkConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? imagePath = freezed,
    Object? opacity = null,
    Object? rotationDegrees = null,
    Object? scale = null,
    Object? position = null,
    Object? colorValue = null,
  }) {
    return _then(
      _$WatermarkConfigImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        opacity: null == opacity
            ? _value.opacity
            : opacity // ignore: cast_nullable_to_non_nullable
                  as double,
        rotationDegrees: null == rotationDegrees
            ? _value.rotationDegrees
            : rotationDegrees // ignore: cast_nullable_to_non_nullable
                  as double,
        scale: null == scale
            ? _value.scale
            : scale // ignore: cast_nullable_to_non_nullable
                  as double,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as WatermarkPosition,
        colorValue: null == colorValue
            ? _value.colorValue
            : colorValue // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$WatermarkConfigImpl extends _WatermarkConfig {
  const _$WatermarkConfigImpl({
    this.text = 'CONFIDENTIAL',
    this.imagePath,
    this.opacity = 0.25,
    this.rotationDegrees = -45.0,
    this.scale = 1.0,
    this.position = WatermarkPosition.center,
    this.colorValue = 0xFF808080,
  }) : super._();

  @override
  @JsonKey()
  final String text;

  /// Set for an image watermark; when present it replaces [text].
  @override
  final String? imagePath;
  @override
  @JsonKey()
  final double opacity;
  @override
  @JsonKey()
  final double rotationDegrees;

  /// Relative size: 1.0 spans roughly half the page's shorter edge.
  @override
  @JsonKey()
  final double scale;
  @override
  @JsonKey()
  final WatermarkPosition position;
  @override
  @JsonKey()
  final int colorValue;

  @override
  String toString() {
    return 'WatermarkConfig(text: $text, imagePath: $imagePath, opacity: $opacity, rotationDegrees: $rotationDegrees, scale: $scale, position: $position, colorValue: $colorValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatermarkConfigImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.rotationDegrees, rotationDegrees) ||
                other.rotationDegrees == rotationDegrees) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    text,
    imagePath,
    opacity,
    rotationDegrees,
    scale,
    position,
    colorValue,
  );

  /// Create a copy of WatermarkConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatermarkConfigImplCopyWith<_$WatermarkConfigImpl> get copyWith =>
      __$$WatermarkConfigImplCopyWithImpl<_$WatermarkConfigImpl>(
        this,
        _$identity,
      );
}

abstract class _WatermarkConfig extends WatermarkConfig {
  const factory _WatermarkConfig({
    final String text,
    final String? imagePath,
    final double opacity,
    final double rotationDegrees,
    final double scale,
    final WatermarkPosition position,
    final int colorValue,
  }) = _$WatermarkConfigImpl;
  const _WatermarkConfig._() : super._();

  @override
  String get text;

  /// Set for an image watermark; when present it replaces [text].
  @override
  String? get imagePath;
  @override
  double get opacity;
  @override
  double get rotationDegrees;

  /// Relative size: 1.0 spans roughly half the page's shorter edge.
  @override
  double get scale;
  @override
  WatermarkPosition get position;
  @override
  int get colorValue;

  /// Create a copy of WatermarkConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatermarkConfigImplCopyWith<_$WatermarkConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
