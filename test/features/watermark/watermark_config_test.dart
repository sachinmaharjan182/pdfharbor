import 'package:flutter_test/flutter_test.dart';
import 'package:pdfharbor/features/watermark/domain/entities/watermark_config.dart';

void main() {
  group('WatermarkConfig', () {
    test('a text watermark is valid when the text is non-blank', () {
      expect(const WatermarkConfig(text: 'DRAFT').isValid, isTrue);
      expect(const WatermarkConfig(text: '').isValid, isFalse);
      expect(const WatermarkConfig(text: '   ').isValid, isFalse);
    });

    test('an image watermark is valid regardless of text', () {
      const config = WatermarkConfig(text: '', imagePath: '/logo.png');
      expect(config.isImageWatermark, isTrue);
      expect(config.isValid, isTrue);
    });

    test('defaults to a diagonal, semi-transparent centered mark', () {
      const config = WatermarkConfig();
      expect(config.isImageWatermark, isFalse);
      expect(config.position, WatermarkPosition.center);
      expect(config.opacity, lessThan(1.0));
      expect(config.rotationDegrees, isNot(0));
    });

    test('copyWith preserves unrelated fields', () {
      const config = WatermarkConfig(text: 'SECRET', opacity: 0.4);
      final updated = config.copyWith(position: WatermarkPosition.tiled);
      expect(updated.text, 'SECRET');
      expect(updated.opacity, 0.4);
      expect(updated.position, WatermarkPosition.tiled);
    });

    test('every position exposes a label', () {
      for (final position in WatermarkPosition.values) {
        expect(position.label, isNotEmpty);
      }
    });
  });
}
