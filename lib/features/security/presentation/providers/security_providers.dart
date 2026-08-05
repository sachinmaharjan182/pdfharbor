import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/security_repository_impl.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/usecases/manage_password.dart';

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return const SecurityRepositoryImpl();
});

final protectPdfUseCaseProvider = Provider(
  (ref) => ProtectPdf(ref.watch(securityRepositoryProvider)),
);
final removePdfPasswordUseCaseProvider = Provider(
  (ref) => RemovePdfPassword(ref.watch(securityRepositoryProvider)),
);
final checkPdfEncryptedUseCaseProvider = Provider(
  (ref) => CheckPdfEncrypted(ref.watch(securityRepositoryProvider)),
);

final isPdfEncryptedProvider = FutureProvider.autoDispose.family<bool, String>((ref, path) async {
  final result = await ref.watch(checkPdfEncryptedUseCaseProvider).call(path);
  return result.fold((encrypted) => encrypted, (failure) => throw failure);
});
