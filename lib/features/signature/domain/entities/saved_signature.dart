import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_signature.freezed.dart';
part 'saved_signature.g.dart';

/// A reusable signature image the user has saved for later placement.
@freezed
class SavedSignature with _$SavedSignature {
  const factory SavedSignature({
    required String id,
    required String imagePath,
    required DateTime createdAt,
  }) = _SavedSignature;

  factory SavedSignature.fromJson(Map<String, dynamic> json) => _$SavedSignatureFromJson(json);
}

/// Where and how large a signature is stamped on a page. Coordinates are
/// fractions of the page (0..1) so a placement survives any page size.
@freezed
class SignaturePlacement with _$SignaturePlacement {
  const factory SignaturePlacement({
    required int pageNumber,
    @Default(0.5) double centerX,
    @Default(0.8) double centerY,

    /// Width as a fraction of the page width.
    @Default(0.3) double widthFraction,
    @Default(0.0) double rotationDegrees,
  }) = _SignaturePlacement;
}
