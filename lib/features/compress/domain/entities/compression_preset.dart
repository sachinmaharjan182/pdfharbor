/// Compression strength. Each preset trades page resolution and JPEG
/// quality against output size.
///
/// Compression works by rasterizing pages — the resulting PDF is images,
/// so text is no longer selectable or searchable. The UI states this
/// plainly rather than surprising the user after the fact.
enum CompressionPreset {
  low,
  medium,
  high;

  String get label => switch (this) {
        CompressionPreset.low => 'Low',
        CompressionPreset.medium => 'Medium',
        CompressionPreset.high => 'High',
      };

  String get description => switch (this) {
        CompressionPreset.low => 'Best quality, smallest size reduction',
        CompressionPreset.medium => 'Balanced quality and size',
        CompressionPreset.high => 'Smallest file, lowest quality',
      };

  String get estimatedQuality => switch (this) {
        CompressionPreset.low => 'Near-original',
        CompressionPreset.medium => 'Good',
        CompressionPreset.high => 'Reduced',
      };

  /// Multiplier applied to each page's natural pixel size when rasterizing.
  double get renderScale => switch (this) {
        CompressionPreset.low => 1.6,
        CompressionPreset.medium => 1.2,
        CompressionPreset.high => 0.9,
      };

  /// JPEG encoder quality (0-100).
  int get jpegQuality => switch (this) {
        CompressionPreset.low => 85,
        CompressionPreset.medium => 70,
        CompressionPreset.high => 50,
      };
}
