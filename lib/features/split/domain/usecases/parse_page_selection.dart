/// Parses a human page selection like `1,3,5-8` into zero-based page
/// indices.
///
/// Rules: 1-based input, whitespace ignored, ranges inclusive, reversed
/// ranges (`8-5`) accepted and normalized, duplicates removed, result
/// sorted ascending. Any page outside `1..pageCount` makes the whole
/// selection invalid — silently dropping it would produce a PDF the user
/// didn't ask for.
///
/// Returns `null` when the input is malformed or out of bounds.
List<int>? parsePageSelection(String input, {required int pageCount}) {
  final cleaned = input.replaceAll(' ', '');
  if (cleaned.isEmpty) return null;

  final pages = <int>{};
  for (final part in cleaned.split(',')) {
    if (part.isEmpty) return null;

    if (part.contains('-')) {
      final bounds = part.split('-');
      if (bounds.length != 2) return null;
      final start = int.tryParse(bounds[0]);
      final end = int.tryParse(bounds[1]);
      if (start == null || end == null) return null;
      if (!_inRange(start, pageCount) || !_inRange(end, pageCount)) return null;
      final from = start <= end ? start : end;
      final to = start <= end ? end : start;
      for (var page = from; page <= to; page++) {
        pages.add(page - 1);
      }
    } else {
      final page = int.tryParse(part);
      if (page == null || !_inRange(page, pageCount)) return null;
      pages.add(page - 1);
    }
  }

  if (pages.isEmpty) return null;
  return pages.toList()..sort();
}

bool _inRange(int page, int pageCount) => page >= 1 && page <= pageCount;
