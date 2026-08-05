import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/watermark_repository_impl.dart';
import '../../domain/entities/watermark_config.dart';
import '../../domain/repositories/watermark_repository.dart';
import '../../domain/usecases/apply_watermark.dart';

final watermarkRepositoryProvider = Provider<WatermarkRepository>((ref) {
  return const WatermarkRepositoryImpl();
});

final applyWatermarkUseCaseProvider = Provider(
  (ref) => ApplyWatermark(ref.watch(watermarkRepositoryProvider)),
);
final renderWatermarkPreviewUseCaseProvider = Provider(
  (ref) => RenderWatermarkPreview(ref.watch(watermarkRepositoryProvider)),
);

final watermarkConfigProvider = NotifierProvider<WatermarkConfigNotifier, WatermarkConfig>(
  WatermarkConfigNotifier.new,
);

class WatermarkConfigNotifier extends Notifier<WatermarkConfig> {
  @override
  WatermarkConfig build() => const WatermarkConfig();

  void setText(String text) => state = state.copyWith(text: text);

  void setOpacity(double value) => state = state.copyWith(opacity: value);

  void setRotation(double value) => state = state.copyWith(rotationDegrees: value);

  void setScale(double value) => state = state.copyWith(scale: value);

  void setPosition(WatermarkPosition position) => state = state.copyWith(position: position);

  void setImagePath(String? path) => state = state.copyWith(imagePath: path);

  void setColor(int colorValue) => state = state.copyWith(colorValue: colorValue);

  void reset() => state = const WatermarkConfig();
}

/// Debounced preview render. Watching the config means any change
/// re-runs this provider; the leading delay collapses a slider drag's
/// many updates into one render, and `disposed` stops a superseded run
/// from doing the expensive work at all.
final watermarkPreviewProvider =
    FutureProvider.autoDispose.family<Uint8List, String>((ref, sourcePath) async {
  final config = ref.watch(watermarkConfigProvider);
  if (!config.isValid) throw const EmptyWatermarkException();

  var disposed = false;
  ref.onDispose(() => disposed = true);

  await Future<void>.delayed(const Duration(milliseconds: 350));
  if (disposed) throw const EmptyWatermarkException();

  final result = await ref
      .read(renderWatermarkPreviewUseCaseProvider)
      .call(sourcePath: sourcePath, config: config);
  return result.fold((bytes) => bytes, (failure) => throw failure);
});

/// Signals "nothing to preview yet" rather than a real failure, so the UI
/// can show a prompt instead of an error.
class EmptyWatermarkException implements Exception {
  const EmptyWatermarkException();
}
