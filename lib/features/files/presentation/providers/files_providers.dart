import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/hive/hive_service.dart';
import '../../data/datasources/local_pdf_datasource.dart';
import '../../data/repositories/files_repository_impl.dart';
import '../../domain/entities/pdf_file_entry.dart';
import '../../domain/repositories/files_repository.dart';
import '../../domain/usecases/delete_pdf_file.dart';
import '../../domain/usecases/get_favorite_files.dart';
import '../../domain/usecases/get_recent_files.dart';
import '../../domain/usecases/record_opened.dart';
import '../../domain/usecases/rename_pdf_file.dart';
import '../../domain/usecases/scan_device_for_pdfs.dart';
import '../../domain/usecases/toggle_favorite.dart';

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepositoryImpl(const LocalPdfDatasource(), HiveService.recentFilesBox);
});

final scanDeviceForPdfsUseCaseProvider = Provider(
  (ref) => ScanDeviceForPdfs(ref.watch(filesRepositoryProvider)),
);
final getRecentFilesUseCaseProvider = Provider(
  (ref) => GetRecentFiles(ref.watch(filesRepositoryProvider)),
);
final getFavoriteFilesUseCaseProvider = Provider(
  (ref) => GetFavoriteFiles(ref.watch(filesRepositoryProvider)),
);
final toggleFavoriteUseCaseProvider = Provider(
  (ref) => ToggleFavorite(ref.watch(filesRepositoryProvider)),
);
final deletePdfFileUseCaseProvider = Provider(
  (ref) => DeletePdfFile(ref.watch(filesRepositoryProvider)),
);
final renamePdfFileUseCaseProvider = Provider(
  (ref) => RenamePdfFile(ref.watch(filesRepositoryProvider)),
);
final recordOpenedUseCaseProvider = Provider(
  (ref) => RecordOpened(ref.watch(filesRepositoryProvider)),
);

/// All PDFs found on device storage, sorted by last-modified.
final allPdfFilesProvider = FutureProvider.autoDispose<List<PdfFileEntry>>((ref) async {
  final result = await ref.watch(scanDeviceForPdfsUseCaseProvider).call();
  return result.fold((data) => data, (failure) => throw failure);
});

/// Files with a recorded `lastOpened` timestamp, most recent first.
final recentFilesProvider = FutureProvider.autoDispose<List<PdfFileEntry>>((ref) async {
  final result = await ref.watch(getRecentFilesUseCaseProvider).call();
  return result.fold((data) => data, (failure) => throw failure);
});

final favoriteFilesProvider = FutureProvider.autoDispose<List<PdfFileEntry>>((ref) async {
  final result = await ref.watch(getFavoriteFilesUseCaseProvider).call();
  return result.fold((data) => data, (failure) => throw failure);
});

/// Invalidates every provider above after a mutation (favorite toggle,
/// delete, rename, open) so all screens observing file lists refresh.
void invalidateFilesProviders(WidgetRef ref) {
  ref.invalidate(allPdfFilesProvider);
  ref.invalidate(recentFilesProvider);
  ref.invalidate(favoriteFilesProvider);
}
