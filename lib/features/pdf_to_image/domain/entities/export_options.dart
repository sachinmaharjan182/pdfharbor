enum ImageExportFormat {
  jpeg,
  png;

  String get label => switch (this) {
        ImageExportFormat.jpeg => 'JPEG',
        ImageExportFormat.png => 'PNG',
      };

  String get extension => switch (this) {
        ImageExportFormat.jpeg => 'jpg',
        ImageExportFormat.png => 'png',
      };

  String get description => switch (this) {
        ImageExportFormat.jpeg => 'Smaller files, best for photos',
        ImageExportFormat.png => 'Lossless, best for text and diagrams',
      };
}

enum ImageExportQuality {
  low,
  medium,
  high;

  String get label => switch (this) {
        ImageExportQuality.low => 'Low',
        ImageExportQuality.medium => 'Medium',
        ImageExportQuality.high => 'High',
      };

  /// Multiplier on each page's natural pixel size.
  double get renderScale => switch (this) {
        ImageExportQuality.low => 1,
        ImageExportQuality.medium => 2,
        ImageExportQuality.high => 3,
      };

  /// JPEG encoder quality; ignored for PNG, which is lossless.
  int get jpegQuality => switch (this) {
        ImageExportQuality.low => 60,
        ImageExportQuality.medium => 80,
        ImageExportQuality.high => 95,
      };
}
