import '../../../../core/error/result.dart';
import '../entities/image_page_item.dart';
import '../entities/page_layout.dart';

abstract interface class ImageToPdfRepository {
  /// Builds a PDF from [items] in order, applying each item's rotation and
  /// filter, and laying pages out per the supplied options.
  Future<Result<String>> buildPdf({
    required List<ImagePageItem> items,
    required PdfPageSizeOption pageSize,
    required PageOrientation orientation,
    required PageMargin margin,
    required String outputName,
    void Function(int done, int total)? onProgress,
  });
}
