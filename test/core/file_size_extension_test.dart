import 'package:flutter_test/flutter_test.dart';
import 'package:pdfverse/core/utils/file_size_extension.dart';

void main() {
  group('readableFileSize', () {
    test('formats zero and negative sizes as 0 B', () {
      expect(0.readableFileSize, '0 B');
      expect((-1).readableFileSize, '0 B');
    });

    test('formats bytes without decimals', () {
      expect(512.readableFileSize, '512 B');
      expect(1023.readableFileSize, '1023 B');
    });

    test('promotes to the next unit at 1024', () {
      expect(1024.readableFileSize, '1.0 KB');
      expect((1024 * 1024).readableFileSize, '1.0 MB');
      expect((1024 * 1024 * 1024).readableFileSize, '1.0 GB');
    });

    test('keeps one decimal place for non-byte units', () {
      expect((1536).readableFileSize, '1.5 KB');
    });

    test('caps at GB rather than overflowing the unit list', () {
      expect((1024 * 1024 * 1024 * 5).readableFileSize, '5.0 GB');
    });
  });
}
