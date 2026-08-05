import 'package:freezed_annotation/freezed_annotation.dart';

part 'watermark_config.freezed.dart';

/// Where the watermark sits on each page.
enum WatermarkPosition {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  tiled;

  String get label => switch (this) {
        WatermarkPosition.center => 'Center',
        WatermarkPosition.topLeft => 'Top left',
        WatermarkPosition.topRight => 'Top right',
        WatermarkPosition.bottomLeft => 'Bottom left',
        WatermarkPosition.bottomRight => 'Bottom right',
        WatermarkPosition.tiled => 'Tiled',
      };
}

@freezed
class WatermarkConfig with _$WatermarkConfig {
  const factory WatermarkConfig({
    @Default('CONFIDENTIAL') String text,

    /// Set for an image watermark; when present it replaces [text].
    String? imagePath,
    @Default(0.25) double opacity,
    @Default(-45.0) double rotationDegrees,

    /// Relative size: 1.0 spans roughly half the page's shorter edge.
    @Default(1.0) double scale,
    @Default(WatermarkPosition.center) WatermarkPosition position,
    @Default(0xFF808080) int colorValue,
  }) = _WatermarkConfig;

  const WatermarkConfig._();

  bool get isImageWatermark => imagePath != null;

  bool get isValid => isImageWatermark || text.trim().isNotEmpty;
}
