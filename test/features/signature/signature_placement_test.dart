import 'package:flutter_test/flutter_test.dart';
import 'package:pdfharbor/features/signature/domain/entities/saved_signature.dart';

void main() {
  group('SignaturePlacement', () {
    test('defaults to the lower-centre of page 1, unrotated', () {
      const placement = SignaturePlacement(pageNumber: 1);
      expect(placement.pageNumber, 1);
      expect(placement.centerX, 0.5);
      expect(placement.centerY, greaterThan(0.5), reason: 'should sit low on the page');
      expect(placement.rotationDegrees, 0);
    });

    test('fractional coordinates stay within the page', () {
      const placement = SignaturePlacement(pageNumber: 2);
      expect(placement.centerX, inInclusiveRange(0, 1));
      expect(placement.centerY, inInclusiveRange(0, 1));
      expect(placement.widthFraction, inExclusiveRange(0, 1));
    });

    test('copyWith changes only the named field', () {
      const placement = SignaturePlacement(pageNumber: 1, widthFraction: 0.4);
      final moved = placement.copyWith(pageNumber: 5);
      expect(moved.pageNumber, 5);
      expect(moved.widthFraction, 0.4);
      expect(moved.centerX, placement.centerX);
    });
  });

  group('SavedSignature', () {
    test('round-trips through JSON for Hive persistence', () {
      final signature = SavedSignature(
        id: 'abc',
        imagePath: '/sig/abc.png',
        createdAt: DateTime.utc(2026, 8, 5, 12, 30),
      );
      final restored = SavedSignature.fromJson(signature.toJson());
      expect(restored, signature);
    });
  });
}
