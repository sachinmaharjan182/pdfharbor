import 'dart:typed_data';

import '../../../../core/error/result.dart';
import '../entities/saved_signature.dart';
import '../repositories/signature_repository.dart';

class GetSavedSignatures {
  const GetSavedSignatures(this._repository);

  final SignatureRepository _repository;

  List<SavedSignature> call() => _repository.savedSignatures();
}

class SaveSignature {
  const SaveSignature(this._repository);

  final SignatureRepository _repository;

  Future<Result<SavedSignature>> call(Uint8List pngBytes) => _repository.saveSignature(pngBytes);
}

class DeleteSignature {
  const DeleteSignature(this._repository);

  final SignatureRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteSignature(id);
}

class PlaceSignatureOnPdf {
  const PlaceSignatureOnPdf(this._repository);

  final SignatureRepository _repository;

  Future<Result<String>> call({
    required String sourcePath,
    required String signatureImagePath,
    required SignaturePlacement placement,
  }) {
    return _repository.placeOnPdf(
      sourcePath: sourcePath,
      signatureImagePath: signatureImagePath,
      placement: placement,
    );
  }
}

class RenderSignaturePreview {
  const RenderSignaturePreview(this._repository);

  final SignatureRepository _repository;

  Future<Result<Uint8List>> call({
    required String sourcePath,
    required String signatureImagePath,
    required SignaturePlacement placement,
  }) {
    return _repository.renderPreview(
      sourcePath: sourcePath,
      signatureImagePath: signatureImagePath,
      placement: placement,
    );
  }
}

class GetSignaturePageCount {
  const GetSignaturePageCount(this._repository);

  final SignatureRepository _repository;

  Future<Result<int>> call(String path) => _repository.pageCount(path);
}
