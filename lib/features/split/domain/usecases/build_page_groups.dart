import '../entities/split_mode.dart';
import 'parse_page_selection.dart';

/// Turns a [SplitMode] plus its inputs into the page groups the repository
/// writes as separate files. Zero-based indices throughout.
///
/// Returns `null` when the mode's input is invalid (bad custom selection,
/// out-of-bounds range), so the UI can show a validation error instead of
/// producing an unexpected file.
List<List<int>>? buildPageGroups({
  required SplitMode mode,
  required int pageCount,
  int? rangeStart,
  int? rangeEnd,
  String customSelection = '',
}) {
  if (pageCount <= 0) return null;

  switch (mode) {
    case SplitMode.everyPage:
      return [for (var i = 0; i < pageCount; i++) [i]];

    case SplitMode.pageRange:
      final start = rangeStart;
      final end = rangeEnd;
      if (start == null || end == null) return null;
      if (start < 1 || end < 1 || start > pageCount || end > pageCount) return null;
      final from = start <= end ? start : end;
      final to = start <= end ? end : start;
      return [
        [for (var page = from; page <= to; page++) page - 1],
      ];

    case SplitMode.oddPages:
      final pages = [for (var i = 0; i < pageCount; i += 2) i];
      return pages.isEmpty ? null : [pages];

    case SplitMode.evenPages:
      final pages = [for (var i = 1; i < pageCount; i += 2) i];
      return pages.isEmpty ? null : [pages];

    case SplitMode.customPages:
      final pages = parsePageSelection(customSelection, pageCount: pageCount);
      return pages == null ? null : [pages];
  }
}
