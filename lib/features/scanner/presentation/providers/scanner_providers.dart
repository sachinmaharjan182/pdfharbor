import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../image_to_pdf/domain/entities/image_filter_type.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../domain/usecases/scan_document.dart';

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return const ScannerRepositoryImpl();
});

final scanPagesUseCaseProvider = Provider(
  (ref) => ScanPages(ref.watch(scannerRepositoryProvider)),
);
final saveScanAsPdfUseCaseProvider = Provider(
  (ref) => SaveScanAsPdf(ref.watch(scannerRepositoryProvider)),
);

/// Captured page image paths, in output order.
class ScannedPagesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void addAll(Iterable<String> paths) => state = [...state, ...paths];

  void removeAt(int index) => state = [...state]..removeAt(index);

  void reorder(int oldIndex, int newIndex) {
    final next = [...state];
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    next.insert(target, next.removeAt(oldIndex));
    state = next;
  }

  void clear() => state = const [];
}

final scannedPagesProvider =
    NotifierProvider<ScannedPagesNotifier, List<String>>(ScannedPagesNotifier.new);

final scanFilterProvider = StateProvider<ImageFilterType>((ref) => ImageFilterType.original);

/// Per-page rotation in degrees, keyed by image path.
final scanRotationsProvider = StateProvider<Map<String, int>>((ref) => const {});
