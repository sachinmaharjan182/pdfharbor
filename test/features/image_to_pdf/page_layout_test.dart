import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdfharbor/features/image_to_pdf/domain/entities/page_layout.dart';

void main() {
  group('resolvePageSize', () {
    const landscapeImage = Size(1600, 900);

    test('returns the portrait dimensions for a portrait fixed size', () {
      final size = resolvePageSize(
        sizeOption: PdfPageSizeOption.a4,
        orientation: PageOrientation.portrait,
        imagePixelSize: landscapeImage,
      );
      expect(size, const Size(595, 842));
    });

    test('swaps dimensions for a landscape fixed size', () {
      final size = resolvePageSize(
        sizeOption: PdfPageSizeOption.a4,
        orientation: PageOrientation.landscape,
        imagePixelSize: landscapeImage,
      );
      expect(size, const Size(842, 595));
    });

    test('fitImage uses the image dimensions and ignores orientation', () {
      for (final orientation in PageOrientation.values) {
        final size = resolvePageSize(
          sizeOption: PdfPageSizeOption.fitImage,
          orientation: orientation,
          imagePixelSize: landscapeImage,
        );
        expect(size, landscapeImage, reason: 'orientation $orientation should not matter');
      }
    });

    test('fitImage falls back to A4 when the image size is degenerate', () {
      for (final bad in const [Size.zero, Size(0, 100), Size(100, 0)]) {
        final size = resolvePageSize(
          sizeOption: PdfPageSizeOption.fitImage,
          orientation: PageOrientation.portrait,
          imagePixelSize: bad,
        );
        expect(size, const Size(595, 842), reason: 'size $bad should fall back');
      }
    });

    test('every fixed page size has portrait dimensions and fitImage has none', () {
      for (final option in PdfPageSizeOption.values) {
        if (option == PdfPageSizeOption.fitImage) {
          expect(option.portraitSize, isNull);
        } else {
          final portrait = option.portraitSize;
          expect(portrait, isNotNull);
          expect(
            portrait!.height,
            greaterThan(portrait.width),
            reason: '${option.label} portrait should be taller than wide',
          );
        }
      }
    });
  });

  group('PageMargin', () {
    test('none is zero and margins increase monotonically', () {
      expect(PageMargin.none.points, 0);
      expect(PageMargin.small.points, lessThan(PageMargin.medium.points));
      expect(PageMargin.medium.points, lessThan(PageMargin.large.points));
    });
  });
}
