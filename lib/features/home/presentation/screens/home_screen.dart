import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_time_extension.dart';
import '../../../../core/utils/file_size_extension.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../../shared/theme/app_palette.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../files/domain/entities/pdf_file_entry.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../files/presentation/providers/files_ui_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crossAxisCount = context.isTablet ? 6 : 4;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(child: _TopBar()),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(child: _Greeting()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(
                child: _SearchBar(onTap: () => _goToFilesTab(context, ref, FileFilter.all)),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(child: _ContinueReadingCard()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Recent Files',
                  actionLabel: 'See all',
                  onActionTap: () => _goToFilesTab(context, ref, FileFilter.recent),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: _RecentFilesRail(),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(child: SectionHeader(title: 'Quick Actions')),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final action = _quickActions[index];
                    return ActionCard(
                      icon: action.icon,
                      label: action.label,
                      accent: action.accent,
                      onTap: () => action.onTap(context),
                    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.08, end: 0);
                  },
                  childCount: _quickActions.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToFilesTab(BuildContext context, WidgetRef ref, FileFilter filter) {
    ref.read(fileFilterProvider.notifier).state = filter;
    context.go('/files');
  }

  static Future<void> _openPdfFromPicker(BuildContext context) async {
    final path = await PdfPicker.pickSingle();
    if (path == null || !context.mounted) return;
    await context.push(AppRoutes.viewerFor(path));
  }

  static final List<_QuickAction> _quickActions = [
    const _QuickAction(
      Icons.picture_as_pdf_rounded,
      'Open PDF',
      AppAccents.blue,
      _openPdfFromPicker,
    ),
    _QuickAction(
      Icons.document_scanner_rounded,
      'Scan Document',
      AppAccents.green,
      (c) => c.push(AppRoutes.scanner),
    ),
    _QuickAction(
      Icons.image_rounded,
      'Images to PDF',
      AppAccents.violet,
      (c) => c.push(AppRoutes.imageToPdf),
    ),
    _QuickAction(
      Icons.call_merge_rounded,
      'Merge PDF',
      AppAccents.orange,
      (c) => c.push(AppRoutes.merge),
    ),
    _QuickAction(
      Icons.call_split_rounded,
      'Split PDF',
      AppAccents.red,
      (c) => c.push(AppRoutes.split),
    ),
    _QuickAction(
      Icons.compress_rounded,
      'Compress PDF',
      AppAccents.amber,
      (c) => c.push(AppRoutes.compress),
    ),
    _QuickAction(
      Icons.water_drop_rounded,
      'Watermark',
      AppAccents.cyan,
      (c) => c.push(AppRoutes.watermark),
    ),
    _QuickAction(
      Icons.draw_rounded,
      'Signature',
      AppAccents.pink,
      (c) => c.push(AppRoutes.signature),
    ),
  ];
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.accent, this.onTap);

  final IconData icon;
  final String label;
  final Color accent;
  final void Function(BuildContext context) onTap;
}

/// App mark on the left, quick access to Settings on the right.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // The launcher icon artwork itself, so the in-app mark and the icon
        // on the home screen are the same thing.
        Image.asset(
          'images/app_logo.png',
          width: 44,
          height: 44,
          filterQuality: FilterQuality.medium,
        ),
        const Spacer(),
        _CircleIconButton(
          icon: Icons.settings_outlined,
          onTap: () => context.go(AppRoutes.settings),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 22, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Just the greeting — the app's name belongs to the mark above, not
        // to the person being greeted.
        Text(
          'PDFHarbor',
          style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Everything for your documents.',
          style: context.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 22, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Search files, tools…',
              style: context.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Icon(Icons.tune_rounded, size: 20, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// Picks up where the reader left off: the most recently opened document,
/// on the design's dark "continue" panel.
class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentFilesProvider).valueOrNull;
    if (recent == null || recent.isEmpty) return const SizedBox.shrink();
    final entry = recent.first;

    final scheme = context.colorScheme;
    final opened = entry.lastOpened ?? entry.lastModified;

    return AppCard(
      color: scheme.inverseSurface,
      borderColor: scheme.inverseSurface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: () => context.push(AppRoutes.viewerFor(entry.path)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Continue reading',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.onInverseSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(color: scheme.onInverseSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${entry.sizeBytes.readableFileSize} • ${opened.relativeLabel}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onInverseSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(
            width: 44,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.onInverseSurface.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 22,
              color: scheme.onInverseSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentFilesRail extends ConsumerWidget {
  const _RecentFilesRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecent = ref.watch(recentFilesProvider);

    // The rail only claims full card height when it has cards to show —
    // an empty state at full height left a dead gap above Quick Actions.
    final isEmpty = asyncRecent.valueOrNull?.isEmpty ?? false;
    final hasError = asyncRecent.hasError;

    return SizedBox(
      height: isEmpty || hasError ? 56 : 108,
      child: asyncRecent.when(
        loading: () => ShimmerLoading(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => const SizedBox(width: 168, child: SkeletonGridCard()),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Could not load recent files',
            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
        data: (files) {
          if (files.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'Files you open will show up here',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: files.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final entry = files[index];
              return _RecentFileCard(
                entry: entry,
                onTap: () => context.push(AppRoutes.viewerFor(entry.path)),
                onFavoriteToggle: () async {
                  final result = await ref.read(toggleFavoriteUseCaseProvider).call(entry.path);
                  result.fold((_) => invalidateFilesProviders(ref), (failure) {
                    context.showSnackBar(failure.message, isError: true);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Compact recent-file card: accent file glyph, name, and size/date meta,
/// with the favourite star kept inline.
class _RecentFileCard extends StatelessWidget {
  const _RecentFileCard({
    required this.entry,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final PdfFileEntry entry;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final date = (entry.lastOpened ?? entry.lastModified).relativeLabel;

    return SizedBox(
      width: 168,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconTile(
                  icon: Icons.picture_as_pdf_rounded,
                  accent: AppAccents.red,
                  size: 32,
                  iconSize: 18,
                ),
                const Spacer(),
                InkResponse(
                  onTap: onFavoriteToggle,
                  radius: 18,
                  child: Icon(
                    entry.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 18,
                    color: entry.isFavorite ? AppAccents.amber : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.sizeBytes.readableFileSize} • $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
