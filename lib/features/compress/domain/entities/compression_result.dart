import 'package:freezed_annotation/freezed_annotation.dart';

part 'compression_result.freezed.dart';

@freezed
class CompressionResult with _$CompressionResult {
  const factory CompressionResult({
    required String outputPath,
    required int originalBytes,
    required int compressedBytes,
  }) = _CompressionResult;

  const CompressionResult._();

  /// Percentage saved, clamped at 0 — re-encoding can occasionally grow a
  /// file (e.g. an already-optimized PDF), and a negative "saving" would
  /// read as nonsense in the UI.
  int get savingsPercent {
    if (originalBytes <= 0) return 0;
    final saved = originalBytes - compressedBytes;
    if (saved <= 0) return 0;
    return (saved / originalBytes * 100).round();
  }

  bool get didShrink => compressedBytes < originalBytes;
}
