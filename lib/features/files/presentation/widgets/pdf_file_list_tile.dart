import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_time_extension.dart';
import '../../../../core/utils/file_size_extension.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/pdf_file_entry.dart';
import 'pdf_thumbnail.dart';

enum PdfFileAction { share, rename, delete }

/// Row for the File Manager's list view and Home's recent-files list —
/// thumbnail, name, size, last-opened/modified date, favorite toggle, and
/// an overflow menu for share/rename/delete.
class PdfFileListTile extends StatelessWidget {
  const PdfFileListTile({
    required this.entry,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onAction,
    super.key,
  });

  final PdfFileEntry entry;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<PdfFileAction> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final dateLabel = (entry.lastOpened ?? entry.lastModified).relativeLabel;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          PdfThumbnail(
            path: entry.path,
            width: 48,
            height: 60,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.sizeBytes.readableFileSize} • $dateLabel',
                  style: context.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: entry.isFavorite ? scheme.error : scheme.onSurfaceVariant,
            ),
            onPressed: onFavoriteToggle,
          ),
          PopupMenuButton<PdfFileAction>(
            icon: Icon(Icons.more_vert_rounded, color: scheme.onSurfaceVariant),
            onSelected: onAction,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: PdfFileAction.share,
                child: ListTile(
                  leading: Icon(Icons.share_rounded),
                  title: Text('Share'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: PdfFileAction.rename,
                child: ListTile(
                  leading: Icon(Icons.drive_file_rename_outline_rounded),
                  title: Text('Rename'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: PdfFileAction.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline_rounded),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
