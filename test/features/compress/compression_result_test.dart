import 'package:flutter_test/flutter_test.dart';
import 'package:pdfverse/features/compress/domain/entities/compression_preset.dart';
import 'package:pdfverse/features/compress/domain/entities/compression_result.dart';

void main() {
  group('CompressionResult', () {
    test('reports the percentage saved', () {
      const result = CompressionResult(
        outputPath: '/out.pdf',
        originalBytes: 1000,
        compressedBytes: 250,
      );
      expect(result.savingsPercent, 75);
      expect(result.didShrink, isTrue);
    });

    test('clamps to zero when re-encoding grew the file', () {
      const result = CompressionResult(
        outputPath: '/out.pdf',
        originalBytes: 1000,
        compressedBytes: 1400,
      );
      expect(result.savingsPercent, 0);
      expect(result.didShrink, isFalse);
    });

    test('handles an identical size without claiming a saving', () {
      const result = CompressionResult(
        outputPath: '/out.pdf',
        originalBytes: 500,
        compressedBytes: 500,
      );
      expect(result.savingsPercent, 0);
      expect(result.didShrink, isFalse);
    });

    test('does not divide by zero on an empty original', () {
      const result = CompressionResult(
        outputPath: '/out.pdf',
        originalBytes: 0,
        compressedBytes: 0,
      );
      expect(result.savingsPercent, 0);
    });
  });

  group('CompressionPreset', () {
    test('stronger presets use lower resolution and quality', () {
      expect(
        CompressionPreset.low.renderScale,
        greaterThan(CompressionPreset.medium.renderScale),
      );
      expect(
        CompressionPreset.medium.renderScale,
        greaterThan(CompressionPreset.high.renderScale),
      );
      expect(
        CompressionPreset.low.jpegQuality,
        greaterThan(CompressionPreset.medium.jpegQuality),
      );
      expect(
        CompressionPreset.medium.jpegQuality,
        greaterThan(CompressionPreset.high.jpegQuality),
      );
    });

    test('JPEG quality stays in the encoder range', () {
      for (final preset in CompressionPreset.values) {
        expect(preset.jpegQuality, inInclusiveRange(1, 100));
      }
    });
  });
}
