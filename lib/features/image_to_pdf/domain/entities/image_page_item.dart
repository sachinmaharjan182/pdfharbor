import 'package:freezed_annotation/freezed_annotation.dart';

import 'image_filter_type.dart';

part 'image_page_item.freezed.dart';

/// One picked image plus its per-page edits. Immutable so reordering and
/// editing produce new list state rather than mutating in place.
@freezed
class ImagePageItem with _$ImagePageItem {
  const factory ImagePageItem({
    required String id,
    required String path,
    @Default(0) int rotationDegrees,
    @Default(ImageFilterType.original) ImageFilterType filter,
  }) = _ImagePageItem;

  const ImagePageItem._();

  /// Rotation normalized to 0/90/180/270.
  int get normalizedRotation => ((rotationDegrees % 360) + 360) % 360;
}
