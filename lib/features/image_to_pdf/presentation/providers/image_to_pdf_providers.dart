import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/image_to_pdf_repository_impl.dart';
import '../../domain/entities/image_filter_type.dart';
import '../../domain/entities/image_page_item.dart';
import '../../domain/entities/page_layout.dart';
import '../../domain/repositories/image_to_pdf_repository.dart';
import '../../domain/usecases/build_pdf_from_images.dart';

final imageToPdfRepositoryProvider = Provider<ImageToPdfRepository>((ref) {
  return const ImageToPdfRepositoryImpl();
});

final buildPdfFromImagesUseCaseProvider = Provider(
  (ref) => BuildPdfFromImages(ref.watch(imageToPdfRepositoryProvider)),
);

/// The ordered list of images that will become pages.
class ImageSelectionNotifier extends Notifier<List<ImagePageItem>> {
  static const _uuid = Uuid();

  @override
  List<ImagePageItem> build() => const [];

  void addPaths(Iterable<String> paths) {
    final additions = [
      for (final path in paths) ImagePageItem(id: _uuid.v4(), path: path),
    ];
    if (additions.isNotEmpty) state = [...state, ...additions];
  }

  void removeById(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void reorder(int oldIndex, int newIndex) {
    final next = [...state];
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = next.removeAt(oldIndex);
    next.insert(target, item);
    state = next;
  }

  void rotate(String id, {int byDegrees = 90}) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(rotationDegrees: item.rotationDegrees + byDegrees)
        else
          item,
    ];
  }

  void setFilter(String id, ImageFilterType filter) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(filter: filter) else item,
    ];
  }

  /// Applies one filter to every page — the common case when all images
  /// come from the same source.
  void setFilterForAll(ImageFilterType filter) {
    state = [for (final item in state) item.copyWith(filter: filter)];
  }

  void replacePath(String id, String newPath) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(path: newPath) else item,
    ];
  }

  void clear() => state = const [];
}

final imageSelectionProvider =
    NotifierProvider<ImageSelectionNotifier, List<ImagePageItem>>(ImageSelectionNotifier.new);

final pageSizeOptionProvider = StateProvider<PdfPageSizeOption>((ref) => PdfPageSizeOption.a4);
final pageOrientationProvider = StateProvider<PageOrientation>((ref) => PageOrientation.portrait);
final pageMarginProvider = StateProvider<PageMargin>((ref) => PageMargin.small);
