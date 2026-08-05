import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/compress_repository_impl.dart';
import '../../domain/repositories/compress_repository.dart';
import '../../domain/usecases/compress_pdf.dart';

final compressRepositoryProvider = Provider<CompressRepository>((ref) {
  return const CompressRepositoryImpl();
});

final compressPdfUseCaseProvider = Provider(
  (ref) => CompressPdf(ref.watch(compressRepositoryProvider)),
);
