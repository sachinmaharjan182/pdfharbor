import 'package:flutter_test/flutter_test.dart';
import 'package:pdfharbor/features/split/domain/entities/split_mode.dart';
import 'package:pdfharbor/features/split/domain/usecases/build_page_groups.dart';

void main() {
  group('buildPageGroups', () {
    test('everyPage produces one single-page group per page', () {
      final groups = buildPageGroups(mode: SplitMode.everyPage, pageCount: 3);
      expect(groups, [
        [0],
        [1],
        [2],
      ]);
    });

    test('oddPages collects pages 1, 3, 5 as zero-based indices', () {
      final groups = buildPageGroups(mode: SplitMode.oddPages, pageCount: 5);
      expect(groups, [
        [0, 2, 4],
      ]);
    });

    test('evenPages collects pages 2, 4 as zero-based indices', () {
      final groups = buildPageGroups(mode: SplitMode.evenPages, pageCount: 5);
      expect(groups, [
        [1, 3],
      ]);
    });

    test('evenPages is invalid for a single-page document', () {
      expect(buildPageGroups(mode: SplitMode.evenPages, pageCount: 1), isNull);
    });

    test('pageRange yields one inclusive group', () {
      final groups = buildPageGroups(
        mode: SplitMode.pageRange,
        pageCount: 10,
        rangeStart: 2,
        rangeEnd: 4,
      );
      expect(groups, [
        [1, 2, 3],
      ]);
    });

    test('pageRange normalizes a reversed range', () {
      final groups = buildPageGroups(
        mode: SplitMode.pageRange,
        pageCount: 10,
        rangeStart: 4,
        rangeEnd: 2,
      );
      expect(groups, [
        [1, 2, 3],
      ]);
    });

    test('pageRange rejects out-of-bounds and missing bounds', () {
      expect(
        buildPageGroups(mode: SplitMode.pageRange, pageCount: 5, rangeStart: 1, rangeEnd: 9),
        isNull,
      );
      expect(
        buildPageGroups(mode: SplitMode.pageRange, pageCount: 5, rangeStart: 0, rangeEnd: 3),
        isNull,
      );
      expect(buildPageGroups(mode: SplitMode.pageRange, pageCount: 5), isNull);
    });

    test('customPages delegates to the selection parser', () {
      final groups = buildPageGroups(
        mode: SplitMode.customPages,
        pageCount: 10,
        customSelection: '1,4-6',
      );
      expect(groups, [
        [0, 3, 4, 5],
      ]);
    });

    test('customPages is invalid when the selection is malformed', () {
      expect(
        buildPageGroups(mode: SplitMode.customPages, pageCount: 10, customSelection: 'oops'),
        isNull,
      );
    });

    test('any mode is invalid for an empty document', () {
      for (final mode in SplitMode.values) {
        expect(
          buildPageGroups(mode: mode, pageCount: 0, rangeStart: 1, rangeEnd: 1),
          isNull,
          reason: '$mode should be invalid with no pages',
        );
      }
    });
  });
}
