import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../features/image_to_pdf/domain/entities/image_filter_type.dart';

/// Arguments for [ImageProcessor.process], shaped to cross an isolate
/// boundary as one value.
class ImageProcessRequest {
  const ImageProcessRequest({
    required this.bytes,
    required this.filter,
    this.rotationDegrees = 0,
    this.jpegQuality = 88,
    this.maxDimension = 2400,
  });

  final Uint8List bytes;
  final ImageFilterType filter;

  /// Clockwise rotation applied before filtering, in degrees.
  final int rotationDegrees;

  final int jpegQuality;

  /// Longest-edge cap. Full-resolution phone photos would otherwise
  /// produce enormous PDFs with no visible benefit.
  final int maxDimension;
}

/// Decoding, rotating, filtering, and re-encoding images off the UI thread.
/// Shared by Image→PDF and the document scanner.
abstract final class ImageProcessor {
  static Future<Uint8List> process(ImageProcessRequest request) {
    return compute(_processIsolate, request);
  }

  /// Decodes just far enough to report pixel dimensions, used to size
  /// "fit to image" pages.
  static Future<({int width, int height})?> dimensions(Uint8List bytes) {
    return compute(_dimensionsIsolate, bytes);
  }
}

Uint8List _processIsolate(ImageProcessRequest request) {
  final decoded = img.decodeImage(request.bytes);
  // Nothing sensible to do with an undecodable image; hand the original
  // back so the caller still produces a page rather than failing outright.
  if (decoded == null) return request.bytes;

  var image = decoded;

  if (request.rotationDegrees % 360 != 0) {
    image = img.copyRotate(image, angle: request.rotationDegrees);
  }

  final longestEdge = image.width > image.height ? image.width : image.height;
  if (longestEdge > request.maxDimension) {
    final scale = request.maxDimension / longestEdge;
    image = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
  }

  image = switch (request.filter) {
    ImageFilterType.original => image,
    ImageFilterType.grayscale => img.grayscale(image),
    // Lift contrast and saturation so photographed pages read as clean
    // documents rather than dim photos.
    ImageFilterType.magicColor => img.adjustColor(
        img.contrast(image, contrast: 135),
        saturation: 1.25,
        brightness: 1.06,
      ),
    ImageFilterType.blackWhite => img.luminanceThreshold(
        img.grayscale(image),
        threshold: 0.55,
      ),
  };

  return img.encodeJpg(image, quality: request.jpegQuality);
}

({int width, int height})? _dimensionsIsolate(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return (width: decoded.width, height: decoded.height);
}
