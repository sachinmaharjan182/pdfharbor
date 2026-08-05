import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/hive/hive_service.dart';
import '../../data/repositories/signature_repository_impl.dart';
import '../../domain/entities/saved_signature.dart';
import '../../domain/repositories/signature_repository.dart';
import '../../domain/usecases/manage_signatures.dart';

final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  return SignatureRepositoryImpl(HiveService.signaturesBox);
});

final getSavedSignaturesUseCaseProvider = Provider(
  (ref) => GetSavedSignatures(ref.watch(signatureRepositoryProvider)),
);
final saveSignatureUseCaseProvider = Provider(
  (ref) => SaveSignature(ref.watch(signatureRepositoryProvider)),
);
final deleteSignatureUseCaseProvider = Provider(
  (ref) => DeleteSignature(ref.watch(signatureRepositoryProvider)),
);
final placeSignatureUseCaseProvider = Provider(
  (ref) => PlaceSignatureOnPdf(ref.watch(signatureRepositoryProvider)),
);
final renderSignaturePreviewUseCaseProvider = Provider(
  (ref) => RenderSignaturePreview(ref.watch(signatureRepositoryProvider)),
);
final signaturePageCountUseCaseProvider = Provider(
  (ref) => GetSignaturePageCount(ref.watch(signatureRepositoryProvider)),
);

class SavedSignaturesNotifier extends Notifier<List<SavedSignature>> {
  @override
  List<SavedSignature> build() => ref.read(getSavedSignaturesUseCaseProvider).call();

  Future<SavedSignature?> save(Uint8List pngBytes) async {
    final result = await ref.read(saveSignatureUseCaseProvider).call(pngBytes);
    return result.fold(
      (signature) {
        _refresh();
        return signature;
      },
      (_) => null,
    );
  }

  Future<void> delete(String id) async {
    final result = await ref.read(deleteSignatureUseCaseProvider).call(id);
    result.fold((_) => _refresh(), (_) {});
  }

  void _refresh() => state = ref.read(getSavedSignaturesUseCaseProvider).call();
}

final savedSignaturesProvider =
    NotifierProvider<SavedSignaturesNotifier, List<SavedSignature>>(SavedSignaturesNotifier.new);

final signaturePageCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, path) async {
  final result = await ref.watch(signaturePageCountUseCaseProvider).call(path);
  return result.fold((count) => count, (failure) => throw failure);
});
