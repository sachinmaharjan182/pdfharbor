import 'dart:typed_data';

import '../../../../core/error/result.dart';
import '../entities/watermark_config.dart';
import '../repositories/watermark_repository.dart';

class ApplyWatermark {
  const ApplyWatermark(this._repository);

  final WatermarkRepository _repository;

  Future<Result<String>> call({
    required String sourcePath,
    required WatermarkConfig config,
  }) {
    return _repository.applyWatermark(sourcePath: sourcePath, config: config);
  }
}

class RenderWatermarkPreview {
  const RenderWatermarkPreview(this._repository);

  final WatermarkRepository _repository;

  Future<Result<Uint8List>> call({
    required String sourcePath,
    required WatermarkConfig config,
  }) {
    return _repository.renderPreview(sourcePath: sourcePath, config: config);
  }
}
