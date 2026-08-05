import 'package:flutter_test/flutter_test.dart';
import 'package:pdfverse/features/pdf_to_image/domain/entities/export_options.dart';

void main() {
  group('ImageExportFormat', () {
    test('maps to the conventional file extension', () {
      expect(ImageExportFormat.jpeg.extension, 'jpg');
      expect(ImageExportFormat.png.extension, 'png');
    });

    test('every format has a label and description', () {
      for (final format in ImageExportFormat.values) {
        expect(format.label, isNotEmpty);
        expect(format.description, isNotEmpty);
      }
    });
  });

  group('ImageExportQuality', () {
    test('higher quality means higher render scale', () {
      expect(
        ImageExportQuality.low.renderScale,
        lessThan(ImageExportQuality.medium.renderScale),
      );
      expect(
        ImageExportQuality.medium.renderScale,
        lessThan(ImageExportQuality.high.renderScale),
      );
    });

    test('JPEG quality increases with the preset and stays in range', () {
      expect(
        ImageExportQuality.low.jpegQuality,
        lessThan(ImageExportQuality.high.jpegQuality),
      );
      for (final quality in ImageExportQuality.values) {
        expect(quality.jpegQuality, inInclusiveRange(1, 100));
        expect(quality.renderScale, greaterThan(0));
      }
    });
  });
}
