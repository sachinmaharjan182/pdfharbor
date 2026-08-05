import 'dart:typed_data';

import '../../../../core/error/result.dart';
import '../entities/watermark_config.dart';

abstract interface class WatermarkRepository {
  /// Writes a watermarked copy of [sourcePath] and returns its path.
  Future<Result<String>> applyWatermark({
    required String sourcePath,
    required WatermarkConfig config,
  });

  /// Renders page 1 with the watermark applied, for the live preview.
  Future<Result<Uint8List>> renderPreview({
    required String sourcePath,
    required WatermarkConfig config,
  });
}
