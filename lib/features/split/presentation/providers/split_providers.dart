import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/split_repository_impl.dart';
import '../../domain/repositories/split_repository.dart';
import '../../domain/usecases/split_pdf.dart';

final splitRepositoryProvider = Provider<SplitRepository>((ref) {
  return const SplitRepositoryImpl();
});

final splitPdfUseCaseProvider = Provider((ref) => SplitPdf(ref.watch(splitRepositoryProvider)));

final getPdfPageCountUseCaseProvider = Provider(
  (ref) => GetPdfPageCount(ref.watch(splitRepositoryProvider)),
);

/// Page count for the document being split, keyed by path.
final pdfPageCountProvider = FutureProvider.autoDispose.family<int, String>((ref, path) async {
  final result = await ref.watch(getPdfPageCountUseCaseProvider).call(path);
  return result.fold((count) => count, (failure) => throw failure);
});
