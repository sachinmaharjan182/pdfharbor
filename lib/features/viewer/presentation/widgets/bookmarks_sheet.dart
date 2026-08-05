import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/viewer_providers.dart';

/// Lists the user's bookmarks for the open document and jumps to one on tap.
class BookmarksSheet extends ConsumerWidget {
  const BookmarksSheet({required this.documentPath, required this.onJumpToPage, super.key});

  final String documentPath;
  final ValueChanged<int> onJumpToPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider(documentPath));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        if (bookmarks.isEmpty) {
          return const EmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'No bookmarks yet',
            message: 'Tap the bookmark icon while reading to save a page.',
          );
        }
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          itemCount: bookmarks.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, 0, AppSpacing.md),
                child: Text('Bookmarks', style: context.textTheme.titleLarge),
              );
            }
            final bookmark = bookmarks[index - 1];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: context.colorScheme.secondaryContainer,
                child: Text(
                  '${bookmark.pageNumber}',
                  style: context.textTheme.labelLarge
                      ?.copyWith(color: context.colorScheme.onSecondaryContainer),
                ),
              ),
              title: Text(bookmark.label),
              subtitle: Text('Page ${bookmark.pageNumber}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () =>
                    ref.read(bookmarksProvider(documentPath).notifier).remove(bookmark.id),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onJumpToPage(bookmark.pageNumber);
              },
            );
          },
        );
      },
    );
  }
}
