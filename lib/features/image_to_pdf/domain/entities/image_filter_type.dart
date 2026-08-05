/// Post-processing applied to each image before it becomes a PDF page.
/// Shared with the document scanner, which offers the same treatments.
enum ImageFilterType {
  original,
  grayscale,

  /// High-contrast "magic color" clean-up for photographed documents.
  magicColor,

  /// Hard black-and-white threshold, best for text scans.
  blackWhite;

  String get label => switch (this) {
        ImageFilterType.original => 'Original',
        ImageFilterType.grayscale => 'Grayscale',
        ImageFilterType.magicColor => 'Magic color',
        ImageFilterType.blackWhite => 'Black & white',
      };
}
