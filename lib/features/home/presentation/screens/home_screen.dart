import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../files/presentation/providers/files_ui_state.dart';
import '../../../files/presentation/widgets/pdf_file_grid_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crossAxisCount = context.isTablet ? 4 : 2;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
              sliver: SliverToBoxAdapter(child: _Header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxl),
                  child: _SearchBar(onTap: () => _goToFilesSearch(context, ref)),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                  child: SectionHeader(
                    title: 'Recent Files',
                    actionLabel: 'See all',
                    onActionTap: () => _goToFilesTab(context, ref, FileFilter.recent),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: _RecentFilesRail(),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xxxl),
                  child: SectionHeader(title: 'Quick Actions'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final action = _quickActions[index];
                    return ActionCard(
                      icon: action.icon,
                      label: action.label,
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

  void _goToFilesSearch(BuildContext context, WidgetRef ref) {
    ref.read(fileFilterProvider.notifier).state = FileFilter.all;
    context.go('/files');
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
    const _QuickAction(Icons.picture_as_pdf_rounded, 'Open PDF', _openPdfFromPicker),
    _QuickAction(
      Icons.document_scanner_rounded,
      'Scan Document',
      (c) => c.push(AppRoutes.scanner),
    ),
    _QuickAction(Icons.image_rounded, 'Image to PDF', (c) => c.push(AppRoutes.imageToPdf)),
    _QuickAction(Icons.call_merge_rounded, 'Merge PDF', (c) => c.push(AppRoutes.merge)),
    _QuickAction(Icons.call_split_rounded, 'Split PDF', (c) => c.push(AppRoutes.split)),
    _QuickAction(Icons.compress_rounded, 'Compress PDF', (c) => c.push(AppRoutes.compress)),
    _QuickAction(Icons.water_drop_rounded, 'Watermark', (c) => c.push(AppRoutes.watermark)),
    _QuickAction(Icons.draw_rounded, 'Signature', (c) => c.push(AppRoutes.signature)),
  ];
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final void Function(BuildContext context) onTap;
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello',
                style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
              Text(
                'PDF Toolkit',
                style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings_rounded),
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
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Search your PDFs',
            style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
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
    // an empty state at 220px left a dead gap above Quick Actions.
    final isEmpty = asyncRecent.valueOrNull?.isEmpty ?? false;
    final hasError = asyncRecent.hasError;

    return SizedBox(
      height: isEmpty || hasError ? 72 : 220,
      child: asyncRecent.when(
        loading: () => ShimmerLoading(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) => const SizedBox(width: 140, child: SkeletonGridCard()),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            itemCount: files.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              final entry = files[index];
              return PdfFileGridCard(
                width: 140,
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
