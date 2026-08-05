import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/file_size_extension.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/pdf_file_entry.dart';
import 'pdf_thumbnail.dart';

/// Square-ish card for the File Manager's grid view and Home's horizontal
/// Recent Files rail.
class PdfFileGridCard extends StatelessWidget {
  const PdfFileGridCard({
    required this.entry,
    required this.onTap,
    required this.onFavoriteToggle,
    super.key,
    this.width,
  });

  final PdfFileEntry entry;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PdfThumbnail(
                      path: entry.path,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _FavoriteBadge(isFavorite: entry.isFavorite, onTap: onFavoriteToggle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge,
            ),
            Text(
              entry.sizeBytes.readableFileSize,
              style: context.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
