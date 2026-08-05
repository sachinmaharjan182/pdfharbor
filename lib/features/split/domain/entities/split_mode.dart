/// How a document should be divided.
enum SplitMode {
  /// One output file per page.
  everyPage,

  /// A single output containing a contiguous range.
  pageRange,

  /// One output with all odd-numbered pages.
  oddPages,

  /// One output with all even-numbered pages.
  evenPages,

  /// A single output containing an arbitrary page selection, e.g. `1,3,5-8`.
  customPages;

  String get label => switch (this) {
        SplitMode.everyPage => 'Every page',
        SplitMode.pageRange => 'Page range',
        SplitMode.oddPages => 'Odd pages',
        SplitMode.evenPages => 'Even pages',
        SplitMode.customPages => 'Custom pages',
      };

  String get description => switch (this) {
        SplitMode.everyPage => 'Creates a separate PDF for each page',
        SplitMode.pageRange => 'Extracts a continuous range into one PDF',
        SplitMode.oddPages => 'Collects pages 1, 3, 5… into one PDF',
        SplitMode.evenPages => 'Collects pages 2, 4, 6… into one PDF',
        SplitMode.customPages => 'Pick exact pages, e.g. 1,3,5-8',
      };
}
