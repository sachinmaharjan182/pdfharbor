import 'dart:typed_data';

import '../../../../core/error/result.dart';
import '../entities/saved_signature.dart';

abstract interface class SignatureRepository {
  List<SavedSignature> savedSignatures();

  /// Persists [pngBytes] as a reusable signature.
  Future<Result<SavedSignature>> saveSignature(Uint8List pngBytes);

  Future<Result<void>> deleteSignature(String id);

  /// Stamps a signature onto [sourcePath] and saves the result.
  Future<Result<String>> placeOnPdf({
    required String sourcePath,
    required String signatureImagePath,
    required SignaturePlacement placement,
  });

  /// Renders the target page with the signature applied, for preview.
  Future<Result<Uint8List>> renderPreview({
    required String sourcePath,
    required String signatureImagePath,
    required SignaturePlacement placement,
  });

  Future<Result<int>> pageCount(String sourcePath);
}
