import 'dart:ui';

/// Output page size, in PDF points (1 pt = 1/72 inch).
enum PdfPageSizeOption {
  a4,
  letter,
  legal,
  a3,
  a5,

  /// Each page matches its image's own aspect ratio — no letterboxing.
  fitImage;

  String get label => switch (this) {
        PdfPageSizeOption.a4 => 'A4',
        PdfPageSizeOption.letter => 'Letter',
        PdfPageSizeOption.legal => 'Legal',
        PdfPageSizeOption.a3 => 'A3',
        PdfPageSizeOption.a5 => 'A5',
        PdfPageSizeOption.fitImage => 'Fit to image',
      };

  /// Portrait dimensions; [PageOrientation] swaps them when needed.
  /// Null for [fitImage], whose size depends on the image itself.
  Size? get portraitSize => switch (this) {
        PdfPageSizeOption.a4 => const Size(595, 842),
        PdfPageSizeOption.letter => const Size(612, 792),
        PdfPageSizeOption.legal => const Size(612, 1008),
        PdfPageSizeOption.a3 => const Size(842, 1191),
        PdfPageSizeOption.a5 => const Size(420, 595),
        PdfPageSizeOption.fitImage => null,
      };
}

enum PageOrientation {
  portrait,
  landscape;

  String get label => switch (this) {
        PageOrientation.portrait => 'Portrait',
        PageOrientation.landscape => 'Landscape',
      };
}

/// Margin around the image on each page.
enum PageMargin {
  none,
  small,
  medium,
  large;

  String get label => switch (this) {
        PageMargin.none => 'None',
        PageMargin.small => 'Small',
        PageMargin.medium => 'Medium',
        PageMargin.large => 'Large',
      };

  /// Margin in PDF points.
  double get points => switch (this) {
        PageMargin.none => 0,
        PageMargin.small => 18,
        PageMargin.medium => 36,
        PageMargin.large => 54,
      };
}

/// Resolves the page size for one image given the chosen options.
///
/// [fitImage] derives the page from the image's own pixel dimensions so
/// nothing is letterboxed; fixed sizes honour [orientation].
Size resolvePageSize({
  required PdfPageSizeOption sizeOption,
  required PageOrientation orientation,
  required Size imagePixelSize,
}) {
  final portrait = sizeOption.portraitSize;
  if (portrait == null) {
    // Guard against a zero-dimension decode falling through as an invalid page.
    if (imagePixelSize.width <= 0 || imagePixelSize.height <= 0) {
      return const Size(595, 842);
    }
    return imagePixelSize;
  }
  return orientation == PageOrientation.portrait
      ? portrait
      : Size(portrait.height, portrait.width);
}
