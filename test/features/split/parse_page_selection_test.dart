import 'package:flutter_test/flutter_test.dart';
import 'package:pdfverse/features/split/domain/usecases/parse_page_selection.dart';

void main() {
  group('parsePageSelection', () {
    test('parses a single page to a zero-based index', () {
      expect(parsePageSelection('1', pageCount: 10), [0]);
      expect(parsePageSelection('7', pageCount: 10), [6]);
    });

    test('parses a comma list', () {
      expect(parsePageSelection('1,3,5', pageCount: 10), [0, 2, 4]);
    });

    test('expands inclusive ranges', () {
      expect(parsePageSelection('2-5', pageCount: 10), [1, 2, 3, 4]);
    });

    test('normalizes reversed ranges', () {
      expect(parsePageSelection('5-2', pageCount: 10), [1, 2, 3, 4]);
    });

    test('combines lists and ranges, sorted and deduplicated', () {
      expect(parsePageSelection('5-8,1,3', pageCount: 10), [0, 2, 4, 5, 6, 7]);
      expect(parsePageSelection('1,1,2-3,3', pageCount: 10), [0, 1, 2]);
    });

    test('ignores whitespace', () {
      expect(parsePageSelection(' 1 , 3 - 4 ', pageCount: 10), [0, 2, 3]);
    });

    test('rejects empty and malformed input', () {
      expect(parsePageSelection('', pageCount: 10), isNull);
      expect(parsePageSelection('   ', pageCount: 10), isNull);
      expect(parsePageSelection('1,,2', pageCount: 10), isNull);
      expect(parsePageSelection('abc', pageCount: 10), isNull);
      expect(parsePageSelection('1-2-3', pageCount: 10), isNull);
      expect(parsePageSelection('1-', pageCount: 10), isNull);
    });

    test('rejects out-of-bounds pages rather than clamping them', () {
      expect(parsePageSelection('0', pageCount: 10), isNull);
      expect(parsePageSelection('11', pageCount: 10), isNull);
      expect(parsePageSelection('5-11', pageCount: 10), isNull);
      expect(parsePageSelection('1,99', pageCount: 10), isNull);
    });

    test('accepts a selection covering the whole document', () {
      expect(parsePageSelection('1-3', pageCount: 3), [0, 1, 2]);
    });
  });
}
