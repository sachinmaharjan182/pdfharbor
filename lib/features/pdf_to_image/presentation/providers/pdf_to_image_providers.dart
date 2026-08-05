import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/pdf_to_image_repository_impl.dart';
import '../../domain/repositories/pdf_to_image_repository.dart';
import '../../domain/usecases/export_pdf_pages.dart';

final pdfToImageRepositoryProvider = Provider<PdfToImageRepository>((ref) {
  return const PdfToImageRepositoryImpl();
});

final exportPdfPagesUseCaseProvider = Provider(
  (ref) => ExportPdfPages(ref.watch(pdfToImageRepositoryProvider)),
);

final pdfToImagePageCountUseCaseProvider = Provider(
  (ref) => GetPdfToImagePageCount(ref.watch(pdfToImageRepositoryProvider)),
);

final exportPageCountProvider = FutureProvider.autoDispose.family<int, String>((ref, path) async {
  final result = await ref.watch(pdfToImagePageCountUseCaseProvider).call(path);
  return result.fold((count) => count, (failure) => throw failure);
});
